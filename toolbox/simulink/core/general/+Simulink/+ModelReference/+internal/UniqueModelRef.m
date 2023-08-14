classdef UniqueModelRef



    properties(SetAccess=immutable,GetAccess=public)




modelName
mode
protected
originalSimMode
isTopCodeInterface
    end

    properties(SetAccess=private,GetAccess=public)
simMode
    end

    methods
        function obj=UniqueModelRef(modelName,isNormal,protected,simMode,isTopCodeInterface)

            if nargin~=0
                nModels=numel(modelName);
                if nModels==0
                    obj=Simulink.ModelReference.internal.UniqueModelRef.empty(1,0);
                else
                    obj(1,nModels)=Simulink.ModelReference.internal.UniqueModelRef;
                    for kModel=1:nModels
                        obj(1,kModel).modelName=modelName{kModel};
                        obj(1,kModel).mode=isNormal;
                        obj(1,kModel).protected=protected;
                        obj(1,kModel).simMode=simMode;
                        obj(1,kModel).originalSimMode=simMode;
                        obj(1,kModel).isTopCodeInterface=isTopCodeInterface;
                    end
                end
            end
        end


        function obj=overrideSimMode(obj,lParentModel,lSimModeParent,lTopOfHierarchyModel,lIsRSim,lIsLicensedForEcoder,lIsModelRefSILPILOverride)
            import Simulink.ModelReference.internal.SimulationMode
            effectiveSimMode=obj.originalSimMode;

            lNormalModeString=lower(SimulationMode.SimulationModeNormal);
            lAccelModeString=lower(SimulationMode.SimulationModeAccel);
            lXILModeStrings=lower({SimulationMode.SimulationModeSIL,SimulationMode.SimulationModePIL});
            lChildIsXIL=ismember(lower(obj.originalSimMode),lXILModeStrings);
            lChildIsNormalOrAccel=ismember(lower(obj.originalSimMode),{lNormalModeString,lAccelModeString});



            if lIsModelRefSILPILOverride&&lChildIsXIL
                lChildIsXIL=false;
                lChildIsNormalOrAccel=true;
            end

            switch(lower(lSimModeParent))
            case lAccelModeString
                if lChildIsNormalOrAccel
                    effectiveSimMode=lSimModeParent;
                elseif lChildIsXIL&&~strcmp(lTopOfHierarchyModel,lParentModel)


                    obj.errorIncompatibleSimModes(lParentModel,lSimModeParent,obj.modelName,obj.originalSimMode);
                end
            case{'rapid-accelerator'}
                if lChildIsNormalOrAccel
                    effectiveSimMode=lSimModeParent;
                elseif lChildIsXIL

                    obj.errorIncompatibleSimModes(lParentModel,lSimModeParent,obj.modelName,obj.originalSimMode);
                end
            case lXILModeStrings
                if lChildIsNormalOrAccel
                    effectiveSimMode=lSimModeParent;
                elseif~strcmpi(lSimModeParent,obj.originalSimMode)

                    obj.errorIncompatibleSimModes(lParentModel,lSimModeParent,obj.modelName,obj.originalSimMode);
                end
            otherwise
                if obj.protected&&any(strcmpi(lSimModeParent,{'external','rapid-accelerator'}))
                    DAStudio.error('Simulink:protectedModel:ExternalModeAndProtectedModel');
                end

                if(~lIsLicensedForEcoder||lIsRSim)&&ismember(lower(effectiveSimMode),lXILModeStrings)




                    effectiveSimMode=lSimModeParent;
                end


                assert(isempty(lSimModeParent)||...
                any(strcmpi(lSimModeParent,{'normal','rapid-accelerator','external'})),...
                'Unexpected simulation mode');
            end
            if~strcmp(obj.simMode,effectiveSimMode)
                obj.simMode=effectiveSimMode;
            end
        end
    end

    methods(Static)
        function errorIncompatibleSimModes(model,simMode,childModel,childSimMode)
            simMode=strrep(lower(strtok(simMode,' ')),'-','_');
            childSimMode=strrep(lower(strtok(childSimMode,' ')),'-','_');

            simModeStr=DAStudio.message(['Simulink:modelReference:slMdlRef_',simMode]);
            obj.originalSimModeStr=DAStudio.message(['Simulink:modelReference:slMdlRef_',childSimMode]);

            DAStudio.error('Simulink:modelReference:slMdlRefIncompatibleSimModes',...
            model,simModeStr,childModel,obj.originalSimModeStr);
        end
    end
end