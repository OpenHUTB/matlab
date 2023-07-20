function dlgstruct=getDialogSchema(this,~)




    if~isempty(this.CustomDialogSchema)
        [addonStruct]=this.CustomDialogSchema(this);
    elseif this.MACIndex>0

        [addonStruct]=createDialogForMACheck(this,true);
    elseif this.MACIndex<=0

        [addonStruct]=createDialogForStubNode(this);
    else
        addonStruct.Items={};
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
    if isa(this,'ModelAdvisor.Task')
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








