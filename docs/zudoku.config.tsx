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
    customCss: `header [style*="background-color"] > .w-full { text-align: center; }`,
    fonts: {
      sans: "Space Grotesk",
      mono: "JetBrains Mono",
    },
    light: {
      primary: "#44a340",
      primaryForeground: "#ffffff",
      background: "#f8fdf7",
      foreground: "#1a1a2e",
      border: "#d4e8d0",
    },
    dark: {
      primary: "#97ce4c",
      primaryForeground: "#0d0d2b",
      background: "#0d0d2b",
      foreground: "#e8e8f0",
      border: "#2a2a4a",
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
      color: "#44a340",
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
