function fcnInfo=rtw_tfl_query_nothrow(model,FcnRec,isSimBuild)





























    fcnInfo=[];

    libH=get_param(model,'TargetFcnLibHandle');
    if isempty(libH)
        implH=[];
    else
        entry=[];
        switch FcnRec.Name

        case{'RTW_OP_ADD','RTW_OP_MINUS','RTW_OP_MUL',...
            'RTW_OP_DIV','RTW_OP_SL','RTW_OP_SRA',...
            'RTW_OP_SRL','RTW_OP_HMMUL','RTW_OP_TRMUL',...
            'RTW_OP_ELEM_MUL','RTW_OP_LDIV','RTW_OP_RDIV',...
            'RTW_OP_GREATER_THAN','RTW_OP_LESS_THAN',...
            'RTW_OP_GREATER_THAN_OR_EQ','RTW_OP_LESS_THAN_OR_EQ',...
            'RTW_OP_EQUAL','RTW_OP_NOT_EQUAL'}
        otherwise
            entry=RTW.TflCFunctionEntry;
        end
        if~isempty(entry)
            entry.Key=FcnRec.Name;
            if~isempty(entry.EntryInfo)
                entry.EntryInfo.Algorithm='RTW_DEFAULT';
            end
            if~isfield(FcnRec,'RetTypeId')
                FcnRec.RetTypeId='void';
            end
            argType=FcnRec.RetTypeId;
            if isfield(FcnRec,'IsPtr')&&FcnRec.IsPtr==1&&~strcmp(argType,'pointer')
                argType=strcat(argType,'*');
            end
            if isfield(FcnRec,'IsCplx')&&FcnRec.IsCplx==1
                argType=strcat('c',argType);
            end

            arg=libH.getTflArgFromString('y1',argType);
            arg.IOType='RTW_IO_OUTPUT';
            entry.addConceptualArg(arg);

            if FcnRec.NumArgs==1
                argType=FcnRec.ArgList.TypeId;
                if FcnRec.ArgList.IsPtr&&~strcmp(argType,'pointer')
                    argType=strcat(argType,'*');
                end
                if FcnRec.ArgList.IsCplx
                    argType=strcat('c',argType);
                end
                arg=libH.getTflArgFromString('u1',argType);
                entry.addConceptualArg(arg);
            else
                for idx=1:FcnRec.NumArgs
                    argName=sprintf('u%d',idx);
                    argType=FcnRec.ArgList{1,idx}.TypeId;
                    if FcnRec.ArgList{1,idx}.IsPtr&&~strcmp(argType,'pointer')
                        argType=strcat(argType,'*');
                    end
                    if FcnRec.ArgList{1,idx}.IsCplx
                        argType=strcat('c',argType);
                    end
                    if isfield(FcnRec.ArgList{1,idx},'IsMtx')&&isfield(FcnRec.ArgList{1,idx},'Dim')&&FcnRec.ArgList{1,idx}.IsMtx
                        argDim=FcnRec.ArgList{1,idx}.Dim;
                        assert(size(argDim,1)==1);
                        arg=RTW.TflArgMatrix(argName,'RTW_IO_INPUT',argType);
                        arg.DimRange=argDim;
                        arg.Type.Dimensions=argDim;
                    else
                        arg=libH.getTflArgFromString(argName,argType);
                    end
                    entry.addConceptualArg(arg);
                end
            end

            implH=libH.getImplementation(entry);
        end
    end


    if~isempty(implH)
        if~isa(implH,'RTW.TflCustomization')


            if~isSimBuild
                err=pwsCheckCrlUnsizedArgs_nothrow(model,implH);
                if(~isempty(err))


                    fcnInfo=struct('ErrIdentifier',{err.Identifier},...
                    'ErrArguments',{err.Arguments});
                    return;
                end
            end


            numDWorkArgs=0;
            if isa(class(implH),'RTW.TflCSemaphoreEntry')
                numDWorkArgs=length(implH.DWorkArgs);
            end
            retArg=implH.Implementation.Return.toString;
            retIsPtr=0;
            retIsDoublePtr=0;
            ptr=strfind(retArg,'*');
            if~isempty(ptr)
                if length(ptr)==2
                    retIsDoublePtr=1;
                else
                    retIsPtr=1;
                end
                retArg=strrep(retArg,'*','');
            end

            numArgs=implH.Implementation.NumInputs;
            Args=implH.Implementation.Arguments;
            ArgArray={};
            for idx=1:numArgs
                argType=Args(idx).toString;
                isPtr=0;
                isDoublePtr=0;
                ptr=strfind(argType,'*');
                if~isempty(ptr)
                    if length(ptr)==2
                        isDoublePtr=1;
                    else
                        isPtr=1;
                    end
                    argType=strrep(argType,'*','');
                end
                value=num2str(0);
                if isa(Args(idx),'RTW.TflArgNumericConstant')
                    value=num2str(Args(idx).Value);
                end
                ArgArray=[ArgArray;{Args(idx).Name,argType,isPtr,isDoublePtr,value}];%#ok
            end
            hasTLCGenCallBack=(numel(implH.GenCallback)>=4)&&...
            strcmpi(implH.GenCallback(end-3:end),'.tlc');
            fcnInfo=struct(...
            'CustomizationEntry',0,...
            'FcnName',implH.getEmitName(),...
            'FcnType',retArg,...
            'IsPtr',retIsPtr,...
            'IsDoublePtr',retIsDoublePtr,...
            'HasTLCGenCallBack',hasTLCGenCallBack,...
            'HdrFile',implH.Implementation.HeaderFile,...
            'NumInputs',numArgs,...
            'NumDWorkArgs',numDWorkArgs,...
            'Args',cell2struct(ArgArray,...
            {'Name','Type','IsPtr','IsDoublePtr','Expr'},2),...
            'InlineFcn',implH.InlineMatlabFcn,...
            'ImplCallback',implH.MatlabCallback);
        else


            fcnInfo=struct(...
            'CustomizationEntry',1,...
            'InlineFcn',implH.InlineFcn,...
            'SupportNonFinite',implH.SupportNonFinite,...
            'ImplCallback',implH.ImplCallback,...
            'Precise',implH.Precise);
        end
    end

end


