classdef BuilderBase<handle







    properties(Access=protected)
        Data;

    end
    properties(Access=private)
        ZeroIndexArrayStructElements;



        CalibrationCompilerCachedInfo;
        InstParamMap;

        SIDPathMap;
        PreprocMaxBitsSint;
        PreprocMaxBitsUint;
        SupportLongLong;
    end

    methods(Abstract,Access=public)
        getCoeffsAndConversTypeOfCompuMethod(this);
        isLookupDimensionsSupported(this,dimensions);
    end

    methods(Access=public)



        function this=BuilderBase(modelName)
            this.Data=coder.internal.asap2.Data(modelName);
            this.ZeroIndexArrayStructElements=[];
            this.InstParamMap=containers.Map;
            this.SIDPathMap=containers.Map;
        end

        function data=getData(this)
            data=this.Data;
        end

        function this=buildRecursive(this,codeDescriptor,codeDescRepo,path,modelClassInstanceName,instanceName,instancePath,topModelName,customizeGroups)
            this.Data.CustomizeGroupsByType=customizeGroups;
            bhm=codeDescriptor.getBlockHierarchyMap();
            modelMapping=[];
            if~this.Data.IsAutosarCompliant...
                &&~this.Data.IsCppInterface...
                &&isempty(path)
                modelMapping=Simulink.CodeMapping.get(this.Data.ModelName);
            end
            if isempty(path)


                buildDir=RTW.getBuildDir(this.Data.ModelName);
                binfoMATFile=coderprivate.getBinfoMATFileAndCodeName(buildDir.BuildDirectory);
                tmwInternalFolder=fileparts(binfoMATFile);
                parser=mf.zero.io.XmlParser;
                compileInfo=fullfile(tmwInternalFolder,'CompileInfo.xml');
                parsedFile=parser.parseFile(compileInfo);
                this.CalibrationCompilerCachedInfo=parsedFile.calibrationData;
            end

            if~isempty(bhm)

                refMdlBlks=bhm.getBlocksByType('ModelReference');

            else
                refMdlBlks=[];
            end

            for ii=1:length(refMdlBlks)
                refMdlBlk=refMdlBlks(ii);
                refMdlName=refMdlBlk.ReferencedModelName;
                cur_path=[path,refMdlBlk.GraphicalName,'_'];
                refMdl_codeDesc=codeDescriptor.getReferencedModelCodeDescriptor(refMdlName);
                buildDir=RTW.getbuildDir(refMdlName);
                refMdl_codeDescRepo=fullfile(buildDir.CodeGenFolder,buildDir.ModelRefRelativeBuildDir);
                if~isempty(instanceName)
                    ref_instanceName=[instanceName,'_',refMdlName,'_',refMdlBlk.GraphicalName];
                else
                    ref_instanceName=[refMdlBlk.ParentSystemSID,'_',refMdlName,'_',refMdlBlk.GraphicalName];
                end
                ref_instanceName=regexprep(ref_instanceName,'[^a-zA-Z_0-9]','_');
                ref_instancePath=refMdlBlk.Path;


                if this.Data.IsCppInterface||refMdlBlk.DWorks.Size==0
                    if isempty(modelClassInstanceName)&&isempty(refMdlBlk.ModelClassInstanceVariableName)
                        modelClassInstanceNameTemp=[];
                    else
                        modelClassInstanceNameTemp=[modelClassInstanceName,'.',refMdlBlk.ModelClassInstanceVariableName];
                    end
                    this=this.buildRecursive(refMdl_codeDesc,refMdl_codeDescRepo,cur_path,modelClassInstanceNameTemp,ref_instanceName,ref_instancePath,topModelName,customizeGroups);
                else

                    if isempty(path)

                        varName=refMdlBlk.DWorks(1).Implementation.assumeOwnershipAndGetExpression;
                    else



                        if(count(refMdlBlk.DWorks(1).Implementation.assumeOwnershipAndGetExpression,'.')>1)








                            varName=eraseBetween(refMdlBlk.DWorks(1).Implementation.assumeOwnershipAndGetExpression,1,'.');
                        else
                            varName=refMdlBlk.DWorks(1).Implementation.assumeOwnershipAndGetExpression;
                        end
                    end

                    varName=[modelClassInstanceName,varName];
                    this=this.buildRecursive(refMdl_codeDesc,refMdl_codeDescRepo,cur_path,varName,ref_instanceName,ref_instancePath,topModelName,customizeGroups);
                end
            end


            this=this.build(codeDescriptor,codeDescRepo,modelClassInstanceName,path,modelMapping,instanceName,instancePath,topModelName);
        end
    end

    methods(Access=private)



        function this=build(this,codeDescriptor,codeDescRepo,modelClassInstanceName,path,modelMapping,instanceName,instancePath,topModelName)
            this.Data.ModelName=codeDescriptor.ModelName;
            codeDescriptor=coder.getCodeDescriptor(codeDescRepo,247362);
            compInterface=codeDescriptor.getComponentInterface;
            if~isempty(compInterface)
                if Simulink.CodeMapping.isSLRealTimeCompliant(topModelName)




                    this.Data.PeriodicEventList=coder.internal.xcp.a2l.slrealtime.PeriodicEventList(codeDescriptor);
                else
                    this.Data.PeriodicEventList=coder.internal.xcp.a2l.PeriodicEventList(compInterface);
                end
            end
            modelRepo=codeDescriptor.getMF0FullModel;
            this.PreprocMaxBitsSint=modelRepo.CoderAssumptions.CoderConfig.PreprocMaxBitsSint;
            this.PreprocMaxBitsUint=modelRepo.CoderAssumptions.CoderConfig.PreprocMaxBitsUint;
            this.SupportLongLong=modelRepo.CoderAssumptions.CoderConfig.LongLongMode;
            if strcmp(codeDescriptor.getArrayLayout,'Column-major')
                this.Data.ArrayLayout='COLUMN_DIR';
            else
                this.Data.ArrayLayout='ROW_DIR';
            end
            if~this.Data.IsAutosarCompliant...
                &&~this.Data.IsCppInterface
                cacheInfoArray=this.CalibrationCompilerCachedInfo.toArray;
                for cacheInfo=cacheInfoArray
                    if strcmp(cacheInfo.ModelName,this.Data.ModelName)&&...
                        ~isempty(cacheInfo)
                        if~isempty(cacheInfo.Parameters)
                            paramMappings=jsondecode(cacheInfo.Parameters);

                            for ii=1:numel(paramMappings)
                                parameterMapping=paramMappings(ii);
                                if~isempty(parameterMapping.Profile)
                                    parameterMapping.Profile=jsondecode(parameterMapping.Profile);
                                end

                                this.Data.CalibrationValuesCache(parameterMapping.Name)=parameterMapping;
                            end
                        end
                        if~isempty(cacheInfo.InternalData)
                            internalDataMappings=jsondecode(cacheInfo.InternalData);
                            for ii=1:numel(internalDataMappings)
                                internalDataMapping=internalDataMappings(ii);
                                if~isempty(internalDataMapping.Profile)
                                    internalDataMapping.Profile=jsondecode(internalDataMapping.Profile);
                                end
                                internalDataMapping.IsIO=false;
                                this.Data.MeasurementValuesCache(internalDataMapping.Name)=internalDataMapping;
                            end

                        end
                        if~isempty(cacheInfo.RootIOData)
                            ioDataMappings=jsondecode(cacheInfo.RootIOData);
                            for ii=1:numel(ioDataMappings)
                                ioDataMapping=ioDataMappings(ii);
                                if~isempty(ioDataMapping.Profile)
                                    ioDataMapping.Profile=jsondecode(ioDataMapping.Profile);
                                    ioDataMapping.IsIO=true;
                                    this.Data.MeasurementValuesCache(ioDataMapping.Name)=ioDataMapping;
                                end
                            end

                        end
                    end
                end
            end
            this.Data.CategoryToObjectsMap('SCALAR')=struct('Characteristics','','Measurements','');
            this.Data.CategoryToObjectsMap('ARRAY')=struct('Characteristics','','Measurements','');


            signals=codeDescriptor.getDataInterfaces('InternalData');
            for k=1:numel(signals)
                signal=signals(k);
                signalImpl=signal.Implementation;
                if~coder.internal.asap2.Utils.isExportableObject(signalImpl,this.Data.SupportStructureElements,this.Data.IncludeAUTOSARElements)
                    continue;
                end
                [signalVariableName,~,className]=coder.internal.asap2.Utils.getVariableInfo(signal);
                sigName=signal.GraphicalName;

                if~isempty(signalVariableName)
                    this.getStereotypeProperties(sigName,'Measurement');
                    this.updateAdditionalCalibrationAttributes(sigName);
                    exportToA2lFile=this.Data.AdditionalCalibrationAttributesValues.export;
                    if~exportToA2lFile
                        continue;
                    end
                    signalVariableName=coder.internal.asap2.Utils.getFullyQualifiedVariableName(signal,modelClassInstanceName);
                    interface='Signals';
                    this.buildObjectInfo(interface,className,modelClassInstanceName,signalVariableName,signal.Implementation,signal,modelRepo,path,false);
                end
            end


            globalDataStores=codeDescriptor.getDataInterfaces('GlobalDataStores');
            sharedDataStores=codeDescriptor.getDataInterfaces('SharedLocalDataStores');
            dataStores=[globalDataStores,sharedDataStores];

            for kk=1:numel(dataStores)
                dataStore=dataStores(kk);
                dataStoreImpl=dataStore.Implementation;
                if~coder.internal.asap2.Utils.isExportableObject(dataStoreImpl,this.Data.SupportStructureElements,this.Data.IncludeAUTOSARElements)
                    continue;
                end
                [dataStoreVariableName,~,className]=coder.internal.asap2.Utils.getVariableInfo(dataStore);
                dataStoreName=dataStore.GraphicalName;
                this.getStereotypeProperties(dataStoreName,'Measurement');
                this.updateAdditionalCalibrationAttributes(dataStoreName);
                exportToA2lFile=this.Data.AdditionalCalibrationAttributesValues.export;
                if~exportToA2lFile
                    continue;
                end
                if~isempty(dataStoreVariableName)
                    interface='Signals';
                    dataStoreVariableName=coder.internal.asap2.Utils.getFullyQualifiedVariableName(dataStore,modelClassInstanceName);
                    this.buildObjectInfo(interface,className,modelClassInstanceName,dataStoreVariableName,dataStore.Implementation,dataStore,modelRepo,path,false);
                end
            end

            this.Data.Endianess=modelRepo.CoderAssumptions.Assumptions.TargetHardware.Endianess;


            params=codeDescriptor.getDataInterfaces('Parameters');
            this.Data.HWDeviceType=modelRepo.CoderAssumptions.CoderConfig.HWDeviceType;

            bhms=codeDescriptor.getBlockHierarchyMap();

            instanceNames=[];

            parameterGrp=[];
            signalGrp=[];
            paramBuses=[];
            signalBuses=[];
            subSystemsGrp=[];

            if~isempty(bhms)
                subsys=bhms.GraphicalSystems;
                if~isempty(subsys(1))

                    [parameterGrp,signalGrp,paramBuses,signalBuses,instanceNames,subSystemsGrp]=this.getListOfParamsAndSignals(subsys(1),path,modelClassInstanceName,topModelName,instanceName);
                end
            end



            for ii=1:numel(params)
                param=params(ii);
                paramImpl=param.Implementation;
                if~coder.internal.asap2.Utils.isExportableObject(paramImpl,this.Data.SupportStructureElements,this.Data.IncludeAUTOSARElements)
                    continue;
                end
                this.getStereotypeProperties(param.GraphicalName,'Characteristic');
                this.updateAdditionalCalibrationAttributes(param.GraphicalName);
                exportToA2lFile=this.Data.AdditionalCalibrationAttributesValues.export;
                if~exportToA2lFile
                    continue;
                end
                if~isempty(paramImpl)
                    paramNameFromGraphicalName=split(param.GraphicalName,':');
                    paramNameFromGraphicalName=split(paramNameFromGraphicalName{end},'.');
                    if slfeature('BreakpointsAsModelArguments')==1


                        [paramVariableName,~,className]=coder.internal.asap2.Utils.getVariableInfo(param);
                        if isempty(paramVariableName)
                            continue;
                        end



                        if isa(paramImpl,'coder.descriptor.StructExpression')
                            if~isa(param.Implementation.BaseRegion,'coder.descriptor.Variable')
                                getinstanceName=strsplit(param.Implementation.BaseRegion.ElementIdentifier,'_');
                            else
                                getinstanceName=strsplit(param.Implementation.ElementIdentifier,'_');
                            end
                            name=[getinstanceName{end},'_',paramNameFromGraphicalName{end}];
                        else
                            name=paramNameFromGraphicalName{end};
                        end

                        if this.InstParamMap.isKey(paramNameFromGraphicalName{end})



                            instParamMapValues=this.InstParamMap(paramNameFromGraphicalName{end});
                            if instParamMapValues.IsArgument
                                instParamMapValues.AliasName=paramVariableName;
                                this.InstParamMap(name)=instParamMapValues;
                            end
                        end
                    end
                    if isa(paramImpl,'coder.descriptor.Variable')||isa(paramImpl,'coder.descriptor.AutosarCalibration')
                        if coder.internal.asap2.Utils.isAutosarRTEElement(paramImpl)
                            paramName=coder.internal.asap2.Utils.getAutosarVariableinfo(param);
                        else
                            paramName=paramImpl.Identifier;
                        end

                        sharedName='';
                        aliasName='';
                        modelParam=modelRepo.getModelParameterByName(paramName);

                        if~isempty(modelParam)&&...
                            ~isempty(modelParam.GraphicalReferences)&&...
                            strcmp(modelParam.GraphicalReferences(1).Type,'PreLookup')
                            isSupported=this.updateCommonAxesMap(modelParam,codeDescriptor,modelRepo,sharedName,aliasName);
                            if~isSupported
                                continue;
                            end
                        end
                    end
                    if param.isLookupTableDataInterface
                        this.Data.LutWithParamObj{end+1}=coder.internal.asap2.Utils.getVariableInfo(param);
                    end
                end
            end
            for ii=1:numel(params)
                param=params(ii);
                paramImpl=param.Implementation;
                if~coder.internal.asap2.Utils.isExportableObject(paramImpl,this.Data.SupportStructureElements,this.Data.IncludeAUTOSARElements)
                    continue;
                end
                paramNameFromGraphicalName=split(param.GraphicalName,':');
                paramNameFromGraphicalName=split(paramNameFromGraphicalName{end},'.');
                this.updateAdditionalCalibrationAttributes(param.GraphicalName);
                exportToA2lFile=this.Data.AdditionalCalibrationAttributesValues.export;

                if~exportToA2lFile
                    continue;
                end




                if~isempty(paramImpl)


                    if~isempty(path)
                        if coder.internal.asap2.Utils.isLocalVariable(paramImpl)


                            continue;
                        end
                    end
                    if isa(paramImpl,'coder.descriptor.Variable')
                        paramName=param.Implementation.Identifier;
                    elseif isa(paramImpl,'coder.descriptor.StructExpression')
                        paramName=param.Implementation.ElementIdentifier;

                    elseif isa(paramImpl,'coder.descriptor.CustomExpression')


                        if~isempty(param.Implementation.ExprOwner)
                            paramName=param.Implementation.ReadExpression;
                        end
                    elseif coder.internal.asap2.Utils.isAutosarRTEElement(paramImpl)
                        paramName=coder.internal.asap2.Utils.getVariableInfo(param);
                    end
                    if this.Data.ParametersMap.isKey(paramName)&&~param.isLookupTableDataInterface


                        continue;
                    elseif param.isLookupTableDataInterface



                        LUTInfo.shortName=paramName;
                        LUTInfo.bpSpec=param.BreakpointSpecification;
                        LUTBPInfo.Info='';
                        LUTInfo.breakpoints(1:numel(param.Breakpoints))=LUTBPInfo;
                        for bpIndex=1:numel(param.Breakpoints)

                            if strcmp(param.BreakpointSpecification,'Reference')
                                LUTInfo.breakpoints(bpIndex).Info=param.Breakpoints(bpIndex).GraphicalName;
                            elseif strcmp(param.BreakpointSpecification,'Even spacing')
                                LUTInfo.breakpoints(bpIndex).Info=param.Breakpoints(bpIndex).FixAxisMetadata;
                                if isa(param.Breakpoints(bpIndex).FixAxisMetadata,'coder.descriptor.NonEvenSpacingMetadata')
                                    LUTInfo.breakpoints(bpIndex).Info=num2str(param.Breakpoints(bpIndex).FixAxisMetadata.AllPoints.toArray);
                                elseif isa(param.Breakpoints(bpIndex).FixAxisMetadata,'coder.descriptor.EvenSpacingMetadata')
                                    evenSpacingVals(1:param.Breakpoints(bpIndex).FixAxisMetadata.NumPoints)=0;
                                    evenSpacingVals(1)=param.Breakpoints(bpIndex).FixAxisMetadata.StartingValue;
                                    if param.Breakpoints(bpIndex).FixAxisMetadata.IsPow2
                                        spacing=pow2(param.Breakpoints(bpIndex).FixAxisMetadata.StepValue);
                                    else
                                        spacing=param.Breakpoints(bpIndex).FixAxisMetadata.StepValue;
                                    end
                                    for esmid=2:param.Breakpoints(bpIndex).FixAxisMetadata.NumPoints
                                        evenSpacingVals(esmid)=evenSpacingVals(esmid-1)+spacing;
                                    end
                                    LUTInfo.breakpoints(bpIndex).Info=num2str(evenSpacingVals);
                                else
                                    continue;
                                end
                            end
                        end

                        if this.Data.LUTInfoMap.isKey(paramName)
                            dupLUTInfo=this.Data.LUTInfoMap(paramName);
                            matched=true;
                            if strcmp(LUTInfo.bpSpec,dupLUTInfo.bpSpec)&&numel(LUTInfo.breakpoints)==numel(dupLUTInfo.breakpoints)
                                for bid=1:numel(LUTInfo.breakpoints)
                                    if~strcmp(LUTInfo.breakpoints(bid).Info,dupLUTInfo.breakpoints(bid).Info)
                                        matched=false;
                                        break;
                                    end
                                end
                            else
                                matched=false;
                            end
                            if~matched
                                fprintf("%s is used to configure multiple lookup tables which has conflicting breakpoints."+...
                                " Hence %s is described only once.\n",param.GraphicalName,param.GraphicalName);
                            end
                            continue;
                        else
                            this.Data.LUTInfoMap(paramName)=LUTInfo;
                        end
                    end
                    if~isempty(paramImpl.Type)
                        if paramImpl.Type.isMatrix
                            paramType=paramImpl.Type.BaseType;
                        else
                            paramType=paramImpl.Type;
                        end
                    end
                    isMultiWord=this.isDataTypeMultiWord(paramType);

                    toProcessLutFromBottomModel=false;
                    isMdlargument=false;
                    lutFromReferenced='';
                    [paramVariableName,~,className]=coder.internal.asap2.Utils.getVariableInfo(param);
                    if isempty(paramVariableName)
                        continue;
                    end

                    if this.InstParamMap.isKey(paramNameFromGraphicalName{end})

                        instParamMapValues=this.InstParamMap(paramNameFromGraphicalName{end});
                        instParam=instParamMapValues.Name;
                        if instParamMapValues.IsArgument
                            isMdlargument=true;
                        end
                        modelRef=instParamMapValues.ReferenceModel;
                        if strcmp(codeDescriptor.ModelName,modelRef)
                            codedescRefMdl=codeDescriptor;
                        else
                            codedescRefMdl=codeDescriptor.getReferencedModelCodeDescriptor(modelRef);
                        end
                        paramrefs=codedescRefMdl.getDataInterfaces('Parameters');
                        for jj=1:numel(paramrefs)
                            paramref=paramrefs(jj);
                            if strcmp(paramref.GraphicalName,instParam)...
                                &&isa(paramref,'coder.descriptor.LookupTableDataInterface')
                                lutFromReferenced=paramref;
                            end
                        end
                        if~isempty(lutFromReferenced)
                            param=lutFromReferenced;
                            toProcessLutFromBottomModel=true;

                            if~strcmp(param.BreakpointSpecification,'Explicit values')&&isMdlargument











                                if slfeature('BreakpointsAsModelArguments')==1
                                    if~strcmp(param.BreakpointSpecification,'Reference')
                                        continue;
                                    end
                                else
                                    continue;
                                end


                            end
                        end
                        if~isMdlargument&&~toProcessLutFromBottomModel&&(isa(paramImpl,'coder.descriptor.StructExpression')...
                            ||isa(paramType,'coder.descriptor.types.Struct'))
                            if~isa(param.Implementation.BaseRegion,'coder.descriptor.Variable')
                                getinstanceName=strsplit(param.Implementation.BaseRegion.ElementIdentifier,'_');

                                existingInstanceGrpName=[codedescRefMdl.ModelName,'_',getinstanceName{end}];
                            else
                                getinstanceName=strsplit(param.Implementation.ElementIdentifier,'_');
                                existingInstanceGrpName=[codedescRefMdl.ModelName,'_',getinstanceName{1}];
                            end
                            if this.Data.GroupsMap.isKey(existingInstanceGrpName)
                                values=this.Data.GroupsMap(existingInstanceGrpName);
                                values.SubSysParams{end+1}=paramVariableName;
                                this.Data.GroupsMap(existingInstanceGrpName)=values;
                            end

                        elseif isMdlargument&&toProcessLutFromBottomModel...
                            &&(isempty(parameterGrp)||~any(contains(parameterGrp,paramVariableName)))


                            parameterGrp{end+1}=paramVariableName;
                        end
                    end
                    if this.Data.CommonAxesMap.isKey(paramNameFromGraphicalName{end})&&...
                        isempty(this.Data.CommonAxesMap(paramNameFromGraphicalName{end}).SharedAxis)
                        continue;
                    end
                    if~toProcessLutFromBottomModel&&(isa(paramImpl,'coder.descriptor.StructExpression')...
                        ||isa(paramType,'coder.descriptor.types.Struct')||isMultiWord)
                        if~isempty(paramVariableName)



                            interface='Params';
                            paramVariableName=coder.internal.asap2.Utils.getFullyQualifiedVariableName(param,modelClassInstanceName);
                            this.buildObjectInfo(interface,className,modelClassInstanceName,paramVariableName,param.Implementation,param,modelRepo,path,false);
                            continue;
                        end
                    end
                    paramType=param.Implementation.Type;
                    if isempty(paramType)
                        paramType=param.Type;
                    end
                    longIdentifier=coder.internal.asap2.Utils.getLongIdentifierParam(modelRepo,paramName,param);
                    matrixDims=[];
                    width='';

                    if isa(param,'coder.descriptor.LookupTableDataInterface')
                        if~this.isLookupDimensionsSupported(param.Breakpoints.Size)
                            continue;
                        else
                            lutFieldsAsSeparateElems=false;

                            if strcmp(param.BreakpointSpecification,'Explicit values')
                                lutFieldsAsSeparateElems=this.updateLutRecordLayoutInfo('',paramName,paramType.BaseType,param,modelClassInstanceName,modelRepo,paramVariableName);
                                isSupported=true;

                            elseif strcmp(param.BreakpointSpecification,'Reference')
                                isSupported=this.updateCommonAxisLutInfo(param,modelClassInstanceName,modelRepo,paramVariableName);
                            elseif strcmp(param.BreakpointSpecification,'Even spacing')
                                [isSupported,lutFieldsAsSeparateElems]=this.updateFixAxisLutInfo(param,modelClassInstanceName,modelRepo,paramVariableName);
                            end
                            if lutFieldsAsSeparateElems
                                interface='Params';
                                this.buildObjectInfo(interface,className,modelClassInstanceName,paramVariableName,param.Implementation,param,modelRepo,path,true);
                                break;
                            end
                            if~isSupported
                                continue;
                            end
                        end

                    elseif isa(paramType.BaseType,'coder.descriptor.types.Struct')
                        this.updateGroupsMap(paramName,'',paramName,paramType.BaseType,param);
                    else
                        if isa(paramType.BaseType,'coder.descriptor.types.Complex')
                            continue;
                        end
                        [aliasName,~,isSupported]=this.updateRecordLayoutsMap('',paramType.BaseType);
                        if~isSupported
                            this.Data.ObjectsWithInvalidDataType{end+1}=paramName;
                            continue;
                        end
                        cmName=this.updateCompuMethodsMap(paramType.BaseType,param);

                        category='VALUE';
                        if~isa(paramType,'coder.descriptor.types.Pointer')
                            if isempty(paramType.CompileTimeDimensions.toArray)
                                dimension=paramType.Dimensions;
                            else
                                dimension=paramType.CompileTimeDimensions;
                            end
                            [width,matrixDims]=coder.internal.asap2.Utils.getWidthFromDimension(dimension);
                        end

                        if(width>1)
                            category='VAL_BLK';
                        end
                        ecuAddress=['0x0000 /* @ECU_Address@',paramName,'@ */'];
                        dataTypeBaseType=paramType.BaseType;



                        [lowerLimit,upperLimit]=this.getMinMaxValues(param,dataTypeBaseType,this.Data.ModelName);
                        if~isempty(this.Data.AdditionalCalibrationAttributesValues)&&...
                            ~isempty(this.Data.AdditionalCalibrationAttributesValues.bitMask)

                            if dataTypeBaseType.isEnum...
                                ||(~dataTypeBaseType.isFixed&&~dataTypeBaseType.isInteger&&~dataTypeBaseType.isBoolean)


                                this.Data.ObjectsWithInvalDataTypeForBitmask{end+1}=param.GraphicalName;
                            end
                        end
                        categoryToObjectsMapValues=[];
                        categoryToObjectsMapClass='';
                        if strcmp(category,'VALUE')
                            categoryToObjectsMapClass='SCALAR';
                            categoryToObjectsMapValues=this.Data.CategoryToObjectsMap('SCALAR');
                        elseif strcmp(category,'VAL_BLK')
                            categoryToObjectsMapClass='ARRAY';
                            categoryToObjectsMapValues=this.Data.CategoryToObjectsMap('ARRAY');
                        end

                        if~isempty(categoryToObjectsMapValues)
                            if any(strcmp(categoryToObjectsMapClass,this.Data.CustomizeGroupsByType))&&(strcmp('SCALAR',categoryToObjectsMapClass)||strcmp('ARRAY',categoryToObjectsMapClass))
                                categoryToObjectsMapValues.Characteristics{end+1}=paramName;
                                this.Data.CategoryToObjectsMap(categoryToObjectsMapClass)=categoryToObjectsMapValues;
                            end
                        end
                        this.Data.ParametersMap(paramName)=struct('GraphicalName',param.GraphicalName,'LongIdentifier',longIdentifier,...
                        'Type',category,'EcuAddress',ecuAddress,'RecordLayout',aliasName,...
                        'CompuMethodName',cmName,'LowerLimit',lowerLimit,...
                        'UpperLimit',upperLimit,'Width',width,'Dimensions',matrixDims,'EcuAddressComment','',...
                        'Export',this.Data.AdditionalCalibrationAttributesValues.export,...
                        'CalibrationAccess',this.Data.AdditionalCalibrationAttributesValues.calibrationAccess,...
                        'DisplayIdentifier',this.Data.AdditionalCalibrationAttributesValues.displayIdentifier,...
                        'Format',this.Data.AdditionalCalibrationAttributesValues.format,...
                        'BitMask',this.Data.AdditionalCalibrationAttributesValues.bitMask,...
                        'EcuAddressExtension',double.empty...
                        );
                    end
                end
            end

            if isempty(path)
                if~this.Data.IsCppInterface
                    inports=codeDescriptor.getDataInterfaces('Inports');
                    for k=1:numel(inports)
                        port=inports(k);
                        portImpl=port.Implementation;
                        if isempty(portImpl)...
                            ||~coder.internal.asap2.Utils.isExportableObject(portImpl,this.Data.SupportStructureElements,this.Data.IncludeAUTOSARElements)

                            continue;
                        end
                        this.getStereotypeProperties(port.GraphicalName,'Measurement');
                        this.updateAdditionalCalibrationAttributes(port.GraphicalName);
                        exportToA2lFile=this.Data.AdditionalCalibrationAttributesValues.export;

                        if~exportToA2lFile
                            continue;
                        end


                        if isa(port.Implementation,'coder.descriptor.CustomExpression')


                            if~isempty(port.Implementation.ExprOwner)
                                signalVariableName=port.Implementation.ReadExpression;
                            end
                        else
                            [signalVariableName,~,~]=coder.internal.asap2.Utils.getVariableInfo(port);
                        end

                        if~isempty(signalVariableName)
                            interface='Port';
                            signalVariableName=coder.internal.asap2.Utils.getFullyQualifiedVariableName(port,[]);
                            this.buildObjectInfo(interface,[],[],signalVariableName,port.Implementation,port,modelRepo,path,false);

                        end
                    end
                    outports=codeDescriptor.getDataInterfaces('Outports');

                    for k=1:numel(outports)
                        port=outports(k);
                        portImpl=port.Implementation;
                        if isempty(portImpl)...
                            ||~coder.internal.asap2.Utils.isExportableObject(portImpl,this.Data.SupportStructureElements,this.Data.IncludeAUTOSARElements)

                            continue;
                        end
                        this.getStereotypeProperties(port.GraphicalName,'Measurement');
                        this.updateAdditionalCalibrationAttributes(port.GraphicalName);
                        exportToA2lFile=this.Data.AdditionalCalibrationAttributesValues.export;

                        if~exportToA2lFile
                            continue;
                        end
                        if isa(port.Implementation,'coder.descriptor.CustomExpression')


                            if~isempty(port.Implementation.ExprOwner)
                                signalVariableName=port.Implementation.WriteExpression;
                            end
                        else
                            [signalVariableName,~,~]=coder.internal.asap2.Utils.getVariableInfo(port);
                        end

                        if~isempty(signalVariableName)
                            interface='Port';
                            signalVariableName=coder.internal.asap2.Utils.getFullyQualifiedVariableName(port,[]);
                            this.buildObjectInfo(interface,[],[],signalVariableName,port.Implementation,port,modelRepo,path,false);
                        end
                    end
                end
            end
            if slfeature('RTEElementsInASAP2')==1&&this.Data.IsAutosarSTF&&this.Data.IncludeAUTOSARElements
                irvs=codeDescriptor.getFullComponentInterface.InternalData;
                for i=1:irvs.Size()
                    irv=irvs(i);
                    if isa(irv.Implementation,'coder.descriptor.AutosarInterRunnable')
                        signalVariableName=coder.internal.asap2.Utils.getFullyQualifiedVariableName(irv,[]);
                        signalGrp{end+1}=signalVariableName;
                        this.buildObjectInfo('Signals',[],[],signalVariableName,irv.Implementation,irv,modelRepo,path,false);
                    end
                end
            end
            if strcmp(this.Data.ModelName,topModelName)
                this.Data.GroupsMap(this.Data.ModelName)=struct('LongIdentifier',this.Data.ModelName,'Params',{parameterGrp},'Signals',{signalGrp});
                this.Data.SubGroupsMap(this.Data.ModelName)=struct('ParamBuses',{paramBuses},'SignalsBuses',{signalBuses},'Instances',{instanceNames},'SubSystems',{subSystemsGrp});
            end
            if~isempty(instanceName)&&~this.Data.GroupsMap.isKey(instanceName)
                if~isempty(parameterGrp)||~isempty(signalGrp)||~isempty(instanceNames)||~isempty(subSystemsGrp)
                    this.Data.GroupsMap(instanceName)=struct('LongIdentifier',instancePath,'SubSysParams',{parameterGrp},'SubSysSignals',{signalGrp});
                    this.Data.SubGroupsMap(instanceName)=struct('Instances',{instanceNames},'SubSystems',{subSystemsGrp});
                end
            end
            coder.internal.asap2.Utils.validateProfileAttributes(this.Data.CompuMethodValidationMap,this.Data.ObjectsWithInvalDataTypeForBitmask);




            if slfeature('FunctionDescriptionInCalibration')==1
                compInterfaces=codeDescriptor.getFullComponentInterface;
                arrSubSystems=compInterfaces.Subsystems;
                for subSystemIndex=1:arrSubSystems.Size

                    arrOutputFunctions=arrSubSystems.at(subSystemIndex).OutputFunctions;
                    for functionIndex=1:arrOutputFunctions.Size
                        outputFunction=arrOutputFunctions.at(functionIndex);

                        arrInMeasurements=strings(outputFunction.Prototype.NumInputs,0);
                        for argsIndex=1:outputFunction.Prototype.NumInputs
                            currentArg=outputFunction.ActualArgs(argsIndex);


                            if isempty(currentArg.SID())||isempty(currentArg.GraphicalName())
                                continue;
                            end


                            if isa(currentArg.Implementation,'coder.descriptor.Literal')
                                continue;
                            end
                            if~coder.internal.asap2.Utils.isExportableObject(currentArg.Implementation,this.Data.SupportStructureElements,...
                                this.Data.IncludeAUTOSARElements)
                                continue;
                            end
                            [~,~,className]=coder.internal.asap2.Utils.getVariableInfo(currentArg);
                            paramName=coder.internal.asap2.Utils.getFullyQualifiedVariableName(currentArg,modelClassInstanceName);
                            signalIdentifier=this.buildObjectInfo('Function',className,modelClassInstanceName,paramName,currentArg.Implementation,currentArg,modelRepo,path,false);
                            if this.Data.SignalsMap.isKey(signalIdentifier)
                                arrInMeasurements(argsIndex)=signalIdentifier;
                            end
                        end


                        arrOutMeasurements=strings(numel(outputFunction.ActualReturn),0);
                        for returnIndex=1:numel(outputFunction.ActualReturn)
                            outArg=outputFunction.ActualReturn(returnIndex);
                            if~coder.internal.asap2.Utils.isExportableObject(outArg.Implementation,this.Data.SupportStructureElements,...
                                this.Data.IncludeAUTOSARElements)
                                continue;
                            end
                            [~,~,className]=coder.internal.asap2.Utils.getVariableInfo(outArg);
                            paramName=coder.internal.asap2.Utils.getFullyQualifiedVariableName(outArg,modelClassInstanceName);
                            signalIdentifier=this.buildObjectInfo('Function',className,modelClassInstanceName,paramName,outArg.Implementation,outArg,modelRepo,path,false);
                            if this.Data.SignalsMap.isKey(signalIdentifier)
                                arrOutMeasurements(argsIndex)=signalIdentifier;
                            end
                        end

                        functionName=outputFunction.Prototype.Name;
                        if~isempty(arrInMeasurements)||~isempty(arrOutMeasurements)
                            this.Data.FunctionMap(functionName)=coder.asap2.Function(...
                            functionName,...
                            char.empty,...
                            functionVersion=char.empty,...
                            annotation=char.empty,...
                            inMeasurements=arrInMeasurements,...
                            outMeasurements=arrOutMeasurements,...
                            locMeasurements=strings(1,0),...
                            defCharacteristics=strings(1,0),...
                            refCharacteristics=strings(1,0),...
                            subFunctions=strings(1,0)...
                            );
                        end
                    end
                end
            end

        end


        function[cmName,format]=updateCompuMethodsMap(this,dataTypeBaseType,param,varargin)
            ASAP2NumberFormat='%0.6';
            coeffs=[];
            userCompuMethodName='';
            elements={};
            if this.Data.AdditionalCalibrationAttributesMap.isKey(param.GraphicalName)
                userCompuMethodName=this.Data.AdditionalCalibrationAttributesMap(param.GraphicalName).compuMethodName;
            end
            if~isempty(varargin)
                unit=varargin{1};
            else
                unit=param.Unit;
            end
            format='';
            dualScaleCompuMethodName='';
            isDualScaledParam=false;
            if this.Data.CalibrationValuesCache.isKey(param.GraphicalName)
                if~isempty(this.Data.CalibrationValuesCache(param.GraphicalName).DualScaledParamProperty)
                    dualScaleProps=jsondecode(this.Data.CalibrationValuesCache(param.GraphicalName).DualScaledParamProperty);
                    cmLongID=dualScaleProps.Description;
                    coeffs=str2num(dualScaleProps.Coefficient);
                    dualScaleCompuMethodName=dualScaleProps.CompuMethodName;
                    unit=dualScaleProps.Unit;
                    conversionType='RAT_FUNC';
                    format=ASAP2NumberFormat;
                    isDualScaledParam=true;
                end
            end
            if~isempty(userCompuMethodName)
                cmName=userCompuMethodName;
            elseif~isempty(dualScaleCompuMethodName)
                cmName=dualScaleCompuMethodName;
            else
                if~ischar(dataTypeBaseType)
                    cmName=[this.Data.ModelName,'_',getCompuMethodName(dataTypeBaseType.Name,unit)];
                else
                    cmName=[this.Data.ModelName,'_',getCompuMethodName(dataTypeBaseType,unit)];
                end
            end

            isKeyCompuMethodMap=this.Data.CompuMethodsMap.isKey(cmName);
            if isKeyCompuMethodMap
                isValid=true;
                values=this.Data.CompuMethodsMap(cmName);

                if~strcmp(values.DataType,dataTypeBaseType.Name)||~strcmp(values.Units,unit)
                    isValid=false;
                end
                if~isValid
                    conflictingElements={};
                    if this.Data.CompuMethodValidationMap.isKey(cmName)
                        cmNameValues=this.Data.CompuMethodValidationMap(cmName);
                        if~any(strcmp(cmNameValues.ConflictingElements,param.GraphicalName))
                            conflictingElements=cmNameValues.ConflictingElements;
                            conflictingElements{end+1}=param.GraphicalName;
                        end
                    else
                        if~strcmp(values.GraphicalName,param.GraphicalName)
                            conflictingElements={values.GraphicalName,param.GraphicalName};
                        end
                    end

                    if~isempty(conflictingElements)
                        this.Data.CompuMethodValidationMap(cmName)=struct('ConflictingElements',{conflictingElements});
                    end
                else
                    values.Elements{end+1}=param.GraphicalName;
                    this.Data.CompuMethodsMap(cmName)=values;
                end
                format=values.Format;
                return;
            else
                elements{end+1}=param.GraphicalName;
            end
            if~isDualScaledParam
                switch class(dataTypeBaseType)

                case{'coder.descriptor.types.Fixed','coder.types.Fixed'}
                    format=this.getCompuMethodFormat(dataTypeBaseType.Name);
                    if strcmp(format,'customformat')
                        format=ASAP2NumberFormat;
                    end
                    if(dataTypeBaseType.Bias==0)
                        [conversionType,coeffs]=this.getCoeffsAndConversTypeOfCompuMethod(1,0);
                        cmLongID='Q = V';
                    else
                        if dataTypeBaseType.Bias>0.0
                            str=sprintf([ASAP2NumberFormat,'f'],dataTypeBaseType.Bias);
                            cmLongID=['Q = (V-',str,')'];
                        else
                            str=sprintf([ASAP2NumberFormat,'f'],dataTypeBaseType.Bias);
                            cmLongID=['Q = (V+',str,')'];
                        end
                    end
                    if dataTypeBaseType.Slope<1
                        [conversionType,coeffs]=this.getCoeffsAndConversTypeOfCompuMethod(dataTypeBaseType.Slope,dataTypeBaseType.Bias);
                        cmLongID=[cmLongID,'*',num2str(1/dataTypeBaseType.Slope,[ASAP2NumberFormat,'f'])];
                    elseif dataTypeBaseType.Slope>1
                        [conversionType,coeffs]=this.getCoeffsAndConversTypeOfCompuMethod(dataTypeBaseType.Slope,dataTypeBaseType.Bias);
                        cmLongID=[cmLongID,'/',num2str(dataTypeBaseType.Slope,[ASAP2NumberFormat,'f'])];
                    else
                        [conversionType,coeffs]=this.getCoeffsAndConversTypeOfCompuMethod(dataTypeBaseType.Slope,dataTypeBaseType.Bias);
                    end
                    cmLongID=['"',cmLongID,'"'];
                case 'coder.descriptor.types.Enum'
                    format=ASAP2NumberFormat;
                    conversionType='TAB_VERB';
                    cmLongID=['"Enumerated data type: ',dataTypeBaseType.Name,'"'];
                    if~isempty(userCompuMethodName)
                        cvTabName=['VTAB_FOR_',userCompuMethodName];
                    else
                        cvTabName=['VTAB_FOR_',this.Data.ModelName,'_',getCompuMethodName(dataTypeBaseType.Name,unit)];
                    end
                    keys=cell(1,dataTypeBaseType.Strings.Size);
                    for ii=1:dataTypeBaseType.Strings.Size()
                        keys{ii}=dataTypeBaseType.Strings.at(ii);
                    end
                    values=cell(1,dataTypeBaseType.Strings.Size);
                    for ii=1:dataTypeBaseType.Values.Size()
                        values{ii}=num2str(dataTypeBaseType.Values.at(ii));
                    end


                    if~this.Data.CompuVtabsMap.isKey(cvTabName)
                        this.Data.CompuVtabsMap(cvTabName)=struct('LongIdentifier',cmLongID,...
                        'ConversionType',conversionType,'Literals',keys,'Values',values);
                    end
                otherwise
                    cmLongID='"Q = V"';
                    [conversionType,coeffs]=this.getCoeffsAndConversTypeOfCompuMethod(1,0);

                    switch class(dataTypeBaseType)
                    case{'coder.descriptor.types.Double','coder.types.Double'}
                        format=getFloatingPointCompuMethodFormat('DOUBLE',unit);

                    case{'coder.descriptor.types.Single','coder.types.Single'}
                        format=getFloatingPointCompuMethodFormat('SINGLE',unit);
                    case 'coder.descriptor.types.Half'
                        format=getFloatingPointCompuMethodFormat('HALF',unit);

                    case{'coder.descriptor.types.Bool','coder.types.Bool'}
                        format='%1.0';

                    case{'coder.descriptor.types.Integer','coder.types.Integer','coder.types.Int'}
                        format=this.getCompuMethodFormat(dataTypeBaseType.Name);
                    end
                end
            end
            if~isempty(dualScaleCompuMethodName)
                cmName=dualScaleCompuMethodName;
            end

            this.Data.CompuMethodsMap(cmName)=struct('Name',cmName,'LongIdentifier',cmLongID,...
            'Format',format,'Units',unit,'Coefficients',coeffs,'ConversionType',conversionType,'DataType',dataTypeBaseType.Name,'GraphicalName',param.GraphicalName,...
            'Elements',{elements});
        end

        function[cmName,format]=updateCustomCompuMethodsMap(this,paramName,cmName,characteristicProps,unit)

            ASAP2NumberFormat='%0.0';
            coeffs=[];
            format=ASAP2NumberFormat;
            conversionType='TAB_VERB';
            cvTabName=['VTAB_FOR_',cmName];
            cmLongID='""';
            codeMapping=coder.mapping.api.get(this.Data.ModelName);
            val=getModelParameter(codeMapping,paramName,characteristicProps);
            splitValues=strsplit(strtrim(val),{'"',','});
            removeSpaces=regexprep(splitValues,'\s','');
            enumValues=splitValues(~cellfun('isempty',removeSpaces));
            noOfEnumValues=numel(enumValues);

            keys=cell(1,noOfEnumValues);
            for ii=1:noOfEnumValues
                keys{ii}=enumValues{ii};
            end

            values=cell(1,noOfEnumValues);
            for ii=1:noOfEnumValues
                values{ii}=num2str(ii-1);
            end



            if~this.Data.CompuVtabsMap.isKey(cvTabName)
                this.Data.CompuVtabsMap(cvTabName)=struct('LongIdentifier',cmLongID,...
                'ConversionType',conversionType,'Literals',keys,'Values',values);
            end


            if~this.Data.CompuMethodsMap.isKey(cmName)
                this.Data.CompuMethodsMap(cmName)=struct('Name',cmName,'LongIdentifier',cmLongID,...
                'Format',format,'Units',unit,'Coefficients',coeffs,...
                'ConversionType',conversionType,'Elements',[]);
            end
        end





        function lutFieldsAsSeparateElems=updateLutRecordLayoutInfo(this,prefix,paramName,paramBaseType,parameter,classObjectName,modelRepo,paramVariableName,varargin)


            if~isempty(varargin)
                isStructuredElement=varargin{1};
            else
                isStructuredElement=false;
            end
            lutFieldsAsSeparateElems=false;
            if~isStructuredElement
                paramName=coder.internal.asap2.Utils.getFullyQualifiedVariableName(parameter,classObjectName);
            end
            if~strcmp(prefix,'')
                paramName=[prefix,'.',paramName];
            end
            this.getStereotypeProperties(paramName,'Characteristic');
            if~isempty(paramVariableName)
                paramName=paramVariableName;
            end
            longIdentifier=coder.internal.asap2.Utils.getLongIdentifierParam(modelRepo,paramName,parameter);
            breakpoints=parameter.Breakpoints;
            elements=paramBaseType.Elements;
            numOfBreakPoints=breakpoints.Size;
            if numOfBreakPoints~=length(elements)-1
                for i=1:numOfBreakPoints
                    if(breakpoints(i).IsTunableBreakPoint)
                        lutFieldsAsSeparateElems=true;
                        return;
                    end
                end
            end
            for ii=1:length(elements)
                baseTypeElement=elements(ii);

                if isa(baseTypeElement.Type,'coder.descriptor.types.Struct')||...
                    isa(baseTypeElement,'coder.descriptor.types.AggregateElement')&&...
                    isa(baseTypeElement.Type,'coder.descriptor.types.Matrix')&&...
                    isa(baseTypeElement.Type.BaseType,'coder.descriptor.types.Struct')


                    if this.SIDPathMap.isKey(parameter.SID)

                        path_lut=this.SIDPathMap(parameter.SID);
                        path_lut=regexprep(path_lut,'\n+',' ');

                        msg=message("RTW:asap2:IncompatibleLUT",path_lut).getString();
                        sldiagviewer.reportWarning(msg,'MessageId','RTW:asap2:IncompatibleLUT');
                    end
                    break;
                else
                    if isStructuredElement
                        numOfBreakPoints=length(elements)-1;
                    end

                    ecuAddress=['0x0000 /* @ECU_Address@',paramName,'@ */'];
                    axisType='STD_AXIS';
                    category=coder.internal.asap2.Utils.getAxisCategory(numOfBreakPoints);


                    if parameter.SupportTunableSize
                        if strcmp(parameter.StructOrder,'SizeBreakpointsTable')
                            index=[numOfBreakPoints+1,(2*(numOfBreakPoints))+1];
                        elseif strcmp(parameter.StructOrder,'SizeTableBreakpoints')
                            index=[(numOfBreakPoints)+2,(numOfBreakPoints)+1];
                        end
                    else
                        if strcmp(parameter.StructOrder,'SizeTableBreakpoints')
                            index=[2,1];
                        else
                            index=[1,numOfBreakPoints+1];
                        end
                    end
                    if isa(elements(index(2)).Type,'coder.descriptor.types.Pointer')




                        return;
                    else
                        elementBaseType=elements(index(2)).Type.BaseType;
                    end
                    if~this.isSupportedDataType(elementBaseType)
                        this.Data.ObjectsWithInvalidDataType{end+1}=paramName;
                        return;
                    end

                    pCmName=this.updateCompuMethodsMap(elementBaseType,parameter,elements(index(2)).Unit);
                    aliasName=paramBaseType.Name;
                    numOfAxisPts=[];
                    axisPts=[];
                    if parameter.SupportTunableSize
                        for i=1:numOfBreakPoints
                            [~,numOfAxisPts{end+1},isSupported]=this.updateRecordLayoutsMap('STDLookup',elements(i).Type);
                            if~isSupported
                                continue;
                            end
                        end
                    end
                    numOfAxisPts=string(numOfAxisPts);
                    for i=index(1):index(1)+numOfBreakPoints-1
                        axisBaseType=elements(i).Type.BaseType;
                        if~this.isSupportedDataType(axisBaseType)
                            this.Data.ObjectsWithInvalidDataType{end+1}=paramName;
                            return;
                        end
                        [~,axisPts{end+1},isSupported]=this.updateRecordLayoutsMap('STDLookup',axisBaseType);
                        if~isSupported
                            continue;
                        end
                    end
                    axisPts=string(axisPts);
                    [~,tDataType,isSupported]=this.updateRecordLayoutsMap('STDLookup',elementBaseType);

                    if isSupported&&~this.Data.LookUpTableRecordLayoutMap.isKey(aliasName)
                        this.Data.LookUpTableRecordLayoutMap(aliasName)=struct('AxisType','STD_AXIS','noOfAxis',numOfBreakPoints,...
                        'axisPtsDataType',axisPts,'NumOfAxisPtsDataType',numOfAxisPts,'tDataType',tDataType,...
                        'SupportTunableSize',parameter.SupportTunableSize,'StructOrder',parameter.StructOrder,'ToggleArrayLayout',false);
                    end
                    dataTypeBaseType=elementBaseType;

                    [pLowerLimit,pUpperLimit]=this.getMinMaxValues(parameter,dataTypeBaseType,this.Data.ModelName,elements(index(2)));
                    noOfAxis=1;
                    for i=index(1):index(1)+numOfBreakPoints-1
                        refToInput='NO_INPUT_QUANTITY';
                        if~this.Data.IsAutosarCompliant

                            if numOfBreakPoints==1
                                bpIndex=noOfAxis;
                            else

                                if noOfAxis<=2
                                    bpIndex=3-noOfAxis;
                                else
                                    bpIndex=noOfAxis;
                                end
                            end
                            operatingPointIndex=noOfAxis;
                        else
                            bpIndex=noOfAxis;

                            if numOfBreakPoints==1
                                operatingPointIndex=noOfAxis;
                            else

                                if noOfAxis<=2
                                    operatingPointIndex=3-noOfAxis;
                                else
                                    operatingPointIndex=noOfAxis;
                                end
                            end
                        end
                        element=elements(i);
                        axisBaseType=element.Type.BaseType;
                        if isempty(element.Type.CompileTimeDimensions.toArray)
                            dimension=element.Type.Dimensions;
                        else
                            dimension=element.Type.CompileTimeDimensions;
                        end
                        name=element.Identifier;
                        [numOfAxisPts,~]=coder.internal.asap2.Utils.getWidthFromDimension(dimension);


                        if isStructuredElement
                            cmName=this.updateCompuMethodsMap(axisBaseType,parameter);
                            [lowerLimit,upperLimit]=this.getMinMaxValues(parameter,axisBaseType,this.Data.ModelName,element);
                        else
                            cmName=this.updateCompuMethodsMap(axisBaseType,parameter.Breakpoints(noOfAxis),element.Unit);
                            breakpoint=parameter.Breakpoints.at(operatingPointIndex);
                            [lowerLimit,upperLimit]=this.getMinMaxValues(breakpoint,axisBaseType,this.Data.ModelName,element);

                            if~isempty(breakpoint.OperatingPoint)&&...
                                ~breakpoint.OperatingPoint.isParameter&&...
                                ~isempty(breakpoint.OperatingPoint.Implementation.assumeOwnershipAndGetExpression)





                                refToInput=coder.internal.asap2.Utils.getReferenceInput(this.Data.IsCppInterface,breakpoint.OperatingPoint,classObjectName);
                            end
                        end
                        axisInfo(bpIndex)=struct('Name',name,'AxisType',axisType,...
                        'InputQuantity',refToInput,'CompuMethodName',cmName,'MaxAxisPoints',num2str(numOfAxisPts),...
                        'LowerLimit',lowerLimit,'UpperLimit',upperLimit,'EcuAddressComment','');
                        noOfAxis=noOfAxis+1;
                    end
                    this.updateCategoryToObjectsMapForLookups(paramName,numOfBreakPoints);


                    if~this.Data.ParametersMap.isKey(paramName)
                        this.Data.ParametersMap(paramName)=struct('GraphicalName',paramName,'LongIdentifier',longIdentifier,...
                        'Type',category,'EcuAddress',ecuAddress,'RecordLayout',aliasName,...
                        'CompuMethodName',pCmName,'LowerLimit',pLowerLimit,'UpperLimit',pUpperLimit,...
                        'AxisInfo',axisInfo,'EcuAddressComment','',...
                        'Export',this.Data.AdditionalCalibrationAttributesValues.export,...
                        'CalibrationAccess',this.Data.AdditionalCalibrationAttributesValues.calibrationAccess,...
                        'DisplayIdentifier',this.Data.AdditionalCalibrationAttributesValues.displayIdentifier,...
                        'Format',this.Data.AdditionalCalibrationAttributesValues.format,...
                        'BitMask',this.Data.AdditionalCalibrationAttributesValues.bitMask,...
                        'EcuAddressExtension',double.empty...
                        );
                    end
                end
            end
        end





        function[aliasName,dataType,isSupported]=updateRecordLayoutsMap(this,prefix,paramBaseType)
            dataType='';
            aliasName='';
            isSupported=true;
            if strcmp(prefix,'')
                prefix='Record';
            end
            isSupported=this.isSupportedDataType(paramBaseType);
            if~isSupported
                return;
            end

            if isa(paramBaseType,'coder.descriptor.types.Double')
                aliasName=[prefix,'_FLOAT64_IEEE'];
                dataType='FLOAT64_IEEE';
                if~this.Data.RecordLayoutsMap.isKey(aliasName)&&~startsWith(prefix,'STD')&&~startsWith(prefix,'COM')
                    this.Data.RecordLayoutsMap(aliasName)='FLOAT64_IEEE';
                end

            elseif isa(paramBaseType,'coder.descriptor.types.Single')
                aliasName=[prefix,'_FLOAT32_IEEE'];
                dataType='FLOAT32_IEEE';
                if~this.Data.RecordLayoutsMap.isKey(aliasName)&&~startsWith(prefix,'STD')&&~startsWith(prefix,'COM')
                    this.Data.RecordLayoutsMap(aliasName)='FLOAT32_IEEE';
                end


            elseif isa(paramBaseType,'coder.descriptor.types.Half')
                isSupported=this.isSupportedDataType(paramBaseType);
                if~isSupported
                    return;
                end
                aliasName=[prefix,'_FLOAT16_IEEE'];
                dataType='FLOAT16_IEEE';
                if~this.Data.RecordLayoutsMap.isKey(aliasName)&&~startsWith(prefix,'STD')&&~startsWith(prefix,'COM')
                    this.Data.RecordLayoutsMap(aliasName)='FLOAT16_IEEE';
                end

            elseif isa(paramBaseType,'coder.descriptor.types.Bool')
                aliasName=[prefix,'_BOOLEAN'];
                dataType='UBYTE';
                if~this.Data.RecordLayoutsMap.isKey(aliasName)&&~startsWith(prefix,'STD')&&~startsWith(prefix,'COM')
                    this.Data.RecordLayoutsMap(aliasName)='UBYTE';
                end

            elseif isa(paramBaseType,'coder.descriptor.types.Integer')...
                ||isa(paramBaseType,'coder.descriptor.types.Fixed')
                if paramBaseType.Signedness
                    dataType='S';
                else
                    dataType='U';
                end
                numBits=paramBaseType.WordLength;
                if isa(paramBaseType,'coder.descriptor.types.Fixed')
                    numBits=coder.internal.asap2.Utils.getNumberBitsForFixedPoint(paramBaseType.WordLength);
                end
                switch numBits
                case 8
                    dataType=[dataType,'BYTE'];
                case 16
                    dataType=[dataType,'WORD'];
                case 32
                    dataType=[dataType,'LONG'];
                case 64
                    if paramBaseType.Signedness
                        dataType='A_INT64';
                    else
                        dataType='A_UINT64';
                    end
                otherwise
                    assert(false,printf('%d is not supported according to asam specifications.',paramBaseType.WordLength));
                end

                aliasName=[prefix,'_',dataType];
                if~this.Data.RecordLayoutsMap.isKey(aliasName)&&~startsWith(prefix,'STD')&&~startsWith(prefix,'COM')
                    this.Data.RecordLayoutsMap(aliasName)=dataType;
                end

            elseif isa(paramBaseType,'coder.descriptor.types.Enum')
                if~isempty(paramBaseType.StorageType)
                    [aliasName,~,isSupported]=this.updateRecordLayoutsMap(prefix,paramBaseType.StorageType);
                    if~isSupported
                        return;
                    end
                else


                    aliasName=[prefix,'_SLONG'];
                    dataType='SLONG';
                    if~this.Data.RecordLayoutsMap.isKey(aliasName)&&~startsWith(prefix,'STD')&&~startsWith(prefix,'COM')
                        this.Data.RecordLayoutsMap(aliasName)=dataType;
                    end
                end
            else
                aliasName='';
                isSupported=this.isSupportedDataType(paramBaseType);
            end
        end






        function updateGroupsMap(this,objGraphicslName,prefix,paramName,paramBaseType,param)


            if~strcmp(prefix,'')
                paramName=[prefix,'.',paramName];
            end
            baseTypeElements=paramBaseType.Elements;

            longIdentifier='';
            width='';
            matrixDims=[];
            params={};
            buses={};
            paramIndex=1;
            busIndex=1;
            for ii=1:baseTypeElements.Size()
                baseTypeElement=baseTypeElements(ii);

                if isa(baseTypeElement.Type,'coder.descriptor.types.Struct')
                    buses{busIndex}=baseTypeElement.Type.Identifier;%#ok<AGROW>
                    busIndex=busIndex+1;
                    this.updateGroupsMap(objGraphicslName,paramName,baseTypeElement.Identifier,baseTypeElement.Type,param);


                elseif isa(baseTypeElement,'coder.descriptor.types.AggregateElement')&&...
                    isa(baseTypeElement.Type,'coder.descriptor.types.Matrix')&&...
                    isa(baseTypeElement.Type.BaseType,'coder.descriptor.types.Struct')
                    buses{busIndex}=baseTypeElement.Identifier;%#ok<AGROW>
                    busIndex=busIndex+1;
                    this.updateGroupsMap(objGraphicslName,paramName,baseTypeElement.Identifier,baseTypeElement.Type.BaseType,param);
                else
                    params{paramIndex}=baseTypeElement.Identifier;%#ok<AGROW>
                    paramIndex=paramIndex+1;
                    modelParamMember=baseTypeElement;
                    if isa(baseTypeElement,'coder.descriptor.types.AggregateElement')&&...
                        isa(baseTypeElement.Type,'coder.descriptor.types.Matrix')
                        dataTypeBaseType=baseTypeElement.Type.BaseType;
                    else
                        dataTypeBaseType=paramBaseType.Elements.at(ii).Type;
                    end

                    if isa(baseTypeElement,'coder.descriptor.types.AggregateElement')&&...
                        isa(baseTypeElement.Type,'coder.descriptor.types.Matrix')&&...
                        ~isa(baseTypeElement.Type.BaseType,'coder.descriptor.types.Matrix')
                        [aliasName,~,isSupported]=this.updateRecordLayoutsMap('',modelParamMember.Type.BaseType);
                        if~isSupported
                            continue;
                        end
                        cmName=this.updateCompuMethodsMap(modelParamMember.Type.BaseType,param);

                        category='VALUE';
                        if isempty(baseTypeElement.Type.CompileTimeDimensions.toArray)
                            dimension=baseTypeElement.Type.Dimensions;
                        else
                            dimension=baseTypeElement.Type.CompileTimeDimensions;
                        end
                        [width,matrixDims]=coder.internal.asap2.Utils.getWidthFromDimension(dimension);

                        if width>1
                            category='VAL_BLK';
                        end




                        object=[];
                        [lowerLimit,upperLimit]=this.getMinMaxValues(object,dataTypeBaseType,this.Data.ModelName,baseTypeElement);

                    elseif~isa(baseTypeElement.Type,'coder.descriptor.types.Matrix')
                        if isa(modelParamMember.Type,'coder.descriptor.types.Complex')
                            continue;
                        end
                        [aliasName,~,isSupported]=this.updateRecordLayoutsMap('',modelParamMember.Type);
                        if~isSupported
                            continue;
                        end
                        cmName=this.updateCompuMethodsMap(modelParamMember.Type,param);
                        category='VALUE';




                        object=[];
                        [lowerLimit,upperLimit]=this.getMinMaxValues(object,dataTypeBaseType,this.Data.ModelName,baseTypeElement);

                    else
                        category='VAL_BLK';
                        modelParamBaseType=modelParamMember.Type.BaseType;
                        [aliasName,~,isSupported]=this.updateRecordLayoutsMap('',modelParamBaseType);
                        if~isSupported
                            continue;
                        end
                        cmName=this.updateCompuMethodsMap(modelParamBaseType,param);
                        if isempty(baseTypeElement.Type.CompileTimeDimensions.toArray)
                            dimension=baseTypeElement.Type.Dimensions;
                        else
                            dimension=baseTypeElement.Type.CompileTimeDimensions;
                        end
                        [width,matrixDims]=coder.internal.asap2.Utils.getWidthFromDimension(dimension);




                        object=[];
                        [lowerLimit,upperLimit]=this.getMinMaxValues(object,dataTypeBaseType,this.Data.ModelName,baseTypeElement);
                    end
                    pName=[paramName,'.',modelParamMember.Identifier];
                    ecuAddress=['0x0000 /* @ECU_Address@',pName,'@ */'];
                    if~this.Data.ParametersMap.isKey(pName)
                        this.Data.ParametersMap(pName)=struct('GraphicalName',objGraphicslName,'LongIdentifier',longIdentifier,...
                        'Type',category,'EcuAddress',ecuAddress,'RecordLayout',aliasName,...
                        'CompuMethodName',cmName,'LowerLimit',lowerLimit,'UpperLimit',upperLimit,'Width',width,'Dimensions',matrixDims,'EcuAddressComment','',...
                        'Export',this.Data.AdditionalCalibrationAttributesValues.export,...
                        'CalibrationAccess',this.Data.AdditionalCalibrationAttributesValues.calibrationAccess,...
                        'DisplayIdentifier',this.Data.AdditionalCalibrationAttributesValues.displayIdentifier,...
                        'Format',this.Data.AdditionalCalibrationAttributesValues.format,...
                        'BitMask',this.Data.AdditionalCalibrationAttributesValues.bitMask,...
                        'EcuAddressExtension',double.empty...
                        );
                    end

                end
            end
            if~this.Data.GroupsMap.isKey(paramName)
                this.Data.GroupsMap(paramName)=struct('LongIdentifier',longIdentifier,'Params',{params});
                this.Data.SubGroupsMap(paramName)=struct('Names',{buses});
            end
        end

        function sName=buildObjectInfo(this,interface,className,classObjectName,objNameRelative,classMemberType,obj,modelRepo,path,lutAsElements)
            longIdentifier='';
            baseTypeElement=classMemberType;
            width='';
            matrixDims=[];
            subString={'.rtb.','.rtdw.'};
            toHaveLutAsElement=lutAsElements;
            isMultiWord=false;
            if isa(baseTypeElement.Type,'coder.descriptor.types.Matrix')
                baseType=baseTypeElement.Type.BaseType;
            else
                baseType=baseTypeElement.Type;
            end
            isMultiWord=this.isDataTypeMultiWord(baseType);

            isSupported=this.isSupportedDataType(baseType);
            if~isSupported
                this.Data.ObjectsWithInvalidDataType{end+1}=objNameRelative;
                return;
            end

            if isa(obj.Implementation.Type,'coder.descriptor.types.Matrix')
                if isempty(obj.Implementation.Type.CompileTimeDimensions.toArray)
                    dimension=obj.Implementation.Type.Dimensions;
                else
                    dimension=obj.Implementation.Type.CompileTimeDimensions;
                end
            else
                dimension=1;
            end
            if isa(obj.Implementation.Type,'coder.descriptor.types.Matrix')...
                &&isa(obj.Implementation.Type.BaseType,'coder.descriptor.types.Struct')...
                &&~contains(objNameRelative,'[')...
                &&coder.internal.asap2.Utils.getWidthFromDimension(dimension)>1




                for i1=0:coder.internal.asap2.Utils.getWidthFromDimension(dimension)-1
                    this.buildObjectInfo(interface,className,classObjectName,...
                    [objNameRelative,'[',num2str(i1),']'],obj.Implementation,obj,modelRepo,path,toHaveLutAsElement);
                end
                codeType=coder.internal.asap2.Utils.getImplementationType(obj.Implementation);
                if this.isUnsupportedVariableType(codeType,obj)
                    return;
                end
                return;
            elseif isa(obj.Implementation,'coder.descriptor.StructExpression')&&...
                (isa(obj.Implementation.BaseRegion,'coder.descriptor.ClassMemberExpression')||...
                isa(obj.Implementation.BaseRegion,'coder.descriptor.StructAccessorVariable')||...
                (isa(obj.Implementation.BaseRegion,'coder.descriptor.StructExpression')...
                &&isa(obj.Implementation.BaseRegion.BaseRegion,'coder.descriptor.ClassMemberExpression')))
                sName=objNameRelative;
                baseRegion=obj.Implementation.BaseRegion;





            elseif~isempty(path)&&~isempty(classObjectName)&&...
                (contains(objNameRelative,subString)||contains(classObjectName,subString))...
                &&(strcmp(interface,'Signals')||strcmp(interface,'Function'))


                str=eraseBetween(objNameRelative,1,'.');
                sName=[classObjectName,str];
                baseRegion=obj.Implementation;
            else
                baseRegion=obj.Implementation;
                sName=objNameRelative;
            end
            if strcmp(interface,'Port')||strcmp(interface,'Signals')
                class='Signals';
            else
                class='Params';
            end
            codeType=coder.internal.asap2.Utils.getImplementationType(obj.Implementation);
            if~isempty(codeType)&&this.isUnsupportedVariableType(codeType,obj)
                return;
            end
            if isa(baseRegion,'coder.descriptor.ClassMemberExpression')
                if isa(baseRegion,'coder.descriptor.StaticMemberExpression')
                    classMemberName=[className,'::',baseRegion.ElementIdentifier];
                else
                    classMemberName=[classObjectName,'.',baseRegion.ElementIdentifier];
                end
                if~this.Data.GroupsMap.isKey(classMemberName)
                    groups={};
                    subGroups={};
                    for ii=1:length(baseRegion.Type.Elements)
                        elem=baseRegion.Type.Elements(ii);
                        if elem.Type.isMatrix
                            elemType=elem.Type.BaseType;
                        else
                            elemType=elem.Type;
                        end
                        if isa(elemType,'coder.descriptor.types.Pointer')
                            continue;
                        end
                        isSupported=this.isSupportedDataType(elemType);
                        if~isSupported
                            continue;
                        end
                        if isa(elemType,'coder.descriptor.types.Struct')
                            subGroups{end+1}=elem.Identifier;%#ok<AGROW>
                        else
                            groups{end+1}=elem.Identifier;%#ok<AGROW>
                        end
                    end
                    this.Data.GroupsMap(classMemberName)=struct('LongIdentifier',longIdentifier,class,{groups});
                    this.Data.SubGroupsMap(classMemberName)=struct('Names',{subGroups});
                end
            end

            if isa(obj.Implementation.Type,'coder.descriptor.types.Complex')
                return;
            end


            if isa(obj,'coder.descriptor.LookupTableDataInterface')&&~lutAsElements
                if~this.isLookupDimensionsSupported(obj.Breakpoints.Size)
                    return;
                else
                    paramVariableName='';

                    if strcmp(obj.BreakpointSpecification,'Explicit values')
                        if isa(obj.Implementation.Type,'coder.descriptor.types.Struct')
                            paramBaseType=obj.Implementation.Type;
                        else
                            paramBaseType=obj.Implementation.Type.BaseType;
                        end
                        if isa(obj.Implementation,'coder.descriptor.Variable')
                            paramName=obj.Implementation.Identifier;
                        elseif isa(obj.Implementation,'coder.descriptor.StructExpression')
                            paramName=obj.Implementation.ElementIdentifier;

                        elseif isa(obj.Implementation,'coder.descriptor.CustomExpression')


                            if~isempty(obj.Implementation.ExprOwner)
                                paramName=obj.Implementation.ReadExpression;
                            end
                        elseif coder.internal.asap2.Utils.isAutosarRTEElement(obj.Implementation)
                            paramName=coder.internal.asap2.Utils.getVariableInfo(obj);
                        end
                        lutFieldsAsSeparateElems=this.updateLutRecordLayoutInfo('',paramName,paramBaseType,obj,classObjectName,modelRepo,paramVariableName);
                        if lutFieldsAsSeparateElems
                            this.buildObjectInfo(interface,className,classObjectName,objNameRelative,obj.Implementation,obj,modelRepo,path,true);
                        end

                    elseif strcmp(obj.BreakpointSpecification,'Reference')
                        isNotSupported=this.updateCommonAxisLutInfo(obj,classObjectName,modelRepo,paramVariableName);
                        if isNotSupported
                            return;
                        end
                    elseif strcmp(obj.BreakpointSpecification,'Even spacing')
                        [isSupported,lutFieldsAsSeparateElems]=this.updateFixAxisLutInfo(obj,classObjectName,modelRepo,paramVariableName);
                        if(~isSupported&&isa(baseTypeElement,'coder.descriptor.StructExpression'))||lutFieldsAsSeparateElems
                            this.buildObjectInfo(interface,className,classObjectName,objNameRelative,obj.Implementation,obj,modelRepo,path,true);
                        end
                    end
                end
            elseif isa(baseTypeElement.Type,'coder.descriptor.types.Opaque')
                return;
            else


                if isa(baseTypeElement,'coder.descriptor.StructExpression')&&...
                    isa(baseTypeElement.BaseRegion,'coder.descriptor.ArrayExpression')
                    return;
                elseif isMultiWord&&isa(codeType,'coder.descriptor.types.Struct')&&~isa(baseTypeElement,'coder.descriptor.types.AggregateElement')&&~lutAsElements
                    groups={};
                    subGroups={};
                    for ii=1:length(codeType.Elements)
                        element=codeType.Elements(ii);
                        type=element.Type;
                        if this.isUnsupportedVariableType(type,obj)
                            continue;
                        end

                        if this.isSupportedDataType(type)
                            if isa(type,'coder.descriptor.types.Struct')
                                subGroups{end+1}=element.Identifier;%#ok<AGROW>
                            else
                                groups{end+1}=element.Identifier;%#ok<AGROW>
                            end
                        end
                        if isa(element.Type,'coder.descriptor.types.Matrix')...
                            &&isa(element.Type.BaseType,'coder.descriptor.types.Struct')

                            this.ZeroIndexArrayStructElements=[];



                            this.buildObjectInfo(interface,className,classObjectName,...
                            [objNameRelative,'.',element.Identifier,'[0]'],element,obj,modelRepo,path,false);
                            this.handleNonZeroArrayIndexStructElements(class,objNameRelative,element);

                        else
                            this.buildObjectInfo(interface,className,classObjectName,[objNameRelative,'.',...
                            element.Identifier],element,obj,modelRepo,path,toHaveLutAsElement);
                        end
                    end
                    this.Data.GroupsMap(sName)=struct('LongIdentifier',longIdentifier,class,{groups});
                    this.Data.SubGroupsMap(sName)=struct('Names',{subGroups});
                    return;
                elseif isa(baseTypeElement.Type,'coder.descriptor.types.Struct')
                    groups={};
                    subGroups={};
                    for ii=1:length(baseTypeElement.Type.Elements)
                        element=baseTypeElement.Type.Elements(ii);
                        type=element.Type;
                        if~isa(baseTypeElement,'coder.descriptor.types.AggregateElement')&&~lutAsElements


                            codeType=coder.internal.asap2.Utils.getImplementationType(baseTypeElement);
                            elementType=codeType.Elements(ii).Type;
                            if this.isUnsupportedVariableType(elementType,obj)
                                continue;
                            end
                        end
                        if this.isSupportedDataType(type)
                            if isa(type,'coder.descriptor.types.Struct')
                                subGroups{end+1}=element.Identifier;%#ok<AGROW>
                            else
                                groups{end+1}=element.Identifier;%#ok<AGROW>
                            end
                        end


                        if isa(element.Type,'coder.descriptor.types.Matrix')...
                            &&isa(element.Type.BaseType,'coder.descriptor.types.Struct')

                            this.ZeroIndexArrayStructElements=[];



                            this.buildObjectInfo(interface,className,classObjectName,...
                            [objNameRelative,'.',element.Identifier,'[0]'],element,obj,modelRepo,path,false);
                            this.handleNonZeroArrayIndexStructElements(class,objNameRelative,element);

                        else
                            this.buildObjectInfo(interface,className,classObjectName,[objNameRelative,'.',...
                            element.Identifier],element,obj,modelRepo,path,toHaveLutAsElement);
                        end
                    end
                    this.Data.GroupsMap(sName)=struct('LongIdentifier',longIdentifier,class,{groups});
                    this.Data.SubGroupsMap(sName)=struct('Names',{subGroups});
                    return;
                elseif isa(baseTypeElement.Type,'coder.descriptor.types.Matrix')
                    if isa(baseTypeElement.Type.BaseType,'coder.descriptor.types.Struct')
                        elements=baseTypeElement.Type.BaseType.Elements;
                        groups={};
                        subGroups={};
                        for ii=1:length(elements)
                            element=elements(ii);
                            isSupported=this.isSupportedDataType(element.Type);
                            if~isa(baseTypeElement,'coder.descriptor.types.AggregateElement')&&~lutAsElements
                                codeType=coder.internal.asap2.Utils.getImplementationType(obj.Implementation);
                                if codeType.isStructure
                                    base=codeType;
                                else
                                    base=codeType.BaseType;
                                end
                                if this.isUnsupportedVariableType(base.Elements(ii).Type,obj)
                                    continue;
                                end

                            end
                            if~isSupported
                                continue;
                            end

                            if isa(element.Type,'coder.descriptor.types.Struct')
                                subGroups{end+1}=element.Identifier;%#ok<AGROW>
                            else
                                groups{end+1}=element.Identifier;%#ok<AGROW>
                            end



                            if isa(element.Type,'coder.descriptor.types.Matrix')...
                                &&isa(element.Type.BaseType,'coder.descriptor.types.Struct')
                                this.ZeroIndexArrayStructElements=[];



                                this.buildObjectInfo(interface,className,classObjectName,...
                                [objNameRelative,'.',element.Identifier,'[0]'],element,obj,modelRepo,path,toHaveLutAsElement);
                                this.handleNonZeroArrayIndexStructElements(class,objNameRelative,element);
                            else
                                this.buildObjectInfo(interface,className,classObjectName,[objNameRelative,'.',...
                                element.Identifier],element,obj,modelRepo,path,toHaveLutAsElement);
                            end
                        end
                        this.Data.GroupsMap(sName)=struct('LongIdentifier',longIdentifier,class,{groups});
                        this.Data.SubGroupsMap(sName)=struct('Names',{subGroups});
                        return;
                    else
                        dataTypeBaseType=baseTypeElement.Type.BaseType;
                    end
                else
                    dataTypeBaseType=baseTypeElement.Type;
                end
                if strcmp(interface,'Function')
                    return;
                end
                type='VALUE';
                if isa(baseTypeElement,'coder.descriptor.types.AggregateElement')&&...
                    isa(baseTypeElement.Type,'coder.descriptor.types.Matrix')&&...
                    ~isa(baseTypeElement.Type.BaseType,'coder.descriptor.types.Matrix')
                    if this.isUnsupportedVariableType(dataTypeBaseType,obj)
                        return;
                    end

                    dataType=coder.internal.asap2.Utils.getAsamDataType(baseTypeElement.Type.BaseType);
                    [aliasName,~,isSupported]=this.updateRecordLayoutsMap('',baseTypeElement.Type.BaseType);

                    if~isSupported
                        return;
                    end
                    conversionMethod=this.updateCompuMethodsMap(baseTypeElement.Type.BaseType,obj);
                    if isempty(baseTypeElement.Type.CompileTimeDimensions.toArray)
                        dimension=baseTypeElement.Type.Dimensions;
                    else
                        dimension=baseTypeElement.Type.CompileTimeDimensions;
                    end
                    [width,matrixDims]=coder.internal.asap2.Utils.getWidthFromDimension(dimension);

                    if(width>1)
                        type='VAL_BLK';
                    end
                elseif~isa(baseTypeElement.Type,'coder.descriptor.types.Matrix')
                    if isa(baseTypeElement.Type,'coder.descriptor.types.Pointer')
                        return;
                    else
                        dataType=coder.internal.asap2.Utils.getAsamDataType(baseTypeElement.Type);
                        if this.Data.RecordLayoutsofDataTypeMap.isKey(baseTypeElement.Type.Name)
                            recordLayoutValues=this.Data.RecordLayoutsofDataTypeMap(baseTypeElement.Type.Name);
                            aliasName=recordLayoutValues.AliasName;
                            isSupported=recordLayoutValues.IsSupported;
                        else
                            [aliasName,~,isSupported]=this.updateRecordLayoutsMap('',baseTypeElement.Type);
                            this.Data.RecordLayoutsofDataTypeMap(baseTypeElement.Type.Name)=struct('AliasName',aliasName,'IsSupported',isSupported);
                        end
                        if~isSupported
                            return;
                        end
                    end
                    if isa(obj.Type,'coder.descriptor.types.Enum')

                        conversionMethod=this.updateCompuMethodsMap(obj.Type,obj);
                    elseif isa(baseTypeElement,'coder.descriptor.types.AggregateElement')
                        conversionMethod=this.updateCompuMethodsMap(baseTypeElement.Type,obj,baseTypeElement.Unit);
                    else
                        conversionMethod=this.updateCompuMethodsMap(baseTypeElement.Type,obj);
                    end
                else
                    if isa(baseTypeElement.Type,'coder.descriptor.types.Pointer')...
                        ||isa(baseTypeElement.Type.BaseType,'coder.descriptor.types.Pointer')...
                        ||isa(baseTypeElement.Type.BaseType,'coder.descriptor.types.Complex')
                        return;
                    else
                        dataType=coder.internal.asap2.Utils.getAsamDataType(dataTypeBaseType);
                        [aliasName,~,isSupported]=this.updateRecordLayoutsMap('',dataTypeBaseType);
                        if~isSupported
                            return;
                        end
                    end
                    if isa(obj.Type.BaseType,'coder.descriptor.types.Enum')

                        conversionMethod=this.updateCompuMethodsMap(obj.Type.BaseType,obj);
                    else
                        conversionMethod=this.updateCompuMethodsMap(baseTypeElement.Type.BaseType,obj);
                    end
                    if isempty(baseTypeElement.Type.CompileTimeDimensions.toArray)
                        dimension=baseTypeElement.Type.Dimensions;
                    else
                        dimension=baseTypeElement.Type.CompileTimeDimensions;
                    end
                    [width,matrixDims]=coder.internal.asap2.Utils.getWidthFromDimension(dimension);

                    if width>1
                        type='VAL_BLK';
                    end
                end

                if isa(baseTypeElement,'coder.descriptor.types.AggregateElement')
                    [lowerLimit,upperLimit]=this.getMinMaxValues(obj,dataTypeBaseType,this.Data.ModelName,baseTypeElement);
                    desc=baseTypeElement.Description;
                elseif~isa(dataTypeBaseType,'coder.descriptor.types.Pointer')
                    [lowerLimit,upperLimit]=this.getMinMaxValues(obj,dataTypeBaseType,this.Data.ModelName);
                    desc=coder.internal.asap2.Utils.getLongIdentifierFromImplementationAndClass(modelRepo,obj,class);
                end

                if~isempty(desc)
                    longIdentifier=desc;
                end
                categoryToObjectsMapValues=[];
                categoryToObjectsMapClass='';
                if strcmp(type,'VALUE')
                    categoryToObjectsMapClass='SCALAR';
                    categoryToObjectsMapValues=this.Data.CategoryToObjectsMap('SCALAR');
                elseif strcmp(type,'VAL_BLK')
                    categoryToObjectsMapClass='ARRAY';
                    categoryToObjectsMapValues=this.Data.CategoryToObjectsMap('ARRAY');
                end

                if~isempty(categoryToObjectsMapValues)
                    if strcmp(class,'Signals')
                        categoryToObjectsMapValues.Measurements{end+1}=sName;
                    elseif strcmp(class,'Params')
                        categoryToObjectsMapValues.Characteristics{end+1}=sName;
                    end
                    if any(strcmp(categoryToObjectsMapClass,this.Data.CustomizeGroupsByType))&&(strcmp('SCALAR',categoryToObjectsMapClass)||strcmp('ARRAY',categoryToObjectsMapClass))
                        this.Data.CategoryToObjectsMap(categoryToObjectsMapClass)=categoryToObjectsMapValues;
                    end
                end
                ecuAddress=['0x0000 /* @ECU_Address@',sName,'@ */'];
                if~isempty(this.Data.AdditionalCalibrationAttributesValues)&&...
                    ~isempty(this.Data.AdditionalCalibrationAttributesValues.bitMask)

                    if dataTypeBaseType.isEnum...
                        ||(~dataTypeBaseType.isFixed&&~dataTypeBaseType.isInteger&&~dataTypeBaseType.isBoolean)


                        this.Data.ObjectsWithInvalDataTypeForBitmask{end+1}=obj.GraphicalName;
                    end
                end

                if strcmp(class,'Signals')
                    if~this.Data.SignalsMap.isKey(sName)
                        if~isempty(this.Data.PeriodicEventList)&&...
                            this.Data.PeriodicEventList.NumEvents>1&&...
                            ~isempty(obj.Timing)&&strcmp(obj.Timing.TimingMode,'PERIODIC')&&...
                            this.Data.IncludeDefaultEventList




                            defaultEventID=coder.internal.asap2.Utils.getRateID(obj.Timing.SamplePeriod,this.Data.PeriodicEventList);
                        else
                            defaultEventID=[];

                        end
                        this.ZeroIndexArrayStructElements{end+1}=sName;
                        raster=struct('DefaultEventID',defaultEventID,...
                        'AvailableEventID',[],'FixedEventID',[]);
                        this.Data.SignalsMap(sName)=struct('GraphicalName',obj.GraphicalName,'LongIdentifier',longIdentifier,...
                        'DataType',dataType,'EcuAddress',ecuAddress,'CompuMethodName',conversionMethod,...
                        'LowerLimit',lowerLimit,'UpperLimit',upperLimit,'Width',width,'Dimensions',matrixDims,...
                        'Raster',raster,'EcuAddressComment','',...
                        'Export',this.Data.AdditionalCalibrationAttributesValues.export,...
                        'CalibrationAccess',this.Data.AdditionalCalibrationAttributesValues.calibrationAccess,...
                        'DisplayIdentifier',this.Data.AdditionalCalibrationAttributesValues.displayIdentifier,...
                        'Format',this.Data.AdditionalCalibrationAttributesValues.format,...
                        'BitMask',this.Data.AdditionalCalibrationAttributesValues.bitMask,...
                        'EcuAddressExtension',double.empty...
                        );
                    end
                else
                    if~this.Data.ParametersMap.isKey(sName)

                        this.ZeroIndexArrayStructElements{end+1}=sName;

                        this.Data.ParametersMap(sName)=struct('GraphicalName',obj.GraphicalName,'LongIdentifier',longIdentifier,...
                        'Type',type,'EcuAddress',ecuAddress,'RecordLayout',aliasName,...
                        'CompuMethodName',conversionMethod,'LowerLimit',lowerLimit,...
                        'UpperLimit',upperLimit,'Width',width,'Dimensions',matrixDims,'EcuAddressComment','',...
                        'Export',this.Data.AdditionalCalibrationAttributesValues.export,...
                        'CalibrationAccess',this.Data.AdditionalCalibrationAttributesValues.calibrationAccess,...
                        'DisplayIdentifier',this.Data.AdditionalCalibrationAttributesValues.displayIdentifier,...
                        'Format',this.Data.AdditionalCalibrationAttributesValues.format,...
                        'BitMask',this.Data.AdditionalCalibrationAttributesValues.bitMask,...
                        'EcuAddressExtension',double.empty...
                        );
                    end
                end
            end
        end




        function unSupported=updateCommonAxisLutInfo(this,parameter,classObjectName,modelRepo,paramVariableName)
            if~isempty(paramVariableName)
                pName=paramVariableName;
            else
                pName=coder.internal.asap2.Utils.getFullyQualifiedVariableName(parameter,classObjectName);
            end
            LongId=coder.internal.asap2.Utils.getLongIdentifierParam(modelRepo,pName,parameter);
            unSupported=false;
            ecuAddress=['0x0000 /* @ECU_Address@',pName,'@ */'];
            sharedName='';
            axisFix='';
            refToInput='NO_INPUT_QUANTITY';
            paramBaseType=parameter.Implementation.Type.BaseType;
            if~this.isSupportedDataType(paramBaseType)
                return;
            end
            breakpoints=parameter.Breakpoints;
            numOfBreakpoints=breakpoints.Size;
            if(numOfBreakpoints==0)
                return;
            end
            for i=1:numOfBreakpoints
                breakpoint=breakpoints(i);
                if~coder.internal.asap2.Utils.isExportableObject(breakpoint.Implementation,this.Data.SupportStructureElements,this.Data.IncludeAUTOSARElements)&&...
                    isempty(breakpoint.FixAxisMetadata)


                    return;
                end
            end
            [lowerLimit,upperLimit]=this.getMinMaxValues(parameter,paramBaseType,this.Data.ModelName);
            conversionMethod=this.updateCompuMethodsMap(paramBaseType,parameter);
            category=coder.internal.asap2.Utils.getAxisCategory(numOfBreakpoints);
            noOfAxis=1;
            for i=1:numOfBreakpoints
                if numOfBreakpoints==1
                    bpIndex=noOfAxis;
                else

                    if noOfAxis<=2
                        bpIndex=3-noOfAxis;
                    else
                        bpIndex=noOfAxis;
                    end
                end
                breakpoint=breakpoints(i);

                Name=['Bp',num2str(i)];
                this.getStereotypeProperties(breakpoint.GraphicalName,'Characteristic');

                [RecordLayout,~,isSupported]=this.updateRecordLayoutsMap('Record',paramBaseType);
                if~isSupported
                    unSupported=true;
                    return;
                end
                axisName=coder.internal.asap2.Utils.getFullyQualifiedVariableName(breakpoint,classObjectName);
                if this.InstParamMap.isKey(breakpoint.GraphicalName)

                    instParamMapValues=this.InstParamMap(breakpoint.GraphicalName);
                    if instParamMapValues.IsArgument



                        temp=split(paramVariableName,'_');
                        temp=split(temp{end},'.');
                        if this.InstParamMap.isKey([temp{1},'_',breakpoint.GraphicalName])
                            instParamMapValues=this.InstParamMap([temp{1},'_',breakpoint.GraphicalName]);
                            axisName=instParamMapValues.AliasName;
                        elseif this.InstParamMap.isKey(breakpoint.GraphicalName)
                            axisName=instParamMapValues.AliasName;
                        end

                    end

                    if this.Data.ParametersMap.isKey(axisName)


                        remove(this.Data.ParametersMap,axisName);
                    end
                end
                axisType='COM_AXIS';
                if~isempty(breakpoint.FixAxisMetadata)
                    axisType='FIX_AXIS';
                end
                if any(ismember(this.Data.LutWithParamObj,axisName))

                    if this.Data.AxisNameToAliasAxisNameMap.isKey(axisName)


                        sharedName=this.Data.AxisNameToAliasAxisNameMap(axisName);
                    else

                        sharedName=coder.internal.asap2.Utils.getUniqueName(axisName);
                        this.Data.AxisNameToAliasAxisNameMap(axisName)=sharedName;
                    end
                end
                if~this.Data.CommonAxesMap.isKey(axisName)

                    unSupported=this.updateCommonAxesMap(breakpoint,classObjectName,modelRepo,sharedName,axisName);
                    if~unSupported
                        return;
                    end
                end
                if~isempty(breakpoint.OperatingPoint)&&~breakpoint.OperatingPoint.isParameter...
                    &&~isempty(breakpoint.OperatingPoint.Implementation.assumeOwnershipAndGetExpression)





                    refToInput=coder.internal.asap2.Utils.getReferenceInput(this.Data.IsCppInterface,breakpoint.OperatingPoint,classObjectName);
                end
                if strcmp(axisType,'COM_AXIS')

                    axis=this.Data.CommonAxesMap(axisName);
                    if~isempty(sharedName)


                        axisName=sharedName;
                    end


                    axisInfo(bpIndex)=struct('Name',Name,'AxisType',axisType,'InputQuantity',refToInput,...
                    'CompuMethodName',axis.CompuMethodName,'MaxAxisPoints',axis.MaxAxisPoints,'LowerLimit',axis.LowerLimit,...
                    'UpperLimit',axis.UpperLimit,'AxisPointsRef',axisName,'FixAxisType','','Distance','','Offset','','Format','','EvenSpacingLutObjWithExplicitBPSpec','');
                else

                    axisBaseType=breakpoint.Type.BaseType;
                    [unSupported,axisInfo(bpIndex)]=this.getFixAxisInfo(axisBaseType,parameter,breakpoint,Name,classObjectName,false);
                end
                noOfAxis=noOfAxis+1;
            end
            this.updateCategoryToObjectsMapForLookups(pName,numOfBreakpoints);
            this.updateAdditionalCalibrationAttributes(pName);


            if~this.Data.ParametersMap.isKey(pName)
                this.Data.ParametersMap(pName)=struct('GraphicalName',parameter.GraphicalName,'LongIdentifier',LongId,'Type',category,...
                'EcuAddress',ecuAddress,'RecordLayout',RecordLayout,'CompuMethodName',conversionMethod,...
                'LowerLimit',lowerLimit,'UpperLimit',upperLimit,'AxisInfo',axisInfo,'EcuAddressComment','',...
                'Export',this.Data.AdditionalCalibrationAttributesValues.export,...
                'CalibrationAccess',this.Data.AdditionalCalibrationAttributesValues.calibrationAccess,...
                'DisplayIdentifier',this.Data.AdditionalCalibrationAttributesValues.displayIdentifier,...
                'Format',this.Data.AdditionalCalibrationAttributesValues.format,...
                'BitMask',this.Data.AdditionalCalibrationAttributesValues.bitMask,...
                'EcuAddressExtension',double.empty...
                );
            end
        end





        function isSupported=updateCommonAxesMap(this,parameter,classObjectName,modelRepo,sharedAxis,paramName)
            isSupported=true;
            if isa(parameter,'coder.descriptor.ModelParameter')
                return;
            end
            if~isempty(parameter.FixAxisMetadata)

                return;
            end
            if isempty(paramName)
                [pName,~,~]=coder.internal.asap2.Utils.getVariableInfo(parameter);
            else
                pName=paramName;
            end

            LongId=coder.internal.asap2.Utils.getLongIdentifierParam(modelRepo,pName,parameter);
            ecuAddress=['0x0000 /* @ECU_Address@',pName,'@ */'];
            MaxDif=0;
            refToInput='NO_INPUT_QUANTITY';
            nxDataType=0;

            if parameter.SupportTunableSize
                if parameter.Implementation.Type.isStructure

                    parameterElements=parameter.Implementation.Type.Elements;
                else
                    parameterElements=parameter.Implementation.Type.BaseType.Elements;
                end


                axisBaseType=parameterElements(2).Type.BaseType;
                if isempty(parameterElements(2).Type.CompileTimeDimensions.toArray)
                    dimension=parameterElements(2).Type.Dimensions;
                else
                    dimension=parameterElements(2).Type.CompileTimeDimensions;
                end
                if~this.isSupportedDataType(axisBaseType)
                    isSupported=false;
                    return;
                end
                [NoOfAxisPts,~]=coder.internal.asap2.Utils.getWidthFromDimension(dimension);
                [lowerLimit,upperLimit]=this.getMinMaxValues(parameter,axisBaseType,this.Data.ModelName);
                [~,nxDataType,isSupported]=this.updateRecordLayoutsMap('COM',parameterElements(1).Type);
                if~isSupported
                    return;
                end
                [~,xDataType,isSupported]=this.updateRecordLayoutsMap('COM',axisBaseType);
                if~isSupported
                    return;
                end
                conversionMethod=this.updateCompuMethodsMap(axisBaseType,parameter);
                recordLayout=['Axis_',nxDataType,'_',xDataType];
            else
                paramBaseType=parameter.Implementation.Type.BaseType;
                if isempty(parameter.Implementation.Type.CompileTimeDimensions.toArray)
                    dimension=parameter.Implementation.Type.Dimensions;
                else
                    dimension=parameter.Implementation.Type.CompileTimeDimensions;
                end
                [NoOfAxisPts,~]=coder.internal.asap2.Utils.getWidthFromDimension(dimension);
                [lowerLimit,upperLimit]=this.getMinMaxValues(parameter,paramBaseType,this.Data.ModelName);
                [~,xDataType,isSupported]=this.updateRecordLayoutsMap('COM',paramBaseType);
                if~isSupported
                    return;
                end
                conversionMethod=this.updateCompuMethodsMap(paramBaseType,parameter);
                recordLayout=['Axis_',xDataType];
            end
            this.updateAdditionalCalibrationAttributes(pName);

            if~this.Data.CommonAxesMap.isKey(pName)
                this.Data.CommonAxesMap(pName)=struct('GraphicalName',parameter.GraphicalName,'LongIdentifier',LongId,'EcuAddress',ecuAddress,...
                'RecordLayout',recordLayout,'MaxDiff',MaxDif,'CompuMethodName',conversionMethod,...
                'MaxAxisPoints',num2str(NoOfAxisPts),'LowerLimit',lowerLimit,'UpperLimit',upperLimit,...
                'InputQuantity',refToInput,'SharedAxis',sharedAxis,'CalibrationAccess',this.Data.AdditionalCalibrationAttributesValues.calibrationAccess,...
                'DisplayIdentifier',this.Data.AdditionalCalibrationAttributesValues.displayIdentifier,...
                'Format',this.Data.AdditionalCalibrationAttributesValues.format,...
                'EcuAddressExtension',double.empty...
                );
            end

            if~this.Data.LookUpTableRecordLayoutMap.isKey(recordLayout)
                this.Data.LookUpTableRecordLayoutMap(recordLayout)=struct('AxisType','COM_AXIS',...
                'xDataType',xDataType,'nxDataType',nxDataType,'SupportTunableSize',parameter.SupportTunableSize,'ToggleArrayLayout',false);
            end
        end

        function[isSupported,lutFieldsAsSeparateElems]=updateFixAxisLutInfo(this,parameter,classObjectName,modelRepo,paramVariableName)
            if~isempty(paramVariableName)
                pName=paramVariableName;
            else
                pName=coder.internal.asap2.Utils.getFullyQualifiedVariableName(parameter,classObjectName);
            end
            longIdentifier=coder.internal.asap2.Utils.getLongIdentifierParam(modelRepo,pName,parameter);
            index=[];
            isSupported=true;
            lutFieldsAsSeparateElems=false;
            isEvenSpacingLutObjWithExplicitBPSpec=false;
            paramBaseType='';
            if~isa(parameter.Implementation.Type,'coder.descriptor.types.Struct')
                paramImplType=parameter.Implementation.Type.BaseType;
            else
                paramImplType=parameter.Implementation.Type;
            end
            if~this.isSupportedDataType(paramImplType)
                this.Data.ObjectsWithInvalidDataType{end+1}=pName;
                isSupported=false;
                return;
            end
            if paramImplType.isStructure...
                &&~strcmp(parameter.StructOrder,'Unset')





                ecuAddress=['0x0000 /* @ECU_Address@',[pName,'.Table'],'@ */'];
            else
                ecuAddress=['0x0000 /* @ECU_Address@',pName,'@ */'];
            end
            numOfBreakPoints=parameter.Breakpoints.Size;
            category=coder.internal.asap2.Utils.getAxisCategory(numOfBreakPoints);
            if parameter.SupportTunableSize
                isSupported=false;
                return;
            end
            if~isa(paramImplType,'coder.descriptor.types.Struct')
                paramBaseType=paramImplType;
            else
                countArrayElements=0;
                elements=paramImplType.Elements;
                for jj=1:length(paramImplType.Elements)
                    elementType=elements(jj).Type;
                    if isa(elementType,'coder.descriptor.types.Matrix')
                        countArrayElements=countArrayElements+1;
                        if countArrayElements>1
                            isEvenSpacingLutObjWithExplicitBPSpec=true;
                        end
                    end

                end
                if length(paramImplType.Elements)==2*numOfBreakPoints+1


                    if strcmp(parameter.StructOrder,'SizeBreakpointsTable')
                        index=[1,(2*(numOfBreakPoints))+1];
                    elseif strcmp(parameter.StructOrder,'SizeTableBreakpoints')
                        index=[2,1];
                    else



                        index=[2,1];
                    end

                else



                    if strcmp(parameter.StructOrder,'SizeBreakpointsTable')
                        index=[1,numOfBreakPoints+1];
                    elseif strcmp(parameter.StructOrder,'SizeTableBreakpoints')
                        index=[2,1];
                    else



                        index=[2,1];
                    end

                end
                if paramImplType.Elements(index(2)).Type.isMatrix
                    paramBaseType=paramImplType.Elements(index(2)).Type.BaseType;
                end
            end
            if(isempty(paramBaseType))
                isSupported=false;
                return;
            end
            pCmName=this.updateCompuMethodsMap(paramBaseType,parameter);

            [pLowerLimit,pUpperLimit]=this.getMinMaxValues(parameter,paramBaseType,this.Data.ModelName);
            breakpoints=parameter.Breakpoints;
            noOfAxis=1;
            [aliasName,~,~]=this.updateRecordLayoutsMap('Record',paramBaseType);
            for i=1:1:numOfBreakPoints
                if numOfBreakPoints==1
                    bpIndex=noOfAxis;
                else

                    if noOfAxis<=2
                        bpIndex=3-noOfAxis;
                    else
                        bpIndex=noOfAxis;
                    end
                end

                if this.Data.IsAdaptiveAutosarSTF||...
                    (this.Data.IsAutosarSTF&&isEvenSpacingLutObjWithExplicitBPSpec)




                    bpName=noOfAxis;
                else
                    bpName=bpIndex;
                    bpIndex=i;
                end
                element=breakpoints(bpIndex);
                if isempty(element.FixAxisMetadata)



                    if(element.IsTunableBreakPoint)
                        lutFieldsAsSeparateElems=true;
                        return;

                    end
                    isSupported=false;
                    return;
                end
                refToInput='NO_INPUT_QUANTITY';
                if~isa(paramImplType,'coder.descriptor.types.Struct')


                    if~isempty(element.Type)
                        axisBaseType=element.Type.BaseType;
                    else
                        axisBaseType=parameter.Type.BaseType;
                    end
                elseif isEvenSpacingLutObjWithExplicitBPSpec



                    axisBaseType=element.Implementation.Type.BaseType.Elements(index(1)).Type.BaseType;
                elseif strcmp(parameter.StructOrder,'Unset')


                    axisBaseType=paramBaseType;
                else

                    if isa(element.Implementation.Type,'coder.descriptor.types.Struct')


                        if paramImplType.Elements.Size==2*numOfBreakPoints+1



                            axisBaseType=element.Implementation.Type.Elements(index(1)+2*i-1).Type;
                        else

                            axisBaseType=element.Implementation.Type.Elements(index(2)).Type;
                        end
                    else
                        axisBaseType=element.Implementation.Type.BaseType.Elements(index(1)+2*i-1).Type;
                    end
                end
                name=['Bp',num2str(noOfAxis)];
                [isSupported,axisInfo(bpName)]=this.getFixAxisInfo(axisBaseType,parameter,element,name,classObjectName,isEvenSpacingLutObjWithExplicitBPSpec);
                noOfAxis=noOfAxis+1;
            end
            this.updateCategoryToObjectsMapForLookups(pName,numOfBreakPoints);

            if~this.Data.ParametersMap.isKey(pName)
                this.Data.ParametersMap(pName)=struct('GraphicalName',parameter.GraphicalName,'LongIdentifier',longIdentifier,...
                'Type',category,'EcuAddress',ecuAddress,'RecordLayout',aliasName,...
                'CompuMethodName',pCmName,'LowerLimit',pLowerLimit,'UpperLimit',pUpperLimit,...
                'AxisInfo',axisInfo,'EcuAddressComment','',...
                'Export',this.Data.AdditionalCalibrationAttributesValues.export,...
                'CalibrationAccess',this.Data.AdditionalCalibrationAttributesValues.calibrationAccess,...
                'DisplayIdentifier',this.Data.AdditionalCalibrationAttributesValues.displayIdentifier,...
                'Format',this.Data.AdditionalCalibrationAttributesValues.format,...
                'BitMask',this.Data.AdditionalCalibrationAttributesValues.bitMask,...
                'EcuAddressExtension',double.empty...
                );
            end
        end

        function updateArrayAsFixAxisLut(this,parameter,classObjectName,longIdentifier)


            pName=coder.internal.asap2.Utils.getFullyQualifiedVariableName(parameter,classObjectName);
            ecuAddress=['0x0000 /* @ECU_Address@',pName,'@ */'];
            axisType='FIX_AXIS';
            refToInput='NO_INPUT_QUANTITY';
            cmName='NO_COMPU_METHOD';
            numOfBreakPoints=parameter.Type.Dimensions.Size;
            category=coder.internal.asap2.Utils.getAxisCategory(numOfBreakPoints);
            numOfAxisPts=[];
            axisPts=[];
            paramBaseType=parameter.Implementation.Type.BaseType;
            pCmName=this.updateCompuMethodsMap(paramBaseType,parameter);

            [pLowerLimit,pUpperLimit]=this.getMinMaxValues(parameter,paramBaseType,this.Data.ModelName);
            aliasName=parameter.Type.BaseType.Name;
            isEvenSpacingLutObjWithExplicitBPSpec=false;
            bpIndex=1;
            for i=numOfBreakPoints:-1:1
                axisBaseType=parameter.Type.BaseType;
                [aliasName,~,~]=this.updateRecordLayoutsMap('Record',parameter.Type.BaseType);
                name=['Bp',num2str(i)];
                [~,format]=this.updateCompuMethodsMap(axisBaseType,parameter);

                [lowerLimit,upperLimit]=this.getMinMaxValues(parameter,axisBaseType,this.Data.ModelName);
                dist='1';
                val='0';
                typeOfFix='FIX_AXIS_PAR_DIST';
                axisInfo(bpIndex)=struct('Name',name,'AxisType',axisType,...
                'InputQuantity',refToInput,'CompuMethodName',cmName,'MaxAxisPoints',num2str(parameter.Type.Dimensions(i)),...
                'LowerLimit',lowerLimit,'UpperLimit',upperLimit,'FixAxisType',typeOfFix,'Distance',num2str(dist),'Offset',str2num(val),'Format',format,'EvenSpacingLutObjWithExplicitBPSpec',isEvenSpacingLutObjWithExplicitBPSpec);
                bpIndex=bpIndex+1;
            end
            tDataType=coder.internal.asap2.Utils.getAsamDataType(paramBaseType);
            if isa(parameter.Implementation.Type.BaseType,'coder.descriptor.types.Struct')
                if~this.Data.LookUpTableRecordLayoutMap.isKey(aliasName)
                    this.Data.LookUpTableRecordLayoutMap(aliasName)=struct('AxisType','FIX_AXIS','noOfAxis',numOfBreakPoints,...
                    'axisPtsDataType',axisPts,'NumOfAxisPtsDataType',numOfAxisPts,'tDataType',tDataType,'FixAxisType',typeOfFix,'ToggleArrayLayout',false);
                end
            end
            this.updateCategoryToObjectsMapForLookups(pName,numOfBreakPoints);


            if~this.Data.ParametersMap.isKey(pName)
                this.Data.ParametersMap(pName)=struct('GraphicalName',parameter.GraphicalName,'LongIdentifier',longIdentifier,...
                'Type',category,'EcuAddress',ecuAddress,'RecordLayout',aliasName,...
                'CompuMethodName',pCmName,'LowerLimit',pLowerLimit,'UpperLimit',pUpperLimit,...
                'AxisInfo',axisInfo,'EcuAddressComment','',...
                'Export',this.Data.AdditionalCalibrationAttributesValues.export,...
                'CalibrationAccess',this.Data.AdditionalCalibrationAttributesValues.calibrationAccess,...
                'DisplayIdentifier',this.Data.AdditionalCalibrationAttributesValues.displayIdentifier,...
                'Format',this.Data.AdditionalCalibrationAttributesValues.format,...
                'BitMask',this.Data.AdditionalCalibrationAttributesValues.bitMask,...
                'EcuAddressExtension',double.empty...
                );
            end
        end


        function updateArrayAsFixAxisLutWithTabVerb(this,parameter,classObjectName,longIdentifier)


            pName=coder.internal.asap2.Utils.getFullyQualifiedVariableName(parameter,classObjectName);
            ecuAddress=['0x0000 /* @ECU_Address@',pName,'@ */'];
            axisType='FIX_AXIS';
            refToInput='NO_INPUT_QUANTITY';
            cmNameForXAxis='';
            cmNameForYAxis='';
            numOfBreakPoints=parameter.Type.Dimensions.Size;
            category=coder.internal.asap2.Utils.getAxisCategory(numOfBreakPoints);
            numOfAxisPts=[];
            axisPts=[];
            paramBaseType=parameter.Implementation.Type.BaseType;
            pCmName=this.updateCompuMethodsMap(paramBaseType,parameter);

            [pLowerLimit,pUpperLimit]=this.getMinMaxValues(parameter,paramBaseType,this.Data.ModelName);
            aliasName=parameter.Type.BaseType.Name;
            characteristicProps=coder.internal.ProfileStereotypeUtils.getStereotypeProperties(...
            'Calibration','Calibration','getAllProps');
            codeMapping=coder.mapping.api.get(this.Data.ModelName);
            for jj=1:numel(characteristicProps)
                propName=characteristicProps{jj};
                switch propName
                case 'XAxisCompuMethodName'
                    cmNameForXAxis=characteristicProps{jj};
                case 'YAxisCompuMethodName'
                    cmNameForYAxis=characteristicProps{jj};
                case 'XAxisLabels'
                    xLabels=characteristicProps{jj};
                case 'YAxisLabels'
                    yLabels=characteristicProps{jj};
                end
            end
            bpIndex=1;
            for i=numOfBreakPoints:-1:1
                axisBaseType=parameter.Type.BaseType;
                [aliasName,~,~]=this.updateRecordLayoutsMap('Record',parameter.Type.BaseType);
                name=['Bp',num2str(i)];
                if i==2
                    cmName=cmNameForXAxis;
                    axisLabels=xLabels;
                else
                    cmName=cmNameForYAxis;
                    axisLabels=yLabels;
                end
                cmName=getModelParameter(codeMapping,parameter.GraphicalName,cmName);


                if isempty(cmName)
                    if(i==2)
                        cmName='CM_X_AXIS';
                    else
                        cmName='CM_Y_AXIS';
                    end
                end
                axisVerbalTable=getModelParameter(codeMapping,parameter.GraphicalName,axisLabels);
                if~isempty(axisVerbalTable)
                    [~,format]=this.updateCustomCompuMethodsMap(parameter.GraphicalName,cmName,axisLabels,parameter.Unit);
                else


                    cmName="NO_COMPU_METHOD";
                    [~,format]=this.updateCompuMethodsMap(axisBaseType,parameter);
                end

                [lowerLimit,upperLimit]=this.getMinMaxValues(parameter,axisBaseType,this.Data.ModelName);
                dist='1';
                val='0';
                typeOfFix='FIX_AXIS_PAR_DIST';
                axisInfo(bpIndex)=struct('Name',name,'AxisType',axisType,...
                'InputQuantity',refToInput,'CompuMethodName',cmName,'MaxAxisPoints',num2str(parameter.Type.Dimensions(i)),...
                'LowerLimit',lowerLimit,'UpperLimit',upperLimit,'FixAxisType',typeOfFix,'Distance',num2str(dist),'Offset',str2num(val),'Format',format);
                bpIndex=bpIndex+1;
            end
            tDataType=coder.internal.asap2.Utils.getAsamDataType(paramBaseType);
            if isa(parameter.Implementation.Type.BaseType,'coder.descriptor.types.Struct')
                if~this.Data.LookUpTableRecordLayoutMap.isKey(aliasName)
                    this.Data.LookUpTableRecordLayoutMap(aliasName)=struct('AxisType','FIX_AXIS','noOfAxis',numOfBreakPoints,...
                    'axisPtsDataType',axisPts,'NumOfAxisPtsDataType',numOfAxisPts,'tDataType',tDataType,'FixAxisType',typeOfFix,'ToggleArrayLayout',false);
                end
            end
            this.updateCategoryToObjectsMapForLookups(pName,numOfBreakPoints);


            if~this.Data.ParametersMap.isKey(pName)
                this.Data.ParametersMap(pName)=struct('GraphicalName',parameter.GraphicalName,'LongIdentifier',longIdentifier,...
                'Type',category,'EcuAddress',ecuAddress,'RecordLayout',aliasName,...
                'CompuMethodName',pCmName,'LowerLimit',pLowerLimit,'UpperLimit',pUpperLimit,...
                'AxisInfo',axisInfo,'EcuAddressComment','',...
                'Export',this.Data.AdditionalCalibrationAttributesValues.export,...
                'CalibrationAccess',this.Data.AdditionalCalibrationAttributesValues.calibrationAccess,...
                'DisplayIdentifier',this.Data.AdditionalCalibrationAttributesValues.displayIdentifier,...
                'Format',this.Data.AdditionalCalibrationAttributesValues.format,...
                'BitMask',this.Data.AdditionalCalibrationAttributesValues.bitMask,...
                'EcuAddressExtension',double.empty...
                );
            end
        end

        function getStereotypeProperties(this,modelElementName,class)


            export=true;
            calibrationAccess='';
            compuMethodName='';
            displayIdentifier='';
            format='';
            bitMask='';
            if~this.Data.IsAutosarCompliant...
                &&~this.Data.IsCppInterface
                if~this.Data.AdditionalCalibrationAttributesMap.isKey(modelElementName)
                    if strcmp(class,'Measurement')&&this.Data.MeasurementValuesCache.isKey(modelElementName)
                        stereoTypeValues=this.Data.MeasurementValuesCache(modelElementName).Profile;
                    elseif this.Data.CalibrationValuesCache.isKey(modelElementName)
                        stereoTypeValues=this.Data.CalibrationValuesCache(modelElementName).Profile;
                    else
                        stereoTypeValues=[];
                    end
                    for ss=1:numel(stereoTypeValues)

                        switch stereoTypeValues(ss).Name
                        case 'Export'
                            export=stereoTypeValues(ss).Value;
                        case 'CalibrationAccess'
                            calibrationAccess=stereoTypeValues(ss).Value;
                        case 'CompuMethod'
                            compuMethodName=stereoTypeValues(ss).Value;
                        case 'DisplayIdentifier'
                            displayIdentifier=stereoTypeValues(ss).Value;
                        case 'Format'
                            format=stereoTypeValues(ss).Value;
                        case 'BitMask'
                            bitMask=stereoTypeValues(ss).Value;
                        end
                    end
                    this.Data.AdditionalCalibrationAttributesMap(modelElementName)=struct('export',export,'calibrationAccess',calibrationAccess,'compuMethodName',compuMethodName,...
                    'displayIdentifier',displayIdentifier,'format',format,'bitMask',bitMask);
                end

            end

        end





        function[paramsGrp,measurementsGrp,paramBusesGrp,measurementsBusesGrp,instanceNames,subSystemsGrp]=getListOfParamsAndSignals(this,getChildSubsys,path,modelClassInstanceName,topModelName,instanceName)
            grBlocks=getChildSubsys.GraphicalBlocks.toArray();
            paramsGrp=[];
            measurementsGrp=[];
            measurementsBusesGrp=[];
            paramBusesGrp=[];
            instanceNames=[];
            subSystemsGrp=[];
            parentSubsystems=[];
            paramsToRemove={};
            for nGrBlock=1:numel(grBlocks)



                grBlock=grBlocks(nGrBlock);
                if strcmp(grBlock.Type,'SubSystem')
                    parentSubsytem=grBlock.GraphicalSubsystem;
                    subsys_path=parentSubsytem.Path;
                    [parentParamsGrp,parentSignalsGrp,paramBusesGrp,measurementsBusesGrp,parent_instanceNames,parent_subSystemsGrp]=this.getListOfParamsAndSignals(parentSubsytem,subsys_path,modelClassInstanceName,topModelName,instanceName);







                    if~isempty(subsys_path)
                        if~isempty(instanceName)
                            parentSubSysName=strsplit(subsys_path,'/');
                            parentSubSysName=strjoin(parentSubSysName(2:end),'_');
                            parentSubSysName=[instanceName,'_',parentSubSysName];
                        else
                            parentSubSysName=strrep(subsys_path,'/','_');
                        end
                    else
                        parentSubSysName=[this.Data.ModelName,'_',parentSubsytem.GraphicalName];
                    end
                    if~isempty(regexp(parentSubSysName,'[^a-zA-Z_0-9]','once'))
                        parentSubSysName=regexprep(parentSubSysName,'[^a-zA-Z_0-9]','_');
                    end
                    parentSubsystems{end+1}=parentSubSysName;
                    longIdentifier='';
                    if~isempty(parentSubsytem.Path)
                        longIdentifier=parentSubsytem.Path;
                    end


                    if~this.Data.GroupsMap.isKey(parentSubsystems{end})
                        if~isempty(parentParamsGrp)||~isempty(parentSignalsGrp)||~isempty(parent_subSystemsGrp)||~isempty(parent_instanceNames)
                            this.Data.GroupsMap(parentSubsystems{end})=struct('LongIdentifier',longIdentifier,'SubSysParams',{parentParamsGrp},'SubSysSignals',{parentSignalsGrp});
                            this.Data.SubGroupsMap(parentSubsystems{end})=struct('SubSystems',{parent_subSystemsGrp},'Instances',{parent_instanceNames});
                        else
                            parentSubsystems=setdiff(parentSubsystems,parentSubsystems{end});
                        end
                    end


                    if~isempty(parentSubsystems)&&this.Data.GroupsMap.isKey(parentSubsystems{end})
                        subSystemsGrp=parentSubsystems;
                    end
                    subSystemsGrp=unique(subSystemsGrp);
                    continue;
                elseif strcmp(grBlock.Type,'Lookup_n-D')
                    if~this.SIDPathMap.isKey(grBlock.SID)
                        this.SIDPathMap(grBlock.SID)=grBlock.Path;
                    end
                end




                if strcmp(grBlock.Type,'ModelReference')
                    if grBlock.IsProtectedModelBlock
                        continue;
                    end
                    refMdlName=grBlock.ReferencedModelName;
                    if~isempty(instanceName)
                        refMdlName=[instanceName,'_',refMdlName,'_',grBlock.GraphicalName];
                    else
                        refMdlName=[grBlock.ParentSystemSID,'_',refMdlName,'_',grBlock.GraphicalName];
                    end
                    if this.Data.GroupsMap.isKey(refMdlName)
                        instanceNames{end+1}=refMdlName;
                    end
                end

                blockParams=grBlock.BlockParameters.toArray();
                for nBlockParam=1:numel(blockParams)
                    blockParam=blockParams(nBlockParam);
                    modelParams=blockParam.ModelParameters.toArray();
                    for nModelParam=1:numel(modelParams)
                        if modelParams(nModelParam).WorkspaceVariable||modelParams(nModelParam).LocalParameter||modelParams(nModelParam).GlobalParameter||modelParams(nModelParam).Tunable
                            dataIntrfs=modelParams(nModelParam).DataInterface;


                            if isa(dataIntrfs,'coder.descriptor.BreakpointDataInterface')&&~isempty(dataIntrfs.FixAxisMetadata)
                                continue;
                            end
                            if strcmp(grBlock.Type,'ModelReference')
                                for ii=1:numel(modelParams(nModelParam).GraphicalReferences)
                                    blocks=modelParams(nModelParam).GraphicalReferences(ii).BlockParameters;
                                    for jj=1:blocks.Size
                                        block=blocks(jj);
                                        instName=block.Name;
                                        if strcmp(modelParams(nModelParam).Name,block.ModelParameters(1).Name)
                                            if~this.InstParamMap.isKey(modelParams(nModelParam).Name)

                                                if modelParams(nModelParam).WorkspaceVariable
                                                    name=modelParams(nModelParam).Name;
                                                    if strcmp(instName,block.ModelParameters(1).Name)
                                                        continue;
                                                    end
                                                else
                                                    name=instName;
                                                end
                                                if isa(modelParams(nModelParam).GraphicalReferences(ii),'coder.descriptor.ModelBlock')



                                                    this.InstParamMap(name)=struct("Name",instName,"ReferenceModel",modelParams(nModelParam).GraphicalReferences(ii).ReferencedModelName,'IsArgument',true,'AliasName','');
                                                end
                                            end
                                            if this.InstParamMap.isKey(instName)
                                                value=this.InstParamMap(instName);
                                                value.AliasName=modelParams(nModelParam).Name;
                                                this.InstParamMap(instName)=value;
                                            end
                                        end
                                    end
                                end
                            end
                            if~strcmp(grBlock.Type,'ModelReference')||~isempty(this.InstParamMap)
                                if~isempty(dataIntrfs)&&~isempty(dataIntrfs.Implementation)...
                                    &&~(strcmp(this.Data.ModelName,topModelName)&&this.InstParamMap.isKey(dataIntrfs.GraphicalName))

                                    if(isa(dataIntrfs,'coder.descriptor.LookupTableDataInterface')...
                                        ||isa(dataIntrfs,'coder.descriptor.BreakpointDataInterface'))&&~strcmp(this.Data.ModelName,topModelName)
                                        if isempty(modelParams(nModelParam).GraphicalReferences)
                                            isArgument=true;
                                        else
                                            isArgument=false;
                                        end
                                        if~coder.internal.asap2.Utils.isExportableObject(dataIntrfs.Implementation,this.Data.SupportStructureElements,this.Data.IncludeAUTOSARElements)&&...
                                            isa(dataIntrfs,'coder.descriptor.LookupTableDataInterface')


                                            continue;
                                        end
                                        this.InstParamMap(dataIntrfs.GraphicalName)=struct("Name",dataIntrfs.GraphicalName,"ReferenceModel",this.Data.ModelName,'IsArgument',isArgument,'AliasName','');
                                    end
                                    if~coder.internal.asap2.Utils.isExportableObject(dataIntrfs.Implementation,this.Data.SupportStructureElements,this.Data.IncludeAUTOSARElements)
                                        if isa(dataIntrfs,'coder.descriptor.LookupTableDataInterface')&&...
                                            strcmp(dataIntrfs.BreakpointSpecification,'Reference')




                                            breakpoints=dataIntrfs.Breakpoints;
                                            for ii=1:breakpoints.Size()
                                                paramsToRemove{end+1}=breakpoints(ii).GraphicalName;
                                            end
                                        end
                                        continue;
                                    end
                                    if isa(dataIntrfs,'coder.descriptor.LookupTableDataInterface')
                                        if strcmp(dataIntrfs.BreakpointSpecification,'Reference')




                                            bpNotExportable=false;
                                            breakpoints=dataIntrfs.Breakpoints;
                                            for ii=1:numel(breakpoints)
                                                if~coder.internal.asap2.Utils.isExportableObject(breakpoints(ii).Implementation,this.Data.SupportStructureElements,this.Data.IncludeAUTOSARElements)
                                                    bpNotExportable=true;
                                                end
                                            end
                                            if bpNotExportable
                                                continue
                                            end
                                        elseif strcmp(dataIntrfs.BreakpointSpecification,'Even spacing')




                                            bpNotExportable=false;
                                            breakpoints=dataIntrfs.Breakpoints;
                                            for ii=1:numel(breakpoints)
                                                if isempty(breakpoints(ii).FixAxisMetadata)
                                                    bpNotExportable=true;
                                                    break;
                                                end
                                            end
                                            if bpNotExportable
                                                paramsToRemove{end+1}=breakpoints(ii).GraphicalName;
                                                continue;
                                            end

                                        end
                                    end
                                    if isa(dataIntrfs.Implementation,'coder.descriptor.StructExpression')||...
                                        isa(dataIntrfs.Implementation,'coder.descriptor.Variable')
                                        if coder.internal.asap2.Utils.isLocalVariable(dataIntrfs.Implementation)
                                            continue;
                                        end
                                    end
                                    implementation=dataIntrfs.Implementation;
                                    this.getStereotypeProperties(dataIntrfs.GraphicalName,'Characteristics');
                                    exportToA2lFile=true;
                                    if this.Data.AdditionalCalibrationAttributesMap.isKey(dataIntrfs.GraphicalName)
                                        this.Data.AdditionalCalibrationAttributesValues=this.Data.AdditionalCalibrationAttributesMap(dataIntrfs.GraphicalName);
                                        exportToA2lFile=this.Data.AdditionalCalibrationAttributesValues.export;
                                    end
                                    if~exportToA2lFile
                                        continue;
                                    end
                                    if isa(implementation.Type,'coder.descriptor.types.Matrix')
                                        elementType=implementation.Type.BaseType;
                                    else
                                        elementType=implementation.Type;
                                    end

                                    isMultiWord=this.isDataTypeMultiWord(elementType);


                                    if isa(elementType,'coder.descriptor.types.Complex')
                                        continue;
                                    end


                                    isSupported=this.isSupportedDataType(elementType);
                                    if~isSupported
                                        continue;
                                    end

                                    if isa(implementation,'coder.descriptor.CustomExpression')



                                        if isempty(implementation.ExprOwner)
                                            continue;
                                        end
                                    end
                                    paramNameFromGraphicalName=split(dataIntrfs.GraphicalName,':');
                                    paramNameFromGraphicalName=split(paramNameFromGraphicalName{end},'.');
                                    modelParamName='';
                                    if~strcmp(this.Data.ModelName,topModelName)||this.InstParamMap.isKey(paramNameFromGraphicalName{end})
                                        [modelParamName,~,modelClassObjectName]=coder.internal.asap2.Utils.getVariableInfo(dataIntrfs);
                                        if isa(implementation,'coder.descriptor.StructExpression')&&...
                                            (isa(implementation.BaseRegion,'coder.descriptor.ClassMemberExpression')||...
                                            isa(implementation.BaseRegion,'coder.descriptor.StructAccessorVariable')||...
                                            (isa(implementation.BaseRegion,'coder.descriptor.StructExpression')...
                                            &&isa(implementation.BaseRegion.BaseRegion,'coder.descriptor.ClassMemberExpression')))
                                            baseRegion=implementation.BaseRegion;
                                            modelParamName=coder.internal.asap2.getFullyQualifiedVariableName(dataIntrfs,modelClassInstanceName);
                                        end
                                    else
                                        if isa(implementation,'coder.descriptor.Variable')...
                                            ||(isa(implementation,'coder.descriptor.StructExpression')&&isa(implementation.BaseRegion,'coder.descriptor.Variable'))
                                            if isa(implementation,'coder.descriptor.StructExpression')
                                                modelParamName=[implementation.BaseRegion.Identifier,'.',implementation.ElementIdentifier];
                                            else
                                                modelParamName=implementation.Identifier;
                                            end
                                        elseif this.Data.IncludeAUTOSARElements&&coder.internal.asap2.Utils.isAutosarRTEElement(implementation)
                                            modelParamName=coder.internal.asap2.Utils.getVariableInfo(dataIntrfs);
                                        end
                                    end
                                    if~isempty(modelParamName)
                                        if(isMultiWord||isa(dataIntrfs.Type,'coder.descriptor.types.Matrix')&&...
                                            isa(dataIntrfs.Type.BaseType,'coder.descriptor.types.Struct'))...
                                            &&~isa(dataIntrfs,'coder.descriptor.LookupTableDataInterface')...
                                            &&~isa(dataIntrfs,'coder.descriptor.BreakpointDataInterface')...
                                            &&~this.InstParamMap.isKey(paramNameFromGraphicalName{end})
                                            paramBusesGrp{end+1}=modelParamName;%#ok<AGROW>
                                        else

                                            paramsGrp{end+1}=modelParamName;

                                        end
                                    end
                                end
                            end
                        end
                    end

                end
                paramsGrp=setdiff(paramsGrp,paramsToRemove);

                outPorts=grBlock.DataOutputPorts.toArray();
                [outportsGrp,outportsBuses]=this.getAllMeasurements('Outports',outPorts,path,topModelName,modelClassInstanceName);


                inports=grBlock.DataInputPorts.toArray();
                [inportsGrp,inportsBuses]=this.getAllMeasurements('Inports',inports,path,topModelName,modelClassInstanceName);


                states=grBlock.DiscreteStates.toArray();
                [statesGrp,statesBuses]=this.getAllMeasurements('States',states,path,topModelName,modelClassInstanceName);


                dataStores=grBlock.DataStores.toArray();
                [dataStoreGrp,dataStoreBuses]=this.getAllMeasurements('DataStores',dataStores,path,topModelName,modelClassInstanceName);


                dWorks=grBlock.DWorks.toArray();
                [dworksGrp,dworksBuses]=this.getAllMeasurements('DWorks',dWorks,path,topModelName,modelClassInstanceName);

                measurementsGrp=unique([measurementsGrp,inportsGrp,outportsGrp,statesGrp,dataStoreGrp,dworksGrp]);
                measurementsBusesGrp=unique([measurementsBusesGrp,inportsBuses,outportsBuses,statesBuses,dataStoreBuses,dworksBuses]);
                paramsGrp=unique(paramsGrp);
                paramBusesGrp=unique(paramBusesGrp);
                subSystemsGrp=unique(subSystemsGrp);
            end
        end





        function[signalsGrp,signalBusesGrp]=getAllMeasurements(this,class,modelingElements,path,topModelName,modelClassInstanceName)
            signalsGrp=[];
            signalBusesGrp=[];
            for nOutPort=1:numel(modelingElements)
                outPort=modelingElements(nOutPort);
                if strcmp(class,'Outports')||strcmp(class,'Inports')
                    if~outPort.Logged&&~outPort.TestPoint&&~outPort.Connected
                        continue;
                    end
                    dataIntrfs=outPort.DataInterfaces.toArray();

                else
                    dataIntrfs=outPort;
                end
                if~isempty(dataIntrfs)&&numel(dataIntrfs)==1
                    if~isempty(dataIntrfs.Implementation)
                        if isa(dataIntrfs,'coder.descriptor.MessageDataInterface')||...
                            ~coder.internal.asap2.Utils.isExportableObject(dataIntrfs.Implementation,this.Data.SupportStructureElements,this.Data.IncludeAUTOSARElements)
                            continue;
                        end
                        if strcmp(class,'Outports')||strcmp(class,'Inports')
                            if~isempty(dataIntrfs)&&~strcmp(this.Data.ModelName,topModelName)

                                if this.Data.MeasurementValuesCache.isKey(dataIntrfs.GraphicalName)&&...
                                    this.Data.MeasurementValuesCache(dataIntrfs.GraphicalName).IsIO
                                    continue;
                                end
                            end
                        end
                        implementation=dataIntrfs.Implementation;

                        this.getStereotypeProperties(dataIntrfs.GraphicalName,'Measurement');
                        this.updateAdditionalCalibrationAttributes(dataIntrfs.GraphicalName);
                        exportToA2lFile=this.Data.AdditionalCalibrationAttributesValues.export;
                        if~exportToA2lFile
                            continue;
                        end
                        if isa(implementation,'coder.descriptor.Variable')




                            if coder.internal.asap2.Utils.isLocalVariable(implementation)
                                continue;
                            end
                        end

                        if isa(implementation.Type,'coder.descriptor.types.Matrix')
                            elementType=implementation.Type.BaseType;
                        else
                            elementType=implementation.Type;
                        end
                        isSupported=this.isSupportedDataType(elementType);
                        if~isSupported
                            continue;
                        end

                        if isa(elementType,'coder.descriptor.types.Complex')
                            continue;
                        end
                        if isa(implementation.Type,'coder.descriptor.types.Opaque')
                            continue;
                        end
                        if isa(implementation,'coder.descriptor.AutosarMemoryExpression')&&strcmp(implementation.DataAccessMode,'Persistency')
                            continue;
                        end
                        modelSignalName='';
                        isSubsystemOfTopLevel=false;
                        if~isempty(path)
                            expression='\w*(/)\w*';
                            [startRegex,endRegex]=regexp(path,expression,'ONCE');
                            if~isempty(startRegex)&&startRegex==1&&numel(path)==endRegex
                                isSubsystemOfTopLevel=true;
                            end
                        end
                        if~strcmp(this.Data.ModelName,topModelName)||isSubsystemOfTopLevel
                            [modelSignalName,~,modelClassObjectName]=coder.internal.asap2.Utils.getVariableInfo(dataIntrfs);





                            subString={'.rtb.','.rtdw.'};
                            if~isempty(path)&&~isempty(modelClassInstanceName)&&...
                                (contains(modelSignalName,subString)||contains(modelClassInstanceName,subString))


                                str=eraseBetween(modelSignalName,1,'.');
                                modelSignalName=[modelClassInstanceName,str];
                            else
                                if isa(implementation,'coder.descriptor.StructExpression')&&...
                                    (isa(implementation.BaseRegion,'coder.descriptor.ClassMemberExpression')||...
                                    isa(implementation.BaseRegion,'coder.descriptor.StructAccessorVariable')||...
                                    (isa(implementation.BaseRegion,'coder.descriptor.StructExpression')...
                                    &&isa(implementation.BaseRegion.BaseRegion,'coder.descriptor.ClassMemberExpression')))
                                    modelSignalName=coder.internal.asap2.Utils.getFullyQualifiedVariableName(dataIntrfs,modelClassInstanceName);
                                end
                            end
                        else
                            if isa(implementation,'coder.descriptor.Variable')...
                                ||(isa(implementation,'coder.descriptor.StructExpression')&&isa(implementation.BaseRegion,'coder.descriptor.Variable'))
                                if isa(implementation,'coder.descriptor.StructExpression')
                                    modelSignalName=[implementation.BaseRegion.Identifier,'.',implementation.ElementIdentifier];
                                else
                                    modelSignalName=implementation.Identifier;
                                end
                            elseif this.Data.IncludeAUTOSARElements&&coder.internal.asap2.Utils.isAutosarRTEElement(implementation)
                                modelSignalName=coder.internal.asap2.Utils.getVariableInfo(dataIntrfs);
                            end
                        end
                        isMultiWord=this.isDataTypeMultiWord(elementType);

                        if~isempty(modelSignalName)
                            if isMultiWord||isa(dataIntrfs.Type,'coder.descriptor.types.Struct')||(isa(dataIntrfs.Type,'coder.descriptor.types.Matrix')&&...
                                isa(dataIntrfs.Type.BaseType,'coder.descriptor.types.Struct'))
                                signalBusesGrp{end+1}=modelSignalName;%#ok<AGROW>
                            else
                                signalsGrp{end+1}=modelSignalName;%#ok<AGROW>
                            end
                        end
                    end
                end
            end
        end
        function[isSupported,axisInfo]=getFixAxisInfo(this,axisBaseType,parameter,element,name,classObjectName,isEvenSpacingLutObjWithExplicitBPSpec)

            refToInput='NO_INPUT_QUANTITY';
            isSupported=true;
            axisInfo=[];
            [cmName,format]=this.updateCompuMethodsMap(axisBaseType,element);

            [lowerLimit,upperLimit]=this.getMinMaxValues(element,axisBaseType,this.Data.ModelName);
            dist=[];
            val=[];

            if isa(element.FixAxisMetadata,'coder.descriptor.NonEvenSpacingMetadata')
                for ii=1:element.FixAxisMetadata.AllPoints.Size
                    val(ii)=element.FixAxisMetadata.AllPoints(ii);
                end
                dimension=element.FixAxisMetadata.AllPoints.Size;
            elseif isa(element.FixAxisMetadata,'coder.descriptor.EvenSpacingMetadata')
                val=element.FixAxisMetadata.StartingValue;
                dist=element.FixAxisMetadata.StepValue;
                dimension=element.FixAxisMetadata.NumPoints;
            else
                isSupported=false;
                return;
            end
            typeOfFix=coder.internal.asap2.Utils.determineFixAxisType(element);
            if~isempty(element.OperatingPoint)...
                &&~element.OperatingPoint.isParameter...
                &&~isempty(element.OperatingPoint.Implementation.assumeOwnershipAndGetExpression)




                refToInput=coder.internal.asap2.Utils.getReferenceInput(this.Data.IsAutosarCompliant,element.OperatingPoint,classObjectName);
            end
            axisInfo=struct('Name',name,'AxisType','FIX_AXIS',...
            'InputQuantity',refToInput,'CompuMethodName',cmName,'MaxAxisPoints',num2str(dimension),...
            'LowerLimit',lowerLimit,'UpperLimit',upperLimit,'AxisPointsRef','','FixAxisType',typeOfFix,'Distance',num2str(dist),'Offset',val,'Format',format,'EvenSpacingLutObjWithExplicitBPSpec',isEvenSpacingLutObjWithExplicitBPSpec);

        end

        function updateCategoryToObjectsMapForLookups(this,paramName,numOfBreakPoints)
            lookUpType='';
            categoryToObjectsMapValues=[];
            switch numOfBreakPoints
            case 1
                lookUpType='CURVE';
            case 2
                lookUpType='MAP';
            case 3
                lookUpType='CUBOID';
            case 4
                lookUpType='CUBE_4';
            case 5
                lookUpType='CUBE_5';
            end
            if this.Data.CategoryToObjectsMap.isKey(lookUpType)
                categoryToObjectsMapValues=this.Data.CategoryToObjectsMap(lookUpType);
            end

            if~isempty(lookUpType)&&any(strcmp(lookUpType,this.Data.CustomizeGroupsByType))&&~any(strcmp(paramName,categoryToObjectsMapValues))
                if~isempty(categoryToObjectsMapValues)
                    categoryToObjectsMapValues{end+1}=paramName;
                    this.Data.CategoryToObjectsMap(lookUpType)=categoryToObjectsMapValues;
                else
                    values={paramName};
                    this.Data.CategoryToObjectsMap(lookUpType)=values;
                end
            end
        end
        function isUnsupportedParamType=isUnsupportedVariableType(~,elementType,obj)
            isUnsupportedParamType=false;


            if~isempty(obj.Type)
                if obj.Type.isMatrix
                    paramBaseType=obj.Type.BaseType;
                else
                    paramBaseType=obj.Type;
                end
            else
                paramBaseType=elementType;
            end

            if elementType.isStdContainer&&isa(paramBaseType,'coder.descriptor.types.Struct')
                isUnsupportedParamType=true;
            end
        end

        function cmFormat=getCompuMethodFormat(this,dataTypeName)




            if this.Data.DataTypeToCompuMethodFormatMap.isKey(dataTypeName)
                cmFormat=this.Data.DataTypeToCompuMethodFormatMap(dataTypeName);
                return;
            end
            try
                numericTypeOfDataType=numerictype(dataTypeName);
                minval=double(numericTypeOfDataType.lowerbound);
                maxval=double(numericTypeOfDataType.upperbound);
                total_Length=ceil(log10(max(abs(minval),max(maxval))));
                switch numericTypeOfDataType.DataTypeMode
                case 'Fixed-point: slope and bias scaling'

                    layout=max(coder.internal.asap2.Utils.DecimalPointCount(numericTypeOfDataType.Slope),coder.internal.asap2.Utils.DecimalPointCount(numericTypeOfDataType.Bias));
                    total_Length=total_Length+layout;

                case 'Fixed-point: binary point scaling'

                    layout=max(0,min(numericTypeOfDataType.FractionLength,16));
                    total_Length=total_Length+layout;

                otherwise
                    total_Length=0;
                    layout=0;
                end
            catch exp
                total_Length=0;
                layout=0;
            end


            if total_Length==0&&layout==0
                cmFormat='customformat';
            else
                cmFormat=['%',num2str(total_Length),'.',num2str(layout)];
            end
            this.Data.DataTypeToCompuMethodFormatMap(dataTypeName)=cmFormat;
        end

        function[lowerLimit,upperLimit]=getMinMaxValues(this,object,dataTypeBaseType,modelName,varargin)





            baseTypeElement='';
            if nargin>2
                baseTypeElement=varargin;
            end
            if~isempty(baseTypeElement)




                [lowerLimit,upperLimit]=this.getMinMaxValues('',dataTypeBaseType,modelName);
                if~isempty(baseTypeElement{1}.Min)&&~strcmp(baseTypeElement{1}.Min,'-inf')
                    lowerLimit=num2str(str2double(baseTypeElement{1}.Min));
                end
                if~isempty(baseTypeElement{1}.Max)&&~strcmp(baseTypeElement{1}.Max,'inf')
                    upperLimit=num2str(str2double(baseTypeElement{1}.Max));
                end
            elseif isa(dataTypeBaseType,'coder.descriptor.types.Double')...
                ||isa(dataTypeBaseType,'coder.types.Double')
                lowerLimit='-1.7E+308';
                upperLimit='1.7E+308';
            elseif isa(dataTypeBaseType,'coder.descriptor.types.Bool')...
                ||isa(dataTypeBaseType,'coder.types.Bool')
                lowerLimit='0';
                upperLimit='1';
            elseif isa(dataTypeBaseType,'coder.descriptor.types.Single')...
                ||isa(dataTypeBaseType,'coder.types.Single')
                lowerLimit='-3.4E+38';
                upperLimit='3.4E+38';
            elseif isa(dataTypeBaseType,'coder.descriptor.types.Half')
                lowerLimit='-6.55E+4';
                upperLimit='6.55E+4';
            elseif isa(dataTypeBaseType,'coder.descriptor.types.Integer')...
                ||isa(dataTypeBaseType,'coder.types.Integer')...
                ||isa(dataTypeBaseType,'coder.types.Int')
                if dataTypeBaseType.Signedness
                    lowerLimit=num2str(-(2^double(dataTypeBaseType.WordLength-1)));
                    upperLimit=num2str((2^double(dataTypeBaseType.WordLength-1))-1);
                else
                    lowerLimit='0';
                    upperLimit=num2str((2^double(dataTypeBaseType.WordLength))-1);
                end
            elseif isa(dataTypeBaseType,'coder.descriptor.types.Fixed')...
                ||isa(dataTypeBaseType,'coder.types.Fixed')
                if dataTypeBaseType.Signedness

                    lowerLimit=num2str(-(dataTypeBaseType.Slope)*(2.^double(dataTypeBaseType.WordLength-1))+dataTypeBaseType.Bias,'%.1f');

                    upperLimit=num2str(double(dataTypeBaseType.Slope)*(2.^(double(dataTypeBaseType.WordLength)-1)-1)+dataTypeBaseType.Bias);
                else
                    lowerLimit=num2str(dataTypeBaseType.Bias,'%.1f');

                    upperLimit=num2str(double(dataTypeBaseType.Slope)*(2^double(dataTypeBaseType.WordLength)-1)+dataTypeBaseType.Bias);
                end



            elseif isa(dataTypeBaseType,'coder.descriptor.types.Enum')...
                ||isa(dataTypeBaseType,'coder.types.Enum')
                lowerLimit=dataTypeBaseType.Values(1);
                upperLimit=dataTypeBaseType.Values(1);
                if isa(dataTypeBaseType,'coder.types.Enum')
                    value=size(dataTypeBaseType.Values);
                else
                    value=dataTypeBaseType.Values.Size();
                end
                for i=2:value
                    if lowerLimit>dataTypeBaseType.Values.at(i)
                        lowerLimit=dataTypeBaseType.Values.at(i);
                    end
                    if upperLimit<dataTypeBaseType.Values.at(i)
                        upperLimit=dataTypeBaseType.Values.at(i);
                    end
                end
                lowerLimit=num2str(lowerLimit);
                upperLimit=num2str(upperLimit);
            end



            if~isempty(object)&&~isempty(object.Range)


                if~strcmpi(num2str(object.Range.Min),'-inf')
                    lowerLimit=num2str(object.Range.Min);
                end


                if~strcmpi(num2str(object.Range.Max),'inf')
                    upperLimit=num2str(object.Range.Max);
                end
            end
            if~isempty(object)
                graphicalName=object.GraphicalName;
                if this.Data.CalibrationValuesCache.isKey(graphicalName)...
                    &&~isempty(this.Data.CalibrationValuesCache(graphicalName).DualScaledParamProperty)
                    dualScaleProps=jsondecode(this.Data.CalibrationValuesCache(graphicalName).DualScaledParamProperty);
                    if~isempty(dualScaleProps.Min)
                        lowerLimit=num2str(dualScaleProps.Min);
                    end
                    if~isempty(dualScaleProps.Max)
                        upperLimit=num2str(dualScaleProps.Max);
                    end
                end
            end
        end

        function handleNonZeroArrayIndexStructElements(this,interface,objNameRelative,element)






            noOfArrayElements=prod(element.Type.Dimensions.toArray);
            for ii=1:noOfArrayElements-1

                for structelement=this.ZeroIndexArrayStructElements


                    sName=strrep(structelement{1},[objNameRelative,'.',element.Identifier,'[0]'],[objNameRelative,'.',element.Identifier,'[',num2str(ii),']']);
                    ecuAddress=['0x0000 /* @ECU_Address@',sName,'@ */'];
                    if strcmp(interface,'Signals')
                        if this.Data.SignalsMap.isKey(structelement{1})
                            info=this.Data.SignalsMap(structelement{1});
                            this.Data.SignalsMap(sName)=struct('GraphicalName',info.GraphicalName,'LongIdentifier',info.LongIdentifier,...
                            'DataType',info.DataType,'EcuAddress',ecuAddress,'CompuMethodName',info.CompuMethodName,...
                            'LowerLimit',info.LowerLimit,'UpperLimit',info.UpperLimit,'Width',info.Width,'Dimensions',info.Dimensions,...
                            'Raster',info.Raster,'EcuAddressComment','',...
                            'Export',info.Export,...
                            'CalibrationAccess',info.CalibrationAccess,...
                            'DisplayIdentifier',info.DisplayIdentifier,...
                            'Format',info.Format,...
                            'BitMask',info.BitMask,...
                            'EcuAddressExtension',double.empty...
                            );
                        end
                    else
                        if this.Data.ParametersMap.isKey(structelement{1})
                            info=this.Data.ParametersMap(structelement{1});
                            this.Data.ParametersMap(sName)=struct('GraphicalName',info.GraphicalName,'LongIdentifier',info.LongIdentifier,...
                            'Type',info.Type,'EcuAddress',ecuAddress,'RecordLayout',info.RecordLayout,...
                            'CompuMethodName',info.CompuMethodName,'LowerLimit',info.LowerLimit,...
                            'UpperLimit',info.UpperLimit,'Width',info.Width,'Dimensions',info.Dimensions,'EcuAddressComment','',...
                            'Export',info.Export,...
                            'CalibrationAccess',info.CalibrationAccess,...
                            'DisplayIdentifier',info.DisplayIdentifier,...
                            'Format',info.Format,...
                            'BitMask',info.BitMask,...
                            'EcuAddressExtension',double.empty...
                            );

                        end

                    end
                end
            end
        end
        function updateAdditionalCalibrationAttributes(this,objName)
            varNameFromGraphicalName=split(objName,':');
            varNameFromGraphicalName=split(varNameFromGraphicalName{end},'.');
            if this.Data.AdditionalCalibrationAttributesMap.isKey(varNameFromGraphicalName{end})
                this.Data.AdditionalCalibrationAttributesValues=this.Data.AdditionalCalibrationAttributesMap(varNameFromGraphicalName{end});

            else
                this.Data.AdditionalCalibrationAttributesValues=struct('export',true,'calibrationAccess','','compuMethodName','',...
                'displayIdentifier','','format','','bitMask','');
            end
        end
        function isMultiWord=isDataTypeMultiWord(this,paramType)
            isMultiWord=false;
            if~this.SupportLongLong&&~isempty(paramType)&&isa(paramType,'coder.descriptor.types.Fixed')...
                ||isa(paramType,'coder.types.Fixed')
                wordlength=paramType.WordLength;
                if paramType.Signedness
                    maxWordLength=this.PreprocMaxBitsSint;
                else
                    maxWordLength=this.PreprocMaxBitsUint;
                end
                if wordlength>maxWordLength
                    isMultiWord=true;
                end
            end
        end
    end
end





