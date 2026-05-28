import { useEffect, useRef, useState } from "react";

type ExposedComponentProps = {
  location: { pathname: string };
  [key: string]: unknown;
};

export default function PickleExplosion({ location }: ExposedComponentProps) {
  const lastClickTime = useRef(0);
  const [explosions, setExplosions] = useState<
    Array<{ id: number; x: number; y: number }>
  >([]);
  const nextId = useRef(0);

  // Disable on API reference pages
  const isApiPage = location.pathname.startsWith("/api");

  useEffect(() => {
    if (isApiPage) return;

    const DOUBLE_CLICK_WINDOW = 400; // ms

    const CARD_SELECTOR = ".relative.rounded-lg.border.p-6.flex.flex-col";
    const INTERACTIVE_SELECTOR = "a, button, input, textarea, select, [role='button']";

    const handleClick = (e: MouseEvent) => {
      const target = e.target as HTMLElement;
      const isInsideCard = !!target.closest(CARD_SELECTOR);

      if (isInsideCard) {
        // Inside a card: allow, but skip if clicking an interactive element within it
        if (target.closest(INTERACTIVE_SELECTOR)) return;
      } else {
        // Outside a card: only trigger on page background, not interactive elements
        if (target.closest(`${INTERACTIVE_SELECTOR}, nav, code, pre`)) return;
      }

      const now = Date.now();
      const timeSinceLastClick = now - lastClickTime.current;
      lastClickTime.current = now;

      if (timeSinceLastClick < DOUBLE_CLICK_WINDOW) {
        // Prevent text selection from rapid clicking
        window.getSelection()?.removeAllRanges();

        lastClickTime.current = 0;
        const id = nextId.current++;
        setExplosions((prev) => [...prev, { id, x: e.clientX, y: e.clientY }]);

        setTimeout(() => {
          setExplosions((prev) => prev.filter((exp) => exp.id !== id));
        }, 2500);
      }
    };

    document.addEventListener("click", handleClick);
    return () => document.removeEventListener("click", handleClick);
  }, [isApiPage]);

  if (isApiPage) return null;

  return (
    <>
      <style>{`
        @keyframes pickle-fly {
          0% {
            transform: translate(0, 0) rotate(0deg) scale(1);
            opacity: 1;
          }
          30% {
            transform: translate(var(--px), var(--burst-y)) rotate(calc(var(--pr) * 0.3)) scale(1);
            opacity: 1;
          }
          100% {
            transform: translate(var(--px), var(--fall-y)) rotate(var(--pr)) scale(0.8);
            opacity: 0;
          }
        }
        .pickle-particle {
          position: fixed;
          pointer-events: none;
          z-index: 99999;
          font-size: 64px;
          animation: pickle-fly 2s cubic-bezier(0.25, 0.46, 0.45, 0.94) forwards;
        }
      `}</style>
      {explosions.map((explosion) => (
        <PickleBurst key={explosion.id} x={explosion.x} y={explosion.y} />
      ))}
    </>
  );
}

function PickleBurst({ x, y }: { x: number; y: number }) {
  const pickles = useRef(
    Array.from({ length: 30 }, () => {
      const angle = Math.random() * Math.PI * 2;
      const distance = 150 + Math.random() * 300;
      const burstX = Math.cos(angle) * distance;
      const burstY = Math.sin(angle) * distance * 0.5 - 80; // bias upward for the initial burst
      const fallY = window.innerHeight - y + 200; // always fall well below the viewport
      return {
        px: burstX,
        burstY,
        fallY,
        pr: (Math.random() - 0.5) * 720,
      };
    }),
  ).current;

  return (
    <>
      {pickles.map((pickle, i) => (
        <span
          key={i}
          className="pickle-particle"
          style={
            {
              left: x,
              top: y,
              "--px": `${pickle.px}px`,
              "--burst-y": `${pickle.burstY}px`,
              "--fall-y": `${pickle.fallY}px`,
              "--pr": `${pickle.pr}deg`,
            } as React.CSSProperties
          }
        >
          <img src="/pickle-rick.png" alt="Pickle Rick" style={{ width: "1em", height: "auto" }} />
        </span>
      ))}
    </>
  );
}
