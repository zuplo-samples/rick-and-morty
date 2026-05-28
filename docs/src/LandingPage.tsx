import { Button, Head, Link } from "zudoku/components";

export default function LandingPage() {
  return (
    <section className="flex items-center justify-center min-h-[50vh] px-6 py-16">
      <Head>
        <title>Rick and Morty API</title>
      </Head>
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 max-w-6xl w-full items-center">
        <div className="flex flex-col gap-6">
          <h1 className="text-5xl md:text-6xl font-bold tracking-tight leading-tight">
            Explore the Multiverse with the{" "}
            <span className="inline-block bg-primary text-primary-foreground px-3 py-1 rounded-md -rotate-1">
              Rick and Morty API
            </span>
          </h1>
          <p className="text-lg text-muted-foreground max-w-lg">
            Access data on 826+ characters, 126 locations, and every episode
            across the multiverse. Built on Zuplo with API key auth, rate
            limiting, and full OpenAPI documentation.
          </p>
          <div className="flex flex-wrap gap-4 pt-2">
            <Button asChild variant="outline" size="xl">
              <Link to="/getting-started">Browse Docs</Link>
            </Button>
            <Button asChild size="xl">
              <Link to="/api">API Reference</Link>
            </Button>
          </div>
        </div>
        <div className="flex justify-center lg:justify-end">
          <img
            src="https://cdn.zuplo.com/assets/50a9c235-65e3-4a88-8c86-dc023196476f.png"
            alt="Rick and Morty API"
            className="w-64 md:w-80 lg:w-96 drop-shadow-2xl"
          />
        </div>
      </div>
    </section>
  );
}
