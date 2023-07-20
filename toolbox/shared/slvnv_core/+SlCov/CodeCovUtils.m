



classdef CodeCovUtils<SlCov.Utils

    methods(Static)





        function out=isXILCoverageEnabled(topModelName,modelName,isSIL,varargin)


            if~any(strcmp(topModelName,find_system('type','block_diagram','name',topModelName)))
                load_system(topModelName);
                clr=onCleanup(@()close_system(topModelName,0));
            end



            covSettings=slprivate('getCodeCoverageSettings',topModelName);
            if~strcmpi(covSettings.CoverageTool,SlCov.getCoverageToolName())
                out=false;
                return
            end


            if strcmp(modelName,topModelName)

                out=strcmpi(covSettings.TopModelCoverage,'on');

            else

                if SlCov.CodeCovUtils.isAtomicSubsystem(topModelName)||...
                    SlCov.CodeCovUtils.isReusableLibrarySubsystem(topModelName)
                    harnessInfo=Simulink.harness.internal.getHarnessInfoForHarnessBD(topModelName);
                    if~isempty(harnessInfo)
                        if strcmp(modelName,harnessInfo.model)||...
                            strcmp(modelName,get_param(topModelName,'XILModelName'))
                            out=true;
                        else


                            out=false;
                        end
                        return
                    end
                end


                if~strcmpi(covSettings.ReferencedModelCoverage,'on')
                    out=false;
                    return
                end


                if~strcmpi(get_param(topModelName,'CovModelRefEnable'),'filtered')
                    out=true;
                    return
                end


                modelInfo=SlCov.Utils.extractExcludedModelInfo(get_param(topModelName,'CovModelRefExcluded'));
                if isSIL
                    fName='sil';
                else
                    fName='pil';
                end
                out=~ismember(modelName,modelInfo.(fName));
            end

        end




        function ret=isAtomicSubsystem(model)
            ret=SlCov.isATSCodeCovFeatureOn()&&...
            coder.connectivity.XILSubsystemUtils.isAtomicSubsystem(model);
        end




        function ret=isReusableLibrarySubsystem(model)
            ret=coder.connectivity.XILSubsystemUtils.isRLS(model);
        end
    end

end


