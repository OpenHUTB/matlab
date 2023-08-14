function err=pwsCheckCrlUnsizedArgs_nothrow(model,replEnt)
















    err=[];

    isPwsEnabled=isequal(get_param(model,'PortableWordSizes'),'on');
    if(~isPwsEnabled)
        return;
    end
    if(slfeature('PwsProcessUnsizedArgs')<=0||...
        isempty(replEnt)||~isprop(replEnt,'Implementation')||isempty(replEnt.Implementation))
        return;
    end

    persistent hostwl;
    if(isempty(hostwl))
        hostwl=rtwhostwordlengths;
    end

    targetwl=struct(...
    'IntNumBits',get_param(model,'ProdBitPerInt'),...
    'LongNumBits',get_param(model,'ProdBitPerLong'),...
    'LongLongNumBits',get_param(model,'ProdBitPerLongLong')...
    );
    longLongIsDisabledOrEqual=strcmpi(get_param(model,'ProdLongLongMode'),'Off')||...
    targetwl.LongLongNumBits==hostwl.LongLongNumBits;
    if targetwl.IntNumBits==hostwl.IntNumBits&&...
        targetwl.LongNumBits==hostwl.LongNumBits&&...
longLongIsDisabledOrEqual
        return;
    end



    impl=replEnt.Implementation;
    complexOrPassByRefList=[];
    realScalarPassByValList=[];
    if(isprop(impl,'Return'))
        retArg=impl.Return;
        if(~isempty(retArg))
            if(~isArgTypeEqOnHostAndTarget(retArg,targetwl,hostwl))
                if(isImplArgPassByRealScalarValue(retArg))
                    realScalarPassByValList(end+1)=-1;
                else
                    complexOrPassByRefList(end+1)=-1;
                end
            end
        end
    end
    for idx=1:numel(impl.Arguments)
        iarg=impl.Arguments(idx);
        if(~isempty(iarg))
            if(~isArgTypeEqOnHostAndTarget(iarg,targetwl,hostwl))
                if(isImplArgPassByRealScalarValue(iarg))
                    realScalarPassByValList(end+1)=idx;%#ok<AGROW>
                else
                    complexOrPassByRefList(end+1)=idx;%#ok<AGROW>
                end
            end
        end
    end


    if(~isempty(realScalarPassByValList)||~isempty(complexOrPassByRefList))
        assert(replEnt.Inhouse==0||replEnt.Inhouse==1);
        if~replEnt.Inhouse
            argIdxList=sort([realScalarPassByValList,complexOrPassByRefList]);
            if argIdxList(1)==-1
                MSLDiagnostic([],message('Coder:buildProcess:PWSWarnAboutUnsizedReturnArg',...
                impl.Name,'TLC')).reportAsWarning;
                if(numel(argIdxList)>1)
                    argListStr=convertIntegerListToStr(argIdxList(2:end));
                    MSLDiagnostic([],message('Coder:buildProcess:PWSWarnAboutUnsizedArgs',argListStr,impl.Name,'TLC')).reportAsWarning;
                end
            else
                argListStr=convertIntegerListToStr(argIdxList);
                MSLDiagnostic([],message('Coder:buildProcess:PWSWarnAboutUnsizedArgs',argListStr,impl.Name,'TLC')).reportAsWarning;
            end
        else
            if(~isempty(complexOrPassByRefList))









                if(convertIntegerListToStr(1)==-1)
                    err=message('Coder:buildProcess:PWSUnsupportedUnsizedRetArgInhouse',...
                    impl.Name,'TLC');
                else
                    argListStr=convertIntegerListToStr(complexOrPassByRefList);
                    err=message('Coder:buildProcess:PWSUnsupportedUnsizedArgInhouseTlc',...
                    argListStr,impl.Name);
                end
            end
        end
    end

end




function isequal=isArgTypeEqOnHostAndTarget(implCrlArg,targetWl,hostWl)



    typeMode='RTW_TYPEMODE_SIZED';
    if(isprop(implCrlArg,'TypeMode'))
        typeMode=implCrlArg.TypeMode;
    elseif(isprop(implCrlArg,'BaseTypeMode'))
        typeMode=implCrlArg.BaseTypeMode;
    end
    if(strcmp(typeMode,'RTW_TYPEMODE_SIZED'))
        isequal=true;
        return;
    end

    switch(typeMode)
    case{'RTW_TYPEMODE_UNSIZED_INT','RTW_TYPEMODE_UNSIZED_SIZET'}
        isequal=targetWl.IntNumBits==hostWl.IntNumBits;
    case 'RTW_TYPEMODE_UNSIZED_LONG'
        isequal=targetWl.LongNumBits==hostWl.LongNumBits;
    case 'RTW_TYPEMODE_UNSIZED_LONGLONG'
        isequal=targetWl.LongLongNumBits==hostWl.LongLongNumBits;
    otherwise
        error('Unhandled TypeMode = %s',typeMode);
    end

end


function isPassByRealScalarVal=isImplArgPassByRealScalarValue(implArg)


    isPassByRealScalarVal=implArg.Type.isnumerictype;

    if(isPassByRealScalarVal&&isprop(implArg,'PassByType'))
        switch implArg.PassByType
        case 'RTW_PASSBY_AUTO'

        case{'RTW_PASSBY_POINTER','RTW_PASSBY_VOID_POINTER','RTW_PASSBY_BASE_POINTER'}
            isPassByRealScalarVal=false;
        otherwise
            error('Unknown PassByType %s',implArg.PassByType);
        end
    end

end


function listStr=convertIntegerListToStr(list)

    listStr='';
    if(~isempty(list))
        for idx=1:numel(list)-1
            item=int2str(list(idx));
            listStr=[listStr,item,', '];%#ok<AGROW>
        end
        listStr=[listStr,int2str(list(end))];
    end

end
