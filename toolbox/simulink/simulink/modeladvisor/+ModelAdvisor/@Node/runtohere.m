function runtohere





    mdladvObj=Simulink.ModelAdvisor.getFocusModelAdvisorObj;
    if(isempty(mdladvObj))
        mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    end

    if isa(mdladvObj,'Simulink.ModelAdvisor')
        me=mdladvObj.MAExplorer;
        if isa(me,'DAStudio.Explorer')
            imme=DAStudio.imExplorer(me);
            selectedNode=Advisor.Utils.convertMCOS(imme.getCurrentTreeNode);
            runToBreakpoint(selectedNode);
        end
    end

    function runToBreakpoint(this)


        this.MAObj.Breakpoint=this;



        try

            needClearStartTime=false;
            if this.MAObj.StartTime==0
                this.MAObj.StartTime=now;
                needClearStartTime=true;
            end


            startNode=this;
            CallGraph=startNode;
            if~this.Enable
                while isa(startNode,'ModelAdvisor.Task')&&~startNode.Enable
                    startNode=startNode.PreviousInProcedureCallGraph;
                    if length(startNode)>1
                        startNode=startNode(1);
                    end
                    if isa(startNode,'ModelAdvisor.Task')
                        CallGraph(end+1)=startNode;%#ok<AGROW>
                    end
                end
            end

            for i=length(CallGraph):-1:1
                startNode=CallGraph(i);
                if~startNode.Enable



                    if isa(this.MAObj.MAExplorer,'DAStudio.Explorer')
                        imme=DAStudio.imExplorer(this.MAObj.MAExplorer);
                        if i<length(CallGraph)
                            imme.selectTreeViewNode(CallGraph(i+1));
                        end
                    end
                    break
                end


                if isa(this.MAObj.MAExplorer,'DAStudio.Explorer')


                    this.MAObj.MAExplorer.highlight(startNode,[0.5,0.5,1]);
                    startNode.runTaskAdvisor;
                    this.MAObj.MAExplorer.unhighlight(startNode);
                else
                    startNode.runTaskAdvisor;
                end
                if strcmp(startNode.ID,this.MAObj.Breakpoint.ID)

                    break
                end
            end

            this.MAObj.Breakpoint=[];
            if this.MAObj.HasCompiled||this.MAObj.HasCompiledForCodegen
                modeladvisorprivate('modeladvisorutil2','TerminateModelCompile',this.MAObj);
            end
            if this.MAObj.HasCGIRed
                modeladvisorprivate('modeladvisorutil2','TermCGIRModelCompile',this.MAObj);
            end
        catch E

            if needClearStartTime
                this.MAObj.StartTime=0;
            end

            this.MAObj.Breakpoint=[];
            if this.MAObj.HasCompiled||this.MAObj.HasCompiledForCodegen
                modeladvisorprivate('modeladvisorutil2','TerminateModelCompile',this.MAObj);
            end
            if this.MAObj.HasCGIRed
                modeladvisorprivate('modeladvisorutil2','TermCGIRModelCompile',this.MAObj);
            end
            rethrow(E);
        end


        if needClearStartTime
            this.MAObj.StartTime=0;
        end


        if(isa(this,'ModelAdvisor.Group')&&this.LaunchReport)||(isjava(this.MAObj.BrowserWindow)&&this.MAObj.BrowserWindow.isShowing)
            this.viewReport('');
        end


