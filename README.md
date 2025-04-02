# BibStandardizer.jl

A simple package for standardizing LaTeX bibitems and bibfiles to my liking.

Given bibitems, standardization will...
1. Try to remove duplicates.
2. Delete `file`, `abstract`, and `url` fields (these are often long and unnessecary imo).
3. Delete `day` and `month` from the date field (so only the year appears in a reference list).
4. Ensure capitalization of title and journal is preserved by adding curly braces.
5. Create a citekey based on the form `initials of last names of authors`\_`journal abbreviation`\_`year`.
    - If the citekey is not unique, a suffix will be added to make it unique.

... and output a sorted list of the standardized bibitems.

## Bibitems as a string

BibStandardizer support string parsing via `BibTeX.jl`. Simply pass the string to `standardize_bibstr` which returns a standardized bibitem as a string that can be printed or written to a file.

```julia
using BibStandardizer

bibstr = """
@article{jensen2023there,
  title={Is There a Replication Crisis in Finance?},
  author={Jensen, Theis Ingerslev and Kelly, Bryan and Pedersen, Lasse Heje},
  journal={The Journal of Finance},
  volume={78},
  number={5},
  pages={2465--2518},
  year={2023},
  publisher={Wiley Online Library}
}
"""
standardize_bibstr(bibstr) |> print
```

Outputs:
```julia
@article{jkp_jf_23,
 number        = {5},
 publisher     = {Wiley Online Library},
 pages         = {2465--2518},
 author        = {Jensen, Theis Ingerslev and Kelly, Bryan and Pedersen, Lasse Heje},
 year          = {2023},
 volume        = {78},
 journal       = {{The} {Journal} {of} {Finance}},
 title         = {{Is} {There} {a} {Replication} {Crisis} {in} {Finance?}}
}
```

A common use-case for me is that I copy a bibitem from Google Scholar and want to standardize it. In this case, you can simply do:
```julia
standardize_bibstr(clipboard()) |> print
```

## Bibitems in a file
Given a `.bib` file, use `standardize_bibfile` to standardize it. The first argument is the path to the file. The standardized bibfile will be saved at the second argument.

```julia
standardize_bibfile(".../refs.bib", ".../standardized_refs.bib")
```

## Journal abbreviations
The package includes a list of common abbreviations for journals in economics and finance which is used when generating citekeys. If the journal is not found in this list, `wp` (working paper) is used in the citekey instead. However, users can add and modify the list of journal abbreviations by creating a dictionary that maps (lowercase) journal names to the desired abbreviation. This dictionary can be passed as an additional argument to both `standardize_str` or `standardize_bibfile`. For example, let's say we want another abbreviation for The Journal of Finance.
```julia
custom_abb = Dict("the journal of finance" => "jfin")
bibstr = """
@article{jensen2023there,
  title={Is There a Replication Crisis in Finance?},
  author={Jensen, Theis Ingerslev and Kelly, Bryan and Pedersen, Lasse Heje},
  journal={The Journal of Finance},
  volume={78},
  number={5},
  pages={2465--2518},
  year={2023},
  publisher={Wiley Online Library}
}
"""
standardize_bibstr(bibstr, custom_abb) |> print
```

Outputs:
```julia
@article{jkp_jfin_23,
 number        = {5},
 publisher     = {Wiley Online Library},
 pages         = {2465--2518},
 author        = {Jensen, Theis Ingerslev and Kelly, Bryan and Pedersen, Lasse Heje},
 year          = {2023},
 volume        = {78},
 journal       = {{The} {Journal} {of} {Finance}},
 title         = {{Is} {There} {a} {Replication} {Crisis} {in} {Finance?}}
}
```
Journal name must match exactly to the internal list to give the correct abbreviation. For example, `journal of finance` would return the default `wp` as it is missing the `the`.