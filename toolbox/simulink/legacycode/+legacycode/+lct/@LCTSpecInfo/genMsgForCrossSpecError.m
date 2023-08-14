





function msg=genMsgForCrossSpecError(this,dataRole,propPosStr,propExprStr)

    if legacycode.lct.spec.Common.Role2RadixMap.isKey(dataRole)


        dataId=0;
    else


        [radix,dataId]=legacycode.lct.spec.Common.splitIdentifier(dataRole);
        dataRole=legacycode.lct.spec.Common.Radix2RoleMap(radix);
    end

    dataKind=legacycode.lct.spec.DataKind.fromString(dataRole);


    argPerFun=struct();


    this.forEachFunction(@(o,n,f)collectFun(f,n));


    msg='';


    sep='';
    fNames=fieldnames(argPerFun);
    for ii=1:numel(fNames)


        funKind=fNames{ii};
        argFun=argPerFun.(funKind);
        if isempty(argFun)
            continue
        end


        numArgs=numel(argFun);
        numT=zeros(1,numArgs);
        numS=zeros(1,numArgs);

        posOffset=0;
        lastNumT=0;
        for jj=1:numArgs
            numT(jj)=numel(argFun(jj).(propExprStr));
            numS(jj)=argFun(jj).(propPosStr)-posOffset-lastNumT-1;


            posOffset=argFun(jj).(propPosStr)-1;
            lastNumT=numT(jj);
        end


        msg=sprintf('%s%s%s',msg,sep,legacycode.lct.spec.Common.genSpecAnnotation(...
        this.Fcns.(funKind).Expression,numS,numT));

        sep=sprintf('\n');
    end

    function collectFun(funSpec,funKind)

        argPerFun.(funKind)=legacycode.lct.spec.FunctionArg.empty();


        funSpec.forEachArg(@(f,a)collectArg(a,funKind));
    end

    function collectArg(argSpec,funKind)

        if argSpec.Data.Kind==dataKind
            if dataId==0||argSpec.Data.Id==dataId
                argPerFun.(funKind)(end+1)=argSpec;
            end
        end
    end

end
