




classdef ParameterInfoGetter<Simulink.ModelReference.ProtectedModel.Creator
    properties
originalParamsToObfuscatedIds
    end

    methods
        function obj=ParameterInfoGetter(input)
            import Simulink.ModelReference.ProtectedModel.*;
            obj=obj@Simulink.ModelReference.ProtectedModel.Creator(input);
            obj.AccessibleVarNames={};
            obj.AccessibleSigNames={};
        end
        function vars=get(obj)
            obj.protect();
            vars=obj.originalParamsToObfuscatedIds;
        end
        function vars=getSignalsAndParams(obj)
            obj.protect();
            vars=struct;
            vars.Parameters=obj.UnprotectedParamIdToProtectedId;
            vars.Signals=obj.UnprotectedSigIdToProtectedId;
        end
        function[harnessHandle,neededVars]=doProtect(obj,harnessHandle)

            neededVars={};%#ok<NASGU>




            obj.updateProgress(15,'ProtectedModelPhaseConfig');


            obj.protectingMode('on');


            protectCleanup=onCleanup(@obj.exitProtection);
            directoryCleanup=onCleanup(@obj.backToInitialDir);



            obj.build();


            lModelReferenceTargetTypeList=obj.getAllModelReferenceTargetTypes();
            neededVars=obj.findNeededVariables(obj.ModelName,obj.SubModels,lModelReferenceTargetTypeList);


            clear protectCleanup directoryCleanup;

            obj.provideParamMappingForVars(neededVars);

            obj.restoreLdStatus();


            obj.clearPasswords();
        end

        function out=generatingObfuscatedParameterMapping(~)
            out=true;
        end








        function out=provideParamMappingForVars(obj,neededVars)
            identifierMap={};


            if isempty(obj.UnprotectedParamIdToProtectedId)
                out=neededVars;
                return;
            end



            for i=1:length(neededVars)
                currentVar=neededVars{i};
                if isKey(obj.UnprotectedParamIdToProtectedId,currentVar)
                    identifierMap{end+1}={currentVar,obj.UnprotectedParamIdToProtectedId(currentVar)};%#ok<AGROW>
                else
                    identifierMap{end+1}={currentVar,''};%#ok<AGROW>
                end
            end
            obj.originalParamsToObfuscatedIds=identifierMap;


        end
    end
    methods(Access=protected)
        function checkModelConfig(obj)

        end
    end

end


