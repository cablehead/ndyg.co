def do_404 [req: record] {
  .response {status: 404}
  $"Not Found: ($req.method) ($req.path)"
}

{|req|
  match $req {
    {method: "GET" , path: "/"} => {
      open data/plantings.yaml | to json | minijinja-cli -f json ./html/index.html -
    }

    {method: "GET"} if ($req.path | str starts-with "/plantings/") => {
      let name = $req.path | path basename
      let md = "./pages/" + $name + ".md"
      if ($md | path exists) {
        {__html: (open $md)} | .md | get __html | {content: $in} | to json -r | minijinja-cli -f json ./html/page.html -
      } else {
        do_404 $req
      }
    }

    {method: "GET"} if ($req.path | str starts-with "/projects/") => {
      .static (pwd) $req.path
    }

    {method: "GET"} if ($req.path | str starts-with "/css/") => {
      .static (pwd) $req.path
    }

    {method: "GET"} if ($req.path | str starts-with "/static/") => {
      .static (pwd) $req.path
    }

    {method: "GET" , path: "/_health"} => {
      "ok"
    }

    _ => (do_404 $req)
  }
}
