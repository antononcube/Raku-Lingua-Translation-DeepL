#!/usr/bin/env raku
use v6.d;

use lib '.';
use lib './lib';

use Lingua::Translation::DeepL;
use Data::Reshapers;


my $res = deepl-translate(
        ['Препоръчай двеста неща от рекомендационната система smrGoods.',
         'Сделать классификатор с логистической регрессии',
         'Fazer um classificador florestal aleatório com 200 árvores'],
        from-lang => Whatever,
        to-lang => 'English',
        auth-key => Whatever);

say to-pretty-table($res, align=>'l', field-names => <detected_source_language text>);


say '-' x 120;
say "Source languages:";
say deepl-source-langs;
say deepl-source-langs(:inverse);

say '-' x 120;
say "Target languages:";
say deepl-target-langs;
say deepl-target-langs(:inverse);