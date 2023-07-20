function obj=factoryConstruct(maxRows,maxCols)




















%#codegen

    coder.allowpcode('plain');

    validateattributes(maxRows,{coder.internal.indexIntClass},{'scalar','nonnegative'});
    validateattributes(maxCols,{coder.internal.indexIntClass},{'scalar','nonnegative'});
    coder.internal.prefer_const(maxRows,maxCols);

    obj=struct();

    minRowCol=min(maxRows,maxCols);


    obj.ldq=maxRows;


    obj.QR=coder.nullcopy(realmax*ones(maxRows,maxCols,'double'));










    obj.Q=zeros(maxRows,maxRows,'double');

    obj.jpvt=zeros(maxCols,1,coder.internal.indexIntClass);
    obj.mrows=coder.internal.indexInt(0);
    obj.ncols=coder.internal.indexInt(0);


    obj.tau=coder.nullcopy(realmax*ones(minRowCol,1));
    obj.minRowCol=coder.internal.indexInt(0);
    obj.usedPivoting=false;










end

