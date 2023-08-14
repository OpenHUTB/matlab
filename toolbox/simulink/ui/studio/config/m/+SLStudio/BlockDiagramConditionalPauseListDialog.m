classdef BlockDiagramConditionalPauseListDialog<handle




    properties(SetObservable=true)
        dlgInstance={};
        modelUDD=[];











        portHandle=[];
        conditionalPauseList=[];
        changed=[];
        simStatusChangelistener=[];

    end

    methods
        function obj=BlockDiagramConditionalPauseListDialog(modelH)
            obj.modelUDD=get_param(modelH,'UDDObject');
            obj.portHandle=0;
            obj.conditionalPauseList=[];
            obj.changed=false;
            obj.simStatusChangelistener=handle.listener(...
            DAStudio.EventDispatcher,...
            'SimStatusChangedEvent',...
            {@refreshBlockDiagramConditionalPauseListDialog,obj});
        end

        function refreshConditionalPauseList(obj)


            if(obj.portHandle==-1)
                return;
            end
            obj.conditionalPauseList=...
            get_param(obj.modelUDD.Handle,'ConditionalPauseList');
            validHandle=false;
            for pIdx=1:length(obj.conditionalPauseList)
                if(obj.portHandle==obj.conditionalPauseList(pIdx).portHandle)
                    validHandle=true;
                    break;
                end
            end
            if(~validHandle)
                obj.portHandle=0;
            end
        end

        function refreshDialog(obj)
            if~isempty(obj.dlgInstance)
                obj.dlgInstance.refresh;
            end
        end

        function showBlockDiagramConditionalPauseListDialog(obj,portH)



            if slfeature('slBreakpointList')==0
                obj.portHandle=portH;
                if isempty(obj.dlgInstance)
                    obj.dlgInstance=DAStudio.Dialog(obj);
                else
                    obj.dlgInstance.refresh;
                    obj.dlgInstance.show;
                end
            else
                editor=GLUE2.Util.findAllEditors(obj.modelUDD.Name);
                studio=editor.getStudio();
                toggleBpList=false;
                obj.showBlockDiagramConditionalPauseListDialog_helper(studio,portH,toggleBpList);
            end
        end

        function showBlockDiagramConditionalPauseListDialog_helper(~,studio,portH,toggleBpList)



            toggleClosedIfAlreadyOpen=toggleBpList;
            instance=SimulinkDebugger.breakpoints.GlobalBreakpointsListAccessor.getInstance();
            ssComp=SimulinkDebugger.breakpoints.BreakpointListSpreadsheet.createSpreadSheetComponent(...
            studio,instance,toggleClosedIfAlreadyOpen);
            SimulinkDebugger.breakpoints.BreakpointListSpreadsheet.moveComponentToDock(ssComp,studio);


            ssComp.getSource().addSrcToBeRefreshed(portH);
        end

        function deleteDialog(obj)
            if~isempty(obj.dlgInstance)
                delete(obj.dlgInstance);
                obj.dlgInstance=[];
            end


            if(obj.portHandle==-1)
                obj.portHandle=0;
            end
        end

        function closeBlockDiagramConditionalPauseListDialog(obj,~)
            obj.dlgInstance={};
        end

        function changeConditionalPauseRelation(...
            obj,portIdx,conditionIdx,value)


            portH=obj.conditionalPauseList(portIdx).portHandle;
            condRelation.index=...
            obj.conditionalPauseList(portIdx).data{conditionIdx,1};
            condRelation.relation=value;
            set_param(portH,'ConditionalPauseRelation',condRelation);
            obj.refreshDialog;
        end


        function showPauseValueChangeErrorDialog(~,badVal)


            dp=DAStudio.DialogProvider;

            msg=DAStudio.message('Simulink:studio:ConditionalPauseInvalidValue',badVal);
            title=DAStudio.message('Simulink:studio:ConditionalPauseInvalidValueDlgTitle');
            [~]=dp.msgbox(msg,title,true);
        end


        function changeConditionalPauseValue(...
            obj,portIdx,conditionIdx,value)
            portH=obj.conditionalPauseList(portIdx).portHandle;
            condValue.index=...
            obj.conditionalPauseList(portIdx).data{conditionIdx,1};
            condValue.value=str2double(value);





            if(isnan(condValue.value)||~isreal(condValue.value))

                showPauseValueChangeErrorDialog(obj,value);
            else
                set_param(portH,'ConditionalPauseValue',condValue);
            end
            obj.refreshDialog;
        end


        function changeConditionalPauseStatus(...
            obj,portIdx,conditionIdx,value)
            portH=obj.conditionalPauseList(portIdx).portHandle;
            condStatus.index=...
            obj.conditionalPauseList(portIdx).data{conditionIdx,1};
            condStatus.status=value;
            set_param(portH,'ConditionalPauseStatus',condStatus);

            if(obj.portHandle~=0)


                refreshConditionalPauseList(obj);
                if(obj.portHandle==0)
                    obj.portHandle=-1;
                end
            else
                refreshConditionalPauseList(obj);
            end
            obj.refreshDialog;
        end

        function hiliteNodeCB(~,hilited)
            hilite_system(hilited,'different');
            pause(3);
            hilite_system(hilited,'none');
        end

        function portConditionalPauseListSchemas=...
            getPortConditionalPauseListSchema(obj)

            numPorts=length(obj.conditionalPauseList);
            if(obj.portHandle~=0)
                portConditionalPauseListSchemas=cell(1,1);
            else
                portConditionalPauseListSchemas=cell(1,numPorts);
            end
            locPIdx=0;
            for pIdx=1:numPorts
                portH=obj.conditionalPauseList(pIdx).portHandle;
                if(obj.portHandle~=0&&obj.portHandle~=portH)
                    continue;
                end
                locPIdx=locPIdx+1;
                portPauseList=obj.conditionalPauseList(pIdx).data;
                portDataSize=size(portPauseList);
                wConditionalPauseRelation=cell(1,portDataSize(1));
                wConditionalPauseValue=cell(1,portDataSize(1));
                wConditionalPauseEnabled=cell(1,portDataSize(1));
                wConditionalPauseHits=cell(1,portDataSize(1));
                wConditionalPauseDelete=cell(1,portDataSize(1));
                for pDataIdx=1:portDataSize(1)

                    if(slfeature('ConditionalPause')==3)
                        wConditionalPauseRelation{pDataIdx}.Type=...
                        'combobox';
                        wConditionalPauseRelation{pDataIdx}.Name='';
                        wConditionalPauseRelation{pDataIdx}.Entries=...
                        allowedRelations;
                        wConditionalPauseRelation{pDataIdx}.ObjectMethod=...
                        'changeConditionalPauseRelation';
                        wConditionalPauseRelation{pDataIdx}.MethodArgs=...
                        {pIdx,pDataIdx,'%value'};
                        wConditionalPauseRelation{pDataIdx}.ArgDataTypes=...
                        {'int32','int32','handle'};
                        wConditionalPauseRelation{pDataIdx}.Value=...
                        portPauseList{pDataIdx,2};
                        wConditionalPauseRelation{pDataIdx}.ColSpan=[1,1];
                        wConditionalPauseRelation{pDataIdx}.Graphical=1;
                        wConditionalPauseRelation{pDataIdx}.Alignment=1;
                        wConditionalPauseRelation{pDataIdx}.RowSpan=...
                        [pDataIdx+1,pDataIdx+1];
                        wConditionalPauseRelation{pDataIdx}.Enabled=...
                        (portPauseList{pDataIdx,4}<=1);
                        wConditionalPauseRelation{pDataIdx}.Mode=1;

                        wConditionalPauseValue{pDataIdx}.Type=...
                        'edit';
                        wConditionalPauseValue{pDataIdx}.Name='';
                        wConditionalPauseValue{pDataIdx}.ObjectMethod=...
                        'changeConditionalPauseValue';
                        wConditionalPauseValue{pDataIdx}.MethodArgs=...
                        {pIdx,pDataIdx,'%value'};
                        wConditionalPauseValue{pDataIdx}.ArgDataTypes=...
                        {'int32','int32','handle'};
                        wConditionalPauseValue{pDataIdx}.Value=...
                        num2str(portPauseList{pDataIdx,3});
                        wConditionalPauseValue{pDataIdx}.ColSpan=[2,2];
                        wConditionalPauseValue{pDataIdx}.Alignment=1;
                        wConditionalPauseValue{pDataIdx}.RowSpan=...
                        [pDataIdx+1,pDataIdx+1];
                        wConditionalPauseValue{pDataIdx}.Enabled=...
                        (portPauseList{pDataIdx,4}<=1);
                        wConditionalPauseValue{pDataIdx}.Mode=1;
                    elseif(slfeature('ConditionalPause')==4)
                        wConditionalPauseRelation{pDataIdx}.Type=...
                        'text';
                        wConditionalPauseRelation{pDataIdx}.Name=...
                        relationalOperatorString(portPauseList{pDataIdx,2});
                        wConditionalPauseRelation{pDataIdx}.ColSpan=[1,1];
                        wConditionalPauseRelation{pDataIdx}.Graphical=1;
                        wConditionalPauseRelation{pDataIdx}.Alignment=1;
                        wConditionalPauseRelation{pDataIdx}.RowSpan=...
                        [pDataIdx+1,pDataIdx+1];
                        wConditionalPauseRelation{pDataIdx}.Enabled=...
                        (portPauseList{pDataIdx,4}<=1);
                        wConditionalPauseRelation{pDataIdx}.Mode=1;
                        wConditionalPauseValue{pDataIdx}.Type=...
                        'text';
                        wConditionalPauseValue{pDataIdx}.Name=...
                        num2str(portPauseList{pDataIdx,3});
                        wConditionalPauseValue{pDataIdx}.ColSpan=[2,2];
                        wConditionalPauseValue{pDataIdx}.Graphical=1;
                        wConditionalPauseValue{pDataIdx}.Alignment=1;
                        wConditionalPauseValue{pDataIdx}.RowSpan=...
                        [pDataIdx+1,pDataIdx+1];
                        wConditionalPauseValue{pDataIdx}.Enabled=...
                        (portPauseList{pDataIdx,4}<=1);
                        wConditionalPauseValue{pDataIdx}.Mode=1;
                    end
                    wConditionalPauseEnabled{pDataIdx}.Type=...
                    'checkbox';
                    wConditionalPauseEnabled{pDataIdx}.Name='';
                    wConditionalPauseEnabled{pDataIdx}.ObjectMethod=...
                    'changeConditionalPauseStatus';
                    wConditionalPauseEnabled{pDataIdx}.MethodArgs=...
                    {pIdx,pDataIdx,'%value'};
                    wConditionalPauseEnabled{pDataIdx}.ArgDataTypes=...
                    {'int32','int32','mxArray'};
                    wConditionalPauseEnabled{pDataIdx}.Value=...
                    (portPauseList{pDataIdx,4}~=0);
                    wConditionalPauseEnabled{pDataIdx}.ColSpan=[3,3];
                    wConditionalPauseEnabled{pDataIdx}.Graphical=1;
                    wConditionalPauseEnabled{pDataIdx}.Alignment=6;
                    wConditionalPauseEnabled{pDataIdx}.RowSpan=...
                    [pDataIdx+1,pDataIdx+1];
                    wConditionalPauseEnabled{pDataIdx}.Enabled=...
                    (portPauseList{pDataIdx,4}<=1);
                    wConditionalPauseEnabled{pDataIdx}.Mode=1;

                    wConditionalPauseHits{pDataIdx}.Type=...
                    'text';
                    wConditionalPauseHits{pDataIdx}.Name=...
                    num2str(portPauseList{pDataIdx,6});
                    wConditionalPauseHits{pDataIdx}.ColSpan=[4,4];
                    wConditionalPauseHits{pDataIdx}.Alignment=1;
                    wConditionalPauseHits{pDataIdx}.RowSpan=...
                    [pDataIdx+1,pDataIdx+1];
                    wConditionalPauseHits{pDataIdx}.Enabled=...
                    (portPauseList{pDataIdx,4}<=1);
                    wConditionalPauseHits{pDataIdx}.Mode=1;

                    wConditionalPauseDelete{pDataIdx}.Name=...
                    DAStudio.message('Simulink:studio:NameDelete');
                    wConditionalPauseDelete{pDataIdx}.Type='hyperlink';
                    wConditionalPauseDelete{pDataIdx}.ColSpan=[5,5];
                    wConditionalPauseDelete{pDataIdx}.Alignment=1;
                    wConditionalPauseDelete{pDataIdx}.RowSpan=...
                    [pDataIdx+1,pDataIdx+1];
                    wConditionalPauseDelete{pDataIdx}.ObjectMethod=...
                    'changeConditionalPauseStatus';
                    wConditionalPauseDelete{pDataIdx}.MethodArgs=...
                    {pIdx,pDataIdx,3};
                    wConditionalPauseDelete{pDataIdx}.ArgDataTypes=...
                    {'int32','int32','int32'};
                end

                wPortLabel.Name=...
                DAStudio.message('Simulink:studio:NameSignal');
                wPortLabel.Type='text';
                wPortLabel.Bold=true;
                wPortLabel.RowSpan=[1,1];
                wPortLabel.ColSpan=[1,1];
                wPortLabel.Alignment=1;
                locPrefix='port_label_';
                wPortLabel.Tag=...
                [locPrefix,'tag'];
                wPortLabel.WidgetId=...
                [locPrefix,'widgetid'];
                wPortLabel.ToolTip='';


                wPortLink.Name=...
                DAStudio.message(...
                'Simulink:studio:ConditionalPauseBlockPort',get_param(portH,'Parent'),...
                num2str(get_param(portH,'PortNumber')));
                wPortLink.Type='hyperlink';
                wPortLink.RowSpan=[1,1];
                wPortLink.ColSpan=[2,2];
                wPortLink.Alignment=1;
                locPrefix='port_link_';
                wPortLink.Tag=...
                [locPrefix,'tag'];
                wPortLink.WidgetId=...
                [locPrefix,'widgetid'];
                wPortLink.ObjectMethod=...
                'hiliteNodeCB';
                wPortLink.MethodArgs={portH};
                wPortLink.ArgDataTypes=...
                {'double'};

                if(portDataSize(1)>1)
                    wConditionLabel.Name=...
                    DAStudio.message('Simulink:studio:NameConditions');
                else
                    wConditionLabel.Name=...
                    DAStudio.message('Simulink:studio:NameCondition');
                end
                wConditionLabel.Type='text';
                wConditionLabel.Bold=true;
                wConditionLabel.RowSpan=[1,1];
                wConditionLabel.ColSpan=[1,2];
                wConditionLabel.Alignment=1;
                locPrefix='condtion_label_';
                wConditionLabel.Tag=...
                [locPrefix,'tag'];
                wConditionLabel.WidgetId=...
                [locPrefix,'widgetid'];
                wConditionLabel.ToolTip='';

                wConditionEnabledLabel.Name=...
                DAStudio.message('Simulink:studio:NameEnabled');
                wConditionEnabledLabel.Bold=true;
                wConditionEnabledLabel.Type='text';
                wConditionEnabledLabel.RowSpan=[1,1];
                wConditionEnabledLabel.ColSpan=[3,3];
                wConditionEnabledLabel.Alignment=2;
                locPrefix='condition_enabled_label_';
                wConditionEnabledLabel.Tag=...
                [locPrefix,'tag'];
                wConditionEnabledLabel.WidgetId=...
                [locPrefix,'widgetid'];
                wConditionEnabledLabel.ToolTip='';

                wConditionHitsLabel.Name=...
                DAStudio.message('Simulink:studio:NameHits');

                wConditionHitsLabel.Bold=true;
                wConditionHitsLabel.Type='text';
                wConditionHitsLabel.RowSpan=[1,1];
                wConditionHitsLabel.ColSpan=[4,4];
                wConditionHitsLabel.Alignment=2;
                locPrefix='condition_hits_label_';
                wConditionHitsLabel.Tag=...
                [locPrefix,'tag'];
                wConditionHitsLabel.WidgetId=...
                [locPrefix,'widgetid'];
                wConditionHitsLabel.ToolTip='';

                wConditionDeleteLabel.Name='';
                wConditionDeleteLabel.Bold=true;
                wConditionDeleteLabel.Type='text';
                wConditionDeleteLabel.RowSpan=[1,1];
                wConditionDeleteLabel.ColSpan=[5,5];
                wConditionDeleteLabel.Alignment=2;
                locPrefix='condition_delete_label_';
                wConditionDeleteLabel.Tag=...
                [locPrefix,'tag'];
                wConditionDeleteLabel.WidgetId=...
                [locPrefix,'widgetid'];
                wConditionDeleteLabel.ToolTip='';

                gConditionalPauseList.Name='';
                gConditionalPauseList.Type='panel';
                gConditionalPauseList.RowSpan=[2,2];
                gConditionalPauseList.ColSpan=[1,2];
                gPortConditionalPauseList.ColStretch=[0,0,0,0,1];
                gConditionalPauseList.LayoutGrid=...
                [portDataSize(1)+1,5];
                gConditionalPauseList.Items=...
                [{wConditionLabel,wConditionEnabledLabel,...
                wConditionHitsLabel,wConditionDeleteLabel},...
                wConditionalPauseRelation,wConditionalPauseValue,...
                wConditionalPauseEnabled,wConditionalPauseHits,...
                wConditionalPauseDelete];
                gConditionalPauseList.Alignment=2;
                locPrefix='conditional_pause_list_';
                gConditionalPauseList.Tag=...
                [locPrefix,'tag'];
                gConditionalPauseList.WidgetId=...
                [locPrefix,'widgetid'];
                gConditionalPauseList.ToolTip='';


                gPortConditionalPauseList.Type=...
                'group';
                gPortConditionalPauseList.Flat=true;
                gPortConditionalPauseList.Name='';
                gPortConditionalPauseList.ColSpan=[1,1];
                gPortConditionalPauseList.RowSpan=...
                [locPIdx,locPIdx];
                gPortConditionalPauseList.LayoutGrid=[2,2];
                gPortConditionalPauseList.ColStretch=[0,1];
                gPortConditionalPauseList.RowStretch=[0,1];
                gPortConditionalPauseList.Alignment=0;
                gPortConditionalPauseList.Items=...
                {wPortLabel,wPortLink,...
                gConditionalPauseList};
                locPrefix='port_pause_list_group_';
                gPortConditionalPauseList.Tag=...
                [locPrefix,'tag'];
                gPortConditionalPauseList.WidgetId=...
                [locPrefix,'widgetid'];

                portConditionalPauseListSchemas{locPIdx}=...
                gPortConditionalPauseList;

            end
        end


        function dlgstruct=getDialogSchema(obj)

            refreshConditionalPauseList(obj);

            mdlName=obj.modelUDD.getFullName;
            numPorts=length(obj.conditionalPauseList);

            dlgstruct.DialogTitle=DAStudio.message(...
            'Simulink:studio:ConditionalPauseListForModel',mdlName);
            dlgstruct.StandaloneButtonSet=...
            {'Ok','Help'};
            dlgstruct.SmartApply=0;
            dlgstruct.CloseMethod=...
            'closeBlockDiagramConditionalPauseListDialog';
            dlgstruct.CloseMethodArgs={'%closeaction'};
            dlgstruct.CloseMethodArgsDT={'string'};
            dlgstruct.HelpMethod='helpview';
            dlgstruct.HelpArgs={fullfile(docroot,'simulink',...
            'helptargets.map'),'SimStepper_cond'};

            if(obj.portHandle==-1)






                dlgstruct.LayoutGrid=[1,1];
                EmptyList{1}.Name=DAStudio.message(...
                'Simulink:studio:ConditionalPauseListIsEmptyPort');
                EmptyList{1}.Type='text';
                EmptyList{1}.RowSpan=[1,1];
                EmptyList{1}.ColSpan=[1,1];
                EmptyList{1}.Tag='enable_cond_pause_list_text_tag';
                EmptyList{1}.WidgetId='enable_cond_pause_list_text_widgetid';
                dlgstruct.Items=EmptyList;







            elseif(numPorts==0)

                dlgstruct.LayoutGrid=[1,1];
                EmptyList{1}.Name=DAStudio.message(...
                'Simulink:studio:ConditionalPauseListIsEmpty');
                EmptyList{1}.Type='text';
                EmptyList{1}.RowSpan=[1,1];
                EmptyList{1}.ColSpan=[1,1];
                EmptyList{1}.Tag='enable_cond_pause_list_text_tag';
                EmptyList{1}.WidgetId='enable_cond_pause_list_text_widgetid';
                dlgstruct.Items=EmptyList;
            else
                if(obj.portHandle~=0)
                    dlgstruct.LayoutGrid=[1,1];
                else
                    dlgstruct.LayoutGrid=[numPorts,1];
                end

                dlgstruct.Items=...
                obj.getPortConditionalPauseListSchema();
            end
        end

        function registerDAListeners(obj)
            obj.modelUDD.registerDAListeners;
        end
    end
end




function relationStrs=allowedRelations
    relationStrs={DAStudio.message('Simulink:studio:Greater'),...
    DAStudio.message('Simulink:studio:GreaterEqual'),...
    DAStudio.message('Simulink:studio:Equal'),...
    DAStudio.message('Simulink:studio:NotEqual'),...
    DAStudio.message('Simulink:studio:LessEqual'),...
    DAStudio.message('Simulink:studio:Less')};
end


function str=relationalOperatorString(idx)
    switch(idx)
    case 0
        str=DAStudio.message('Simulink:studio:Greater');
    case 1
        str=DAStudio.message('Simulink:studio:GreaterEqual');
    case 2
        str=DAStudio.message('Simulink:studio:Equal');
    case 3
        str=DAStudio.message('Simulink:studio:NotEqual');
    case 4
        str=DAStudio.message('Simulink:studio:LessEqual');
    case 5
        str=DAStudio.message('Simulink:studio:Less');


    otherwise
        str=DAStudio.message('Simulink:studio:Greater');
    end
end

function refreshBlockDiagramConditionalPauseListDialog(~,~,obj)
    obj.refreshDialog;
end


