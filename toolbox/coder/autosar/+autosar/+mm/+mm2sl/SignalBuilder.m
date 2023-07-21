classdef SignalBuilder<autosar.mm.mm2sl.ObjectBuilder





    properties
        SLMatcher;
        NVBlockNeedsPIMSet;
        InitValueParamSet;
    end

    properties(SetAccess=private)
        RequiresLegacyMemorySectionDefinitions;
    end

    properties(Access=private,Transient)
        ForceLegacyWorkspaceBehavior;
        PimsToCreate;
    end

    methods



        function self=SignalBuilder(m3iModel,typeBuilder,constBuilder,changeLogger,modelMappingHelper,initValueParamSet,nvBlockNeedsPIMSet)
            self@autosar.mm.mm2sl.ObjectBuilder(m3iModel,typeBuilder,constBuilder,changeLogger);
            self.SLMatcher=modelMappingHelper;
            self.NVBlockNeedsPIMSet=nvBlockNeedsPIMSet;
            self.InitValueParamSet=initValueParamSet;
            self.RequiresLegacyMemorySectionDefinitions=false;
            self.bind('Simulink.metamodel.arplatform.interface.VariableData',@walkVariableData,[]);
        end

        function buildComponentSignals(self,workSpace,modelWorkSpace,m3iComp,forceLegacyWorkspaceBehavior)


            self.ForceLegacyWorkspaceBehavior=forceLegacyWorkspaceBehavior;
            if isempty(m3iComp)||...
                (~isa(m3iComp,'Simulink.metamodel.arplatform.component.AtomicComponent')&&...
                ~isa(m3iComp,'Simulink.metamodel.arplatform.component.AdaptiveApplication'))||...
                ~m3iComp.isvalid()
                assert(false,DAStudio.message('RTW:autosar:mmInvalidArgComponent',2));
            end

            assert(m3iComp.rootModel==self.m3iModel,'Expected root of component to be m3iModel');
            m3iBehavior=m3iComp.Behavior;
            if m3iBehavior.isvalid()
                staticMemorySignals=self.applySeq(m3iBehavior.StaticMemory);
                if numel(staticMemorySignals)>0
                    modelSignalIdxs=cellfun(@(x)x.isModelWSSignal,staticMemorySignals);
                    self.assignSignalInWorkspace(staticMemorySignals(~modelSignalIdxs),workSpace);
                    self.assignSignalInWorkspace(staticMemorySignals(modelSignalIdxs),modelWorkSpace);
                end
                arTypedPIMSignals=self.applySeq(m3iBehavior.ArTypedPIM);
                if numel(arTypedPIMSignals)>0
                    modelSignalIdxs=cellfun(@(x)x.isModelWSSignal,arTypedPIMSignals);
                    self.assignSignalInWorkspace(arTypedPIMSignals(~modelSignalIdxs),workSpace);
                    self.assignSignalInWorkspace(arTypedPIMSignals(modelSignalIdxs),modelWorkSpace);
                end
            end
        end
    end

    methods(Static,Access=public,Hidden)
        function buildLegacySignals(modelName,unMappedPims,slTypeBuilder)
            assert(~isempty(unMappedPims),'unmapped Pim names must be specified');

            m3iModel=autosar.api.Utils.m3iModel(modelName);
            slChangeLogger=autosar.updater.ChangeLogger();
            slConstBuilder=autosar.mm.mm2sl.ConstantBuilder(m3iModel,slTypeBuilder);
            slMatcher=autosar.updater.SLComponentMatcher(modelName);
            emptySet=autosar.mm.util.Set(...
            'InitCapacity',20,...
            'KeyType','char',...
            'HashFcn',@(x)x);

            m3iComp=autosar.api.Utils.m3iMappedComponent(modelName);

            memSectionBuilder=autosar.mm.mm2sl.MemorySectionBuilder(m3iModel);
            memSectionBuilder.build();

            builder=autosar.mm.mm2sl.SignalBuilder(m3iModel,slTypeBuilder,slConstBuilder,slChangeLogger,slMatcher,emptySet,emptySet);
            builder.generateSignalsFromPim(modelName,m3iComp,unMappedPims);
        end
    end

    methods(Access='protected')
        function ret=isGlobalMemory(~,object)
            ret=autosar.mm.util.getIsAutosarStaticMemoryObject(object);
        end
    end

    methods(Access=private)

        function generateSignalsFromPim(self,modelName,m3iComp,pimNames)
            assert(~isempty(pimNames),'Pim names must be specified');

            currentWorkspaceBehaviour=self.ForceLegacyWorkspaceBehavior;
            self.ForceLegacyWorkspaceBehavior=true;
            self.PimsToCreate=pimNames;

            arTypedPIMSeq=m3iComp.Behavior.ArTypedPIM;
            staticMemorySeq=m3iComp.Behavior.StaticMemory;

            arTypedPIMSignals=self.applySeq(arTypedPIMSeq);
            staticMemorySignals=self.applySeq(staticMemorySeq);

            signalsToCreate=[arTypedPIMSignals,staticMemorySignals];

            modelWS=get_param(modelName,'ModelWorkspace');
            for idx=1:numel(signalsToCreate)
                modelWS.clear(signalsToCreate{idx}.name);
            end

            self.assignSignalInWorkspace(signalsToCreate,'base');

            self.PimsToCreate=[];
            self.ForceLegacyWorkspaceBehavior=currentWorkspaceBehaviour;
        end



        function slObjInfo=walkVariableData(self,m3iData,~)
            if~m3iData.isvalid()
                assert(false,DAStudio.message('RTW:autosar:mmInvalidArgObject',...
                2,'VariableData'));
            end

            slObjInfo=struct;
            slParamObjInfo=[];
            slObjInfo.isModelWSSignal=false;


            if~isempty(self.PimsToCreate)
                if~any(strcmp(self.PimsToCreate,m3iData.Name))
                    slObjInfo=[];
                    return;
                end
            end


            isArTypedPIM=self.isArTypedPIM(m3iData);
            if isArTypedPIM


                [isMapped,pimObj]=self.SLMatcher.isArTypedPIMMapped(m3iData);
                if isMapped&&isempty(pimObj)
                    slObjInfo=[];
                    return;
                end
            end
            isStaticMemory=~isArTypedPIM;

            [varExists,foundSignal,inModelWS]=self.objectExistsInModelScope(m3iData.Name);
            isLegacySignal=autosar.mm.mm2sl.SignalBuilder.isLegacyPIMSignalObject(foundSignal);
            useLegacyBehavior=self.ForceLegacyWorkspaceBehavior||(varExists&&~inModelWS&&isLegacySignal);
            if useLegacyBehavior
                if isArTypedPIM

                    newClassName='AUTOSAR.Signal';


                    workSpace=self.slTypeBuilder.SharedWorkSpace;
                    varExists=evalin(workSpace,['exist(''',m3iData.Name,''', ''var'')'])==1;
                    if varExists
                        oldObject=evalin(workSpace,m3iData.Name);
                        if isa(oldObject,'AUTOSAR4.Signal')&&...
                            strcmp(oldObject.CoderInfo.StorageClass,Simulink.data.getNameForModelDefaultSC)
                            newClassName='AUTOSAR4.Signal';
                        elseif strcmp(class(oldObject),'Simulink.Signal')%#ok<STISA>

                            newClassName='Simulink.Signal';
                        end
                    end
                else

                    newClassName='AUTOSAR4.Signal';
                end

                [slSignal,isCreated]=self.createOrUpdateObject(m3iData.Name,newClassName,isStaticMemory);

                if isa(slSignal,'AUTOSAR4.Signal')

                    self.RequiresLegacyMemorySectionDefinitions=true;
                end

                if isCreated
                    slSignal.SwCalibrationAccess=autosar.mm.mm2sl.utils.convertSwCalibrationAccessKindToStr(m3iData.SwCalibrationAccess);
                    slSignal.DisplayFormat=m3iData.DisplayFormat;
                    slSignal.CoderInfo.StorageClass='Custom';
                    slSignal.Complexity='real';
                end

                if isArTypedPIM
                    slSignal.Complexity='real';

                    if strcmp(slSignal.CoderInfo.StorageClass,'Custom')

                        slSignal.CoderInfo.CustomStorageClass='PerInstanceMemory';
                        slSignal.CoderInfo.CustomAttributes.IsArTypedPerInstanceMemory=true;
                    else

                        slSignal.CoderInfo.StorageClass='SimulinkGlobal';
                    end
                    m3iBehavior=m3iData.containerM3I;
                    if isempty(m3iData.InitValue)
                        for jj=1:m3iBehavior.ServiceDependency.size()
                            serviceDependency=m3iBehavior.ServiceDependency.at(jj);
                            if~isempty(serviceDependency.UsedDataElement)...
                                &&strcmp(serviceDependency.UsedDataElement.Name,m3iData.Name)
                                if strcmp(slSignal.CoderInfo.StorageClass,'Custom')

                                    slSignal.CoderInfo.CustomAttributes.needsNVRAMAccess=true;
                                end
                                if~isempty(serviceDependency.UsedParameterElement)
                                    initParam=serviceDependency.UsedParameterElement.Name;
                                    slSignal.InitialValue=initParam;
                                    self.InitValueParamSet.set(initParam);
                                end
                                break;
                            end
                        end
                    end
                else
                    if isCreated
                        slSignal.CoderInfo.CustomStorageClass='Global';
                        if autosar.mm.mm2sl.utils.isCompatibleSwAddrMethod(m3iData.SwAddrMethod)
                            try
                                slSignal.CoderInfo.CustomAttributes.MemorySection=m3iData.SwAddrMethod.Name;
                            catch
                            end
                        end
                    end
                end
            else


                slObjInfo.isModelWSSignal=true;

                if~varExists
                    newClassName='Simulink.Signal';
                    [slSignal,isCreated]=self.createOrUpdateObject(m3iData.Name,newClassName,isStaticMemory,true,true);
                else
                    [slSignal,isCreated]=self.createOrUpdateObject(m3iData.Name,class(foundSignal),isStaticMemory,false,inModelWS);
                    slObjInfo.isModelWSSignal=inModelWS;
                end

                if(varExists&&inModelWS)||isCreated


                    slSignal.CoderInfo.StorageClass='Auto';
                    slSignal.Complexity='real';
                end

                if isArTypedPIM
                    slSignal.Complexity='real';
                    m3iBehavior=m3iData.containerM3I;
                    if isempty(m3iData.InitValue)
                        for jj=1:m3iBehavior.ServiceDependency.size()
                            serviceDependency=m3iBehavior.ServiceDependency.at(jj);
                            if~isempty(serviceDependency.UsedDataElement)...
                                &&strcmp(serviceDependency.UsedDataElement.Name,m3iData.Name)
                                if~isempty(serviceDependency.UsedParameterElement)
                                    initParam=serviceDependency.UsedParameterElement.Name;
                                    slSignal.InitialValue=initParam;
                                end
                                break;
                            end
                        end
                    end
                end
            end

            if~m3iData.Type.isvalid()

                self.msgStream.createWarning('RTW:autosar:unspecifiedDataType',...
                {'VariableData',...
                m3iData.Name,...
                'StaticMemory',...
                m3iData.containerM3I.Name});
                return
            end

            typeStr=self.slTypeBuilder.getSLBlockDataTypeStr(m3iData.Type);
            slTypeInfo=self.slTypeBuilder.buildType(m3iData.Type);
            slSignal.DataType=typeStr;
            if isa(m3iData.Type,'Simulink.metamodel.types.Matrix')
                slSignal.Dimensions=slTypeInfo.dims.dataObjStyle;
            else
                slSignal.Dimensions=1;
            end

            if m3iData.DefaultValue.isvalid()

                initValue=m3iData.DefaultValue;
            elseif m3iData.InitValue.isvalid()
                initValue=m3iData.InitValue;
            else
                initValue=[];
            end
            if~isempty(initValue)

                if~initValue.Type.isvalid()

                    initValue.Type=m3iData.Type;
                end

                if initValue.Type.isvalid()...
                    &&isa(initValue,'Simulink.metamodel.types.MatrixValueSpecification')...
                    &&~isa(initValue.Type,'Simulink.metamodel.types.Matrix')
                    initValue=[];
                end
            end
            if~isempty(initValue)
                mlConstInfo=self.slConstBuilder.buildConst(initValue);
                value=mlConstInfo.mlVar;
                if isa(value,'embedded.fi')&&~strncmp(strtrim(typeStr),'fixdt',5)






                    value=value.double;
                    slSignal.DataType=typeStr;
                elseif~isa(value,'double')&&~isa(value,'struct')&&...
                    isa(slTypeInfo.slObj,'Simulink.AliasType')








                    value=double(value);
                end


                if isa(value,'struct')&&isscalar(value)





                    slSignal.InitialValue=mlConstInfo.name;

                    slParamObjInfo=struct;
                    slParamObjInfo.name=mlConstInfo.name;

                    slParam=Simulink.Parameter;
                    slParam.DataType=typeStr;
                    slParam.Value=value;

                    slParamObjInfo.slObj=slParam;

                elseif~isa(value,'struct')
                    dims=size(value);
                    if length(dims)<=2
                        slSignal.InitialValue=mat2str(value);
                    else


                        slSignal.InitialValue=mlConstInfo.name;

                        slParamObjInfo=struct;
                        slParamObjInfo.name=mlConstInfo.name;

                        slParam=Simulink.Parameter;
                        slParam.DataType=typeStr;
                        slParam.Value=value;

                        slParamObjInfo.slObj=slParam;
                    end
                end
            end


            m3iType=m3iData.Type;
            if m3iType.isvalid()&&m3iType.IsApplication
                [isSupported,minVal,maxVal]=...
                autosar.mm.util.MinMaxHelper.getMinMaxValuesFromM3iType(m3iType,slTypeInfo.slObj);
                if isSupported
                    slSignal.Min=minVal;
                    slSignal.Max=maxVal;
                end
            end


            slDesc=autosar.mm.util.DescriptionHelper.getSLDescFromM3IDesc(m3iData.desc);
            if~isempty(slDesc)
                slSignal.Description=slDesc;
            end


            slObjInfo.name=m3iData.Name;
            slObjInfo.slObj=slSignal;
            slObjInfo.slParamObjInfo=slParamObjInfo;
        end

        function assignSignalInWorkspace(self,slSignals,workSpace)

            for ii=1:numel(slSignals)
                variableCreated=self.createOrUpdateWorkspaceObject(...
                workSpace,...
                slSignals{ii}.name,...
                slSignals{ii}.slObj,...
                self.ChangeLogger);
                if variableCreated&&~isempty(slSignals{ii}.slParamObjInfo)

                    self.createOrUpdateWorkspaceObject(...
                    workSpace,...
                    slSignals{ii}.slParamObjInfo.name,...
                    slSignals{ii}.slParamObjInfo.slObj,...
                    self.ChangeLogger);
                end
            end
        end
    end
    methods(Static,Access=private)
        function isArTypedPIM=isArTypedPIM(m3iData)
            isArTypedPIM=false;
            for ii=1:m3iData.containerM3I.ArTypedPIM.size()
                if m3iData==m3iData.containerM3I.ArTypedPIM.at(ii)
                    isArTypedPIM=true;
                    return;
                end
            end
        end
    end

    methods(Static)
        function isLegacy=isLegacyPIMSignalObject(sigObj)


            isLegacy=false;
            if isa(sigObj,'AUTOSAR.Signal')
                if strcmp(sigObj.CoderInfo.StorageClass,'Custom')...
                    &&strcmp(sigObj.CoderInfo.CustomStorageClass,'PerInstanceMemory')
                    isLegacy=true;
                    return;
                end
            elseif isa(sigObj,'AUTOSAR4.Signal')
                if strcmp(sigObj.CoderInfo.StorageClass,'Custom')...
                    &&strcmp(sigObj.CoderInfo.CustomStorageClass,'Global')
                    isLegacy=true;
                    return;
                end
            end
        end
    end
end


