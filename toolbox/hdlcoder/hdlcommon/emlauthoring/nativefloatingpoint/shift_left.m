function Y=shift_left(X,N)
%#codegen


    coder.allowpcode('plain')

    switch N
    case 0
        Y=X;
    case 1
        Y=bitshift(X,1);
    case 2
        Y=bitshift(X,2);
    case 3
        Y=bitshift(X,3);
    case 4
        Y=bitshift(X,4);
    case 5
        Y=bitshift(X,5);
    case 6
        Y=bitshift(X,6);
    case 7
        Y=bitshift(X,7);
    case 8
        Y=bitshift(X,8);
    case 9
        Y=bitshift(X,9);
    case 10
        Y=bitshift(X,10);
    case 11
        Y=bitshift(X,11);
    case 12
        Y=bitshift(X,12);
    case 13
        Y=bitshift(X,13);
    case 14
        Y=bitshift(X,14);
    case 15
        Y=bitshift(X,15);
    case 16
        Y=bitshift(X,16);
    case 17
        Y=bitshift(X,17);
    case 18
        Y=bitshift(X,18);
    case 19
        Y=bitshift(X,19);
    case 20
        Y=bitshift(X,20);
    case 21
        Y=bitshift(X,21);
    case 22
        Y=bitshift(X,22);
    case 23
        Y=bitshift(X,23);
    case 24
        Y=bitshift(X,24);
    case 25
        Y=bitshift(X,25);
    case 26
        Y=bitshift(X,26);
    case 27
        Y=bitshift(X,27);
    case 28
        Y=bitshift(X,28);
    case 29
        Y=bitshift(X,29);
    case 30
        Y=bitshift(X,30);
    case 31
        Y=bitshift(X,31);
    case 32
        Y=bitshift(X,32);
    case 33
        Y=bitshift(X,33);
    case 34
        Y=bitshift(X,34);
    case 35
        Y=bitshift(X,35);
    case 36
        Y=bitshift(X,36);
    case 37
        Y=bitshift(X,37);
    case 38
        Y=bitshift(X,38);
    case 39
        Y=bitshift(X,39);
    case 40
        Y=bitshift(X,40);
    case 41
        Y=bitshift(X,41);
    case 42
        Y=bitshift(X,42);
    case 43
        Y=bitshift(X,43);
    case 44
        Y=bitshift(X,44);
    case 45
        Y=bitshift(X,45);
    case 46
        Y=bitshift(X,46);
    case 47
        Y=bitshift(X,47);
    case 48
        Y=bitshift(X,48);
    case 49
        Y=bitshift(X,49);
    otherwise
        Y=X;
    end
end
