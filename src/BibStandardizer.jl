module BibStandardizer

using Accessors
using Bibliography
using OrderedCollections: OrderedDict

const JOURNAL_ABBREVIATIONS = Dict(
    # Finance
    "the journal of finance"                         => "jf",
    "the review of financial studies"                => "rfs",
    "journal of financial economics"                 => "jfe",
    "journal of empirical finance"                   => "jef",
    "journal of financial and quantitative analysis" => "jfqa",
    "journal of banking and finance"                 => "jbf",
    "journal of financial markets"                   => "jfm",
    "financial analysts journal"                     => "faj",
    
    # Economics
    "american economic review"           => "aer",
    "american economic review: insights" => "aeri",
    "econometrica"                       => "ecta",
    "the quarterly journal of economics" => "qje",
    "journal of political economy"       => "jpe",
    "the review of economic studies"     => "restud",
    "journal of economic theory"         => "jet",
    "journal of monetary economics"      => "jme",
    "economic journal"                   => "ej",
    "rand journal of economics"          => "rand",
    "quantitative economics"             => "eq",
    
    # Econometrics
    "journal of econometrics"                     => "jeconom",
    "review of economics and statistics"          => "restat",
    "journal of business \\& economic statistics" => "jbes",
    "journal of applied econometrics"             => "jae",
    "the econometrics journal"                    => "ectj",

    # Statistics
    "annals of statistics"                                => "aos",
    "the journal of the american statistical association" => "jasa",
    "biometrika"                                          => "biomet",

    # Math
    "proceedings of the american mathematical society" => "proc.am.math.soc.",

)

include("utils.jl")

export JOURNAL_ABBREVIATIONS
export standardize_bibfile
export standardize_bibstr

end
