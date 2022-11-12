#!/usr/bin/env raku
use v6.d;

use lib '.';
use lib './lib';

use Lingua::Translation::DeepL;
use Data::Reshapers;


say deepl-translation('Колко групи могат да се намерят в този облак от точки.');

say '-' x 120;

my $res = deepl-translation(
        ['Препоръчай двеста неща от рекомендационната система smrGoods.',
         'Сделать классификатор с логистической регрессии',
         'Fazer um classificador florestal aleatório com 200 árvores'],
        from-lang => Whatever,
        to-lang => 'English');

say to-pretty-table($res, align=>'l', field-names => <detected_source_language text>);

say '-' x 120;

say "Using formality option:";
say deepl-translation('How are you?', to-lang => 'German', auth-key => Whatever, formality => 'more');
say deepl-translation('How are you?', to-lang => 'German', auth-key => Whatever, formality => 'less');

say '-' x 120;

say "Source languages:";
say deepl-source-languages;
say deepl-source-languages(:inverse);

say '-' x 120;
say "Target languages:";
say deepl-target-languages;
say deepl-target-languages(:inverse);