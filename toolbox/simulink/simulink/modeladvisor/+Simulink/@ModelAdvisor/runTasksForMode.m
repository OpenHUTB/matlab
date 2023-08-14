function runTasksForMode(this,mode,selectedTaskIndices,selectedProceduresInfo)




    CurrentRunTimeStamp=this.StartTime;





    if~isempty(selectedTaskIndices)
        taskObj=this.TaskAdvisorCellArray{selectedTaskIndices{1}};
        if(taskObj.RunTime==CurrentRunTimeStamp)&&(CurrentRunTimeStamp~=0)

            return;
        end




    end


    this.CmdLine=true;
    this.MultiMode=true;


    root=this.TaskAdvisorRoot;


    if mode==Advisor.CompileModes.CommandLineSimulation
        this.HasCompiled=true;
    elseif mode==Advisor.CompileModes.RTW
        this.HasCompiledForCodegen=true;
    elseif mode==Advisor.CompileModes.CGIR
        this.HasCGIRed=true;
    elseif mode==Advisor.CompileModes.SLDV
        this.HasSLDVCompiled=true;
    else
        this.HasCompiled=false;
        this.HasCompiledForCodegen=false;
        this.HasCGIRed=false;
    end


    if~isempty(selectedTaskIndices)
        root.ExtensiveAnalysis=true;
        this.runCheck(selectedTaskIndices,root.OverwriteHTML,root);
    end



    if~isempty(selectedProceduresInfo)


        for n=1:length(selectedProceduresInfo)


            for ni=1:length(selectedProceduresInfo{n}.TaskIdxList)

                task=this.TaskAdvisorCellArray{selectedProceduresInfo{n}.TaskIdxList{ni}};




                if task.RunTime==CurrentRunTimeStamp&&...
                    ~loc_stopProcedureExecution(task)
                    continue;


                elseif task.RunTime==CurrentRunTimeStamp&&...
                    loc_stopProcedureExecution(task)
                    break;


                else
                    if Advisor.CompileModes.char2mode(task.Check.CallbackContext)==mode

                        task.runTaskAdvisor();


                        if loc_stopProcedureExecution(task)
                            break;
                        end
                    else
                        break;
                    end
                end
            end
        end
    end


    this.HasCompiled=false;
    this.HasCompiledForCodegen=false;
    this.HasCGIRed=false;
    this.CmdLine=false;
    this.MultiMode=false;

end

function status=loc_stopProcedureExecution(task)
    status=~task.Check.Success&&...
    ((task.Check.ErrorSeverity>0)||strcmp(task.Severity,'Required'));
end
