classdef PerInstanceMemoryBuilder<handle





    properties(Access=private)
        ModelName;
        M3iModel;
        M3iBehavior;
        TypeBuilder;
        MaxShortNameLength;
    end

    methods(Access=public)
        function this=PerInstanceMemoryBuilder(modelName,m3iBehavior,typeBuilder)
            this.ModelName=modelName;
            this.M3iBehavior=m3iBehavior;
            this.M3iModel=m3iBehavior.modelM3I;
            this.TypeBuilder=typeBuilder;
            this.MaxShortNameLength=get_param(modelName,'AutosarMaxShortNameLength');
        end

        function variants=addCodeDescriptorDataStoresInM3iModel(this,codeDesc)

            variants=containers.Map;
            dataStores=codeDesc.getDataInterfaces('DataStores');

            for ii=1:length(dataStores)
                datastore=dataStores(ii);
                if(datastore.DataStoreKind==coder.descriptor.types.DataStoreKind.SharedLocalFromSubmodel)



                    continue;
                end
                if autosar.mm.sl2mm.ModelBuilder.i_get_isCompatibleCSCForDSM(this.ModelName,datastore)
                    m3iPIM=this.addDataTypeToM3iPIM(datastore);
                    autosar.mm.sl2mm.ModelBuilder.updateCodeDescriptorVariants(variants,m3iPIM,...
                    datastore.VariantInfo,...
                    datastore.GraphicalName);
                    this.addNvBlockNeedsServiceDependencyForCodeDescDataStore(m3iPIM,datastore);

                end
            end
        end
    end

    methods(Access=private)

        function m3iPIM=addDataTypeToM3iPIM(this,datastore)
            implementation=datastore.Implementation;
            if~isa(implementation,'coder.descriptor.AutosarMemoryExpression')
                assert(false,DAStudio.message('RTW:autosar:unrecognisedInternalDataType',class(implementation)));
            end

            dataObj=autosar.mm.sl2mm.ModelBuilder.getDataObjectForDSMorSynthesizedDS(this.ModelName,datastore);

            m3iPIM=this.getM3iPIM(dataObj);
            m3iPIM.Name=arxml.arxml_private('p_create_aridentifier',implementation.BaseRegion.Identifier,this.MaxShortNameLength);
            autosar.mm.sl2mm.ModelBuilder.setSLObjDescriptionForM3iData(dataObj,m3iPIM);
            slAppTypeAttributes=autosar.mm.sl2mm.ModelBuilder.getSLAppTypeAttributes(dataObj);

            this.addImplementationTypeToM3iPIM(dataObj,implementation,m3iPIM,slAppTypeAttributes);
            this.appendPIMToM3iBehavior(datastore,dataObj,m3iPIM);
        end

        function addImplementationTypeToM3iPIM(this,dataObj,implementation,m3iPIM,slAppTypeAttributes)
            [m3iType,m3iTypeImpType]=this.TypeBuilder.findOrCreateType(...
            implementation.Type,implementation.CodeType,slAppTypeAttributes);

            if this.isARTypedPIM(dataObj)
                m3iPIM.Type=m3iType;
            else
                m3iPIM.typeStr=[implementation.BaseRegion.Identifier,'_',m3iTypeImpType.Name];
                m3iPIM.typeDefinitionStr=m3iTypeImpType.Name;





                pimTypePath=autosar.api.Utils.getQualifiedName(m3iTypeImpType);
                m3iPIM.setExternalToolInfo(M3I.ExternalToolInfo(...
                'ARXML_TypePathForCTypedPIM',pimTypePath));
            end
        end

        function appendPIMToM3iBehavior(this,datastore,dataObj,m3iPIM)
            if this.isARTypedPIM(dataObj)
                this.M3iBehavior.ArTypedPIM.append(m3iPIM)
                [m3iPIM.SwCalibrationAccess,m3iPIM.DisplayFormat]=autosar.mm.sl2mm.ModelBuilder.getSwCalibrationAccessForDataObject(this.ModelName,datastore);
            else
                this.M3iBehavior.PIM.append(m3iPIM);
            end
        end

        function addNvBlockNeedsServiceDependencyForCodeDescDataStore(this,m3iPIM,datastore)

            signalObj=autosar.mm.sl2mm.ModelBuilder.getDataObjectForDSMorSynthesizedDS(this.ModelName,datastore);


            if signalObj.CoderInfo.CustomAttributes.needsNVRAMAccess
                serviceDependencyQName=arxml.arxml_private('p_create_aridentifier',['SwcNv_',m3iPIM.Name],this.MaxShortNameLength);


                m3iServiceDependencySeq=this.M3iBehavior.ServiceDependency;
                m3iServiceDependency='';
                for i=1:m3iServiceDependencySeq.size
                    if strcmp(m3iServiceDependencySeq.at(i).Name,serviceDependencyQName)
                        m3iServiceDependency=m3iServiceDependencySeq.at(1);
                    end
                end
                if~isempty(m3iServiceDependency)

                    if isempty(m3iServiceDependency.ServiceNeeds)

                        m3iServiceDependency.ServiceNeeds=Simulink.metamodel.arplatform.behavior.NvBlockNeeds(this.M3iModel);
                        m3iServiceDependency.ServiceNeeds.Name=m3iServiceDependency.Name;
                    end
                else

                    m3iServiceDependency=Simulink.metamodel.arplatform.behavior.ServiceDependency(this.M3iModel);
                    m3iServiceDependency.Name=serviceDependencyQName;
                    m3iServiceDependency.ServiceNeeds=Simulink.metamodel.arplatform.behavior.NvBlockNeeds(this.M3iModel);
                    m3iServiceDependency.ServiceNeeds.Name=m3iServiceDependency.Name;
                    this.M3iBehavior.ServiceDependency.append(m3iServiceDependency);
                end

                if this.isARTypedPIM(signalObj)
                    m3iServiceDependency.UsedDataElement=m3iPIM;
                else
                    m3iServiceDependency.PIM=m3iPIM;
                end
                this.addInitializationParameterToM3iServiceDependency(signalObj,m3iServiceDependency);
            end
        end

        function addInitializationParameterToM3iServiceDependency(this,signalObj,m3iServiceDependency)
            if this.isInitializationNeededForPIM(signalObj)
                [varExists,paramObj]=autosar.utils.Workspace.objectExistsInModelScope(this.ModelName,signalObj.InitialValue);
                if varExists&&this.isInternalCalPrmObject(paramObj)
                    paramM3iData=autosar.mm.Model.findChildByNameAndTypeName(this.M3iBehavior,...
                    signalObj.InitialValue,'Simulink.metamodel.arplatform.interface.ParameterData');
                    if this.isM3IParameterPIMOrShared(paramM3iData)
                        m3iServiceDependency.UsedParameterElement=paramM3iData;
                    end
                end
            end
        end

        function m3iPIM=getM3iPIM(this,dataObj)
            if this.isARTypedPIM(dataObj)
                m3iPIM=Simulink.metamodel.arplatform.interface.VariableData(this.M3iModel);
            else
                m3iPIM=Simulink.metamodel.arplatform.behavior.PerInstanceMemory(this.M3iModel);
            end
        end

        function isTrue=isARTypedPIM(~,dataObj)
            isTrue=dataObj.CoderInfo.CustomAttributes.IsArTypedPerInstanceMemory;
        end

    end

    methods(Static,Access=private)
        function isNeeded=isInitializationNeededForPIM(signalObj)
            isNeeded=~isempty(signalObj)&&isa(signalObj,'Simulink.Signal')&&...
            ~isempty(signalObj.InitialValue);
        end
        function isValid=isInternalCalPrmObject(paramObj)
            isValid=~isempty(paramObj)&&isa(paramObj,'Simulink.Parameter')&&...
            strcmp(paramObj.CoderInfo.StorageClass,'Custom')&&...
            strcmp(paramObj.CoderInfo.CustomStorageClass,'InternalCalPrm');
        end
        function isTrue=isM3IParameterPIMOrShared(paramM3iData)
            isTrue=~isempty(paramM3iData)&&...
            (paramM3iData.Kind==Simulink.metamodel.arplatform.behavior.ParameterKind.Shared||...
            paramM3iData.Kind==Simulink.metamodel.arplatform.behavior.ParameterKind.Pim);
        end
    end
end


