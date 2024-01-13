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
            if(isa(data(jj).Implementation,'RTW.BasicAccessFunctionExpressionCollection'))
                data(jj).Implementation=data(jj).Implementation.Elements(1);
            end
            nComputeSpecifiedMinMax(data(jj));
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
    pimMap=containers.Map('KeyType','char','ValueType','logical');
    cs=self.getConfigSet();
    aiObject=[];
    arPropObject=[];
    arMapObject=[];
    if cs.hasProp('AutosarSchemaVersion')
        self.arInfo.ver=get_param(cs,'AutosarSchemaVersion');
        self.arInfo.idMaxLength=get_param(cs,'AutosarMaxShortNameLength');
        self.arInfo.compName=self.codeInfo.Name;
        aiObject=self.getAutosarInterface();

        if exist('autosar.api.getAUTOSARProperties','class')==8
            try
                if autosar.api.Utils.isMapped(self.slModelName)
                    arPropObject=autosar.api.getAUTOSARProperties(self.slModelName);
                    arMapObject=autosar.api.getSimulinkMapping(self.slModelName);
                end
            catch
                arPropObject=[];
                arMapObject=[];
            end
        end

        for ii=1:numel(self.codeInfo.InternalData)
            nComputeSpecifiedMinMax(self.codeInfo.InternalData(ii));
        end
        fcnField={'InitializeFunctions','OutputFunctions'};
        for ii=1:numel(fcnField)
            fcns=self.codeInfo.(fcnField{ii});
            for jj=1:numel(fcns)
                for kk=1:numel(fcns(jj).DirectReads)
                    if isempty(fcns(jj).DirectReads(kk).Implementation)
                        continue
                    end
                    nFillAutosarFunction(fcns(jj),...
                    fcns(jj).DirectReads(kk),true,self.arInfo.compName);
                end
                for kk=1:numel(fcns(jj).DirectWrites)
                    if isempty(fcns(jj).DirectWrites(kk).Implementation)
                        continue
                    end
                    nFillAutosarFunction(fcns(jj),...
                    fcns(jj).DirectWrites(kk),false,self.arInfo.compName);
                end
            end
        end
    end


    function receiver=getReceiverFromErrorStatus(errorStatusImpl)
        if~isempty(self.expInports)
            graphicalPortIndex=str2double(errorStatusImpl.ReceiverPortNumber);
            codeInfoIdx=self.expInports(graphicalPortIndex).Index;
        else
            codeInfoIdx=str2double(errorStatusImpl.ReceiverPortNumber);
        end
        receiver=self.codeInfo.Inports(codeInfoIdx);
    end


    function shortName=getRunnableName(symbolName)
        shortName=symbolName;
        if isempty(arPropObject)
            return
        end
        try
            entityPath=find(arPropObject,[],'Runnable','symbol',symbolName);
            if isempty(entityPath)
                return
            end
            shortName=get(arPropObject,entityPath{1},'Name');
        catch
        end
    end


    function isEndToEnd=isEndToEndProtection(var,isInput)
        isEndToEnd=false;
        if~isempty(arMapObject)
            try
                if isInput
                    [~,~,accessMode]=arMapObject.getInport(var.GraphicalName);
                    isEndToEnd=strcmp(accessMode,'EndToEndRead');
                else
                    [~,~,accessMode]=arMapObject.getOutport(var.GraphicalName);
                    isEndToEnd=strcmp(accessMode,'EndToEndWrite');
                end
            catch
            end
            return
        end
    end


    function isQueued=isQueuedOutputDataAccess(var)

        isQueued=[];

        if~isempty(arMapObject)
            try
                [~,~,accessMode]=arMapObject.getOutport(var.GraphicalName);
                isQueued=strcmp(accessMode,'QueuedExplicitSend');
            catch
            end
            return
        end

        if~isempty(aiObject)
            try
                for pp=1:numel(aiObject.data)
                    if~strcmpi(aiObject.data(pp).SLObjectType,'outport')||...
                        ~strcmpi(aiObject.data(pp).InterfaceName,var.Implementation.Interface)||...
                        ~strcmpi(aiObject.data(pp).AutosarPort,var.Implementation.Port)||...
                        ~strcmpi(aiObject.data(pp).DataElement,var.Implementation.DataElement)||...
                        ~strcmpi(aiObject.data(pp).DataAccessMode,'ExplicitSend')
                        continue
                    end
                    if isprop(aiObject.data(pp),'isQueued')
                        isQueued=aiObject.data(pp).isQueued;
                    end
                end
            catch
                return
            end
        end
    end


    function nFillAutosarFunction(fcn,var,isRead,compName)

        switch class(var.Implementation)
        case 'RTW.AutosarErrorStatus'
            inport=getReceiverFromErrorStatus(var.Implementation);
            if strcmpi(inport.Implementation.DataAccessMode,'ImplicitReceive')
                startStr='Rte_IStatus';
                endStr=sprintf('%s_%s_%s',getRunnableName(fcn.Prototype.Name),...
                inport.Implementation.Port,...
                inport.Implementation.DataElement);
                name=sprintf('%s_%s',startStr,endStr);
                drsName=sprintf('%s_%s_%s',startStr,compName,endStr);
                nAddAutosarFunction(name,drsName);
                arg=pslink.verifier.Coder.createARFcnArgInfoStruct();
                arg.typeName='uint8_T';
                arg.pos=-1;
                arg.direction='ret';
                arg.kind='input';
                self.arInfo.fcn(end).return=arg;
                return
            end

        case 'RTW.AutosarSenderReceiver'

        case 'RTW.AutosarInterRunnable'

        case 'RTW.AutosarClientServer'

            return

        case 'RTW.AutosarCalibration'

        case 'RTW.Variable'
            if isprop(var,'SLObj')&&isa(var.SLObj,'AUTOSAR.Signal')&&...
                strcmpi(var.SLObj.RTWInfo.CustomStorageClass,'PerInstanceMemory')
                name=sprintf('Rte_Pim_%s',var.Implementation.Identifier);
                if~pimMap.isKey(name)
                    nAddAutosarFunction(name);
                    nFillAutosarArgument(var,var.Implementation,-1,'ret',false,'param');

                    self.arInfo.fcn(end).return.isPtr=true;
                    pimMap(name)=true;
                    self.arInfo.dsm{end+1}=var.Implementation.Identifier;
                end
            end
            return
        otherwise
            return
        end

        switch var.Implementation.DataAccessMode
        case 'ImplicitReceive'
            startStr='Rte_IRead';
            endStr=sprintf('%s_%s_%s',getRunnableName(fcn.Prototype.Name),...
            var.Implementation.Port,var.Implementation.DataElement);
            name=sprintf('%s_%s',startStr,endStr);
            drsName=sprintf('%s_%s_%s',startStr,compName,endStr);
            nAddAutosarFunction(name,drsName);
            nFillAutosarArgument(var,var.Implementation,-1,'ret',false,'input');

        case{'ExplicitReceive','QueuedExplicitReceive'}
            errStatus=nFindErrorStatus(fcn,var);

            startStr='Rte_';
            if strcmpi(var.Implementation.DataAccessMode,'ExplicitReceive')
                if isEndToEndProtection(var,true)
                    startStr='E2EPW_';
                end
                startStr=sprintf('%sRead',startStr);
            else
                startStr=sprintf('%sReceive',startStr);
            end
            endStr=sprintf('%s_%s',...
            var.Implementation.Port,var.Implementation.DataElement);
            name=sprintf('%s_%s',startStr,endStr);
            drsName=sprintf('%s_%s_%s',startStr,compName,endStr);
            nAddAutosarFunction(name,drsName);
            nFillAutosarArgument(var,var.Implementation,1,'out',false,'input');
            if~isempty(errStatus)
                nFillAutosarArgument([],errStatus,-1,'ret',false,'input');
            end

        case 'ImplicitSend'
            if self.outputFullRange||~pslinkprivate('pslinkattic','getBinMode','autosarFinalAssert')
                return
            end
            startStr='Rte_IWrite';
            endStr=sprintf('%s_%s_%s',getRunnableName(fcn.Prototype.Name),...
            var.Implementation.Port,var.Implementation.DataElement);
            name=sprintf('%s_%s',startStr,endStr);
            drsName=sprintf('%s_%s_%s',startStr,compName,endStr);
            nAddAutosarFunction(name,drsName);
            nFillAutosarArgument(var,var.Implementation,1,'in',false,'output');
        case{'ExplicitSend','QueuedExplicitSend'}
            if self.outputFullRange||~pslinkprivate('pslinkattic','getBinMode','autosarFinalAssert')
                return
            end
            isE2EPW=false;
            if strcmpi(var.Implementation.DataAccessMode,'ExplicitSend')
                isQueued=isQueuedOutputDataAccess(var);
                if isempty(isQueued)
                    return
                end
                isE2EPW=isEndToEndProtection(var,false);
            else
                isQueued=true;
            end
            if isQueued
                startStr='Rte_Send';
            else
                if isE2EPW
                    startStr='E2EPW_Write';
                else
                    startStr='Rte_Write';
                end
            end
            endStr=sprintf('%s_%s',var.Implementation.Port,var.Implementation.DataElement);
            name=sprintf('%s_%s',startStr,endStr);
            drsName=sprintf('%s_%s_%s',startStr,compName,endStr);
            nAddAutosarFunction(name,drsName);
            nFillAutosarArgument(var,var.Implementation,1,'in',false,'output');

        case 'ImplicitInterRunnable'
            if isRead
                startStr='Rte_IrvIRead';
                endStr=sprintf('%s_%s',...
                getRunnableName(fcn.Prototype.Name),var.Implementation.VariableName);
                name=sprintf('%s_%s',startStr,endStr);
                drsName=sprintf('%s_%s_%s',startStr,compName,endStr);
                nAddAutosarFunction(name,drsName);
                nFillAutosarArgument(var,var.Implementation,-1,'ret',false,'input');
            else
                if~self.outputFullRange&&pslinkprivate('pslinkattic','getBinMode','autosarFinalAssert')
                    startStr='Rte_IrvIWrite';
                    endStr=sprintf('%s_%s',getRunnableName(fcn.Prototype.Name),...
                    var.Implementation.VariableName);
                    name=sprintf('%s_%s',startStr,endStr);
                    drsName=sprintf('%s_%s_%s',startStr,compName,endStr);
                    nAddAutosarFunction(name,drsName);
                    nFillAutosarArgument(var,var.Implementation,1,'in',false,'output');
                end
            end

        case 'ExplicitInterRunnable'
            if isRead
                startStr='Rte_IrvRead';
                endStr=sprintf('%s_%s',getRunnableName(fcn.Prototype.Name),var.Implementation.VariableName);
                name=sprintf('%s_%s',startStr,endStr);
                drsName=sprintf('%s_%s_%s',startStr,compName,endStr);
                nAddAutosarFunction(name,drsName);
                nFillAutosarArgument(var,var.Implementation,-1,'ret',false,'input');

                if self.arInfo.fcn(end).return.isPtr
                    self.arInfo.fcn(end).arg=self.arInfo.fcn(end).return;
                    self.arInfo.fcn(end).arg.direction='out';
                    self.arInfo.fcn(end).arg.pos=1;
                    self.arInfo.fcn(end).return=struct([]);
                end
            else
                if~self.outputFullRange&&pslinkprivate('pslinkattic','getBinMode','autosarFinalAssert')
                    startStr='Rte_IrvWrite';
                    endStr=sprintf('%s_%s',getRunnableName(fcn.Prototype.Name),...
                    var.Implementation.VariableName);
                    name=sprintf('%s_%s',startStr,endStr);
                    drsName=sprintf('%s_%s_%s',startStr,compName,endStr);
                    nAddAutosarFunction(name,drsName);
                    nFillAutosarArgument(var,var.Implementation,1,'in',false,'output');
                end
            end

        case 'BasicSoftwarePort'

        case 'Calibration'
            if self.arInfo.ver(1)=='4'
                proc='Prm';
            else
                proc='Calprm';
            end
            startStr=sprintf('Rte_%s',proc);
            endStr=sprintf('%s_%s',var.Implementation.Port,var.Implementation.ElementName);
            name=sprintf('%s_%s',startStr,endStr);
            drsName=sprintf('%s_%s_%s',startStr,compName,endStr);
            nAddAutosarFunction(name,drsName);
            nFillAutosarArgument(var,var.Implementation,-1,'ret',true,'param');

        case 'InternalCalPrm'
            startStr='Rte_CData';
            endStr=var.Implementation.Port;
            name=sprintf('%s_%s',startStr,endStr);
            drsName=sprintf('%s_%s_%s',startStr,compName,endStr);
            nAddAutosarFunction(name,drsName);
            nFillAutosarArgument(var,var.Implementation,-1,'ret',true,'param');

        otherwise

        end

    end


    function nAddAutosarFunction(fcnName,drsName)
        fcnInfo=pslink.verifier.Coder.createARFcnInfoStruct();
        if nargin>0
            fcnInfo.name=fcnName;
        end
        if nargin>1
            fcnInfo.drsName=drsName;
        else
            fcnInfo.drsName=fcnInfo.name;
        end
        if isempty(self.arInfo.fcn)
            self.arInfo.fcn=fcnInfo;
        else
            self.arInfo.fcn(end+1)=fcnInfo;
        end
    end


    function errStatus=nFindErrorStatus(fcn,var)

        errStatus=[];
        for pp=1:numel(fcn.DirectReads)
            if pp==var

                continue
            end
            if isa(fcn.DirectReads(pp).Implementation,'RTW.AutosarErrorStatus')
                inport=getReceiverFromErrorStatus(fcn.DirectReads(pp).Implementation);
                if inport==var
                    errStatus=fcn.DirectReads(pp);
                    break
                end
            end
        end
    end


    function nFillAutosarArgument(data,dataImp,pos,direction,useTypeAlias,kind)

        if pos>0
            category='arg';
        else
            category='return';
        end
        argInfo=pslink.verifier.Coder.createARFcnArgInfoStruct();
        argInfo.pos=pos;
        if pos>0
            argInfo.expr=sprintf('u%d',pos);
        end
        argInfo.mode='init';
        argInfo.direction=direction;
        argInfo.udata=dataImp;
        argInfo.kind=kind;

        minVal=[];
        maxVal=[];
        if~isempty(data)
            if isprop(data,'MinMax')||isfield(data,'MinMax')
                minVal=data.MinMax{1};
                maxVal=data.MinMax{2};
            end
            if isprop(data,'isFullDataTypeRange')||isfield(data,'isFullDataTypeRange')
                argInfo.isFullDataTypeRange=data.isFullDataTypeRange;
            end
        end

        argInfo.isFullDataTypeRange=false;
        if strcmpi(kind,'input')&&self.inputFullRange
            argInfo.isFullDataTypeRange=true;
        end
        if strcmpi(kind,'output')&&self.outputFullRange
            argInfo.isFullDataTypeRange=true;
        end
        if strcmpi(kind,'param')&&self.paramFullRange
            argInfo.emit=false;
        end

        argInfo.min=minVal;
        argInfo.max=maxVal;
        argInfo.width=dataImp.Type.getWidth();
        baseType=pslink.verifier.ec.Coder.getUnderlyingType(dataImp.Type);
        if isa(baseType,'embedded.structtype')
            argInfo.isStruct=true;
            if isfield(self.drsInfo.busInfo,baseType.Name)
                if~isempty(data)
                    argInfo.field=nExtractFieldInfo(data,baseType,'',true);
                end
            end
        end

        if useTypeAlias
            argInfo.typeName=baseType.Name;
        else
            argInfo.typeName=nGetCoderTypeName(baseType);
        end

        argInfo.isPtr=(argInfo.width>1)||argInfo.isStruct||strcmpi(argInfo.direction,'out');

        if isempty(self.arInfo.fcn(end).(category))
            self.arInfo.fcn(end).(category)=argInfo;
        else
            self.arInfo.fcn(end).(category)(end+1)=argInfo;
        end

    end


    function typeName=nGetCoderTypeName(type)
        if isa(type,'embedded.numerictype')
            if type.isdouble()
                typeName='real_T';
            elseif type.issingle()
                typeName='real32_T';
            elseif type.isboolean()
                typeName='boolean_T';
            else
                typeName='int';
                if strcmpi(type.Signedness,'Unsigned')
                    typeName=['u',typeName];
                end
                typeName=sprintf('%s%d_T',typeName,type.WordLength());
            end
        else
            typeName=type.Name;
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
        if~isempty(data.Implementation)
            if data.Implementation.isDefined&&...
                ~isa(data.Implementation,'RTW.PointerVariable')&&...
                (isa(data.Implementation,'RTW.Variable')||isa(data.Implementation,'RTW.StructExpression'))
                exprInCode=data.Implementation.getExpression();
            else
                if isa(data.Implementation,'RTW.PointerVariable')&&isa(data.Implementation.TargetVariable,'RTW.Variable')
                    exprInCode=data.Implementation.Identifier;
                elseif isa(data.Implementation,'RTW.Variable')
                    exprInCode=data.Implementation.Identifier;
                else

                end
            end
        end

        if isempty(exprInCode)

            return
        end
        dataInfo=pslink.verifier.Coder.createDataRangeInfoStruct();
        dataType=data.Implementation.Type;
        dataType=pslink.verifier.ec.Coder.getCoderType(dataType);
        if isa(dataType,'embedded.pointertype')
            dataInfo.isPtr=true;

            ptrDataType=data.Type;
            ptrDataType=pslink.verifier.ec.Coder.getCoderType(ptrDataType);
            if isa(ptrDataType,'embedded.matrixtype')
                baseType=ptrDataType;
            else
                baseType=dataType.BaseType;
            end
            dataInfo.width=baseType.getWidth();
        else
            dataInfo.width=dataType.getWidth();
        end
        baseType=pslink.verifier.ec.Coder.getUnderlyingType(dataType);
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
            bottomType=dataType;
            bottomType=pslink.verifier.ec.Coder.getUnderlyingType(bottomType);
            if bottomType.Volatile
                mode='permanent';
            end
        end

        dataInfo.expr=exprInCode;
        dataInfo.min=minVal;
        dataInfo.max=maxVal;
        if isa(data.Implementation,'RTW.Variable')
            dataInfo.sourceFile=data.Implementation.DefinitionFile;
        elseif isa(data.Implementation,'RTW.StructExpression')
            currBaseRegion=data.Implementation.BaseRegion;
            while~isempty(currBaseRegion.findprop('BaseRegion'))
                currBaseRegion=currBaseRegion.BaseRegion;
            end
            if~isempty(currBaseRegion.findprop('DefinitionFile'))
                dataInfo.sourceFile=currBaseRegion.DefinitionFile;
            else
                return
            end
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
        if~isprop(effectiveArg,'FromModel')||~effectiveArg.FromModel
            argInfo.isExtraData=true;
        else
            minVal=[];
            maxVal=[];
            if isprop(effectiveArg,'MinMax')
                minVal=effectiveArg.MinMax{1};
                maxVal=effectiveArg.MinMax{2};
            end
            if isprop(effectiveArg,'isFullDataTypeRange')
                argInfo.isFullDataTypeRange=effectiveArg.isFullDataTypeRange;
            end
            argInfo.min=minVal;
            argInfo.max=maxVal;
        end
        dataType=pslink.verifier.ec.Coder.getCoderType(formalArg.Type);

        if isa(dataType,'embedded.pointertype')
            argInfo.isPtr=true;
            baseType=dataType.BaseType;
            argInfo.width=baseType.getWidth();
        elseif isa(dataType,'embedded.opaquetype')
            argInfo.isPtr=true;
            argInfo.width=dataType.getWidth();
        elseif isa(dataType,'embedded.matrixtype')&&(dataType.getWidth()>1)
            argInfo.isPtr=true;
            argInfo.width=dataType.getWidth();
        else
            argInfo.isPtr=dataType.isPointer;
            argInfo.width=dataType.getWidth();
        end
        baseType=pslink.verifier.ec.Coder.getUnderlyingType(formalArg.Type);
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


    function nComputeSpecifiedMinMax(data)
        if isprop(data,'SLObj')&&~isempty(data.SLObj)&&~strcmpi(data.SLObj.slWorkspaceType,'none')


            minVal=data.SLObj.Min;
            maxVal=data.SLObj.Max;
            if isempty(minVal)||isempty(maxVal)
                minVal=data.BlkMinMax{1};
                maxVal=data.BlkMinMax{2};
            end

        else

            minVal=data.BlkMinMax{1};
            maxVal=data.BlkMinMax{2};
        end

        if~isempty(data.Implementation)
            data.MinMax=pslink.verifier.ec.Coder.computeDataMinMax(data,data.Implementation.Type,minVal,maxVal);
        else

            data.MinMax={[],[]};
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
            bottomType=pslink.verifier.ec.Coder.getUnderlyingType(sE.Type);
            if isa(bottomType,'embedded.structtype')
                infoCell=nExtractFieldInfo(data,bottomType,fullName,isForAutosar);
            else
                fMinVal=[];
                fMaxVal=[];
                if~isempty(bE)&&isprop(bE,'Min')&&isprop(bE,'Max')&&(isForAutosar||self.inputFullRange==false)
                    fMinVal=bE.Min;
                    fMaxVal=bE.Max;
                end
                infoCell={fullName,pslink.verifier.ec.Coder.computeDataMinMax(data,sE.Type,fMinVal,fMaxVal)};
            end
            fieldInfo=[fieldInfo;infoCell];%#ok<AGROW>
        end
    end

end




