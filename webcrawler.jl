using HTTP, Gumbo

const PAGE_URL = "https://en.wikipedia.org/wiki/Julia_(programming_language)"
const LINKS = String[]

function fetchPage(url)
    response = HTTP.get(url)
        if response.status_code == 200 && parse(Int, Dict(response.headers)["Content-Length"]) > 0
            String(response.body)
    else
        ""
    end
end


function extractlinks(elem)
    if  isa(elem, HTMLElement) &&
        tag(elem) == :a && in("href", collect(keys(attrs(elem))))
        url = getattr(elem, "href")
        startswith(url, "/wiki") && push!(LINKS, url)
    end

    for child in children(elem)
        extractlinks(child)
    end
end

content = fetchPage(PAGE_URL)

if ! isempty(content)
    dom = Gumbo.parsehtml(content)
    extractlinks(dom.root)
end


display(unique(LINKS))
