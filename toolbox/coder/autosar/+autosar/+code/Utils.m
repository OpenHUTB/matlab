classdef Utils<handle




    methods(Static)
        function OkToReplace=shouldReplaceRTWTypesWithARTypes(modelName)
            if Simulink.CodeMapping.isAutosarAdaptiveSTF(modelName)
                OkToReplace=false;
            elseif strcmp(get_param(modelName,'EnableUserReplacementTypes'),'off')
                OkToReplace=true;
            else
                OkToReplace=autosar.code.Utils.isDTReplacementConsistentWithARTypes(modelName);
            end
        end
    end

    methods(Static,Access=private)
        function[isConsistent,inconsistentTypes]=isDTReplacementConsistentWithARTypes(modelName)





            inconsistentTypes=[];
            assert(strcmp(get_param(modelName,'EnableUserReplacementTypes'),'on'),...
            'EnableUserReplacementTypes is not enabled for model:%s',modelName);



            slToRTWTypeMap=containers.Map(...
            {'double','single','boolean','int8','int16','int32',...
            'uint8','uint16','uint32','int','uint','char','uint64','int64'},...
            {'real_T','real32_T','boolean_T','int8_T','int16_T','int32_T',...
            'uint8_T','uint16_T','uint32_T','int_T','uint_T','char_T','uint64_T','int64_T'});



            rtwToPlatformTypeMap=autosar.mm.util.BuiltInTypeMapper.getRTWToPlatformTypeMap(modelName);


            repTypes=get_param(modelName,'ReplacementTypes');
            slTypes=fieldnames(repTypes);
            for idx=1:length(slTypes)
                slType=slTypes{idx};
                actualRepType=repTypes.(slType);
                rtwType=slToRTWTypeMap(slType);








                expectedRepType=rtwToPlatformTypeMap(rtwType);
                if~strcmp(rtwType,'char_T')&&~strcmp(actualRepType,expectedRepType)
                    inconsistentType=struct(...
                    'CodeGenTypeNames',rtwType,...
                    'ActualReplacementNames',actualRepType,...
                    'ExpectedReplacementNames',expectedRepType);
                    inconsistentTypes=[inconsistentTypes,inconsistentType];%#ok<AGROW>
                end
            end

            isConsistent=isempty(inconsistentTypes);
        end
    end
end
