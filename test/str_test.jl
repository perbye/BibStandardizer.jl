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
std_bibstr = standardize_bibstr(bibstr) |> BibStandardizer.Bibliography.BibTeX.parse_string
@test first(keys(std_bibstr)) == "jkp_jf_23"