classdef LinePropertiesDDGSource<handle




    properties(SetObservable=true,SetAccess=private)
        source='';
        toggleStateMap='';
    end

    methods
        function this=LinePropertiesDDGSource(h)
            if isa(h,'Simulink.Line')
                this.source=h;
                this.toggleStateMap=containers.Map(...
                {'LoggingTogglePanel','CodeGenTogglePanel','TaskTogglePanel'},...
                {true,true,true});

            else
                ME=MException('linePropertiesDDGSource:InvalidSourceType',...
                'The source type is not a Simulink Line');
                throw(ME);
            end
        end

        function dlgstruct=getDialogSchema(obj,name)
            dlgstruct=[];
            lineObj=obj.source;
            portObj=lineObj.getSourcePort;

            if isempty(portObj)
                dlgstruct=loc_EmptyDialog(name);
                return;
            end

            sourceBlock=portObj.Parent;
            sourceModel=bdroot(sourceBlock);
            isModelClosing=slInternal('isBDClosing',sourceModel);

            if isModelClosing
                dlgstruct=loc_EmptyDialog(name);
                return;
            end

            if strcmp(name,'Simulink:Dialog:Properties')
                dlgstruct=obj.getLinePropertiesSchema(name);



                try
                    dlgstruct=simulinkcoder.internal.CodePerspective.customizePropertyInspector(sourceModel,dlgstruct);
                catch
                end

            elseif strcmp(name,'Simulink:Dialog:Info')
                dlgstruct=obj.getLineInfoSchema(name);
            end
        end


        function fObj=getForwardedObject(obj)
            fObj=obj;
        end

        function[completions,expVec]=getAutoCompleteData(obj,tag,partialText,curPos)
            lineObj=obj.source;
            [completions,expVec]=slprivate('blockAutoCompleteSuggestion',partialText,tag,lineObj,curPos);
        end
    end

    methods(Static)
        function[varargout]=closeCallback(action,portObj,dialog)
            switch(action)
            case 'close_cb'
                Simulink.CodeMapping.remove_mapping_listener(portObj,dialog);
                varargout={true,''};
            otherwise
            end
        end
    end

    methods(Access=private)

        function dlgstruct=getLinePropertiesSchema(obj,name)
            lineObj=obj.source;
            portObj=lineObj.getSourcePort;
            assert(~isempty(portObj));
            sourceBlock=get_param(portObj.Handle,'Parent');
            sourceBlockType=get_param(sourceBlock,'BlockType');


            lblSignalName.Tag='lblSignalName';
            lblSignalName.Name=DAStudio.message('Simulink:dialog:SigpropLblSignalNameName');
            lblSignalName.Type='text';
            lblSignalName.RowSpan=[1,1];
            lblSignalName.ColSpan=[1,1];

            txtSignalName.Tag='Name';
            txtSignalName.Type='edit';
            txtSignalName.ObjectProperty=txtSignalName.Tag;
            txtSignalName.RowSpan=[1,1];
            txtSignalName.ColSpan=[2,2];
            txtSignalName.Enabled=~strcmp(sourceBlockType,'BusSelector');
            txtSignalName.MatlabMethod='defaultLinePropCB_ddg';
            txtSignalName.MatlabArgs={'%dialog','%source','%tag','%value'};

            disableMustResolveToSignalObject=isempty(portObj.Name)||...
            strcmp(sourceBlockType,'BusSelector')||...
            (strcmp(sourceBlockType,'Inport')&&...
            strcmp(get_param(sourceBlock,'IsBusElementPort'),'on'));
            chkResSigObj.Tag='MustResolveToSignalObject';
            chkResSigObj.Type='checkbox';
            chkResSigObj.Name=DAStudio.message('Simulink:dialog:SigpropChkResSigObjName');
            chkResSigObj.ToolTip=DAStudio.message('Simulink:dialog:SigpropChkResSigObjName');
            chkResSigObj.PreferredSize=[200,-1];
            chkResSigObj.ObjectProperty=chkResSigObj.Tag;
            chkResSigObj.Visible=isValidProperty(lineObj,'MustResolveToSignalObject');
            chkResSigObj.Enabled=~disableMustResolveToSignalObject;
            chkResSigObj.RowSpan=[2,2];
            chkResSigObj.ColSpan=[1,2];
            chkResSigObj.MatlabMethod='defaultLinePropCB_ddg';
            chkResSigObj.MatlabArgs={'%dialog','%source','%tag','%value'};

            chkShowSigProp.Tag='ShowPropagatedSignals';
            chkShowSigProp.Type='checkbox';
            chkShowSigProp.Name=DAStudio.message('Simulink:dialog:SigpropLblShowSigPropName');
            chkShowSigProp.Enabled=portObj.supportsSignalPropagation;
            chkShowSigProp.ObjectProperty=chkShowSigProp.Tag;
            chkShowSigProp.RowSpan=[3,3];
            chkShowSigProp.ColSpan=[1,2];
            chkShowSigProp.MatlabMethod='defaultLinePropCB_ddg';
            chkShowSigProp.MatlabArgs={'%dialog','%source','%tag','%value'};








            chkLogSigData.Tag='DataLogging';
            chkLogSigData.Type='checkbox';
            chkLogSigData.Name=DAStudio.message('Simulink:dialog:SigpropChkLogSigDataName');
            chkLogSigData.ObjectProperty=chkLogSigData.Tag;
            chkLogSigData.RowSpan=[1,1];
            chkLogSigData.ColSpan=[1,1];
            chkLogSigData.MatlabMethod='defaultLinePropCB_ddg';
            chkLogSigData.MatlabArgs={'%dialog','%source','%tag','%value'};


            chkTestPoint.Type='checkbox';
            chkTestPoint.Name=DAStudio.message('Simulink:dialog:SigpropChkTestPointName');
            chkTestPoint.Tag='TestPoint';
            chkTestPoint.ObjectProperty=chkTestPoint.Tag;
            chkTestPoint.RowSpan=[1,1];
            chkTestPoint.ColSpan=[2,2];
            chkTestPoint.MatlabMethod='defaultLinePropCB_ddg';
            chkTestPoint.MatlabArgs={'%dialog','%source','%tag','%value'};






            cmbLog.Tag='DataLoggingNameMode';
            cmbLog.Type='combobox';
            cmbLog.ObjectProperty=cmbLog.Tag;
            cmbLog.Values=[0,1];
            cmbLog.Entries={DAStudio.message('Simulink:dialog:SigpropCmbLogEntryUseSignalName'),...
            DAStudio.message('Simulink:dialog:SigpropCmbLogEntryCustom')};
            cmbLog.Enabled=convertToBool(portObj.dataLogging);
            cmbLog.MatlabMethod='defaultLinePropCB_ddg';
            cmbLog.MatlabArgs={'%dialog','%source','%tag','%value'};

            txtName.Tag='UserSpecifiedLogName';
            txtName.Type='edit';
            txtName.ObjectProperty=txtName.Tag;
            txtName.Enabled=convertToBool(portObj.dataLogging)&&~(strcmp(portObj.DataLoggingNameMode,'SignalName'));
            txtName.MatlabMethod='defaultLinePropCB_ddg';
            txtName.MatlabArgs={'%dialog','%source','%tag','%value'};

            grpLog.Tag='grpLog';
            grpLog.Type='group';
            grpLog.Name=DAStudio.message('Simulink:dialog:SigpropGrpLogName');
            grpLog.LayoutGrid=[2,1];
            grpLog.Items={cmbLog,txtName};
            grpLog.RowSpan=[2,2];
            grpLog.ColSpan=[1,2];





            chkDataPoints.Tag='DataLoggingLimitDataPoints';
            chkDataPoints.Type='checkbox';
            chkDataPoints.Name=[DAStudio.message('Simulink:dialog:SigpropLblDataPointsName'),' '];
            chkDataPoints.RowSpan=[1,1];
            chkDataPoints.ColSpan=[1,1];
            chkDataPoints.ObjectProperty=chkDataPoints.Tag;
            chkDataPoints.Enabled=convertToBool(portObj.dataLogging);
            chkDataPoints.MatlabMethod='defaultLinePropCB_ddg';
            chkDataPoints.MatlabArgs={'%dialog','%source','%tag','%value'};

            txtDataPoints.Tag='DataLoggingMaxPoints';
            txtDataPoints.Type='edit';
            txtDataPoints.ObjectProperty=txtDataPoints.Tag;
            txtDataPoints.PreferredSize=[50,-1];
            txtDataPoints.RowSpan=[1,1];
            txtDataPoints.ColSpan=[2,2];
            txtDataPoints.MatlabMethod='defaultLinePropCB_ddg';
            txtDataPoints.MatlabArgs={'%dialog','%source','%tag','%value'};
            txtDataPoints.Enabled=convertToBool(portObj.dataLogging)&&convertToBool(portObj.DataLoggingLimitDataPoints);

            chkDecimation.Tag='DataLoggingDecimateData';
            chkDecimation.Type='checkbox';
            chkDecimation.Name=[DAStudio.message('Simulink:dialog:SigpropLblDecimationName'),' '];
            chkDecimation.ObjectProperty=chkDecimation.Tag;
            chkDecimation.RowSpan=[2,2];
            chkDecimation.ColSpan=[1,1];
            chkDecimation.MatlabMethod='defaultLinePropCB_ddg';
            chkDecimation.MatlabArgs={'%dialog','%source','%tag','%value'};
            chkDecimation.Enabled=convertToBool(portObj.dataLogging);

            txtDecimation.Tag='DataLoggingDecimation';
            txtDecimation.Type='edit';
            txtDecimation.ObjectProperty=txtDecimation.Tag;
            txtDecimation.PreferredSize=[50,-1];
            txtDecimation.RowSpan=[2,2];
            txtDecimation.ColSpan=[2,2];
            txtDecimation.MatlabMethod='defaultLinePropCB_ddg';
            txtDecimation.MatlabArgs={'%dialog','%source','%tag','%value'};
            txtDecimation.Enabled=convertToBool(portObj.DataLoggingDecimateData)&&convertToBool(portObj.dataLogging);


            lblSampleTime.Tag='lblSampleTime';
            lblSampleTime.Name=DAStudio.message('Simulink:dialog:SigpropLblSampleTime');
            lblSampleTime.Type='text';
            lblSampleTime.RowSpan=[3,3];
            lblSampleTime.ColSpan=[1,1];
            lblSampleTime.Enabled=convertToBool(portObj.dataLogging);

            txtSampleTime.Tag='DataLoggingSampleTime';
            txtSampleTime.Type='edit';
            txtSampleTime.ObjectProperty=txtSampleTime.Tag;
            txtSampleTime.PreferredSize=[50,-1];
            txtSampleTime.RowSpan=[3,3];
            txtSampleTime.ColSpan=[2,2];
            txtSampleTime.MatlabMethod='defaultLinePropCB_ddg';
            txtSampleTime.MatlabArgs={'%dialog','%source','%tag','%value'};
            txtSampleTime.Enabled=convertToBool(portObj.dataLogging);

            grpData.Tag='grpData';
            grpData.Type='group';
            grpData.Name=DAStudio.message('Simulink:dialog:SigpropGrpDataName');
            grpData.ColSpan=[1,2];
            grpData.RowSpan=[3,3];

            grpData.LayoutGrid=[3,2];
            grpData.Items={chkDataPoints,txtDataPoints,...
            chkDecimation,txtDecimation,...
            lblSampleTime,txtSampleTime};


            groupspacer.Type='panel';
            groupspacer.RowSpan=[4,4];

            signalLoggingTogglePanel.Tag='LoggingTogglePanel';
            signalLoggingTogglePanel.Type='togglepanel';
            signalLoggingTogglePanel.Expand=obj.toggleStateMap(signalLoggingTogglePanel.Tag);
            signalLoggingTogglePanel.Name=DAStudio.message('Simulink:dialog:SigpropTabOneName');
            signalLoggingTogglePanel.Items={chkLogSigData,chkTestPoint,grpLog,grpData,groupspacer};
            signalLoggingTogglePanel.LayoutGrid=[4,2];
            signalLoggingTogglePanel.RowStretch=[0,0,0,1];
            signalLoggingTogglePanel.RowSpan=[4,4];
            signalLoggingTogglePanel.ColSpan=[1,2];

            sourceBlock=portObj.Parent;
            sourceModel=bdroot(sourceBlock);


            nextRow=6;
            showTaskTrans=DeploymentDiagram.isConcurrentTasks(sourceModel);
            if(showTaskTrans)
                enabTaskTrans=strcmp(get_param(sourceModel,'ExplicitPartitioning'),'on');
                taskTransSpec=strcmpi(portObj.TaskTransitionSpecified,'on');


                chkTaskTransSpec.Name=DAStudio.message('Simulink:mds:DataTransferDlgSpec');
                chkTaskTransSpec.Tag='TaskTransitionSpecified';
                chkTaskTransSpec.Type='checkbox';
                chkTaskTransSpec.ObjectProperty=chkTaskTransSpec.Tag;
                chkTaskTransSpec.Enabled=enabTaskTrans;
                chkTaskTransSpec.RowSpan=[1,1];
                chkTaskTransSpec.ColSpan=[1,2];
                chkTaskTransSpec.MatlabMethod='defaultLinePropCB_ddg';
                chkTaskTransSpec.MatlabArgs={'%dialog','%source','%tag','%value'};

                txtTaskTransType.Name=DAStudio.message('Simulink:mds:DataTransferDlgType');
                txtTaskTransType.Type='text';
                txtTaskTransType.Tag='cmbTaskTransType_Text';
                txtTaskTransType.RowSpan=[2,2];
                txtTaskTransType.ColSpan=[1,2];

                cmbTaskTransType.Tag='TaskTransitionType';
                cmbTaskTransType.Type='combobox';
                cmbTaskTransType.ObjectProperty=cmbTaskTransType.Tag;
                cmbTaskTransType.Enabled=enabTaskTrans&&taskTransSpec;
                cmbTaskTransType.RowSpan=[3,3];
                cmbTaskTransType.ColSpan=[1,2];
                chkTaskTransSpec.PreferredSize=[100,-1];
                cmbTaskTransType.MatlabMethod='defaultLinePropCB_ddg';
                cmbTaskTransType.MatlabArgs={'%dialog','%source','%tag','%value'};

                txtExtrapolationMethod.Name=DAStudio.message('Simulink:mds:DataTransferDlgExtrp');
                txtExtrapolationMethod.Type='text';
                txtExtrapolationMethod.Tag='cmbExtrapolationMethod_Text';
                txtExtrapolationMethod.RowSpan=[4,4];
                txtExtrapolationMethod.ColSpan=[1,2];

                cmbExtrapolationMethod.Tag='ExtrapolationMethod';
                cmbExtrapolationMethod.Type='combobox';
                cmbExtrapolationMethod.ObjectProperty=cmbExtrapolationMethod.Tag;
                cmbExtrapolationMethod.Enabled=enabTaskTrans&&taskTransSpec;
                cmbExtrapolationMethod.RowSpan=[5,5];
                cmbExtrapolationMethod.ColSpan=[1,2];
                cmbExtrapolationMethod.PreferredSize=[100,-1];
                cmbExtrapolationMethod.MatlabMethod='defaultLinePropCB_ddg';
                cmbExtrapolationMethod.MatlabArgs={'%dialog','%source','%tag','%value'};

                txtTaskTransIC.Name=DAStudio.message('Simulink:mds:DataTransferDlgIC');
                txtTaskTransIC.Type='text';
                txtTaskTransIC.Tag='editTaskTransIC_Text';
                txtTaskTransIC.RowSpan=[6,6];
                txtTaskTransIC.ColSpan=[1,1];

                editTaskTransIC.Tag='TaskTransitionIC';
                editTaskTransIC.Type='edit';
                editTaskTransIC.ObjectProperty=editTaskTransIC.Tag;
                editTaskTransIC.Enabled=enabTaskTrans&&taskTransSpec;
                editTaskTransIC.RowSpan=[6,6];
                editTaskTransIC.ColSpan=[2,2];
                editTaskTransIC.PreferredSize=[100,-1];
                editTaskTransIC.MatlabMethod='defaultLinePropCB_ddg';
                editTaskTransIC.MatlabArgs={'%dialog','%source','%tag','%value'};

                taskPanel.Type='panel';
                taskPanel.Enabled=enabTaskTrans;
                taskPanel.Items={chkTaskTransSpec,...
                txtTaskTransType,cmbTaskTransType,...
                txtExtrapolationMethod,cmbExtrapolationMethod,...
                txtTaskTransIC,editTaskTransIC};
                taskPanel.LayoutGrid=[6,2];
                taskPanel.ColStretch=[0,1];

                taskTogglePanel.Tag='TaskTogglePanel';
                taskTogglePanel.Type='togglepanel';
                taskTogglePanel.Name=DAStudio.message('Simulink:mds:DataTransferDlgTab');
                taskTogglePanel.Items={taskPanel};
                taskTogglePanel.RowSpan=[nextRow,nextRow];
                taskTogglePanel.ColSpan=[1,2];
                taskTogglePanel.Expand=obj.toggleStateMap(taskTogglePanel.Tag);

                nextRow=nextRow+1;
            end

            dlgstruct.DialogTitle='';
            dlgstruct.DialogTag=name;
            dlgstruct.DialogMode='Slim';
            dlgstruct.Source=lineObj;
            dlgstruct.Items={lblSignalName,txtSignalName,chkResSigObj,chkShowSigProp,signalLoggingTogglePanel};
            if(showTaskTrans)
                dlgstruct.Items=cat(2,dlgstruct.Items,taskTogglePanel);
            end
            dlgstruct.LayoutGrid=[nextRow,2];
            dlgstruct.RowStretch=[zeros(1,nextRow-1),1];
            dlgstruct.StandaloneButtonSet={''};
            dlgstruct.EmbeddedButtonSet={''};
            dlgstruct.DisableDialog=~isa(portObj,'handle')||...
            obj.source.isHierarchySimulating||...
            obj.disableDialog;

            dlgstruct.CloseCallback='Simulink.LinePropertiesDDGSource.closeCallback';
            dlgstruct.CloseArgs={'close_cb',portObj,'%dialog'};

            dlgstruct.OpenCallback=@(dlg)obj.dlgOpenCallback(dlg,sourceModel,sourceBlock,portObj);
        end



        function dlgOpenCallback(~,dlg,sourceModel,sourceBlock,portObj)
            [~,enableMappingProperties]=Simulink.CodeMapping.isCompatible(sourceModel,sourceBlock);
            if enableMappingProperties
                Simulink.CodeMapping.add_mapping_listener(sourceModel,sourceBlock,dlg,portObj);
            end
        end

        function dlgstruct=getLineInfoSchema(obj,name)
            lineObj=obj.source;
            portObj=lineObj.getSourcePort;
            assert(~isempty(portObj));


            lblDescription.Tag='lblDescription';
            lblDescription.Type='text';
            lblDescription.Name=DAStudio.message('Simulink:dialog:SigpropLblDescriptionName');
            lblDescription.RowSpan=[1,1];
            lblDescription.RowSpan=[1,2];

            txtDescription.Tag='Description';
            txtDescription.Type='editarea';
            txtDescription.RowSpan=[2,2];
            txtDescription.ColSpan=[1,2];
            txtDescription.ObjectProperty=txtDescription.Tag;
            txtDescription.PreferredSize=[200,100];
            txtDescription.MatlabMethod='defaultLinePropCB_ddg';
            txtDescription.MatlabArgs={'%dialog','%source','%tag','%value'};

            hypLink.Tag='hypLink';
            hypLink.Type='hyperlink';
            hypLink.Name=DAStudio.message('Simulink:dialog:SigpropHyplinkName');
            hypLink.MatlabMethod='eval';
            hypLink.MatlabArgs={portObj.documentLink};
            hypLink.RowSpan=[3,3];
            hypLink.ColSpan=[1,1];

            txtLink.Tag='DocumentLink';
            txtLink.Type='edit';
            txtLink.ObjectProperty=txtLink.Tag;
            txtLink.RowSpan=[3,3];
            txtLink.RowSpan=[2,2];
            txtLink.MatlabMethod='defaultLinePropCB_ddg';
            txtLink.MatlabArgs={'%dialog','%source','%tag','%value'};


            spacer.Type='panel';
            spacer.RowSpan=[4,4];
            spacer.ColSpan=[1,2];

            dlgstruct.DialogTitle='';
            dlgstruct.DialogTag=name;
            dlgstruct.DialogMode='Slim';
            dlgstruct.Source=lineObj;
            dlgstruct.Items={lblDescription,txtDescription,hypLink,txtLink,spacer};
            dlgstruct.LayoutGrid=[4,2];
            dlgstruct.RowStretch=[0,0,0,1];
            dlgstruct.StandaloneButtonSet={''};
            dlgstruct.EmbeddedButtonSet={''};
            dlgstruct.DisableDialog=~isa(portObj,'handle')||...
            obj.source.isHierarchySimulating||...
            obj.disableDialog;
        end



        function val=disableDialog(obj)
            val=false;
            sourcePortHandle=obj.source.getSourcePort.Handle;
            readOnly=strcmp(get_param(bdroot(sourcePortHandle),'Lock'),'on');
            if(readOnly)
                val=true;
            end
        end
    end
end




function ret=convertToBool(x)
    if(isa(x,'logical'))
        ret=x;
    else
        ret=strcmp(x,'on');
    end
end

function dataCallback(dialog,tag,src)
    dispatcher=DAStudio.EventDispatcher;
    if~isobject(src)
        dispatcher.broadcastEvent('PropertyChangedEvent',src);
    end

    dialog.clearWidgetDirtyFlag(tag);
end

function fullClassname_cmbbox_cb(dialog,cmbTag,lineObj,cmbEntries)
    selectedItem=cmbEntries{dialog.getWidgetValue(cmbTag)+1};
    oldVal=loc_comboboxIndexOfProp(lineObj.getSourcePort,'SignalObjectClass');
    if strcmp(selectedItem,DAStudio.message('Simulink:Signals:SIMULINK_OBJECT_LIST_CUSTOMIZE_MENU_ITEM'))
        dialog.setWidgetValue(cmbTag,oldVal);
        lineObj.getSourcePort.setPropValue('SignalObjectClass',selectedItem);
    else
        ed=DAStudio.EventDispatcher;
        ed.broadcastEvent('PropertyUpdateRequestEvent',dialog,{cmbTag,selectedItem});
    end

    dialog.clearWidgetDirtyFlag(cmbTag);
end




function idx=loc_comboboxIndexOfProp(obj,prop)

    idx=0;
    cnt=0;
    if strcmp(prop,'SignalObjectClass')
        values=configset.ert.getSigAttribFullClassList(obj.SignalObjectClass,true);
    else
        values=getPropAllowedValues(obj,prop);
    end
    value=get(obj,prop);
    for i=1:length(values)
        if strcmp(values{i},value)
            idx=cnt;
            return;
        end
        cnt=cnt+1;
    end
end

function dlgstruct=loc_EmptyDialog(name)

    txt.Name=DAStudio.message('Simulink:dialog:SigpropEmptyPortObjTxtName');
    txt.Type='text';
    txt.RowSpan=[1,1];
    txt.WordWrap=true;
    txt.Tag='Txt';
    spacer.Type='panel';
    spacer.RowSpan=[2,2];
    spacer.Tag='Spacer';
    dlgstruct.Items={txt,spacer};
    dlgstruct.LayoutGrid=[2,1];
    dlgstruct.RowStretch=[0,1];
    dlgstruct.DialogTag=name;
    dlgstruct.DialogTitle='';
    dlgstruct.DialogMode='Slim';
    dlgstruct.StandaloneButtonSet={''};
    dlgstruct.EmbeddedButtonSet={''};
end



