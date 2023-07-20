function Y=parsosfilt(B,A,FIR,X)










    narginchk(4,4);






    myFunc="parallel.internal.gpu.filter.parsosfilt";

    validateattributes(B,{'single','double'},{'2d','nonempty','nonsparse','size',[2,NaN]},myFunc,'B',1)
    validateattributes(A,{'single','double'},{'2d','nonempty','nonsparse','size',size(B)},myFunc,'A',2)
    validateattributes(FIR,{'single','double'},{'scalar','nonsparse'},myFunc,'FIR',3)
    validateattributes(X,{'single','double'},{'2d','nonempty','nonsparse'},myFunc,'X',4)
    assert(numel(X)>=2,"The input signal (X) must have at least two elements");

    Y=parallel.internal.gpu.filter.doParFilter(B,A,FIR,X);

end
