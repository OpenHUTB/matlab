function handleCheckEvent(this,tag,handle)






    switch_on=false;
    if handle.getWidgetValue(tag)
        switch_on=true;
    end

    if isa(this,'ModelAdvisor.Task')
        sourceObj=this.Check;
    else
        sourceObj=this;
    end

    if strcmp(tag,'CheckBox_launchReport')||strcmp(tag,'CheckBox_WaiveFailure')


        this.LaunchReport=switch_on;
    elseif strcmp(tag,'CheckBox_ExtensiveAnalysis')
        this.ExtensiveAnalysis=switch_on;
        if switch_on
            warndlgHandle=warndlg(DAStudio.message('ModelAdvisor:engine:MAExtensiveAnalysisGroupCBWarn'));
            set(warndlgHandle,'Tag','MAWarnExtensiveAnalysis');
            this.MAObj.DialogCellArray{end+1}=warndlgHandle;
        end
    elseif strncmp(tag,'InputParameters_',length('InputParameters_'))
        ipIndex=str2double(tag(length('InputParameters_')+1:end));
        widgetValue=handle.getWidgetValue(tag);
        if strcmp(sourceObj.InputParameters{ipIndex}.Type,'Enum')&&...
            isnumeric(widgetValue)


            sourceObj.InputParameters{ipIndex}.Value=...
            sourceObj.InputParameters{ipIndex}.Entries{widgetValue+1};
        elseif strcmp(sourceObj.InputParameters{ipIndex}.Type,'ComboBox')
            if isnumeric(widgetValue)
                sourceObj.InputParameters{ipIndex}.Value=...
                sourceObj.InputParameters{ipIndex}.Entries{widgetValue+1};
            elseif ischar(widgetValue)
                sourceObj.InputParameters{ipIndex}.Value=widgetValue;
            end
        elseif strcmp(sourceObj.InputParameters{ipIndex}.Type,'PushButton')


            sourceObj.InputParameters{ipIndex}.Entries(this);
        elseif strcmp(sourceObj.InputParameters{ipIndex}.Type,'Number')
            if isnan(str2double(widgetValue))
                warndlgHandle=warndlg('Invalid number.');
                set(warndlgHandle,'Tag','MACEInvalidNumberforInputParameter');
                this.MAObj.DialogCellArray{end+1}=warndlgHandle;
                return
            else
                sourceObj.InputParameters{ipIndex}.Value=str2double(widgetValue);
            end
        elseif strcmp(sourceObj.InputParameters{ipIndex}.Type,'BlockType')
            if~sourceObj.InputParameters{ipIndex}.importXML(widgetValue)
                warndlgHandle=warndlg('Invalid XML contents.');
                set(warndlgHandle,'Tag','MACEInvalidXMLforInputParameter');
                this.MAObj.DialogCellArray{end+1}=warndlgHandle;
                return
            end
        else
            sourceObj.InputParameters{ipIndex}.Value=widgetValue;
        end

        if~isempty(sourceObj.InputParametersCallback)
            if(nargin(sourceObj.InputParametersCallback)==3)
                sourceObj.InputParametersCallback(this,tag,handle);
            else
                sourceObj.InputParametersCallback(this);
            end
        end
        if~strcmp(sourceObj.InputParameters{ipIndex}.Type,'PushButton')


            this.reset;
        end
    elseif strncmp(tag,'BlockTypeRemoveRow_',length('BlockTypeRemoveRow_'))
        ipIndex=str2double(tag(length('BlockTypeRemoveRow_')+1:end));
        if ismember(sourceObj.InputParameters{ipIndex}.Type,{'BlockType','BlockTypeWithParameter'})
            tableID=['InputParameters_',num2str(ipIndex),'_table'];
            ridx=handle.getSelectedTableRows(tableID)+1;
            blkTypes=sourceObj.InputParameters{ipIndex}.Value;
            newblkTypes={};
            for i=1:size(blkTypes,1)
                if~ismember(i,ridx)
                    newblkTypes(end+1,:)=blkTypes(i,:);%#ok<AGROW>
                end
            end
            sourceObj.InputParameters{ipIndex}.Value=newblkTypes;
            handle.enableApplyButton(true);
        end
    elseif strncmp(tag,'BlockTypeAddRow_',length('BlockTypeAddRow_'))
        ipIndex=str2double(tag(length('BlockTypeAddRow_')+1:end));
        if ismember(sourceObj.InputParameters{ipIndex}.Type,{'BlockType','BlockTypeWithParameter'})
            if strcmp(sourceObj.InputParameters{ipIndex}.Type,'BlockType')
                newRowValue={'New',''};
            else
                newRowValue={'New','',{}};
            end
            tableID=['InputParameters_',num2str(ipIndex),'_table'];
            ridx=handle.getSelectedTableRow(tableID)+1;
            blkTypes=sourceObj.InputParameters{ipIndex}.Value;
            newblkTypes={};
            for i=1:size(blkTypes,1)
                newblkTypes(end+1,:)=blkTypes(i,:);%#ok<AGROW>
                if i==ridx
                    newblkTypes(end+1,:)=newRowValue;%#ok<AGROW>
                end
            end
            if isempty(newblkTypes)
                newblkTypes(1,:)=newRowValue;
            end
            sourceObj.InputParameters{ipIndex}.Value=newblkTypes;
            handle.enableApplyButton(true);
        end
    elseif strncmp(tag,'BlockTypeImport_',length('BlockTypeImport_'))
        ipIndex=str2double(tag(length('BlockTypeImport_')+1:end));
        if strcmp(sourceObj.InputParameters{ipIndex}.Type,'BlockType')
            dlgObj=ModelAdvisor.ImportBlkTypeDialog.getInstance();
            dlgs=DAStudio.ToolRoot.getOpenDialogs(dlgObj);
            if isa(dlgs,'DAStudio.Dialog')
                dlgs.show;
            else
                dlgObj.TaskNode=this;
                dlgObj.InputParameter=sourceObj.InputParameters{ipIndex};
                dlgObj.TaskNodeDialog=handle;
                DAStudio.Dialog(dlgObj);
            end
        end
    elseif strcmp(tag,'ExploreSelectComboBox')
        widgetValue=handle.getWidgetValue('ExploreSelectComboBox');


        this.Check.SelectedListViewParamIndex=widgetValue+1;
    elseif strcmp(tag,'ListViewButton')
        checkobj=this.Check;

        for i=1:length(checkobj.ListViewParameters)
            checkobj.SelectedListViewParamIndex=i;

            if~isempty(checkobj.ListViewActionCallback)
                checkobj.ListViewActionCallback(this);
            end
            if~isempty(checkobj.ListViewParameters{i}.Data)
                LVParamStruct=checkobj.ListViewParameters{checkobj.SelectedListViewParamIndex};
                this.MAObj.displayListView(LVParamStruct,this);
                return
            end
        end

        warndlgHandle=warndlg(DAStudio.message('Simulink:tools:MANoItemToDispaly'));
        set(warndlgHandle,'Tag','MANoItemToDisplay');
    elseif strcmp(tag,'combobox_switchViewCombobox')
        if isa(this,'ModelAdvisor.Task')
            if(this.State~=ModelAdvisor.CheckStatus.Failed)
                supportedStyles=this.Check.SupportedReportStyles;
                newStyle=supportedStyles{handle.getWidgetValue(tag)+1};
                this.switchReportStyle(newStyle);
            end
        end
    else
        wf=this.MAObj.TaskAdvisorCellArray{str2double(tag(10:end))};
        wf.changeSelectionStatus(switch_on);
        handle.apply
    end

    ed=DAStudio.EventDispatcher;
    ed.broadcastEvent('HierarchyChangedEvent',this);
    ed.broadcastEvent('PropertyChangedEvent',this);
