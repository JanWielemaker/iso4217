/*  Author:        Jan Wielemaker
    E-mail:        jan@swi-prolog.org
    WWW:           http://www.swi-prolog.org
    Copyright (c)  2024, SWI-Prolog Solutions b.v.
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions
    are met:

    1. Redistributions of source code must retain the above copyright
       notice, this list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright
       notice, this list of conditions and the following disclaimer in
       the documentation and/or other materials provided with the
       distribution.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
    COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
    POSSIBILITY OF SUCH DAMAGE.
*/

:- module(iso4217,
          [ iso4217/5,        % ?CtryNm, ?CcyNm, ?Ccy, ?CcyNbr, ?CcyMnrUnts
            iso4217_version/1 % -Version
          ]).
:- autoload(library(sgml), [load_xml/3]).
:- autoload(library(terms), [foldsubterms/4]).

/** <module> Access ISO 4217 currency codes

This module loads `data/table.xml` to create   clauses  for iso4217/5 on
the fly.

@see `data/table.xml` was extracted from https://pypi.org/project/iso4217/
*/

%!  iso4217(?CtryNm, ?CcyNm, ?Ccy, ?CcyNbr, ?CcyMnrUnts) is nondet.
%
%   True when the relation is true for a country.  For example:
%
%       ?- iso4217(CtryNm, CcyNm, 'EUR', CcyNbr, CcyMnrUnts).
%       CtryNm = 'ÅLAND ISLANDS',
%       CcyNm = 'Euro',
%       CcyNbr = 978,
%       CcyMnrUnts = 2 ;
%       CtryNm = 'ANDORRA',
%       CcyNm = 'Euro',
%       CcyNbr = 978,
%       CcyMnrUnts = 2 ;
%       ...
%
%   Note  that  SWI-Prolog  JIT  indexing   makes  the  table  efficient
%   regardless of the query.
%
%   @arg CtryNm		Country name
%   @arg CcyNm		Currency name
%   @arg Ccy		Currency code ([A-Z]{3})
%   @arg CcyNbr		Currency number
%   @arg CcyMnrUnts	Currency minor units

%!  iso4217_version(-Version) is det.
%
%   True when Version is the version as in 'YYYY-MM-DD' (an atom).  E.g.
%
%       ?- iso4217_version(X).
%       X = '2024-06-25'.

term_expansion(iso4217('CtryNm', 'CcyNm', 'Ccy', 'CcyNbr', 'CcyMnrUnts'),
               Clauses) :-
    iso4217_clauses(Clauses).

:- det(iso4217_clauses/1).
iso4217_clauses([iso4217_version(Version)|Clauses]) :-
    absolute_file_name('../data/table.xml', File, [access(read)]),
    load_xml(File, DOM, [space(remove)]),
    DOM = [element('ISO_4217', ['Pblshd'=Version], _)],
    foldsubterms(iso4217_clause, DOM, Clauses, []).

iso4217_clause(element('CcyNtry', _,
                       [ element('CtryNm',[],[CtryNm]),
                         element('CcyNm',[],[CcyNm]),
                         element('Ccy',[],[Ccy]),
                         element('CcyNbr',[],[CcyNbrA]),
                         element('CcyMnrUnts',[],[CcyMnrUntsA])
                       ]),
               [ iso4217(CtryNm, CcyNm, Ccy, CcyNbr, CcyMnrUnts) | List ],
               List) :-
    atom_number(CcyNbrA, CcyNbr),
    atom_number(CcyMnrUntsA, CcyMnrUnts).

iso4217('CtryNm', 'CcyNm', 'Ccy', 'CcyNbr', 'CcyMnrUnts').
