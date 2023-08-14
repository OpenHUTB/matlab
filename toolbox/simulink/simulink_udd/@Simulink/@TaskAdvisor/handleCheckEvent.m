function handleCheckEvent(this,tag,handle)






    switch_on=false;
    if handle.getWidgetValue(tag)
        switch_on=true;
    end

    if strcmp(tag,'CheckBox_All')
        if strcmp(this.CheckBoxMode,'All')
            childs=this.AllChildrenIndex;
            for i=1:length(childs)
                wf=this.MAObj.TaskAdvisorCellArray{childs{i}};
                if wf.MACIndex~=0
                    handle.setWidgetValue(['CheckBox_',num2str(childs{i})],switch_on);
                    wf.changeSelectionStatus(switch_on);
                end
            end
        elseif strcmp(this.CheckBoxMode,'Direct')
            for i=1:length(this.ChildrenObj)
                handle.setWidgetValue(['CheckBox_',num2str(this.ChildrenObj{i}.Index)],switch_on);
                this.ChildrenObj{i}.changeSelectionStatus(switch_on);
            end
        end
        handle.apply
    elseif strcmp(tag,'CheckBox_launchReport')||strcmp(tag,'CheckBox_WaiveFailure')

        handle.apply
    elseif strncmp(tag,'InputParameters_',length('InputParameters_'))
        ipIndex=str2double(tag(length('InputParameters_')+1:end));
        widgetValue=handle.getWidgetValue(tag);
        if strcmp(this.MAObj.CheckCellArray{this.MACindex}.InputParameters{ipIndex}.Type,'Enum')&&...
            isnumeric(widgetValue)


            this.MAObj.CheckCellArray{this.MACindex}.InputParameters{ipIndex}.Value=...
            this.MAObj.CheckCellArray{this.MACindex}.InputParameters{ipIndex}.Entries{widgetValue+1};
        elseif strcmp(this.MAObj.CheckCellArray{this.MACindex}.InputParameters{ipIndex}.Type,'PushButton')

            this.MAObj.CheckCellArray{this.MACindex}.InputParameters{ipIndex}.Entries();
        else
            this.MAObj.CheckCellArray{this.MACindex}.InputParameters{ipIndex}.Value=widgetValue;
        end
    elseif strcmp(tag,'ExploreSelectComboBox')
        widgetValue=handle.getWidgetValue('ExploreSelectComboBox');


        this.MAObj.CheckCellArray{this.MACindex}.SelectedListViewParamIndex=widgetValue+1;
    elseif strcmp(tag,'ListViewButton')

        if~isempty(this.MAObj.CheckCellArray{this.MACindex}.ListViewActionCallback)
            this.MAObj.CheckCellArray{this.MACindex}.ListViewActionCallback(this);
        end
        LVParamStruct=this.MAObj.CheckCellArray{this.MACindex}.ListViewParameters{this.MAObj.CheckCellArray{this.MACindex}.SelectedListViewParamIndex};
        this.MAObj.displayListView(LVParamStruct,this);
    else
        wf=this.MAObj.TaskAdvisorCellArray{str2double(tag(10:end))};
        wf.changeSelectionStatus(switch_on);
        handle.apply
    end

    ed=DAStudio.EventDispatcher;

    ed.broadcastEvent('PropertyChangedEvent',this);
