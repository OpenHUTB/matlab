function nodeobj=convertTaskAdvisor(this)




    if isa(this.MAObj,'Simulink.ModelAdvisor')
        maobjvalid=true;
    else
        maobjvalid=false;
    end

    switch this.Type
    case 'Task'
        nodeobj=ModelAdvisor.Task;
        nodeobj.MAC=this.MAC;


        nodeobj.MACIndex=this.MACIndex;
        nodeobj.Severity=this.Severity;
    case 'Group'



        nodeobj=ModelAdvisor.Group('dummy');

        for i=1:length(this.ChildrenObj)
            nodeobj.Children{end+1}=this.ChildrenObj{i}.ID;
        end
    case 'Procedure'
        nodeobj=ModelAdvisor.Procedure('dummy');
        for i=1:length(this.ChildrenObj)
            nodeobj.Children{end+1}=this.ChildrenObj{i}.ID;
        end
    otherwise
        nodeobj=ModelAdvisor.Task;
    end

    if maobjvalid
        nodeobj.CallbackFcnPath=this.MAObj.ConfigFilePath;
    end
    nodeobj.ID=this.ID;
    nodeobj.DisplayName=this.DisplayName;
    if~isstruct(this)
        nodeobj.Description=this.Description;
        nodeobj.HelpMethod=this.HelpMethod;
        nodeobj.HelpArgs=this.HelpArgs;
        nodeobj.InTriState=this.InTriState;
        nodeobj.NeedToggleForTriState=this.NeedToggleForTriState;
        nodeobj.Visible=this.Visible;
        nodeobj.Value=this.Value;
        nodeobj.ShowCheckbox=this.ShowCheckbox;
        nodeobj.LicenseName=this.LicenseName;
    end
    nodeobj.CSHParameters=this.CSHParameters;
    nodeobj.Selected=this.Selected;
    nodeobj.Enable=this.Enable;

    nodeobj.Published=this.Published;
    nodeobj.MAObj=this.MAObj;
    nodeobj.ByTaskMode=false;
    if~isempty(nodeobj.ParentObj)




        this.ParentObj=nodeobj.ParentObj.Index;
    end

    if~isempty(this.InputParameters)
        if maobjvalid

            if ismember(this.Type,{'Group','Procedure'})
                am=Advisor.Manager.getInstance;
                correspondingNode=am.slCustomizationDataStructure.TaskAdvisorIDMap(this.OriginalNodeID);
                nodeobj.InputParameters=modeladvisorprivate('modeladvisorutil2','DeepCopy',correspondingNode.InputParameters);
                nodeobj.InputParametersLayoutGrid=correspondingNode.InputParametersLayoutGrid;
                nodeobj.InputParametersCallback=correspondingNode.InputParametersCallback;

                for i=1:length(nodeobj.InputParameters)
                    nodeobj.InputParameters{i}.Value=this.InputParameters{i}.Value;
                    nodeobj.InputParameters{i}.Visible=this.InputParameters{i}.Visible;
                end





            end
        end
    end
