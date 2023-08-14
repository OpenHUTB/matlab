function out=updateCornerStringToInt(input)
    Val1=13*(strcmp(input,"Smooth"));
    Val2=11*(strcmp(input,"Sharp"));
    Val3=12*(strcmp(input,"Miter"));
    out=Val1+Val2+Val3;
end