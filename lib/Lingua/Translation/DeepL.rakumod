use v6.d;

use HTTP::UserAgent;
use URI::Encode;
use JSON::Fast;

unit module Lingua::Translation::DeepL;

# DeepL API documentation says that up to 50 text parameters can be given.
constant $maxTextsPerQuery = 50;

#============================================================
# Source languages
#============================================================

my Str $sourceLangs = q:to/THEEND/;
BG - Bulgarian
CS - Czech
DA - Danish
DE - German
EL - Greek
EN - English
ES - Spanish
ET - Estonian
FI - Finnish
FR - French
HU - Hungarian
ID - Indonesian
IT - Italian
JA - Japanese
LT - Lithuanian
LV - Latvian
NL - Dutch
PL - Polish
PT - Portuguese
RO - Romanian
RU - Russian
SK - Slovak
SL - Slovenian
SV - Swedish
TR - Turkish
UK - Ukrainian
ZH - Chinese
THEEND

my %sourceLangsAbbrToLang = $sourceLangs.lines.map({
    my $t = $_.split(' - ').Array;
    $t[0] => $t[1].lc
});
my %sourceLangsLangToAbbr = %sourceLangsAbbrToLang.invert;

our sub deepl-source-languages(Bool :$inverse = False) is export {
    return $inverse ?? %sourceLangsAbbrToLang !! %sourceLangsLangToAbbr;
}


#============================================================
# Target languages
#============================================================

my $targetLangs = q:to/THEEND/;
BG - Bulgarian
CS - Czech
DA - Danish
DE - German
EL - Greek
EN - English
EN-GB - English British
EN-US - English American
ES - Spanish
ET - Estonian
FI - Finnish
FR - French
HU - Hungarian
ID - Indonesian
IT - Italian
JA - Japanese
LT - Lithuanian
LV - Latvian
NL - Dutch
PL - Polish
PT - Portuguese
PT-BR - Portuguese Brazilian
PT-PT - Portuguese Non-Brazilian
RO - Romanian
RU - Russian
SK - Slovak
SL - Slovenian
SV - Swedish
TR - Turkish
UK - Ukrainian
ZH - Chinese Simplified
THEEND

my %targetLangsAbbrToLang = $targetLangs.lines.map({
    my $t = $_.split(' - ').Array;
    $t[0] => $t[1].lc
});
my %targetLangsLangToAbbr = %targetLangsAbbrToLang.invert;

our sub deepl-target-languages(Bool :$inverse = False) is export {
    return $inverse ?? %targetLangsAbbrToLang !! %targetLangsLangToAbbr;
}

#============================================================
# Get data from a URL
#============================================================

#| Gets the data from a specified URL.
sub get-url-data(Str $url, UInt :$timeout= 10) {
    my $ua = HTTP::UserAgent.new;
    $ua.timeout = $timeout;

    my $response = $ua.get($url);

    if not $response.is-success {
        # say $response.content.WHAT;
        note $response.status-line;
        return Nil;
    }
    return $response.content;
}

#============================================================
# Get data from a URL
#============================================================

#| Text translation using the DeepL API.
our proto deepl-translation($texts is copy,
                            :$from-lang is copy = Whatever,
                            Str :$to-lang is copy = 'EN',
                            :$auth-key is copy = Whatever,
                            :$formality = Whatever,
                            UInt :$timeout= 10,
                            :$format is copy = Whatever) is export {*}

#| Text translation using the DeepL API.
multi sub deepl-translation(Str $text, *%args) {
    return deepl-translation([$text,], |%args);
}

#| Text translation using the DeepL API.
multi sub deepl-translation(@texts where @texts.elems > $maxTextsPerQuery, *%args) {
    # This might be better done "inside" the main deepl-translation definition.
    # Better means: no repeated processing of arguments, and no multiple error messages.
    my @res;
    for @texts.rotor($maxTextsPerQuery, :partial) -> $t {
        @res.append( |deepl-translation($t, |%args) )
    };

    my $format = %args<format> // 'hash';
    if $format ~~ Str && $format eq 'json' {
        return '[' ~ @res.join(', ') ~ ']';
    }
    return @res;
}

#| Text translation using the DeepL API.
multi sub  deepl-translation(@texts is copy,
                             :$from-lang is copy = Whatever,
                             Str :$to-lang is copy = 'EN',
                             :$auth-key is copy = Whatever,
                             :$formality is copy = Whatever,
                             UInt :$timeout= 10,
                             :$format is copy = Whatever) {

    #------------------------------------------------------
    # Process $from-lang
    #------------------------------------------------------
    my $fromLangMsg = "The argument from-lang is expected to be Whatever or one of the strings: { %sourceLangsAbbrToLang.keys.sort.join(' ') }.";
    if $from-lang ~~ Str {
        if %sourceLangsLangToAbbr{$from-lang.lc}:exists {
            $from-lang = %sourceLangsLangToAbbr{$from-lang.lc}
        }
        $from-lang .= uc;
        die $fromLangMsg unless %sourceLangsAbbrToLang{$from-lang.uc}:exists;
    } elsif !$from-lang.isa(Whatever) {
        die $fromLangMsg unless %sourceLangsAbbrToLang{$from-lang.uc}:exists;
    }

    #------------------------------------------------------
    # Process $target-lang
    #------------------------------------------------------
    if %targetLangsLangToAbbr{$to-lang.lc}:exists {
        $to-lang = %targetLangsLangToAbbr{$to-lang.lc}
    }
    $to-lang .= uc;
    die "The argument to-lang is expected to be one of { %targetLangsAbbrToLang.keys.sort.join(' ') }"
    unless %targetLangsAbbrToLang{$to-lang.uc}:exists;

    #------------------------------------------------------
    # Process $formality
    #------------------------------------------------------
    if $formality.isa(Whatever) { $formality = 'default' }
    die "The argument formality is expected to be a string or Whatever, 'default', 'less', or 'more'."
    unless $formality ~~ Str && $formality.lc ∈ <whatever default less more>;

    $formality .= lc;
    if $formality eq 'whatever' { $formality = 'default' }

    #------------------------------------------------------
    # Process $format
    #------------------------------------------------------
    if $format.isa(Whatever) { $format = 'Whatever' }
    die "The argument format is expected to be a string or Whatever."
    unless $format ~~ Str;

    #------------------------------------------------------
    # Process $auth-key
    #------------------------------------------------------
    if $auth-key.isa(Whatever) {
        if %*ENV<DEEPL_AUTH_KEY>:exists {
            $auth-key = %*ENV<DEEPL_AUTH_KEY>;
        } else {
            note 'Cannot find DeepL authorization key. ' ~
                    'Please provide a valid key to the argument auth-key, or set the ENV variable DEEPL_AUTH_KEY.';
            $auth-key = ''
        }
    }
    die "The argument auth-key is expected to be a string or Whatever."
    unless $auth-key ~~ Str;

    #------------------------------------------------------
    # Make DeepL URL
    #------------------------------------------------------
    my $textQuery = @texts.map({ 'text=' ~ uri_encode($_) }).join('&');

    my $url = "https://api-free.deepl.com/v2/translate?$textQuery&auth_key=$auth-key&formality=$formality&target_lang=$to-lang";

    if $from-lang ~~ Str {
        $url ~= "&source_lang=$from-lang";
    }

    #------------------------------------------------------
    # Invoke DeepL service
    #------------------------------------------------------
    my $res = get-url-data($url, :$timeout);

    #------------------------------------------------------
    # Result
    #------------------------------------------------------
    without $res { return Nil; }

    return do given $format.lc {
        when $_ ∈ <whatever hash raku> {
            my $t = from-json($res);
            $t<translations> // $t;
        }
        when $_ ∈ <json as-is> { $res; }
        default { from-json($res); }
    }
}