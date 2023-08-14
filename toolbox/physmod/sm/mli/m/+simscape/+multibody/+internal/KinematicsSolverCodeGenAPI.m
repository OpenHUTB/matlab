classdef KinematicsSolverCodeGenAPI<coder.ExternalDependency






%#codegen

    methods(Static)

        function bName=getDescriptiveName(~)
            bName='KinematicsSolverCodeGenAPI';
        end

        function tf=isSupportedContext(buildContext)


            if buildContext.isTargetLanguageC&&...
                (buildContext.isCodeGenTarget('mex')||...
                buildContext.isCodeGenTarget('sfun')||...
                (buildContext.isCodeGenTarget('rtw')&&...
                (strcmpi('dll',buildContext.getConfigProp('OutputType'))||...
                strcmpi('lib',buildContext.getConfigProp('OutputType')))))
                tf=true;
            else
                tf=false;
                pm_error('sm:mli:kinematicsSolver:UnsupportedCodegenConfig');
            end
        end

        function updateBuildInfo(buildInfo,~)




            buildConfiguration=physmod.deploy.internal.BuildConfiguration({'sm_ssci'});
            buildInfo.addIncludePaths(buildConfiguration.IncludePath);
            buildInfo.addSourceFiles(buildConfiguration.SourceFiles);
        end

        function[outputVals,status,targetSuccess,actTargetVals]=solveKinematics(...
            mdlName,...
            expTargetVals,...
            initGuessVals,...
            outputVals,...
            targetSuccess,...
            actTargetVals)

            coder.allowpcode('plain');
            status=0.0;%#ok<*NASGU>








            persistent ksDataWrapper;
            if isempty(ksDataWrapper)
                ksDataWrapper=simscape.multibody.internal.KinematicsSolverDataWrapper(mdlName);
            end


            status=coder.ceval(...
            [mdlName,'_solve_kinematics'],...
            ksDataWrapper.ksData,...
            coder.rref(expTargetVals),coder.rref(initGuessVals),...
            coder.wref(outputVals),...
            coder.wref(targetSuccess),coder.wref(actTargetVals));

        end
    end
end


