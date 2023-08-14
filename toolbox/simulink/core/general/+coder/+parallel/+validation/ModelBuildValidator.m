classdef ModelBuildValidator<coder.parallel.validation.interfaces.IModelBuildValidator





    methods
        function isValid=validate(~,...
            iMdl,...
            nTotalMdls,...
            nLevels,...
            targetType,...
            mdlsHaveUnsavedChanges)


            isValid=false;


            if~strcmp(get_param(iMdl,'EnableParallelModelReferenceBuilds'),'on')
                return;
            end

            if mdlsHaveUnsavedChanges


                return;
            end



            slObj=get_param(iMdl,'slobject');
            simInput=slObj.getSimInput();
            if~isempty(simInput)&&(~isempty(simInput.Variables)||~isempty(simInput.BlockParameters))
                return;
            end


            if coder.make.internal.featureOn('SingleMdlRefAllowedForTesting')

                modelRefsAreInAChain=false;
            else
                modelRefsAreInAChain=nTotalMdls==nLevels;
            end

            if modelRefsAreInAChain




                return;
            end


            if~strcmp(get_param(iMdl,'ParMdlRefBuildCompliant'),'on')
                return;
            end


            if coder.coverage.CodeCoverageHook.enabledForModel(iMdl)&&strcmp(targetType,'RTW')


                MSLDiagnostic('Simulink:slbuild:CoverageParallelBuild',iMdl).reportAsWarning;
                return;
            end


            isValid=true;
        end
    end
end

