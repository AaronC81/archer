import { useState } from "react";

/**
 * Hook to relate component state to the current browser anchor (or 'hash') - the bit after the
 * `#` in the URL.
 * 
 * Returns tuple of:
 *   - The current anchor as of rendering (without the leading `#` character)
 *   - Function to change the anchor - pass a string (without the leading `#` character)
 * 
 * A component which uses this hook is re-rendered if the URL hash changes.
 */
export default function useAnchor(): [string, (_: string) => void] {
  const [anchor, internalSetAnchor] = useState(() => window.location.hash.substring(1));

  // Trigger render if anchor changes while the page is open
  window.onhashchange = () => {
    internalSetAnchor(window.location.hash.substring(1));
  };

  // If the user calls `setAnchor`, update the page too
  const setAnchor = (anchor: string) => {
    window.location.hash = anchor;
    internalSetAnchor(anchor);
  }

  return [anchor, setAnchor];
}
