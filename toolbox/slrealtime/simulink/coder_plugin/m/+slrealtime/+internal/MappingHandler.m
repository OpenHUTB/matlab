classdef MappingHandler





    properties(Constant,Access=private)
        ModelParamPageSwitching='PageSwitching';
        ExternalParamPageSwitching='PageSwitching (slrealtime)';
    end

    methods(Static)
        function createMappingIfNecessary(model)


            mappingType='SimulinkCoderCTarget';


            h=get_param(model,'handle');
            mappingObj=Simulink.CodeMapping.get(h,mappingType);
            if isempty(mappingObj)
                modelName=get_param(model,'Name');
                Simulink.CodeMapping.create(modelName,'init',mappingType);


                mapping=coder.mapping.api.get(h,'SimulinkCoderC');


                dirty=get_param(h,'Dirty');

                mapping.setDataDefault('ModelParameters',...
                'StorageClass',slrealtime.internal.MappingHandler.ModelParamPageSwitching);
                if coderdictionary.data.feature.getFeature('SLRTPageSwitchingForExternalParameters')
                    mapping.setDataDefault('ExternalParameters',...
                    'StorageClass',slrealtime.internal.MappingHandler.ExternalParamPageSwitching);
                end

                set_param(h,'Dirty',dirty);
            else
                if coderdictionary.data.feature.getFeature('SLRTPageSwitchingForExternalParameters')




                    fileName=get_param(model,'FileName');
                    if~isempty(fileName)&&isfile(fileName)
                        rel=Simulink.MDLInfo.getReleaseName(fileName);
                        if simulink_version(rel)<simulink_version('R2021b')||strcmp(rel,'R2021a')
                            mapping=coder.mapping.api.get(h,'SimulinkCoderC');
                            defaultI18n=message('coderdictionary:mapping:SimulinkGlobal').getString;
                            previousExternalSc=mapping.getDataDefault('ExternalParameters','StorageClass');
                            if ismember(previousExternalSc,{'Default',defaultI18n})
                                mapping.setDataDefault('ExternalParameters',...
                                'StorageClass',slrealtime.internal.MappingHandler.ExternalParamPageSwitching);
                            end
                        end
                    end
                end
            end
        end


        function onSwitchTargetFromSimulinkRealTime(model)





            mappingType='SimulinkCoderCTarget';
            h=get_param(model,'handle');
            mappingObj=Simulink.CodeMapping.get(h,mappingType);
            if isempty(mappingObj)
                return;
            end

            mapping=coder.mapping.api.get(model,'SimulinkCoderC');



            unresolvedStr=message('coderdictionary:mapping:UnresolvedCell').getString;

            slrtModelSc=mapping.getDataDefault('ModelParameters','StorageClass');
            if ismember(slrtModelSc,{slrealtime.internal.MappingHandler.ModelParamPageSwitching,unresolvedStr})
                mapping.setDataDefault('ModelParameters','StorageClass','Default');
            end

            if coderdictionary.data.feature.getFeature('SLRTPageSwitchingForExternalParameters')
                slrtExternalSc=mapping.getDataDefault('ExternalParameters','StorageClass');
                if ismember(slrtExternalSc,{slrealtime.internal.MappingHandler.ExternalParamPageSwitching,unresolvedStr})
                    mapping.setDataDefault('ExternalParameters','StorageClass','Default');
                end
            end

        end


        function onSwitchTargetToSimulinkRealTime(model)


            slrealtime.internal.MappingHandler.createMappingIfNecessary(model);



            mapping=coder.mapping.api.get(model,'SimulinkCoderC');

            defaultI18n=message('coderdictionary:mapping:SimulinkGlobal').getString;



            previousModelSc=mapping.getDataDefault('ModelParameters','StorageClass');
            if ismember(previousModelSc,{'Default',defaultI18n})
                mapping.setDataDefault('ModelParameters',...
                'StorageClass',slrealtime.internal.MappingHandler.ModelParamPageSwitching);
            end

            if coderdictionary.data.feature.getFeature('SLRTPageSwitchingForExternalParameters')


                previousExternalSc=mapping.getDataDefault('ExternalParameters','StorageClass');
                if ismember(previousExternalSc,{'Default',defaultI18n})
                    mapping.setDataDefault('ExternalParameters',...
                    'StorageClass',slrealtime.internal.MappingHandler.ExternalParamPageSwitching);
                end
            end
        end
    end
end



