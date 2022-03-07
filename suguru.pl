:- use_module(library(clpfd)).

/*----------------------
    Regras do Suguru
------------------------*/
suguru(Rows) :- 
    check_adjacent(Rows),
    check_tectons(Rows),
    only_values(Rows,Values), maplist(label, Values),

    writeln('Soluion: '), maplist(portray_clause, Values),writeln(''), !.

only_values(X,Y) :-
    maplist(only_values_, X, Y).

only_values_(X,Y) :-
    maplist([A,B]>>(A=_-B), X, Y).

/*---------------------------
    Testa adjacentes
---------------------------*/
check_adjacent(Rows) :-
    findall((R,C), element_at(R,C,Rows,_-1),Vars),
    check_adjacent_(Vars, Rows).

check_adjacent_([],_) :- !.
check_adjacent_([(R,C)|Tail], Rows) :-
    test_adj(R,C,Rows),
    check_adjacent_(Tail,Rows).

test_adj(R,C,Rows) :-
    get_up(R,C,Rows,Up),
    get_down(R,C,Rows,Down),
    get_left(R,C,Rows,Left),
    get_right(R,C,Rows,Right),
    get_uldiag(R,C,Rows,UL),
    get_urdiag(R,C,Rows,UR),
    get_lldiag(R,C,Rows,LL),
    get_lrdiag(R,C,Rows,LR),
    element_at(R,C,Rows,_-Ctr),

    Ctr #\= Up, Ctr #\= Down, Ctr #\= Left, Ctr #\= Right,
    Ctr #\= UL, Ctr #\= UR, Ctr #\= LL, Ctr #\= LR.

get_up(R,C,Rows,Val) :- 
    Ru #= R - 1,
    element_at(Ru,C,Rows,_-Val).
get_down(R,C,Rows,Val) :- 
    Rd #= R + 1,
    element_at(Rd,C,Rows,_-Val).
get_right(R,C,Rows,Val) :- 
    Cr #= C + 1,
    element_at(R,Cr,Rows,_-Val).
get_left(R,C,Rows,Val) :- 
    Cl #= C - 1,
    element_at(R,Cl,Rows,_-Val).
% upper left diagonal
get_uldiag(R,C,Rows,Val) :-
    Ru #= R - 1, Cl #= C - 1,
    element_at(Ru,Cl,Rows,_-Val).
% upper right diagonal
get_urdiag(R,C,Rows,Val) :-
    Ru #= R - 1, Cr #= C + 1,
    element_at(Ru,Cr,Rows,_-Val).
% lower left diagonal
get_lldiag(R,C,Rows,Val) :-
    Rd #= R + 1, Cl #= C - 1,
    element_at(Rd,Cl,Rows,_-Val).
% lower right diagonal
get_lrdiag(R,C,Rows,Val) :-
    Rd #= R + 1, Cr #= C + 1,
    element_at(Rd,Cr,Rows,_-Val).

element_at(-1,_,_,Num) :- Num = _-0, !.
element_at(_,-1,_,Num) :- Num = _-0, !.
element_at(Row,_,Matrix,Num) :- length(Matrix, Row), Num = _-0, !.
element_at(_,Col,Matrix,Num) :- nth0(0,Matrix,R), length(R, Col), Num = _-0, !.
element_at(Row,Col,Matrix,Num) :- nth0(Row,Matrix,R), nth0(Col,R,Num).

/*--------------------
    Testa tectons
----------------------*/
check_tectons(Rows) :- 
    append(Rows,Vs),  % cria uma única lista com todos os elementos
    sort(Vs,Ordered), !,  % ordena tectons por ID
    build_tec(Ordered, Tectons), !,
    maplist(tecton_ok, Tectons).

% constrói lista de tectons
build_tec(Ord, Tecs) :- 
    build_tec_(Ord, _, [], [], Tecs).
% se a lista ordenada terminar, colocamos os valores do ultimo tecton avaliado e dos tectons armazenados no Acc em Tecs 
build_tec_([], _, LastTec, Acc, Tecs) :-
    append(Acc, [LastTec], Tecs), !.
% para cada ID, cria uma lista lista de numeros
build_tec_([ID-N|T], ID, NList, Acc, Tecs) :-
    append(NList, [N], NList_),
    build_tec_(T, ID, NList_, Acc, Tecs).
% se o proximo valor a ser avaliado é de outro tecton
build_tec_([ID-N|T], CurrID, NList, Acc, Tecs) :- 
    ID \= CurrID,
    append(Acc, [NList], Acc_),
    build_tec_(T, ID, [N], Acc_, Tecs).

% aplica restrições aos valores do tecton
tecton_ok(Tec) :- 
    all_distinct(Tec),
    length(Tec, L), Tec ins 1..L.

/*-------------------------
    Exemplos de tabuleiro
---------------------------*/

% https://www.janko.at/Raetsel/Suguru/001.a.htm
problem(1,P) :- 
    P = [   
        [a-4,a-_,b-_,c-_,c-_,c-_],
        [a-_,b-_,b-_,b-_,c-_,d-_],
        [a-_,e-_,b-4,g-_,c-_,d-1],
        [e-_,e-_,g-_,g-2,g-_,d-_],
        [e-5,f-_,f-_,g-3,h-5,d-_],
        [e-_,h-_,h-_,h-_,h-_,d-_]].

% https://www.janko.at/Raetsel/Suguru/117.a.htm
problem(117,P) :-
    P = [
        [a-_, a-6, b-5, b-_, c-6, c-_, c-5, c-_, d-_, d-5],
        [a-4, a-_, b-3, b-_, b-2, c-1, c-4, c-_, d-3, e-1],
        [a-_, a-7, f-_, f-6, f-_, f-_, d-6, d-_, d-2, e-_],
        [a-2, g-_, f-5, h-_, h-_, h-5, h-_, h-_, e-_, e-4],
        [g-1, g-_, f-_, i-7, j-3, j-_, j-_, k-_, e-5, e-_],
        [g-_, g-5, f-_, i-5, j-_, j-_, j-_, k-1, l-_, l-1],
        [i-_, i-_, i-3, i-_, j-1, k-_, k-3, k-_, l-_, m-5],
        [i-4, q-_, q-_, q-4, q-_, k-5, n-2, l-_, l-2, m-3],
        [o-3, q-_, p-_, q-6, q-3, n-4, n-_, n-3, m-4, m-_],
        [o-2, o-_, p-4, p-_, p-1, n-_, n-5, m-_, m-1, m-7]].