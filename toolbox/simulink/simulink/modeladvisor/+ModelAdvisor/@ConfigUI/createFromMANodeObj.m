function this=createFromMANodeObj(nodeobj)












    this=ModelAdvisor.ConfigUI;

    this.ID=nodeobj.ID;
    this.OriginalNodeID=nodeobj.ID;
    this.Protected=true;
    this.MAObj=nodeobj.MAObj;
    this.DisplayName=nodeobj.DisplayName;
    this.Description=nodeobj.Description;
    this.HelpMethod=nodeobj.HelpMethod;
    this.HelpArgs=nodeobj.HelpArgs;
    this.Selected=nodeobj.Selected;
    this.InTriState=nodeobj.InTriState;
    this.NeedToggleForTriState=nodeobj.NeedToggleForTriState;


    if isa(nodeobj,'ModelAdvisor.Task')
        this.Type='Task';
        this.MACIndex=nodeobj.MACIndex;
        this.MAC=nodeobj.MAC;
        if nodeobj.MACIndex>0
            am=Advisor.Manager.getInstance;
            this.SupportsEditTime=am.slCustomizationDataStructure.checkCellArray{nodeobj.MACIndex}.SupportsEditTime;
            this.isBlockConstraintCheck=am.slCustomizationDataStructure.checkCellArray{nodeobj.MACIndex}.getIsBlockConstraintCheck();
        end











    elseif isa(nodeobj,'ModelAdvisor.Procedure')
        this.Type='Procedure';
        for i=1:length(nodeobj.ChildrenObj)
            this.ChildrenObj{end+1}=nodeobj.ChildrenObj{i}.Index;
        end
        this.InputParameters=nodeobj.InputParameters;
        this.InputParametersLayoutGrid=nodeobj.InputParametersLayoutGrid;
    elseif isa(nodeobj,'ModelAdvisor.Group')||isa(nodeobj,'ModelAdvisor.FactoryGroup')
        this.Type='Group';
        for i=1:length(nodeobj.ChildrenObj)
            this.ChildrenObj{end+1}=nodeobj.ChildrenObj{i}.Index;
        end
        this.InputParameters=nodeobj.InputParameters;
        this.InputParametersLayoutGrid=nodeobj.InputParametersLayoutGrid;
    else
        this.Type='Task';
    end

    this.Visible=nodeobj.Visible;
    this.Enable=nodeobj.Enable;
    this.Value=nodeobj.Value;
    this.Published=nodeobj.Published;
    this.ShowCheckbox=nodeobj.ShowCheckbox;
    this.LicenseName=nodeobj.LicenseName;
    this.CSHParameters=nodeobj.CSHParameters;
    this.ByTaskMode=nodeobj.ByTaskMode;

    if~isempty(nodeobj.ParentObj)




        this.ParentObj=nodeobj.ParentObj.Index;
    end


end