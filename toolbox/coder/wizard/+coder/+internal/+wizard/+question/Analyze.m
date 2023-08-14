

classdef Analyze<coder.internal.wizard.QuestionBase
    properties(Transient=true)
        AnalyzedSystem='';
        AnalyzedFlavor='';
        State='';
        FirstTimeRun=true
    end
    methods
        function obj=Analyze(env)
            id='Analyze';
            topic=message('RTW:wizard:Topic_Deployment').getString;
            obj@coder.internal.wizard.QuestionBase(id,topic,env);

            obj.getAndAddOption(env,'Analyze_Run');
            obj.SinglePane=true;
            obj.HasSummaryMessage=false;
        end
        function reset=resetStateIfNeeded(obj)
            reset=false;


            env=obj.Env;
            if env.isSubsystemBuild
                system=env.SourceSubsystem;
            else
                system=env.ModelName;
            end

            analyzedFlavorChanged=false;
            if~strcmp(env.Flavor,obj.AnalyzedFlavor)
                analyzedFlavorChanged=true;
            end

            analysisSystemChanged=false;
            if(~isempty(obj.AnalyzedSystem)&&~strcmp(system,obj.AnalyzedSystem))
                analysisSystemChanged=true;
            end

            hasModelChangedSinceLastAnalysis=false;
            if~isempty(env.AnalysisTimeStamp)
                modifiedTimeStamp=get_param(env.ModelName,'RTWModifiedTimeStamp');
                hasModelChangedSinceLastAnalysis=(env.AnalysisTimeStamp~=modifiedTimeStamp);
            end
            if obj.FirstTimeRun||hasModelChangedSinceLastAnalysis||analysisSystemChanged||analyzedFlavorChanged
                obj.changeToAnalyzeState;


                obj.reset;
                reset=true;
            end
        end
        function updateStateAfterAnalyze(obj)
            env=obj.Env;

            obj.changeToSuccessState;
            env.AnalysisTimeStamp=get_param(env.ModelName,'RTWModifiedTimeStamp');
            obj.Options{1}.updateStateAfterAnalyze;
            if env.isSubsystemBuild
                system=env.SourceSubsystem;
            else
                system=env.ModelName;
            end
            obj.TrailTable.Title=['<table width="100%"><tr><td style="text-align:left;border:none;">',message('RTW:wizard:AnalyzeResult',get_param(system,'Name')).getString,...
            '</td><td style="text-align:right;border:none;padding-right:5px;" class="warning">',message('RTW:wizard:ReadMoreOnAnalysis').getString,'</td></tr></table>'];
            obj.TrailTable.Content=obj.getAnalyzeResult;
            msg='';
            if env.UseContinuousSolver&&license('test','Control_Toolbox')
                msg=message('RTW:wizard:WarnContinuousState').getString;
                msg=['<p class="warning">',env.Gui.getWarningImage,msg,'</p>'];
            end
            if~env.isSubsystemBuild
                if~env.isSubsystemBuild&&strcmp(get_param(env.ModelHandle,'SolverType'),'Variable-step')
                    newMsg=[message('RTW:wizard:WarnVariableStepSolver').getString,' '];
                    newMsg=['<p class="warning">',env.Gui.getWarningImage,newMsg,'</p>'];
                    msg=[msg,newMsg];
                end
            end
            obj.TrailTable.TailMessage=msg;
        end
        function reset(obj)


            obj.Options{1}.reset;
            env=obj.Env;
            obj.TrailTable=loc_getInitAnalysisTable(env.isSubsystemBuild);
        end
        function preShow(obj)
            reset=obj.resetStateIfNeeded;
            obj.FirstTimeRun=false;
            if reset

                preShow@coder.internal.wizard.QuestionBase(obj);
            end
            if strcmp(obj.State,'Analyze')
                obj.QuestionMessage=message(obj.Question_Message_Id).getString;
                env=obj.Env;
                obj.TrailTable=loc_getInitAnalysisTable(env.isSubsystemBuild);
            elseif strcmp(obj.State,'Fail')

                obj.QuestionMessage=obj.getErrorMessage();
                obj.TrailTable='';
            elseif strcmp(obj.State,'Success')
                obj.QuestionMessage=message('RTW:wizard:AnalyzeDone').getString;
            end
        end
        function out=getErrorMessage(obj)
            msg1=['<p">',message('RTW:wizard:AnalyzeFail').getString,'</p>'];
            msg2=['<p>',message('RTW:wizard:AnalyzeFailModelCompile').getString,'</p><br /><br />'];
            out=obj.constructErrorText(msg1,msg2);
        end
        function out=getAnalyzeResult(obj)
            env=obj.Env;
            if env.isSubsystemBuild
                rate=env.SubsystemSampleTime;
            else
                rate=env.ModelSampleTime;
            end
            if isempty(rate)
                out='';
                return;
            end
            out='<table id="analysisSummaryTbl">';
            out=[out,'<tr>'];
            out=[out,'<tr><td>',message('RTW:wizard:SampleRate').getString,'</td><td></td><td>'];
            if rate.SingleRate
                out=[out,message('RTW:wizard:SingleRate').getString];
                if~isempty(rate.FiniteRates)
                    out=[out,' (',num2str(rate.FiniteRates),' ',message('RTW:wizard:Second').getString,')'];
                end
            else
                out=[out,message('RTW:wizard:MultiRate',num2str(rate.NumFiniteRate)).getString];
            end
            out=[out,'</td></tr>'];
            if~env.isSubsystemBuild
                out=[out,'<tr><td>',message('RTW:wizard:HasContinuousState').getString,'</td><td></td><td>'];
                if env.UseContinuousSolver
                    out=[out,message('RTW:wizard:Yes').getString];
                    if license('test','Control_Toolbox')
                        out=[out,'<span class="warning">',env.Gui.getWarningImage,'</span>'];
                    end
                else
                    out=[out,message('RTW:wizard:No').getString];
                end
            end
            out=[out,'<tr><td>',message('RTW:wizard:ExportFcnCalls').getString,'</td><td></td><td>'];
            if env.ExportedFunctionCalls
                out=[out,message('RTW:wizard:Yes').getString];
            else
                out=[out,message('RTW:wizard:No').getString];
            end
            out=[out,'<tr><td>',message('RTW:wizard:HasRefMdl').getString,'</td><td></td><td>'];
            if~isempty(env.SubModels)
                out=[out,message('RTW:wizard:Yes').getString];
            else
                out=[out,message('RTW:wizard:No').getString];
            end
            out=[out,'</td></tr></table>'];
        end
        function updateAnalyzedSystem(obj)
            env=obj.Env;
            if env.isSubsystemBuild
                obj.AnalyzedSystem=env.SourceSubsystem;
            else
                obj.AnalyzedSystem=env.ModelName;
            end
            obj.AnalyzedFlavor=env.Flavor;
        end
        function changeToFailedState(obj)
            obj.State='Fail';
            obj.updateAnalyzedSystem;
        end
        function changeToSuccessState(obj)
            obj.State='Success';
            obj.updateAnalyzedSystem;
        end
        function changeToAnalyzeState(obj)
            obj.State='Analyze';
        end
    end
end


function TrailTable=loc_getInitAnalysisTable(isSubsystemBuild)
    TrailTable.Title=['<table width="100%"><tr><td style="text-align:left;border:none;">',message('RTW:wizard:QuestionHint_AnalyzeTitle').getString,...
    '</td><td style="text-align:right;border:none;padding-right:5px;" class="warning">',message('RTW:wizard:ReadMoreOnAnalysis').getString,'</td></tr></table>'];
    if isSubsystemBuild
        TrailTable.Content=message('RTW:wizard:QuestionHint_Analyze_Subsystem').getString;
    else
        TrailTable.Content=message('RTW:wizard:QuestionHint_Analyze').getString;
    end
    TrailTable.TailMessage='';
end

