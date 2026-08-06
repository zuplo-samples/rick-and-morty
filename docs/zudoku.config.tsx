import type { ZudokuConfig } from "zudoku";
import { zuploMonetizationPlugin } from "@zuplo/zudoku-plugin-monetization";
import LandingPage from "./src/LandingPage.js";
import PickleExplosion from "./src/PickleExplosion.js";

const config: ZudokuConfig = {
  basePath: "/",
  docs: {
    files: "pages/**/*.{md,mdx}",
    publishMarkdown: true,
    llms: {
      llmsTxt: true,
      llmsTxtFull: true,
    },
  },
  theme: {
    customCss: `
      header [style*="background-color"] > .w-full { text-align: center; }
      /* Zudoku applies bg-accent to active/hover nav items but not text-accent-foreground,
         which makes labels unreadable on the bright cyan accent in this theme. */
      [aria-current="page"],
      [aria-current="page"]:hover,
      .hover\\:bg-accent:hover { color: var(--accent-foreground); }
    `,
    fonts: {
      sans: "Outfit",
      mono: "Fira Code",
    },
    light: {
      background: "oklch(0.9816 0.0017 247.8390)",
      foreground: "oklch(0.1649 0.0352 281.8285)",
      card: "oklch(1.0000 0 0)",
      cardForeground: "oklch(0.1649 0.0352 281.8285)",
      popover: "oklch(1.0000 0 0)",
      popoverForeground: "oklch(0.1649 0.0352 281.8285)",
      primary: "oklch(0.6726 0.2904 341.4084)",
      primaryForeground: "oklch(1.0000 0 0)",
      secondary: "oklch(0.9595 0.0200 286.0164)",
      secondaryForeground: "oklch(0.1649 0.0352 281.8285)",
      muted: "oklch(0.9595 0.0200 286.0164)",
      mutedForeground: "oklch(0.1649 0.0352 281.8285)",
      accent: "oklch(0.8903 0.1739 171.2690)",
      accentForeground: "oklch(0.1649 0.0352 281.8285)",
      destructive: "oklch(0.6535 0.2348 34.0370)",
      destructiveForeground: "oklch(1.0000 0 0)",
      border: "oklch(0.9205 0.0086 225.0878)",
      input: "oklch(0.9205 0.0086 225.0878)",
      ring: "oklch(0.6726 0.2904 341.4084)",
    },
    dark: {
      background: "oklch(0.1649 0.0352 281.8285)",
      foreground: "oklch(0.9513 0.0074 260.7315)",
      card: "oklch(0.2542 0.0611 281.1423)",
      cardForeground: "oklch(0.9513 0.0074 260.7315)",
      popover: "oklch(0.2542 0.0611 281.1423)",
      popoverForeground: "oklch(0.9513 0.0074 260.7315)",
      primary: "oklch(0.6726 0.2904 341.4084)",
      primaryForeground: "oklch(1.0000 0 0)",
      secondary: "oklch(0.2542 0.0611 281.1423)",
      secondaryForeground: "oklch(0.9513 0.0074 260.7315)",
      muted: "oklch(0.2123 0.0522 280.9917)",
      mutedForeground: "oklch(0.6245 0.0500 278.1046)",
      accent: "oklch(0.8903 0.1739 171.2690)",
      accentForeground: "oklch(0.1649 0.0352 281.8285)",
      destructive: "oklch(0.6535 0.2348 34.0370)",
      destructiveForeground: "oklch(1.0000 0 0)",
      border: "oklch(0.3279 0.0832 280.7890)",
      input: "oklch(0.3279 0.0832 280.7890)",
      ring: "oklch(0.6726 0.2904 341.4084)",
    },
  },
  site: {
    logo: {
      src: {
        light:
          "https://cdn.zuplo.com/assets/50a9c235-65e3-4a88-8c86-dc023196476f.png",
        dark: "https://cdn.zuplo.com/assets/50a9c235-65e3-4a88-8c86-dc023196476f.png",
      },
      alt: "Rick and Morty API (by Zuplo)",
      href: "/",
    },
    title: "Rick and Morty API (by Zuplo)",
    banner: {
      message:
        "\"Nobody exists on purpose. Nobody belongs anywhere.\" — but you DO belong here. Use test card 4242 4242 4242 4242 to try paid plans free!",
      color: "oklch(0.6726 0.2904 341.4084)",
      dismissible: true,
    },
    footer: {
      columns: [
        {
          title: "Documentation",
          links: [
            { label: "Home", href: "/" },
            { label: "Getting Started", href: "/getting-started" },
            { label: "Characters", href: "/characters" },
            { label: "Locations", href: "/locations" },
            { label: "Episodes", href: "/episodes" },
          ],
        },
        {
          title: "API",
          links: [
            { label: "REST", href: "/api" },
            { label: "GraphQL", href: "/graphql" },
          ],
        },
        {
          title: "Resources",
          links: [
            {
              label: "Original Rick and Morty API",
              href: "https://rickandmortyapi.com",
            },
            { label: "Zuplo", href: "https://zuplo.com" },
            {
              label: "GitHub",
              href: "https://github.com/zuplo-samples/rick-and-morty",
            },
          ],
        },
      ],
      social: [
        {
          icon: "github",
          href: "https://github.com/zuplo-samples/rick-and-morty",
          label: "GitHub",
        },
      ],
      copyright: `© ${new Date().getFullYear()} Zuplo, Inc. Rick and Morty data from rickandmortyapi.com.`,
    },
  },
  metadata: {
    favicon:
      "https://cdn.zuplo.com/assets/50a9c235-65e3-4a88-8c86-dc023196476f.png",
    title: "Rick and Morty API (by Zuplo)",
  },
  navigation: [
    {
      type: "custom-page",
      path: "/",
      element: <LandingPage />,
    },
    {
      type: "category",
      label: "Documentation",
      icon: "book-open",
      collapsed: false,
      items: [
        {
          type: "doc",
          file: "welcome",
          label: "Welcome",
          icon: "home",
        },
        {
          type: "doc",
          file: "getting-started",
          label: "Getting Started",
          icon: "rocket",
        },
        {
          type: "doc",
          file: "characters",
          label: "Characters",
          icon: "users",
        },
        {
          type: "doc",
          file: "locations",
          label: "Locations & Dimensions",
          icon: "map",
        },
        {
          type: "doc",
          file: "episodes",
          label: "Episodes",
          icon: "tv",
        },
      ],
    },
    {
      type: "link",
      to: "/api",
      label: "REST",
    },
    {
      type: "link",
      to: "/graphql",
      label: "GraphQL",
    },
    {
      type: "link",
      to: "/mcp",
      label: "MCP",
    },
  ],
  apis: [
    {
      type: "file",
      input: "../config/routes.oas.json",
      path: "/api",
    },
    {
      type: "file",
      input: "../config/graphql.oas.json",
      path: "/graphql",
    },
    {
      type: "file",
      input: "../config/mcp.oas.json",
      path: "/mcp",
    },
  ],
  authentication: {
    type: "auth0",
    clientId: "v0cOpST3pX6NIs1VGLVvNjaN3mSBomKk",
    domain: "zuplo-samples.us.auth0.com",
    audience: "https://api.example.com/",
  },
  apiKeys: {
    enabled: true,
  },
  plugins: [
    zuploMonetizationPlugin({
      pricing: {
        title: "Wubba Lubba Pricing Plans",
        subtitle: "Every dimension has its price. Choose the reality that fits your budget.",
      },
    }),
  ],
  slots: {
    "content-after": PickleExplosion,
  },
  redirects: [
    { from: "/docs", to: "/" },
    { from: "/docs/pricing", to: "/pricing" },
    { from: "/docs/welcome", to: "/welcome" },
    { from: "/docs/getting-started", to: "/getting-started" },
    { from: "/docs/characters", to: "/characters" },
    { from: "/docs/locations", to: "/locations" },
    { from: "/docs/episodes", to: "/episodes" },
    { from: "/docs/api", to: "/api" },
    { from: "/docs/api/welcome", to: "/welcome" },
    { from: "/docs/api/getting-started", to: "/getting-started" },
    { from: "/docs/api/characters", to: "/characters" },
    { from: "/docs/api/locations", to: "/locations" },
    { from: "/docs/api/episodes", to: "/episodes" },
    { from: "/docs/api/~endpoints", to: "/~endpoints" },
  ],
};

export default config;
