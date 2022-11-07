use v6.d;

use lib '.';
use lib './lib';

use Lingua::Translation::DeepL;
use Test;

plan 5;

isa-ok deepl-source-langs, Hash;

isa-ok deepl-source-langs():inverse, Hash;

isa-ok deepl-target-langs, Hash;

isa-ok deepl-target-langs():inverse, Hash;

is deepl-target-langs.keys.sort == deepl-source-langs.keys.sort, False;

done-testing;
