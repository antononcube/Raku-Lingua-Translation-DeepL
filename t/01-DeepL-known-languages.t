use v6.d;

use lib '.';
use lib './lib';

use Lingua::Translation::DeepL;
use Test;

plan 5;

isa-ok deepl-source-languages, Hash;

isa-ok deepl-source-languages():inverse, Hash;

isa-ok deepl-target-languages, Hash;

isa-ok deepl-target-languages():inverse, Hash;

is deepl-target-languages.keys.sort == deepl-source-languages.keys.sort, False;

done-testing;
