classdef SDPTypes<handle






    properties(SetAccess=private,GetAccess=public)



        PlatformType=coder.internal.rte.PlatformType.Invalid
        DeploymentType=coder.internal.rte.DeploymentType.empty
    end

    properties(Access=private)
Model
ModelReferenceTargetType
    end

    methods
        function this=SDPTypes(model)
            this.Model=model;
            this.ModelReferenceTargetType=get_param(model,'ModelReferenceTargetType');
            if~ismember(this.ModelReferenceTargetType,{'NONE','RTW'})
                return;
            end
            isSimBuild=slprivate('isSimulationBuild',model,this.ModelReferenceTargetType);
            if isSimBuild
                return;
            end


            [mapping,mappingType]=Simulink.CodeMapping.getCurrentMapping(model);
            if coder.make.internal.featureOn('ApplicationWithServices')








                if~isempty(mapping)&&isprop(mapping,'DeploymentType')
                    this.setDeploymentType(mapping.DeploymentType);
                else

                    this.setDeploymentType('Unset');
                end
                this.PlatformType=coder.internal.rte.PlatformType.ApplicationWithServices;
                return;
            end
            platformType=coder.dictionary.internal.getPlatformType(model);
            expectedStrings={'FunctionPlatform','ApplicationPlatform'};
            assert(ismember(platformType,expectedStrings),...
            'Unexpected platform type encountered: %s',platformType);








            if isempty(mapping)&&platformType=="FunctionPlatform"
                DAStudio.error('RTW:buildProcess:NoMappingForFunctionPlatform',model);
            elseif~isempty(mapping)&&strcmp(mappingType,'CoderDictionary')
                isDictionaryServiceAware=strcmp(platformType,'FunctionPlatform');
                isMappingServiceAware=mapping.isFunctionPlatform;
                if(isDictionaryServiceAware~=isMappingServiceAware)
                    modelH=get_param(model,'Handle');
                    sharedDDName=coderdictionary.data.SlCoderDataClient.getSharedCoderDictionarySource(modelH);
                    assert(~isempty(sharedDDName),...
                    'Shared Embedded Coder Dictionary is missing');
                    serviceInterfaceLabel=message('SimulinkCoderApp:sdp:ServiceInterfaceLabel').getString;
                    dataInterfaceLabel=message('SimulinkCoderApp:sdp:DataInterfaceLabel').getString;
                    if(isMappingServiceAware)
                        dictionaryCodeInterface=dataInterfaceLabel;
                        mappingCodeInterface=serviceInterfaceLabel;
                    else
                        dictionaryCodeInterface=serviceInterfaceLabel;
                        mappingCodeInterface=dataInterfaceLabel;
                    end
                    DAStudio.error('coderdictionary:mapping:SharedDictionaryIncompatibleWithCodeMappings',...
                    sharedDDName,dictionaryCodeInterface,model,mappingCodeInterface);
                end
            end



            sdpMappingTypes={'CoderDictionary','CppModelMapping'};
            if~ismember(mappingType,sdpMappingTypes)
                return;
            end
            switch platformType
            case 'ApplicationPlatform'
                if~isempty(mapping)
                    assert(isprop(mapping,'DeploymentType'),...
                    'No DeploymentType property in %s mapping.',mappingType);
                    this.setDeploymentType(mapping.DeploymentType);
                else

                    this.setDeploymentType('Unset');
                end
                this.PlatformType=coder.internal.rte.PlatformType.Application;
            case 'FunctionPlatform'
                assert(mappingType=="CoderDictionary",...
                'Unexpected mapping type %s encountered for Function Platform.',mappingType);
                assert(ismember(mapping.DeploymentType,{'Component','Subcomponent'}),...
                'Unexpected deployment type was detected for Function Platform: %s',mapping.DeploymentType);
                this.setDeploymentType(mapping.DeploymentType);
                this.PlatformType=coder.internal.rte.PlatformType.Function;
            otherwise
                assert(false,'Unexpected platform type encountered: %s',platformType);
            end
        end

        function rteFolders=getServiceFolders(this,buildFolder)


            assert(this.DeploymentType==coder.internal.rte.DeploymentType.Component,...
            'Deployment Type must be Component for service folders to exist. Detected: %s',this.DeploymentType);
            assert(this.PlatformType==coder.internal.rte.PlatformType.Function||...
            this.PlatformType==coder.internal.rte.PlatformType.ApplicationWithServices,...
            'Platform Type must be either Function or ApplicationWithServices for service folders to exist. Detected: %s',this.PlatformType);
            switch this.PlatformType
            case coder.internal.rte.PlatformType.Function
                rteFolders=this.getFunctionPlatformFolders(buildFolder);
            case coder.internal.rte.PlatformType.ApplicationWithServices
                rteFolders=this.getApplicationWithServicesPlatformFolders(buildFolder);
            otherwise
                assert(false,'Unexpected platform type encountered: %s',this.PlatformType);
            end
        end
    end

    methods(Access=private)
        function setDeploymentType(this,mappingDeploymentType)





            switch mappingDeploymentType
            case 'Component'
                switch this.ModelReferenceTargetType
                case 'NONE'


                    this.DeploymentType=coder.internal.rte.DeploymentType.Component;
                case 'RTW'
                    DAStudio.error(...
                    'RTW:buildProcess:DeploymentTypeModelRefTargetTypeMismatch',...
                    'Referenced',this.Model,mappingDeploymentType,'Subcomponent');
                end
            case 'Subcomponent'
                switch this.ModelReferenceTargetType
                case 'NONE'
                    DAStudio.error(...
                    'RTW:buildProcess:DeploymentTypeModelRefTargetTypeMismatch',...
                    'Top',this.Model,mappingDeploymentType,'Component');
                case 'RTW'


                    this.DeploymentType=coder.internal.rte.DeploymentType.Subcomponent;
                end
            case{'Unset','Application'}





                switch this.ModelReferenceTargetType
                case 'NONE'
                    this.DeploymentType=coder.internal.rte.DeploymentType.Component;
                case 'RTW'
                    this.DeploymentType=coder.internal.rte.DeploymentType.Subcomponent;
                end
            otherwise
                assert(false,'Unexpected mapping.DeploymentType value was encountered: %s',mappingDeploymentType);
            end
        end
    end

    methods(Static,Access=private)
        function rteFolders=getApplicationWithServicesPlatformFolders(buildFolder)
            rteFolders.intFolder=fullfile(buildFolder,'services');
            rteFolders.libFolder='';
            rteFolders.impFolder=fullfile(buildFolder,'services','imp');
            rteFolders.exeFolder=fullfile(buildFolder,'exe');
        end
    end

    methods(Static,Access=public)
        function rteFolders=getFunctionPlatformFolders(buildFolder)
            rteFolders.intFolder=fullfile(buildFolder,'services');
            rteFolders.libFolder=fullfile(buildFolder,'services','lib');
            rteFolders.impFolder='';
            rteFolders.exeFolder='';
        end

        function cleanServiceInterfaceFolder(buildFolder)
            serviceFolders=coder.internal.rte.SDPTypes.getFunctionPlatformFolders(buildFolder);
            if isfolder(serviceFolders.intFolder)
                coder.make.internal.removeDir(serviceFolders.intFolder);
            end
        end

        function buildInfoFile=getBuildInfoFile(model,buildFolder)







            platformType=coder.dictionary.internal.getPlatformType(model);
            if platformType=="FunctionPlatform"
                mapping=Simulink.CodeMapping.getCurrentMapping(model);
                if isempty(mapping)
                    DAStudio.error('RTW:buildProcess:NoMappingForFunctionPlatform',model);
                end
                assert(isprop(mapping,'DeploymentType'),...
                'No DeploymentType property found in mapping used for Function Platform.');
                switch mapping.DeploymentType
                case 'Component'
                    buildInfoFolder=coder.internal.rte.SDPTypes.getFunctionPlatformFolders(...
                    buildFolder).libFolder;
                case 'Subcomponent'
                    buildInfoFolder=buildFolder;
                otherwise
                    assert(false,...
                    'Unexpected deployment type was detected for Function Platform: %s',...
                    mapping.DeploymentType);
                end
            else
                buildInfoFolder=buildFolder;
            end
            buildInfoFile=fullfile(buildInfoFolder,'buildInfo.mat');
        end
    end

end
