function dlgstruct=getDialogSchema(this,~)





    row=1;

    if~isempty(this.CustomDialogSchema)
        if nargin(this.CustomDialogSchema)~=1
            [addonStruct]=this.CustomDialogSchema();
        else
            [addonStruct]=this.CustomDialogSchema(this);
        end

    elseif strcmp(this.ID,'com.mathworks.FPCA.FixedPointConversionTask')
        [addonStruct]=createFPCAContainerNode(this);
    elseif strcmp(this.ID,'com.mathworks.HDL.WorkflowAdvisor')
        [addonStruct]=createHDLContainerNode(this);
    elseif strcmp(this.ID,'SysRoot')
        [addonStruct]=createDialogForRoot(this);
    elseif~isempty(this.StartMessage)
        [addonStruct]=createCustomRoot(this);
    else
        [addonStruct]=createContainerDialog(this,row);
    end


    dlgstruct.DialogTitle=[this.DisplayName];
    dlgstruct.LayoutGrid=[6,10];
    dlgstruct.RowStretch=[0,0,0,0,0,1];
    dlgstruct.ColStretch=[0,0,0,0,0,0,0,0,0,0];




    if isempty(this.HelpMethod)
        if~isempty(this.CSHParameters)&&isfield(this.CSHParameters,'MapKey')&&...
            isfield(this.CSHParameters,'TopicID')
            mapkey=['mapkey:',this.CSHParameters.MapKey];
            topicid=this.CSHParameters.TopicID;
            dlgstruct.HelpMethod='helpview';
            dlgstruct.HelpArgs={mapkey,topicid,'CSHelpWindow'};
        else
            dlgstruct.HelpMethod='helpview';
            dlgstruct.HelpArgs={[docroot,'/mapfiles/simulink.map'],'model_advisor'};
        end
    else
        dlgstruct.HelpMethod=this.HelpMethod;
        dlgstruct.HelpArgs=this.HelpArgs;
    end

    dlgstruct.Items=addonStruct.Items(1:end);
    if isa(this,'ModelAdvisor.Task')||~isempty(this.InputParameters)
        dlgstruct.EmbeddedButtonSet={'Help','Apply'};
    else
        dlgstruct.EmbeddedButtonSet={'Help'};
    end
    dlgstruct.SmartApply=true;
    addOnFields=fieldnames(addonStruct);
    for i=1:length(addOnFields)
        if~strcmp(addOnFields{i},'Items')
            dlgstruct.(addOnFields{i})=addonStruct.(addOnFields{i});
        end
    end






