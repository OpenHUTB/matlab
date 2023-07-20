function checkTopModelProfilingConfig(model,lTopOfBuildModel,...
    lTopModelStandalone,lTopModelXILBuild,isSimulationBuild,...
    lCodeExecutionProfiling,lCodeStackProfiling,...
    lCodeProfilingWCETAnalysis,lIsExtModeXCP)





    if lTopModelStandalone&&~lCodeExecutionProfiling&&...
        ~strcmp(get_param(model,'CodeProfilingInstrumentation'),'off')&&...
        ~isSimulationBuild
        DAStudio.error('CoderProfile:ExecutionTime:ExecutionProfilingOff',...
        model,lTopOfBuildModel);
    end

    if lCodeExecutionProfiling&&lCodeStackProfiling
        DAStudio.error('CoderProfile:ExecutionStack:ProfilingEnabled',model);
    end

    if lCodeExecutionProfiling
        if lTopModelStandalone


            if~lTopModelXILBuild&&~isSimulationBuild&&~lIsExtModeXCP&&...
                strcmp(model,lTopOfBuildModel)&&...
                strcmp(get_param(model,'GRTInterface'),'on')
                DAStudio.error('CoderProfile:ExecutionTime:StandaloneBuildWithGRTInterfaceOn',...
                model);
            end

            if strcmp(get_param(model,'CreateSILPILBlock'),'SIL')&&...
                strcmp(silblocktype,'legacy')

                lTaskProfilingPrompt=DAStudio.message('RTW:configSet:ERTDialogSilPilExecProfiling');
                DAStudio.error('CoderProfile:ExecutionTime:ClassicSILBlockNoProfiling',...
                lTaskProfilingPrompt);
            end


            tlcOpts=lower(get_param(model,'TLCOptions'));
            tlcProfEnabled=regexp(tlcOpts,'-aprofilegencode\s*=\s*1');
            if tlcProfEnabled
                DAStudio.error('CoderProfile:ExecutionTime:TLCProfilingEnabled',model);
            end

            nonSilPilCodeProfilingSTFs={...
            'slrt.tlc',...
            'slrtert.tlc',...
            'slrealtime.tlc',...
            'grt_profiling_test.tlc',...
            'xpctarget.tlc',...
            'xpctargetert.tlc'};
            if~lTopModelXILBuild&&~isSimulationBuild&&strcmp(model,lTopOfBuildModel)&&...
                ~strcmp(get_param(model,'IsERTTarget'),'on')&&...
                ~any(strcmp(get_param(model,'SystemTargetFile'),nonSilPilCodeProfilingSTFs))
                if lIsExtModeXCP
                    DAStudio.error('CoderProfile:ExecutionTime:XCPSTFNotSupported');
                else
                    DAStudio.error('CoderProfile:ExecutionTime:StandaloneSTFNotSupported');
                end
            end
        end

        lWorkspaceVar=get_param(model,'CodeExecutionProfileVariable');
        if~isvarname(lWorkspaceVar)
            DAStudio.error('CoderProfile:ExecutionTime:InvalidExecutionProfileVariable',...
            model,lWorkspaceVar);
        end

        if lIsExtModeXCP








            i_checkXCPSettings(model);
        end
    end

    if lCodeStackProfiling
        if ismac
            DAStudio.error('CoderProfile:ExecutionStack:ProfilingOnMac');
        end
        if Simulink.ModelReference.ProtectedModel.protectingModel(model)
            DAStudio.error('CoderProfile:ExecutionStack:ProfilingWithProtectedModel');
        end
        if lIsExtModeXCP
            DAStudio.error('CoderProfile:ExecutionStack:ProfilingNotSIL','Measure task stack usage');
        end
        lWorkspaceVar=get_param(model,'CodeStackProfileVariable');
        if~isvarname(lWorkspaceVar)
            DAStudio.error('CoderProfile:ExecutionStack:InvalidStackProfileVariable',...
            model,lWorkspaceVar);
        end
    end

    if lCodeProfilingWCETAnalysis
        if~lCodeExecutionProfiling
            DAStudio.error('CoderProfile:ExecutionTime:WCETWithoutTaskProfiling',model);
        end
        if Simulink.ModelReference.ProtectedModel.protectingModel(model)
            DAStudio.error('CoderProfile:ExecutionTime:WCETWithProtectedModel');
        end
        if lIsExtModeXCP
            DAStudio.error('CoderProfile:ExecutionTime:WCETNotSIL',model);
        end
    end
end


function i_checkXCPSettings(model)

    if~coder.internal.connectivity.featureOn('XcpBigEndian')
        assert(strcmp(get_param(model,'TargetEndianess'),'LittleEndian'),...
        'BigEndian targets not supported yet');
    end
    if~any(get_param(model,'TargetWordSize')==[8,16,32,64])
        DAStudio.error('CoderProfile:ExecutionTime:XCPNoSupportedWordSize');
    end
    if strcmp(get_param(model,'GRTInterface'),'on')
        DAStudio.error('CoderProfile:ExecutionTime:XCPParameterNotValid','GRTInterface','off');
    end

end
