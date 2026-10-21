// ==UserScript==
// @name         42 Intra - Force 42cursus Header
// @namespace    https://intra.42.fr/
// @version      1.0.1
// @description  Automatically forces the 42 Intra dashboard header selector to display "42cursus" instead of C Piscine or Piscine Reloaded.
// @author       BernatQi
// @match        https://profile.intra.42.fr/*
// @match        https://profile-v3.intra.42.fr/*
// @run-at       document-idle
// @grant        none
// ==/UserScript==

(function () {
  'use strict';

  const TARGET_CURSUS_REGEX = /42\s*cursus/i;
  const EXCLUDED_CURSUS_REGEX = /piscine|reload/i;
  const HIDE_MENU_STYLE_ID = 'ft-force-cursus-hide-radix-menu';
  const MAX_SWITCH_ATTEMPTS = 2;

  let isSwitching = false;
  let userInteractedManually = false;
  let switchAttempts = 0;
  let lastPathname = location.pathname;
  let rafScheduled = false;

  /**
   * Checks whether a given label matches the main cursus (42cursus)
   * and is not a C Piscine or Piscine Reloaded entry.
   */
  function isTargetCursus(text) {
    if (!text) return false;
    const normalized = text.trim();
    return TARGET_CURSUS_REGEX.test(normalized) && !EXCLUDED_CURSUS_REGEX.test(normalized);
  }

  /**
   * Finds the Radix UI combobox button belonging to the cursus selector in the profile header.
   */
  function findCursusCombobox() {
    // 1. Primary lookup: via the adjacent cursus experience link in the header
    const cursusLink = document.querySelector('a[href*="/experiences/cursus_id/"]');
    if (cursusLink && cursusLink.parentElement) {
      const btn = cursusLink.parentElement.querySelector('button[role="combobox"]');
      if (btn) return btn;
    }

    // 2. Fallback lookup: any combobox whose text contains cursus/piscine/reload keywords
    const comboboxes = document.querySelectorAll('button[role="combobox"]');
    for (const btn of comboboxes) {
      const text = (btn.textContent || '').trim();
      if (/cursus|piscine|reload|cadet|novice|learner/i.test(text)) {
        return btn;
      }
    }

    return null;
  }

  /**
   * Temporarily hides the Radix UI dropdown portal so the automatic switch
   * produces zero visual flicker.
   */
  function setRadixMenuHidden(hidden) {
    let styleEl = document.getElementById(HIDE_MENU_STYLE_ID);
    if (hidden) {
      if (!styleEl) {
        styleEl = document.createElement('style');
        styleEl.id = HIDE_MENU_STYLE_ID;
        styleEl.textContent = `
          [data-radix-popper-content-wrapper],
          div[role="listbox"] {
            opacity: 0 !important;
            pointer-events: none !important;
            transition: none !important;
          }
        `;
        (document.head || document.documentElement).appendChild(styleEl);
      }
    } else if (styleEl) {
      styleEl.remove();
    }
  }

  /**
   * Dispatches the synthetic event sequence required by Radix UI Select to open its portal.
   */
  function triggerRadixOpen(button) {
    button.dispatchEvent(
      new PointerEvent('pointerdown', {
        bubbles: true,
        cancelable: true,
        button: 0,
        ctrlKey: false,
        pointerId: 1,
        isPrimary: true,
      })
    );
    button.dispatchEvent(
      new KeyboardEvent('keydown', {
        bubbles: true,
        cancelable: true,
        key: 'ArrowDown',
        code: 'ArrowDown',
      })
    );
  }

  /**
   * Dispatches the synthetic event sequence required to select an option inside a Radix UI Select.
   */
  function triggerRadixSelectOption(optionEl) {
    optionEl.dispatchEvent(
      new PointerEvent('pointermove', {
        bubbles: true,
        cancelable: true,
        pointerId: 1,
        isPrimary: true,
      })
    );
    optionEl.dispatchEvent(
      new PointerEvent('pointerdown', {
        bubbles: true,
        cancelable: true,
        button: 0,
        pointerId: 1,
        isPrimary: true,
      })
    );
    optionEl.dispatchEvent(
      new PointerEvent('pointerup', {
        bubbles: true,
        cancelable: true,
        button: 0,
        pointerId: 1,
        isPrimary: true,
      })
    );
    optionEl.click();
    optionEl.dispatchEvent(
      new KeyboardEvent('keydown', {
        bubbles: true,
        cancelable: true,
        key: 'Enter',
        code: 'Enter',
      })
    );
  }

  /**
   * Inspects the header combobox and forces "42cursus" if currently set to Piscine or Reloaded.
   */
  function enforceCursusHeader() {
    if (location.pathname !== lastPathname) {
      lastPathname = location.pathname;
      switchAttempts = 0;
      userInteractedManually = false;
    }

    if (isSwitching || userInteractedManually || switchAttempts >= MAX_SWITCH_ATTEMPTS) {
      return;
    }

    const combobox = findCursusCombobox();
    if (!combobox) return;

    // Respect manual user interaction during the current view
    if (!combobox.dataset.ftListenerAttached) {
      combobox.dataset.ftListenerAttached = 'true';
      combobox.addEventListener(
        'pointerdown',
        (e) => {
          if (e.isTrusted) {
            userInteractedManually = true;
          }
        },
        { capture: true }
      );
    }

    const currentLabel = (combobox.textContent || '').trim();
    if (isTargetCursus(currentLabel)) {
      return;
    }

    isSwitching = true;
    switchAttempts++;
    setRadixMenuHidden(true);

    // Safety timer: guarantee temporary CSS never remains active longer than 1.5s
    const safetyTimer = setTimeout(() => {
      setRadixMenuHidden(false);
      isSwitching = false;
    }, 1500);

    try {
      triggerRadixOpen(combobox);
    } catch {
      clearTimeout(safetyTimer);
      setRadixMenuHidden(false);
      isSwitching = false;
      return;
    }

    let attempts = 0;
    const maxAttempts = 20;

    const pollOptions = setInterval(() => {
      attempts++;
      const ariaControlsId = combobox.getAttribute('aria-controls');
      let listbox = ariaControlsId ? document.getElementById(ariaControlsId) : null;
      if (!listbox) {
        listbox = document.querySelector('div[role="listbox"]');
      }

      if (listbox) {
        const options = listbox.querySelectorAll('[role="option"]');
        let targetOption = null;

        for (const opt of options) {
          if (isTargetCursus(opt.textContent)) {
            targetOption = opt;
            break;
          }
        }

        if (targetOption) {
          clearInterval(pollOptions);
          triggerRadixSelectOption(targetOption);
          setTimeout(() => {
            clearTimeout(safetyTimer);
            setRadixMenuHidden(false);
            isSwitching = false;
          }, 120);
          return;
        }
      }

      if (attempts >= maxAttempts) {
        clearInterval(pollOptions);
        combobox.dispatchEvent(
          new KeyboardEvent('keydown', {
            bubbles: true,
            cancelable: true,
            key: 'Escape',
            code: 'Escape',
          })
        );
        clearTimeout(safetyTimer);
        setRadixMenuHidden(false);
        isSwitching = false;
      }
    }, 40);
  }

  enforceCursusHeader();

  const observer = new MutationObserver(() => {
    if (rafScheduled) return;
    rafScheduled = true;
    requestAnimationFrame(() => {
      rafScheduled = false;
      enforceCursusHeader();
    });
  });

  observer.observe(document.documentElement, {
    childList: true,
    subtree: true,
  });
})();
