classdef DataObjectValidator<autosar.validation.PhasedValidator




    properties(Access=private)
        CalibPortMap;
    end

    methods(Access=public)
        function this=DataObjectValidator(modelHandle)
            this@autosar.validation.PhasedValidator('ModelHandle',modelHandle);
        end
    end

    methods(Access=protected)

        function verifyPostProp(this,hModel)
            this.CalibPortMap=containers.Map;


            this.verifyCalPrms(hModel);
            this.verifyInternalCalPrms(hModel);
            this.verifyConstantMemoryPrms(hModel);
            this.verifyStaticMemorySignals(hModel);
            this.verifyDSMPIMs(hModel);
            this.verifyStateSignalObj(hModel);
            this.verifyLookupTables(hModel);
        end
    end

    methods(Access=public)
        function shortNames=getInternalDataMappedToNames(this,hModel)
            shortNames={};
            modelMapping=autosar.api.Utils.modelMapping(hModel);
            maxShortNameLength=get_param(hModel,'AutosarMaxShortNameLength');

            for ii=1:numel(modelMapping.Signals)
                signal=modelMapping.Signals(ii);
                mappedTo=signal.MappedTo;
                if~isempty(mappedTo)
                    if~strcmp(mappedTo.ArDataRole,'Auto')
                        shortName=mappedTo.getPerInstancePropertyValue('ShortName');
                        if~isempty(shortName)
                            [isValid,errmsg,errId]=autosarcore.checkIdentifier(shortName,'shortName',maxShortNameLength);
                            if~isValid
                                error(errId,errmsg);
                            end
                            shortNames=[shortNames,shortName];%#ok<AGROW>
                        end
                    end
                end
            end

            for ii=1:numel(modelMapping.States)
                state=modelMapping.States(ii);
                mappedTo=state.MappedTo;
                if~isempty(mappedTo)
                    if~strcmp(mappedTo.ArDataRole,'Auto')
                        shortName=mappedTo.getPerInstancePropertyValue('ShortName');
                        if~isempty(shortName)
                            [isValid,errmsg,errId]=autosarcore.checkIdentifier(shortName,'shortName',maxShortNameLength);
                            if~isValid
                                error(errId,errmsg);
                            end
                            shortNames=[shortNames,shortName];%#ok<AGROW>
                        end
                    end
                end
            end

            for ii=1:numel(modelMapping.DataStores)
                dsm=modelMapping.DataStores(ii);
                mappedTo=dsm.MappedTo;
                if~isempty(mappedTo)
                    if~strcmp(mappedTo.ArDataRole,'Auto')
                        shortName=mappedTo.getPerInstancePropertyValue('ShortName');
                        if~isempty(shortName)
                            [isValid,errmsg,errId]=autosarcore.checkIdentifier(shortName,'shortName',maxShortNameLength);
                            if~isValid
                                error(errId,errmsg);
                            end
                            shortNames=[shortNames,shortName];%#ok<AGROW>
                        end
                    end
                end
            end

            for ii=1:numel(modelMapping.SynthesizedDataStores)
                synthDS=modelMapping.SynthesizedDataStores(ii);
                mappedTo=synthDS.MappedTo;
                if~isempty(mappedTo)
                    if~strcmp(mappedTo.ArDataRole,'Auto')
                        shortName=mappedTo.getPerInstancePropertyValue('ShortName');
                        if~isempty(shortName)
                            [isValid,errmsg,errId]=autosarcore.checkIdentifier(shortName,'shortName',maxShortNameLength);
                            if~isValid
                                error(errId,errmsg);
                            end
                            shortNames=[shortNames,shortName];%#ok<AGROW>
                        end
                    end
                end
            end

            for ii=1:numel(modelMapping.ModelScopedParameters)
                param=modelMapping.ModelScopedParameters(ii);
                mappedTo=param.MappedTo;
                if~isempty(mappedTo)
                    if~strcmp(mappedTo.ArDataRole,'Auto')
                        paramGraphicalName=param.Parameter;
                        [paramObjExists,paramObj]=autosar.utils.Workspace.objectExistsInModelScope(hModel,paramGraphicalName);

                        if paramObjExists
                            this.validateLookupTableParamObj(...
                            paramObj,paramGraphicalName,mappedTo.ArDataRole,hModel);
                        end

                        shortName=mappedTo.getPerInstancePropertyValue('ShortName');
                        if~isempty(shortName)
                            [isValid,errmsg,errId]=autosarcore.checkIdentifier(shortName,'shortName',maxShortNameLength);
                            if~isValid
                                error(errId,errmsg);
                            end
                            shortNames=[shortNames,shortName];%#ok<AGROW>
                        end
                    end
                end
            end
        end

        function validateLookupTableParamObj(this,paramObj,paramGraphicalName,arDataRole,hModel)

            if isa(paramObj,'Simulink.LookupTable')
                this.verifyLUTObject(paramObj,paramGraphicalName,arDataRole,hModel);
            elseif isa(paramObj,'Simulink.Breakpoint')
                autosar.validation.DataObjectValidator.verifyBreakpointObject(paramObj,paramGraphicalName,arDataRole,hModel);
            end
        end

    end

    methods(Access=private)
        function verifyStaticMemorySignals(this,hModel)



            cs=getActiveConfigSet(hModel);
            maxShortNameLength=get_param(cs,'AutosarMaxShortNameLength');
            supportMatrixIOAsArray=strcmpi(...
            get_param(cs,'AutosarMatrixIOAsArray'),'on');

            [vars,identifiers]=autosar.validation.DataObjectValidator.getReferencedStaticMemoryVars(hModel);
            for i=1:length(vars)
                identifier=identifiers{i};
                prefix=DAStudio.message('RTW:autosar:staticMemory',identifier);

                this.AutosarUtilsValidator.checkDataType(prefix,vars(i).obj.DataType,maxShortNameLength,supportMatrixIOAsArray);

                idcheckmessage=autosar.validation.AutosarUtils.isValidIdentifier({identifier},'shortName',maxShortNameLength);
                if~isempty(idcheckmessage)
                    msg=DAStudio.message('RTW:autosar:staticMemory',idcheckmessage);
                    autosar.validation.Validator.logError('RTW:fcnClass:finish',msg);
                end
                autosar.validation.DataObjectValidator.verifyDisplayFormat(prefix,vars(i).obj);
            end
        end

        function verifyDSMPIMs(this,hModel)



            cs=getActiveConfigSet(hModel);
            maxShortNameLength=get_param(cs,'AutosarMaxShortNameLength');
            supportMatrixIOAsArray=strcmpi(...
            get_param(cs,'AutosarMatrixIOAsArray'),'on');

            [vars,identifiers]=autosar.validation.DataObjectValidator.getReferencedDSMPIMs(hModel);
            for i=1:length(vars)
                identifier=identifiers{i};

                this.AutosarUtilsValidator.checkDataType(['PerInstanceMemory ',identifier],...
                vars(i).obj.DataType,maxShortNameLength,...
                supportMatrixIOAsArray);

                idcheckmessage=autosar.validation.AutosarUtils.isValidIdentifier({identifier},'shortName',maxShortNameLength);
                if~isempty(idcheckmessage)
                    msg=DAStudio.message('RTW:autosar:perInstanceMemory',identifier,idcheckmessage);
                    autosar.validation.Validator.logError('RTW:fcnClass:finish',msg);
                end
                autosar.validation.DataObjectValidator.verifyDisplayFormat(['PerInstanceMemory ',identifier],vars(i).obj);
            end
        end

        function verifyInternalCalPrms(this,hModel)



            cs=getActiveConfigSet(hModel);
            maxShortNameLength=get_param(cs,'AutosarMaxShortNameLength');
            supportMatrixIOAsArray=strcmpi(...
            get_param(cs,'AutosarMatrixIOAsArray'),'on');

            [vars,identifiers]=autosar.validation.DataObjectValidator.getReferencedInternalCalPrms(hModel);
            for i=1:length(vars)
                identifier=identifiers{i};
                prefix=DAStudio.message('RTW:autosar:internalCalPrm',identifier);
                if strcmpi(vars(i).obj.DataType,'struct')
                    autosar.mm.util.MessageReporter.createWarning('RTW:autosar:calPrmHasAnonymousStructType',vars(i).objName);
                end
                this.AutosarUtilsValidator.checkDataType(prefix,vars(i).obj.DataType,maxShortNameLength,supportMatrixIOAsArray);

                idcheckmessage=autosar.validation.AutosarUtils.isValidIdentifier({identifier},'shortName',maxShortNameLength);
                if~isempty(idcheckmessage)
                    msg=DAStudio.message('RTW:autosar:internalCalPrm',idcheckmessage);
                    autosar.validation.Validator.logError('RTW:fcnClass:finish',msg);
                end
                autosar.validation.DataObjectValidator.verifyDisplayFormat(prefix,vars(i).obj);
            end
        end

        function verifyConstantMemoryPrms(this,hModel)



            cs=getActiveConfigSet(hModel);
            maxShortNameLength=get_param(cs,'AutosarMaxShortNameLength');
            supportMatrixIOAsArray=strcmpi(...
            get_param(cs,'AutosarMatrixIOAsArray'),'on');

            [vars,identifiers]=autosar.validation.DataObjectValidator.getReferencedConstantMemoryParams(hModel);
            for i=1:length(vars)
                if isa(vars(i).obj,'Simulink.Parameter')
                    identifier=identifiers{i};
                    prefix=DAStudio.message('autosarstandard:validation:constantMemory',identifier);
                    if strcmpi(vars(i).obj.DataType,'struct')
                        autosar.mm.util.MessageReporter.createWarning('RTW:autosar:calPrmHasAnonymousStructType',vars(i).objName);
                    end

                    this.AutosarUtilsValidator.checkDataType(prefix,vars(i).obj.DataType,maxShortNameLength,supportMatrixIOAsArray);

                    idcheckmessage=autosar.validation.AutosarUtils.isValidIdentifier({identifier},'shortName',maxShortNameLength);
                    if~isempty(idcheckmessage)
                        msg=DAStudio.message('autosarstandard:validation:constantMemory',idcheckmessage);
                        autosar.validation.Validator.logError('RTW:fcnClass:finish',msg);
                    end
                    autosar.validation.DataObjectValidator.verifyDisplayFormat(prefix,vars(i).obj);
                elseif(isa(vars(i).obj,'Simulink.LookupTable')||isa(vars(i).obj,'Simulink.Breakpoint'))
                    this.validateLookupTableParamObj(...
                    vars(i).obj,vars(i).objName,'ConstantMemory',hModel);
                else
                    assert(false,sprintf('Unexpected constant memory parameter %s of type %s',...
                    vars(i).objName,class(vars(i).obj)));
                end
            end
        end

        function verifyLUTObject(this,lutObj,paramName,arDataRole,hModel)
            assert(isa(lutObj,'Simulink.LookupTable'),'expect Simulink.LookupTable object');

            if lutObj.AllowMultipleInstancesOfTypeToHaveDifferentTableBreakpointSizes
                autosar.validation.Validator.logError('autosarstandard:validation:VariableSizeLookupTablesNotSupported',paramName);
            end


            if~strcmp(lutObj.BreakpointsSpecification,'Reference')
                autosar.validation.DataObjectValidator.verifyLUTObjStructTypeInfo(...
                lutObj,paramName,arDataRole,hModel);


                supportMatrixIO=strcmpi(...
                get_param(hModel,'AutosarMatrixIOAsArray'),'on')||...
                strcmpi(get_param(hModel,'ArrayLayout'),'row-major');

                breakpoints=lutObj.Breakpoints;
                for i=1:length(breakpoints)
                    bp=breakpoints(i);
                    identifier=sprintf('Breakpoint %s for object %s',bp.FieldName,paramName);
                    maxShortNameLength=get_param(hModel,'AutosarMaxShortNameLength');
                    this.AutosarUtilsValidator.checkDataType(identifier,...
                    bp.DataType,maxShortNameLength,supportMatrixIO);
                end
            end
        end
    end

    methods(Static,Access=public)

        function dsmPIMNames=getDSMPIMNames(hModel)
            [~,dsmPIMNames]=autosar.validation.DataObjectValidator.getReferencedDSMPIMs(hModel);
        end

        function internalCalPrmNames=getInternalCalPrmNames(hModel)
            [~,internalCalPrmNames]=autosar.validation.DataObjectValidator.getReferencedInternalCalPrms(hModel);
        end

        function constMemPrmNames=getConstMemoryPrmNames(hModel)
            [~,constMemPrmNames]=autosar.validation.DataObjectValidator.getReferencedConstantMemoryParams(hModel);
        end

        function staticMemoryVarNames=getStaticMemoryVarNames(hModel)
            [~,staticMemoryVarNames]=autosar.validation.DataObjectValidator.getReferencedStaticMemoryVars(hModel);
        end

        function verifyBreakpointObject(bpObj,paramName,arDataRole,hModel)
            assert(isa(bpObj,'Simulink.Breakpoint'),'expect Simulink.Breakpoint object');
            autosar.validation.DataObjectValidator.verifyLUTObjStructTypeInfo(bpObj,...
            paramName,arDataRole,hModel);
        end

    end

    methods(Access=private)
        function verifyCalPrms(this,hModel)



            cs=getActiveConfigSet(hModel);
            maxShortNameLength=get_param(cs,'AutosarMaxShortNameLength');
            supportMatrixIOAsArray=strcmpi(...
            get_param(cs,'AutosarMatrixIOAsArray'),'on');


            vars=autosar.validation.CompiledModelUtils.getReferencedWSVars(hModel);
            calibComponents=cell(length(vars),0);
            calibInterfaces=cell(length(vars),0);
            calibInterfacePkgs=cell(length(vars),0);
            calibComponentPkgs=cell(length(vars),0);

            nonParamRPortNames={};
            if autosar.api.Utils.isMapped(hModel)
                m3iComp=autosar.api.Utils.m3iMappedComponent(hModel);


                nonParamRPorts=m3i.filter(@(obj)~isa(obj,'Simulink.metamodel.arplatform.port.ParameterReceiverPort'),m3iComp.Port);
                nonParamRPortNames=cellfun(@(obj)obj.Name,nonParamRPorts,'UniformOutput',false);
            end

            if~isempty(vars)
                portParamApiMap=autosar.validation.DataObjectValidator.createPortParamApiMap(hModel);
            end

            for i=1:length(vars)
                obj=vars(i).obj;
                objName=vars(i).objName;


                if(...
                    (isa(obj,'AUTOSAR.Parameter')&&...
                    strcmp(vars(i).obj.CoderInfo.StorageClass,'Custom')&&...
                    strcmp(obj.CoderInfo.CustomStorageClass,'CalPrm'))...
                    ||...
                    (isa(vars(i).obj,'Simulink.Parameter')&&...
                    strcmp(vars(i).obj.CoderInfo.StorageClass,'Custom')&&...
                    isa(vars(i).obj.CoderInfo.CustomAttributes,'SimulinkCSC.AttribClass_AUTOSAR_CalPrm'))...
                    )
                    attr=obj.CoderInfo.CustomAttributes;
                    if strcmpi(vars(i).obj.DataType,'struct')
                        autosar.mm.util.MessageReporter.createWarning('RTW:autosar:calPrmHasAnonymousStructType',vars(i).objName);
                    end

                    this.AutosarUtilsValidator.checkDataType(['CalPrm ',objName],vars(i).obj.DataType,maxShortNameLength,supportMatrixIOAsArray);


                    idcheckmessage=autosar.validation.AutosarUtils.isValidIdentifier({attr.PortName},'shortName',maxShortNameLength);
                    if~isempty(idcheckmessage)
                        msg=DAStudio.message('RTW:autosar:externalCalPrm',objName,'PortName',idcheckmessage);
                        autosar.validation.Validator.logError('RTW:fcnClass:finish',msg);
                    end


                    idcheckmessage=autosar.validation.AutosarUtils.isValidIdentifier({attr.ElementName},'shortName',maxShortNameLength);
                    if~isempty(idcheckmessage)
                        msg=DAStudio.message('RTW:autosar:externalCalPrm',objName,'ElementName',idcheckmessage);
                        autosar.validation.Validator.logError('RTW:fcnClass:finish',msg);
                    end


                    idcheckmessage=autosar.validation.AutosarUtils.isValidIdentifier({attr.InterfacePath},'absPathShortName',maxShortNameLength);
                    if~isempty(idcheckmessage)
                        msg=DAStudio.message('RTW:autosar:externalCalPrm',objName,'InterfacePath',idcheckmessage);
                        autosar.validation.Validator.logError('RTW:fcnClass:finish',msg);
                    end
                    if~strcmp(attr.InterfacePath,'UNDEFINED')
                        calibInterfaces{i}=attr.InterfacePath;
                        [package,~]=autosar.mm.sl2mm.ModelBuilder.getNodePathAndName(attr.InterfacePath);
                        calibInterfacePkgs{i}=package;
                    end
                    if~isempty(attr.CalibrationComponent)
                        calibComponents{i}=attr.CalibrationComponent;
                        [package,~]=autosar.mm.sl2mm.ModelBuilder.getNodePathAndName(attr.CalibrationComponent);
                        calibComponentPkgs{i}=package;
                    end


                    if~isempty(attr.CalibrationComponent)||~isempty(attr.ProviderPortName)
                        idcheckmessage=autosar.validation.AutosarUtils.isValidIdentifier(...
                        {attr.CalibrationComponent},'absPathShortName',maxShortNameLength);
                        if~isempty(idcheckmessage)
                            msg=DAStudio.message('RTW:autosar:externalCalPrm',objName,...
                            'CalibrationComponent',idcheckmessage);
                            autosar.validation.Validator.logError('RTW:fcnClass:finish',msg);
                        end

                        idcheckmessage=autosar.validation.AutosarUtils.isValidIdentifier(...
                        {attr.ProviderPortName},'shortName',maxShortNameLength);
                        if~isempty(idcheckmessage)
                            msg=DAStudio.message('RTW:autosar:externalCalPrm',objName,...
                            'ProviderPortName',idcheckmessage);
                            autosar.validation.Validator.logError('RTW:fcnClass:finish',msg);
                        end






                        if autosar.api.Utils.isMapped(hModel)
                            m3iModel=autosar.api.Utils.m3iModel(hModel);
                            compObj=autosar.mm.Model.findObjectByName(m3iModel,attr.CalibrationComponent);
                            if~isempty(compObj)&&compObj.size>0

                                compObj=compObj.at(1);
                                if~isa(compObj,'Simulink.metamodel.arplatform.component.ParameterComponent')
                                    msg=DAStudio.message('RTW:autosar:CalPrmProviderComponentConflict',...
                                    attr.CalibrationComponent,objName,attr.CalibrationComponent);
                                    autosar.validation.Validator.logError('RTW:fcnClass:finish',msg);
                                end
                            end
                        end
                    end


                    paramAPI=[attr.PortName,'_',attr.ElementName];
                    if portParamApiMap.isKey(paramAPI)
                        otherParamName=portParamApiMap(paramAPI);
                        autosar.validation.Validator.logError('autosarstandard:validation:duplicatePortParamMapping',...
                        objName,otherParamName,attr.PortName,attr.ElementName);
                    end


                    this.checkCalibPortConflicts('RPort',attr,objName,nonParamRPortNames);


                    if~isempty(attr.ProviderPortName)
                        this.checkCalibPortConflicts('PPort',attr,objName,{});
                    end
                    autosar.validation.DataObjectValidator.verifyDisplayFormat(['CalPrm ',objName],vars(i).obj);
                end
            end
            this.checkPackageClash('Calibration interface',calibInterfacePkgs,'calibration component',calibComponents,vars);
            this.checkPackageClash('Calibration interface',calibInterfacePkgs,'calibration interface',calibInterfaces,vars);
            this.checkPackageClash('Calibration component',calibComponentPkgs,'calibration interface',calibInterfaces,vars);
            this.checkPackageClash('Calibration component',calibComponentPkgs,'calibration component',calibComponents,vars);
            if autosar.api.Utils.isMapped(hModel)
                m3iModel=autosar.api.Utils.m3iModel(hModel);
                for ii=1:numel(calibInterfaces)
                    if~isempty(calibInterfaces{ii})
                        calibInterface=autosar.mm.Model.findObjectByName(m3iModel,calibInterfaces{ii});
                        if calibInterface.size()>0
                            if~isa(calibInterface.at(1),'Simulink.metamodel.arplatform.interface.ParameterInterface')
                                msg=DAStudio.message('autosarstandard:ui:packageClashCalibParamErr',...
                                'calibration interface',objName,attr.InterfacePath);
                                autosar.validation.Validator.logError('RTW:fcnClass:finish',msg);
                            end
                        end
                    end
                end
            end
        end

        function verifyLookupTables(this,hModel)

            if autosar.api.Utils.isMapped(hModel)
                modelMapping=autosar.api.Utils.modelMapping(hModel);
                m3iComp=autosar.api.Utils.m3iMappedComponent(hModel);

                nonParamRPorts=m3i.filter(@(x)~isa(x,'Simulink.metamodel.arplatform.port.ParameterReceiverPort'),m3iComp.Port);
                nonParamRPortNames=cellfun(@(x)x.Name,nonParamRPorts,'UniformOutput',false);
                for ii=1:numel(modelMapping.LookupTables)
                    SLLut=modelMapping.LookupTables(ii);
                    if strcmp(SLLut.MappedTo.ParameterAccessMode,'PortParameter')&&...
                        ~isempty(SLLut.MappedTo.Port)&&~isempty(SLLut.MappedTo.Parameter)
                        m3iPort=Simulink.metamodel.arplatform.ModelFinder.findNamedItemInSequence(...
                        m3iComp,m3iComp.ParameterReceiverPorts,SLLut.MappedTo.Port,...
                        'Simulink.metamodel.arplatform.port.ParameterReceiverPort');
                        assert(m3iPort.isvalid(),'Invalid Parameter Receiver Port: %s.',SLLut.MappedTo.Port);
                        attr=SimulinkCSC.AttribClass_AUTOSAR_CalPrm;
                        attr.PortName=SLLut.MappedTo.Port;
                        attr.InterfacePath=autosar.api.Utils.getQualifiedName(m3iPort.Interface);
                        attr.ElementName=SLLut.MappedTo.Parameter;




                        this.checkCalibPortConflicts('RPort',attr,SLLut.MappedTo.Parameter,nonParamRPortNames);
                    end
                end
            end
        end

        function checkPackageClash(this,pkgType,pkgs,qType,qNames,vars)%#ok<INUSL>
            [indexSet1,indexSet2]=autosar.mm.util.findAmbigousPkgElementNames(...
            pkgs,qNames);
            if~isempty(indexSet1)&&~isempty(indexSet2)
                if indexSet1{1}==indexSet2{1}
                    msg=DAStudio.message('autosarstandard:ui:packageClashCalibParamErr',...
                    [qType,' ',qNames{indexSet2{1}}],vars(indexSet2{1}).objName,...
                    pkgType);
                else
                    msg=DAStudio.message('autosarstandard:ui:packageClashWithOtherCalibParamErr',...
                    [qType,' ',qNames{indexSet2{1}}],vars(indexSet2{1}).objName,...
                    pkgType,vars(indexSet1{1}).objName);
                end
                autosar.validation.Validator.logError('RTW:fcnClass:finish',msg);
            end
        end

        function checkCalibPortConflicts(this,portType,attr,objName,excPortNames)



            switch(portType)
            case 'RPort'
                portName=attr.PortName;

                if any(strcmp(portName,excPortNames))
                    autosar.validation.Validator.logError('RTW:autosar:errorDuplicatePort',portName);
                end


            case 'PPort'
                portName=[attr.CalibrationComponent,'/',attr.ProviderPortName];
            otherwise
                assert(false,'Unexpected portType "%s".',portType);
            end

            objNameMsg=DAStudio.message('RTW:autosar:workspaceVariable',objName);
            if~(this.CalibPortMap.isKey(portName))

                this.CalibPortMap(portName)=struct(...
                'interfacePath',attr.interfacePath,...
                'elementName',attr.elementName,...
                'objNameMsg',objNameMsg);


                autosar.validation.AutosarUtils.checkShortNameCaseClash(...
                this.CalibPortMap.keys);
            else

                if~strcmp(attr.interfacePath,this.CalibPortMap(portName).interfacePath)
                    msg=DAStudio.message('RTW:autosar:portHasDuplicateInterfacePath',...
                    portName,objNameMsg,attr.interfacePath,...
                    this.CalibPortMap(portName).interfacePath,...
                    this.CalibPortMap(portName).objNameMsg);
                    autosar.validation.Validator.logError('RTW:fcnClass:finish',msg);
                end


                if strcmp(attr.elementName,this.CalibPortMap(portName).elementName)
                    autosar.validation.Validator.logError('autosarstandard:validation:calprmDuplicateDataElement',...
                    attr.elementName,portName,objNameMsg,...
                    this.CalibPortMap(portName).objNameMsg);
                end

            end
        end
    end
    methods(Static,Access=private)
        function verifyDisplayFormat(identifier,obj)
            if isa(obj,'AUTOSAR.Signal')||isa(obj,'AUTOSAR.Parameter')
                if~isempty(obj.DisplayFormat)
                    [isValid,msg]=autosar.validation.AutosarUtils.checkDisplayFormat(obj.DisplayFormat,identifier);
                    if~isValid
                        autosar.validation.Validator.logError('RTW:fcnClass:finish',msg);
                    end
                end
            end
        end

        function verifyStateSignalObj(hModel)





            modelName=get_param(hModel,'Name');
            modelObj=get_param(modelName,'Object');
            stateOwnerBlkObjs=find(modelObj,'IsStateOwnerBlock','on');
            if isempty(stateOwnerBlkObjs)
                return
            end

            for blkIdx=1:numel(stateOwnerBlkObjs)
                stateOnwerBlkHandle=get(stateOwnerBlkObjs(blkIdx),'handle');


                if~isfield(get_param(stateOnwerBlkHandle,'DialogParameters'),'StateName')
                    continue;
                end
                stateName=get_param(stateOnwerBlkHandle,'StateName');
                if isempty(stateName)

                    continue;
                end


                if isfield(get_param(stateOnwerBlkHandle,'DialogParameters'),'StateMustResolveToSignalObject')&&...
                    strcmp(get_param(stateOnwerBlkHandle,'StateMustResolveToSignalObject'),'on')
                    [~,dataObj]=autosar.utils.Workspace.objectExistsInModelScope(modelName,stateName);
                else
                    dataObj=get_param(stateOnwerBlkHandle,'StateSignalObject');
                end
                if isempty(dataObj)

                    continue;
                end

                isPIM_CSC=isa(dataObj,'AUTOSAR.Signal')&&...
                dataObj.getIsAutosarPerInstanceMemory();
                isPIM_CSC2=isa(dataObj,'Simulink.Signal')&&...
                strcmp(dataObj.CoderInfo.StorageClass,'Custom')&&...
                isa(dataObj.CoderInfo.CustomAttributes,'SimulinkCSC.AttribClass_AUTOSAR_PerInstanceMemory');
                if isPIM_CSC||isPIM_CSC2
                    autosar.validation.Validator.logError('autosarstandard:validation:StateWithPimCSC',getfullname(stateOnwerBlkHandle));
                end
            end
        end







        function[dsmPimVars,dsmPimVarNames]=getReferencedDSMPIMs(hModel)




            dsmPimVars=[];
            dsmPimVarNames={};

            vars=autosar.validation.CompiledModelUtils.getReferencedWSVars(hModel);
            for i=1:length(vars)
                if((isa(vars(i).obj,'AUTOSAR.Signal')&&...
                    vars(i).obj.getIsAutosarPerInstanceMemory())...
                    ||...
                    (isa(vars(i).obj,'Simulink.Signal')&&strcmp(vars(i).obj.CoderInfo.StorageClass,'Custom')&&isa(vars(i).obj.CoderInfo.CustomAttributes,'SimulinkCSC.AttribClass_AUTOSAR_PerInstanceMemory')))

                    if~isempty(vars(i).obj.CoderInfo.Identifier)
                        identifier=vars(i).obj.CoderInfo.Identifier;
                    else
                        identifier=vars(i).objName;
                    end

                    if isempty(dsmPimVars)
                        dsmPimVars=vars(i);
                    else
                        dsmPimVars(end+1)=vars(i);%#ok<AGROW>
                    end
                    dsmPimVarNames{end+1}=identifier;%#ok<AGROW>
                end

            end

        end

        function[internalCalPrmVars,internalCalPrmNames]=getReferencedInternalCalPrms(hModel)




            internalCalPrmVars=[];
            internalCalPrmNames={};

            vars=autosar.validation.CompiledModelUtils.getReferencedWSVars(hModel);
            for i=1:length(vars)
                if(...
                    (isa(vars(i).obj,'AUTOSAR.Parameter')&&...
                    strcmp(vars(i).obj.CoderInfo.StorageClass,'Custom')&&...
                    strcmp(vars(i).obj.CoderInfo.CustomStorageClass,'InternalCalPrm'))...
                    ||...
                    (isa(vars(i).obj,'Simulink.Parameter')&&...
                    strcmp(vars(i).obj.CoderInfo.StorageClass,'Custom')&&...
                    isa(vars(i).obj.CoderInfo.CustomAttributes,'SimulinkCSC.AttribClass_AUTOSAR_InternalCalPrm'))...
                    )

                    if~isempty(vars(i).obj.CoderInfo.Identifier)
                        identifier=vars(i).obj.CoderInfo.Identifier;
                    else
                        identifier=vars(i).objName;
                    end

                    if isempty(internalCalPrmVars)
                        internalCalPrmVars=vars(i);
                    else
                        internalCalPrmVars(end+1)=vars(i);%#ok<AGROW>
                    end
                    internalCalPrmNames{end+1}=identifier;%#ok<AGROW>
                end
            end
        end

        function[constMemPrmVars,constMemNames]=getReferencedConstantMemoryParams(hModel)




            constMemPrmVars=[];
            constMemNames={};
            vars=autosar.validation.CompiledModelUtils.getReferencedWSVars(hModel);
            modelName=get_param(hModel,'Name');
            for i=1:length(vars)
                if(isa(vars(i).obj,'Simulink.Parameter')||isa(vars(i).obj,'Simulink.LookupTable')||...
                    isa(vars(i).obj,'Simulink.Breakpoint'))&&...
                    autosar.mm.util.getIsAutosarConstantMemory(modelName,vars(i).objName)

                    if~isempty(vars(i).obj.CoderInfo.Identifier)
                        identifier=vars(i).obj.CoderInfo.Identifier;
                    else
                        identifier=vars(i).objName;
                    end

                    if isempty(constMemPrmVars)
                        constMemPrmVars=vars(i);
                    else
                        constMemPrmVars(end+1)=vars(i);%#ok<AGROW>
                    end
                    constMemNames{end+1}=identifier;%#ok<AGROW>
                end
            end
        end

        function[staticMemSignalVars,staticMemNames]=getReferencedStaticMemoryVars(hModel)




            staticMemSignalVars=[];
            staticMemNames={};
            modelName=get_param(hModel,'Name');
            vars=autosar.validation.CompiledModelUtils.getReferencedWSVars(hModel);
            for i=1:length(vars)
                if(isa(vars(i).obj,'Simulink.Signal')&&autosar.mm.util.getIsAutosarStaticMemory(modelName,vars(i).objName))

                    if~isempty(vars(i).obj.CoderInfo.Identifier)
                        identifier=vars(i).obj.CoderInfo.Identifier;
                    else
                        identifier=vars(i).objName;
                    end

                    if isempty(staticMemSignalVars)
                        staticMemSignalVars=vars(i);
                    else
                        staticMemSignalVars(end+1)=vars(i);%#ok<AGROW>
                    end
                    staticMemNames{end+1}=identifier;%#ok<AGROW>
                end
            end
        end

        function portParamApiMap=createPortParamApiMap(hModel)


            portParamApiMap=containers.Map();
            mapping=autosar.api.Utils.modelMapping(hModel);
            for i=1:length(mapping.ModelScopedParameters)
                parameterMapping=mapping.ModelScopedParameters(i);
                paramName=parameterMapping.Parameter;
                arDataRole=parameterMapping.MappedTo.ArDataRole;
                if strcmp(arDataRole,'PortParameter')
                    arParamPortName=parameterMapping.MappedTo.getPerInstancePropertyValue('Port');
                    arParamDataElementName=parameterMapping.MappedTo.getPerInstancePropertyValue('DataElement');
                    paramAPI=[arParamPortName,'_',arParamDataElementName];

                    portParamApiMap(paramAPI)=paramName;
                end
            end
        end

        function verifyLUTObjStructTypeInfo(lutObj,paramName,arDataRole,hModel)


            dataTypeName=lutObj.StructTypeInfo.Name;
            if~isempty(dataTypeName)
                maxShortNameLength=get_param(hModel,'AutosarMaxShortNameLength');
                if length(dataTypeName)>maxShortNameLength
                    autosar.validation.Validator.logError('RTW:autosar:invalidDataTypeName',...
                    paramName,dataTypeName,maxShortNameLength,maxShortNameLength);
                end


                if~strcmp(arDataRole,'ConstantMemory')



                    if~strcmp(lutObj.StructTypeInfo.HeaderFileName,'Rte_Type.h')
                        autosar.validation.Validator.logError('RTW:autosar:invalidDataTypeHeader',...
                        paramName,dataTypeName);
                    end


                    if strcmp(lutObj.StructTypeInfo.DataScope,'Exported')
                        autosar.validation.Validator.logError('RTW:autosar:invalidDataTypeScope',...
                        paramName,dataTypeName,get_param(hModel,'Name'));
                    end
                end
            end
        end
    end

end



