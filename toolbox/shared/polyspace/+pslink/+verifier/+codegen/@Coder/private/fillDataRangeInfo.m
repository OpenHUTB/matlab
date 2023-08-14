function fillDataRangeInfo(self)





    filteredIdx=0;
    if self.paramFullRange
        filteredIdx=3;
    end

    srcField={'Inports','Outports','Parameters','DataStores'};
    dstField={'input','output','param','dsm'};

    for ii=1:numel(srcField)
        if ii==filteredIdx
            self.drsInfo.(dstField{ii})=struct([]);
            continue
        end
        data=self.codeInfo.(srcField{ii});
        for jj=1:numel(data)
            nFillData(data(jj),dstField{ii});
        end
    end


    fcnField={'OutputFunctions','UpdateFunctions'};
    for ii=1:numel(fcnField)
        fcns=self.codeInfo.(fcnField{ii});
        for jj=1:numel(fcns)
            nFillFunction(fcns(jj));
        end
    end

    function nFillFunction(fcn)


        if isempty(fcn.ActualArgs)&&isempty(fcn.ActualReturn)

            return
        end

        if isempty(self.drsInfo.fcn)
            self.drsInfo.fcn=pslink.verifier.Coder.createFcnRangeInfoStruct();
        else
            self.drsInfo.fcn(end+1)=pslink.verifier.Coder.createFcnRangeInfoStruct();
        end
        self.drsInfo.fcn(end).name=fcn.Prototype.Name;
        self.drsInfo.fcn(end).sourceFile=fcn.Prototype.SourceFile;
        for pp=1:numel(fcn.ActualArgs)
            nFillArgument(fcn,pp);
        end
        if~isempty(fcn.ActualReturn)
            nFillArgument(fcn,-1);
        end


        if isempty(self.drsInfo.fcn(end).arg)&&isempty(self.drsInfo.fcn(end).return)
            self.drsInfo.fcn(end)=[];
        end
    end

    function nFillData(data,category)



        if isprop(data,'UsageKind')&&data.UsageKind==2

            return
        end



        exprInCode='';
        dataImpl=isprop(data,'Implementation');
        if dataImpl&&~isempty(data.Implementation)
            if isa(data.Implementation,'RTW.TypedCollection')

                dataImpl=data.Implementation.Elements(1);
            else
                dataImpl=data.Implementation;
            end

            if dataImpl.isDefined&&...
                ~isa(dataImpl,'RTW.PointerVariable')&&...
                (isa(dataImpl,'RTW.Variable')||isa(dataImpl,'RTW.StructExpression'))
                exprInCode=dataImpl.getExpression();
            else
                if isa(dataImpl,'RTW.PointerVariable')&&isa(dataImpl.TargetVariable,'RTW.Variable')
                    exprInCode=dataImpl.Identifier;
                elseif isa(dataImpl,'RTW.Variable')
                    exprInCode=dataImpl.Identifier;
                else

                end
            end
        end

        if isempty(exprInCode)

            return
        end


        dataInfo=pslink.verifier.Coder.createDataRangeInfoStruct();
        dataType=pslink.verifier.ec.Coder.getCoderType(dataImpl.Type);
        if isa(dataType,'embedded.pointertype')
            dataInfo.isPtr=true;


            ptrDataType=data.Type;
            ptrDataType=pslink.verifier.codegen.Coder.getCoderType(ptrDataType);
            if isa(ptrDataType,'embedded.matrixtype')
                baseType=ptrDataType;
            else
                baseType=dataType.BaseType;
            end
            dataInfo.width=baseType.getWidth();
        else
            dataInfo.width=dataType.getWidth();
        end

        baseType=pslink.verifier.codegen.Coder.getUnderlyingType(dataType);
        if isa(baseType,'embedded.structtype')
            dataInfo.isStruct=true;
            if isfield(self.drsInfo.busInfo,baseType.Identifier)
                dataInfo.field=nExtractFieldInfo(data,baseType,'');
            end
        end

        minVal=[];
        maxVal=[];
        if isprop(data,'MinMax')
            minVal=data.MinMax{1};
            maxVal=data.MinMax{2};
        end

        mode='init';
        if strcmpi(category,'output')
            if~self.outputFullRange
                mode='globalassert';
            else
                dataInfo.emit=false;
            end
        else
            bottomType=dataImpl.Type;
            bottomType=pslink.verifier.codegen.Coder.getUnderlyingType(bottomType);
            if bottomType.Volatile
                mode='permanent';
            end
        end

        dataInfo.expr=exprInCode;
        dataInfo.min=minVal;
        dataInfo.max=maxVal;
        if isa(dataImpl,'RTW.Variable')
            dataInfo.sourceFile=dataImpl.DefinitionFile;
        elseif isa(dataImpl,'RTW.StructExpression')
            dataInfo.sourceFile=dataImpl.BaseRegion.DefinitionFile;
        end
        dataInfo.mode=mode;
        if isprop(data,'isFullDataTypeRange')
            dataInfo.isFullDataTypeRange=data.isFullDataTypeRange;
        end
        if isempty(self.drsInfo.(category))
            self.drsInfo.(category)=dataInfo;
        else
            self.drsInfo.(category)(end+1)=dataInfo;
        end

    end

    function nFillArgument(fcn,pos)



        doEmit=true;
        if pos>0
            category='arg';
            formalArg=fcn.Prototype.Arguments(pos);
            effectiveArg=fcn.ActualArgs(pos);

        else
            category='return';
            formalArg=fcn.Prototype.Return;
            effectiveArg=fcn.ActualReturn;
        end





        argInfo=pslink.verifier.Coder.createDataRangeInfoStruct();
        argInfo.emit=doEmit;
        argInfo.pos=pos;
        argInfo.expr=formalArg.Name;
        argInfo.mode='init';

        if isprop(effectiveArg,'isFullDataTypeRange')
            argInfo.isFullDataTypeRange=effectiveArg.isFullDataTypeRange;
        end

        if isprop(effectiveArg,'MinMax')
            argInfo.min=effectiveArg.MinMax{1};
            argInfo.max=effectiveArg.MinMax{2};
        else
            argInfo.min=[];
            argInfo.max=[];
        end

        dataType=pslink.verifier.codegen.Coder.getCoderType(formalArg.Type);

        switch class(dataType)
        case 'embedded.pointertype'
            argInfo.isPtr=true;
            argInfo.width=dataType.BaseType.getWidth();
        case 'embedded.opaquetype'
            argInfo.isPtr=true;
            argInfo.width=dataType.getWidth();
        case 'embedded.matrixtype'
            argInfo.isPtr=true;
            if dataType.getWidth()>0
                argInfo.width=dataType.getWidth();
            else
                argInfo.width='max';
            end
        otherwise
            argInfo.isPtr=dataType.isPointer;
            argInfo.width=dataType.getWidth();
        end

        baseType=pslink.verifier.codegen.Coder.getUnderlyingType(formalArg.Type);
        if isa(baseType,'embedded.structtype')
            argInfo.isStruct=true;
            if isfield(self.drsInfo.busInfo,baseType.Identifier)
                argInfo.field=nExtractFieldInfo(effectiveArg,baseType,'');
            end
        end


        if isempty(self.drsInfo.fcn(end).(category))
            self.drsInfo.fcn(end).(category)=argInfo;
        else
            self.drsInfo.fcn(end).(category)(end+1)=argInfo;
        end

    end

    function fieldInfo=nExtractFieldInfo(data,structType,parentName,isForAutosar)

        if nargin<4
            isForAutosar=false;
        end


        busObj=[];
        numBusElements=0;
        if isfield(self.drsInfo.busInfo,structType.Identifier)
            busObj=self.drsInfo.busInfo.(structType.Identifier);
            numBusElements=numel(busObj.Elements);
        end

        fieldInfo=cell(0,2);
        for pp=1:numel(structType.Elements)

            sE=structType.Elements(pp);
            bE=[];
            if pp<=numBusElements
                bE=busObj.Elements(pp);


                if~strcmp(bE.Name,sE.Identifier)
                    bE=[];
                end
            end

            if~isempty(parentName)
                fullName=[parentName,'.',sE.Identifier];
            else
                fullName=sE.Identifier;
            end

            bottomType=pslink.verifier.codegen.Coder.getUnderlyingType(sE.Type);
            if isa(bottomType,'embedded.structtype')

                infoCell=nExtractFieldInfo(data,bottomType,fullName,isForAutosar);
            else
                fMinVal=[];
                fMaxVal=[];
                if~isempty(bE)&&isprop(bE,'Min')&&isprop(bE,'Max')&&(isForAutosar||self.inputFullRange==false)
                    fMinVal=bE.Min;
                    fMaxVal=bE.Max;
                end
                infoCell={fullName,pslink.verifier.codegen.Coder.computeDataMinMax(data,sE.Type,fMinVal,fMaxVal)};
            end
            fieldInfo=[fieldInfo;infoCell];%#ok<AGROW>
        end
    end

end




