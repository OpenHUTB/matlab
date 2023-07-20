function handleCheckEvent(this,tag,handle)




    ModelAdvisor.ConfigUI.stackoperation('push');
    switch_on=false;
    if handle.getWidgetValue(tag)
        switch_on=true;
    end

    if strcmp(tag,'edit_DisplayName')
        newName=handle.getWidgetValue(tag);

        if isempty(deblank(newName))
            warndlgHandle=warndlg(DAStudio.message('Simulink:tools:MACEEmptyDisplayName'));
            set(warndlgHandle,'Tag','MACEEmptyDisplayName');
            this.MAObj.DialogCellArray{end+1}=warndlgHandle;
            return
        end

        if strcmp(this.ParentObj.ID,'SysRoot')&&(strcmp(newName,'By Product')||strcmp(newName,'By Task')||...
            strcmp(newName,DAStudio.message('Simulink:tools:MAByProduct'))||strcmp(newName,DAStudio.message('Simulink:tools:MAByTask')))


            handle.setWidgetValue(tag,this.DisplayName);
            warndlgHandle=warndlg(DAStudio.message('Simulink:tools:MACEReservedName',newName));
            set(warndlgHandle,'Tag','MACEReservedName');
            this.MAObj.DialogCellArray{end+1}=warndlgHandle;
            return
        end
        dupNameObj=findobj([this.ParentObj.getChildren],'DisplayName',newName);
        if isempty(dupNameObj)
            this.DisplayName=newName;

            handle.apply;
            this.updateID(false,true);
        else


            handle.setWidgetValue(tag,this.DisplayName);
            warndlgHandle=warndlg(DAStudio.message('Simulink:tools:MACENoDuplicateName',newName));
            set(warndlgHandle,'Tag','MACENoDuplicateName');
            this.MAObj.DialogCellArray{end+1}=warndlgHandle;
        end
        loc_refresh_dlg(this);
    elseif strncmp(tag,'InputParameters_',length('InputParameters_'))
        ipIndex=str2double(tag(length('InputParameters_')+1:end));
        widgetValue=handle.getWidgetValue(tag);
        if strcmp(this.InputParameters{ipIndex}.Type,'Enum')&&...
            isnumeric(widgetValue)
            if strcmp(this.InputParameters{ipIndex}.Value,this.InputParameters{ipIndex}.Entries{widgetValue+1})

                return
            end


            this.InputParameters{ipIndex}.Value=...
            this.InputParameters{ipIndex}.Entries{widgetValue+1};
        elseif strcmp(this.InputParameters{ipIndex}.Type,'ComboBox')
            if isnumeric(widgetValue)
                if strcmp(this.InputParameters{ipIndex}.Value,this.InputParameters{ipIndex}.Entries{widgetValue+1})

                    return
                end
                this.InputParameters{ipIndex}.Value=...
                this.InputParameters{ipIndex}.Entries{widgetValue+1};
            elseif ischar(widgetValue)
                if strcmp(this.InputParameters{ipIndex}.Value,widgetValue)

                    return
                end
                this.InputParameters{ipIndex}.Value=widgetValue;
            end
        elseif strcmp(this.InputParameters{ipIndex}.Type,'PushButton')


            this.InputParameters{ipIndex}.Entries(this);
        elseif strcmp(this.InputParameters{ipIndex}.Type,'Number')
            if isnan(str2double(widgetValue))
                warndlgHandle=warndlg('Invalid number.');
                set(warndlgHandle,'Tag','MACEInvalidNumberforInputParameter');
                this.MAObj.DialogCellArray{end+1}=warndlgHandle;
                return
            else
                this.InputParameters{ipIndex}.Value=str2double(widgetValue);
            end
        elseif strcmp(this.InputParameters{ipIndex}.Type,'BlockType')
            if~this.InputParameters{ipIndex}.importXML(widgetValue)
                warndlgHandle=warndlg('Invalid XML contents.');
                set(warndlgHandle,'Tag','MACEInvalidXMLforInputParameter');
                this.MAObj.DialogCellArray{end+1}=warndlgHandle;
                return
            end
        else
            this.InputParameters{ipIndex}.Value=widgetValue;
        end

        if~isempty(this.InputParametersCallback)
            if(nargin(this.InputParametersCallback)==3)
                this.InputParametersCallback(this,tag,handle);
            else
                this.InputParametersCallback(this);
            end
            handle.apply;
        end
        this.MAObj.ConfigUIDirty=true;
        loc_refresh_dlg(this);
    elseif strncmp(tag,'BlockTypeRemoveRow_',length('BlockTypeRemoveRow_'))
        ipIndex=str2double(tag(length('BlockTypeRemoveRow_')+1:end));
        if ismember(this.InputParameters{ipIndex}.Type,{'BlockType','BlockTypeWithParameter'})&&~isempty(this.InputParameters{ipIndex}.Value)
            tableID=['InputParameters_',num2str(ipIndex),'_table'];
            ridx=handle.getSelectedTableRows(tableID)+1;
            blkTypes=this.InputParameters{ipIndex}.Value;
            newblkTypes={};
            for i=1:size(blkTypes,1)
                if~ismember(i,ridx)
                    newblkTypes(end+1,:)=blkTypes(i,:);%#ok<AGROW>
                end
            end
            this.InputParameters{ipIndex}.Value=newblkTypes;
            handle.enableApplyButton(true);
            this.MAObj.ConfigUIDirty=true;
            loc_refresh_dlg(this);
        end
    elseif strncmp(tag,'BlockTypeAddRow_',length('BlockTypeAddRow_'))
        ipIndex=str2double(tag(length('BlockTypeAddRow_')+1:end));
        if ismember(this.InputParameters{ipIndex}.Type,{'BlockType','BlockTypeWithParameter'})
            if strcmp(this.InputParameters{ipIndex}.Type,'BlockType')
                newRowValue={'New',''};
            else
                newRowValue={'New','',{}};
            end

            tableID=['InputParameters_',num2str(ipIndex),'_table'];
            ridx=handle.getSelectedTableRow(tableID)+1;
            blkTypes=this.InputParameters{ipIndex}.Value;
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
            this.InputParameters{ipIndex}.Value=newblkTypes;
            handle.enableApplyButton(true);
            this.MAObj.ConfigUIDirty=true;
            loc_refresh_dlg(this);
            handle.selectTableRow(tableID,ridx);
        end
    elseif strncmp(tag,'BlockTypeImport_',length('BlockTypeImport_'))
        ipIndex=str2double(tag(length('BlockTypeImport_')+1:end));
        if strcmp(handle.getWidgetPrompt('InputParameters_2'),DAStudio.message('ModelAdvisor:engine:BlkListInterpretionMode'))



            foundBlkListInterpretionModeParam=true;
            BlkListInterpretionMode=handle.getWidgetValue('InputParameters_2');
        else
            foundBlkListInterpretionModeParam=false;
        end
        if strcmp(this.InputParameters{ipIndex}.Type,'BlockType')
            dlgObj=ModelAdvisor.ImportBlkTypeDialog.getInstance();
            if foundBlkListInterpretionModeParam
                if BlkListInterpretionMode==dlgObj.BlkListInterpretionMode
                    needUpdateDialog=false;
                else
                    needUpdateDialog=true;
                end
            else
                needUpdateDialog=false;
            end
            if needUpdateDialog
                dlgObj.BlkListInterpretionMode=BlkListInterpretionMode;
                dlgObj.BlkTypeSource=DAStudio.message('ModelAdvisor:engine:Library');
                dlgObj.syncInternalValues('write');
            end
            dlgs=DAStudio.ToolRoot.getOpenDialogs(dlgObj);
            if isa(dlgs,'DAStudio.Dialog')
                dlgs.show;
            else
                dlgObj.TaskNode=this;
                dlgObj.InputParameter=this.InputParameters{ipIndex};
                dlgObj.TaskNodeDialog=handle;
                DAStudio.Dialog(dlgObj);
            end
        end
    else
        wf=this.MAObj.TaskAdvisorCellArray{str2double(tag(10:end))};
        wf.changeSelectionStatus(switch_on);
        handle.apply;
        loc_refresh_dlg(this);
    end

    this.LastModifiedDate=now;

    function loc_refresh_dlg(this)
        ed=DAStudio.EventDispatcher;
        ed.broadcastEvent('PropertyChangedEvent',this);
