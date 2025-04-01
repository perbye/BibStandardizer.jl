capitalize_string(str)   = join("{" .* split(str, " ") .* "}", " ")
uncapitalize_string(str) = lowercase(replace(str, "{" => "", "}" => ""))

function next_letter(suffix)
    last_letter = suffix[end]
    if last_letter == 'z'
        return repeat("a", length(suffix) + 1)
    else
        return suffix[1:end-1] * Char(last_letter + 1)
    end
end

function add_suffix_to_bibname(bibname, bibnames)
    suffix = "a"
    while bibname * suffix in bibnames
        suffix = next_letter(suffix)
    end
    return bibname * suffix
end

function standardize_item(bibitem_pair, custom_abbreviations = Dict())
    # Add custom abbreviations to list. If key is present in both, custom_abbreviations takes priority
    abb_lookup = isempty(custom_abbreviations) ? JOURNAL_ABBREVIATIONS : merge(JOURNAL_ABBREVIATIONS, custom_abbreviations)

    # Unpack pair
    _, bibitem = bibitem_pair

    # Create custom itemname: <initials of last names of authors>_<journal abbreviation>_<year>
    authors_initials = reduce(*, lowercase(author.last[1]) for author in bibitem.authors)
    pub_year         = bibitem.date.year
    pub_year_abb     = pub_year[end-1:end]
    journal_abb      = haskey(abb_lookup, uncapitalize_string(bibitem.in.journal)) ? abb_lookup[uncapitalize_string(bibitem.in.journal)] : "wp"
    bibname          = isempty(journal_abb) ? authors_initials * "_" * pub_year_abb : authors_initials * "_" * journal_abb * "_" *pub_year_abb

    # Delete unwanted fields
    for field in ["shorttitle", "abstract", "file", "urldate"]
        delete!(bibitem.fields, field)
    end

    # Only keep the year in date
    @reset bibitem.date = Bibliography.BibInternal.Date("", "", pub_year)

    # Remove url
    @reset bibitem.access = Bibliography.BibInternal.Access("", "", "")

    # Capitalize title
    @reset bibitem.title = capitalize_string(replace(bibitem.title, "{" => "", "}" => ""))

    # Capitalize journal name
    if !isempty(bibitem.in.journal)
        @reset bibitem.in.journal = capitalize_string(replace(bibitem.in.journal, "{" => "", "}" => ""))
    end
    return bibname, bibitem
end

function standardize_items(bibitems, custom_abbreviations = Dict())
    # Try to remove duplicates: Same title and year
    keys_list       = collect(keys(bibitems))
    items_to_remove = []
    for i in eachindex(keys_list)
        for j in (i+1):length(keys_list)
            if bibitems[keys_list[i]].date.year == bibitems[keys_list[j]].date.year &&
                uncapitalize_string(bibitems[keys_list[i]].title) == uncapitalize_string(bibitems[keys_list[j]].title)
                push!(items_to_remove, keys_list[j])             
            end
        end
    end
    for item in items_to_remove
        delete!(bibitems, item)
    end

    bibitems_std = OrderedDict{String, Bibliography.BibInternal.Entry}()
    while !isempty(bibitems)
        bibitem_pair = pop!(bibitems)
        bibname_std, bibitem_std = standardize_item(bibitem_pair, custom_abbreviations)
        if bibname_std ∈ keys(bibitems_std)
            bibname_std = add_suffix_to_bibname(bibname_std, keys(bibitem_std))
        end
        # Update the id of bibitem_std which controls the citation key
        @reset bibitem_std.id = bibname_std
        bibitems_std[bibname_std] = bibitem_std
    end
    return bibitems_std
end

function standardize_bibfile(readpath, savepath, custom_abbreviations = Dict())
    bibitems  = import_bibtex(readpath)
    std_items = standardize_items(bibitems, custom_abbreviations)
    # Export alphabetized list
    sort!(std_items)
    export_bibtex(savepath, std_items)
    return nothing
end

function standardize_bibstr(str, custom_abbreviations = Dict())
    bibitems  = Bibliography.BibTeX.parse_string(str)
    std_items = standardize_items(bibitems, custom_abbreviations)
    sort!(std_items)
    return export_bibtex(std_items)
end