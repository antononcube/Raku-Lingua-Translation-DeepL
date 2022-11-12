# Lingua::Translation::DeepL Raku package

## In brief

This Raku package provides access to the language translation service [DeepL](https://www.deepl.com), [DL1].
For more details of the DeepL's API usage see [the documentation](https://www.deepl.com/docs-api), [DL2].

**Remark:** To use the DeepL API one has to register and obtain authorization key. 

**Remark:** This Raku package is much "less ambitious" than the official Python package, [DLp1], developed by DeepL's team. 
Gradually, over time, I expect to add features to the Raku package that correspond to features of DLp1.

-----

## Installation

Package installations from both sources use [zef installer](https://github.com/ugexe/zef) 
(which should be bundled with the "standard" Rakudo installation file.)

To install the package from [Zef ecosystem](https://raku.land/) use the shell command:

```
zef install Lingua::Translation::DeepL
```

To install the package from the GitHub repository use the shell command:

```
zef install https://github.com/antononcube/Raku-Lingua-Translation-DeepL.git
```

----

## Usage examples

### Translations

**Remark:** When the authorization key, `auth-key`, is specified to be `Whatever` 
then `deepl-translation` attempts to use the env variable `DEEPL_AUTH_KEY`.

Here is a simple call (automatic language detection by DeepL and translation to English):

```perl6
use Lingua::Translation::DeepL;
say deepl-translation('Колко групи могат да се намерят в този облак от точки.');
```
```
# [{detected_source_language => BG, text => How many groups can be found in this point cloud.}]
```

Here we translate from Bulgarian, Russian, and Portuguese to English:

```perl6
my @res = |deepl-translation(
        ['Препоръчай двеста неща от рекомендационната система smrGoods.',
         'Сделать классификатор с логистической регрессии',
         'Fazer um classificador florestal aleatório com 200 árvores'],
        from-lang => Whatever,
        to-lang => 'English',
        auth-key => Whatever);
        
.say for @res;
```
```
# {detected_source_language => BG, text => Recommend two hundred things from the smrGoods recommendation system.}
# {detected_source_language => RU, text => Make a classifier with logistic regression}
# {detected_source_language => PT, text => Make a random forest classifier with 200 trees}
```

**Remark:** DeepL allows up to 50 texts to be translated in one API call.
Hence, if the first argument is an array with more than 50 elements, then it is partitioned
into up-to-50-elements chunks and those are given to `deepl-translation`.   

### Languages

The function `deepl-translation` verifies that the argument languages given to it are 
valid DeepL from- and to-languages. 
See the section ["Request Translation"](https://www.deepl.com/docs-api/translate-text/translate-text/).

Here we get the mappings of abbreviations to source language names:

```perl6
deepl-source-languages()
```
```
# {bulgarian => BG, chinese => ZH, czech => CS, danish => DA, dutch => NL, english => EN, estonian => ET, finnish => FI, french => FR, german => DE, greek => EL, hungarian => HU, indonesian => ID, italian => IT, japanese => JA, latvian => LV, lithuanian => LT, polish => PL, portuguese => PT, romanian => RO, russian => RU, slovak => SK, slovenian => SL, spanish => ES, swedish => SV, turkish => TR, ukrainian => UK}
```

Here we get the mappings of abbreviations to target language names:

```perl6
deepl-target-languages()
```
```
# {bulgarian => BG, chinese simplified => ZH, czech => CS, danish => DA, dutch => NL, english => EN, english american => EN-US, english british => EN-GB, estonian => ET, finnish => FI, french => FR, german => DE, greek => EL, hungarian => HU, indonesian => ID, italian => IT, japanese => JA, latvian => LV, lithuanian => LT, polish => PL, portuguese => PT, portuguese brazilian => PT-BR, portuguese non-brazilian => PT-PT, romanian => RO, russian => RU, slovak => SK, slovenian => SL, spanish => ES, swedish => SV, turkish => TR, ukrainian => UK}
```

-------

## Command Line Interface

The package provides a Command Line Interface (CLI) script:

```shell
deepl-translation --help
```
```
# Usage:
#   deepl-translation <text> [-f|--from-lang=<Str>] [-t|--to-lang=<Str>] [-a|--auth-key=<Str>] [--timeout[=UInt]] [--format=<Str>] -- Text translation using the DeepL API.
#   
#     <text>                  Text to be translated.
#     -f|--from-lang=<Str>    Source language. [default: 'Whatever']
#     -t|--to-lang=<Str>      Target language. [default: 'English']
#     -a|--auth-key=<Str>     Authorization key (to use DeepL API.) [default: 'Whatever']
#     --timeout[=UInt]        Timeout. [default: 10]
#     --format=<Str>          Format of the result; one of "json" or "hash". [default: 'json']
```

**Remark:** When the authorization key argument "auth-key" is specified set to "Whatever"
then `deepl-translation` attempts to use the env variable `DEEPL_AUTH_KEY`.

--------

## Mermaid diagram

The following flowchart corresponds to the steps in the package function `deepl-translation`:  

```mermaid
graph TD
	UI[/Some natural language text/]
	TO[/Translation output/]
	WR[[Web request]]
	DeepL{{deepl.com}}
	PJ[Parse JSON]
	Q{Return<br>hash?}
	QT50{Are texts<br>> 50?}
	MMTC[Compose multiple queries]
	MSTC[Compose one query]
	MURL[[Make URL]]
	TTC[Translate]
	QAK{Auth key<br>supplied?}
	EAK[["Try to find<br>DEEPL_AUTH _KEY<br>in %*ENV"]]
	QEAF{Auth key<br>found?}
	NAK[/Cannot find auth key/]
	UI --> QAK
	QAK --> |yes|QT50
	QAK --> |no|EAK
	EAK --> QEAF
	QT50 --> |no|MSTC
	MSTC --> TTC
	QT50 --> |yes|MMTC
	MMTC --> TTC
	QEAF --> |no|NAK
	QEAF --> |yes|QT50
	TTC -.-> MURL -.-> WR -.-> TTC
	WR -.-> |URL|DeepL 
	DeepL -.-> |JSON|WR
	TTC --> Q 
	Q --> |yes|PJ
	Q --> |no|TO
	PJ --> TO
```

--------

## References

[DL1] DeepL, [DeepL Translator](https://www.deepl.com/translator).

[DL2] DeepL, [DeepL API](https://www.deepl.com/docs-api/).

[DLp1] DeepL,
[DeepL Python Library](https://github.com/DeepLcom/deepl-python),
(2021),
[GitHub/DeepLcom](https://github.com/DeepLcom/).