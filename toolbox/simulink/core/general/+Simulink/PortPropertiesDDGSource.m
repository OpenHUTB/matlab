classdef PortPropertiesDDGSource<handle




    properties(SetObservable=true,SetAccess=private)
        source='';
        toggleStateMap='';
    end

    methods
        function this=PortPropertiesDDGSource(h)
            if isa(h,'Simulink.Port')
                this.source=h;
                this.toggleStateMap=containers.Map(...
                {'LoggingTogglePanel','CodeGenTogglePanel','TaskTogglePanel'},...
                {true,true,true});

            else
                ME=MException('PortPropertiesDDGSource:InvalidSourceType',...
                'The source type is not a Simulink Port');
                throw(ME);
            end
        end

        function dlgstruct=getDialogSchema(obj,name)
            dlgstruct=[];
            portObj=obj.source;

            sourceBlock=portObj.Parent;
            sourceModel=bdroot(sourceBlock);
            isModelClosing=slInternal('isBDClosing',sourceModel);

            if isempty(portObj)||isModelClosing
                dlgstruct=loc_EmptyDialog(name);
                return;
            end

            if strcmp(name,'Simulink:Dialog:Properties')
                dlgstruct=obj.getPortPropertiesSchema(name);
            elseif strcmp(name,'Simulink:Dialog:Info')
                dlgstruct=obj.getPortInfoSchema(name);
            end
        end


        function fObj=getForwardedObject(obj)
            fObj=obj;
        end

        function[completions,expVec]=getAutoCompleteData(obj,tag,partialText,curPos)
            portObj=obj.source;
            [completions,expVec]=slprivate('blockAutoCompleteSuggestion',partialText,tag,portObj,curPos);
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

        function dlgstruct=getPortPropertiesSchema(obj,name)
            portObj=obj.source;
            assert(~isempty(portObj));
            sourceBlock=get_param(portObj.Handle,'Parent');
            sourceBlockType=get_param(sourceBlock,'BlockType');
            portType=get_param(portObj.Handle,'PortType');


            lblPortName.Tag='lblPortName';
            lblPortName.Type='text';
            lblPortName.Name=DAStudio.message('Simulink:dialog:SigpropLblSignalNameName');
            lblPortName.RowSpan=[1,1];
            lblPortName.ColSpan=[1,1];

            txtPortName.Tag='port_Name';
            txtPortName.Type='edit';
            txtPortName.ObjectProperty='Name';
            txtPortName.RowSpan=[1,1];
            txtPortName.ColSpan=[2,2];
            txtPortName.MatlabMethod='defaultPortPropCB_ddg';
            txtPortName.MatlabArgs={'%dialog','%source','%tag','%value'};

            lblPFJ.Tag='lblPFJ';
            lblPFJ.Type='text';
            lblPFJ.Name=DAStudio.message('Simulink:dialog:PortpropLblPerturbationForJacobian');
            lblPFJ.RowSpan=[1,1];
            lblPFJ.RowSpan=[1,1];

            txtPFJ.Tag='port_PerturbationForJacobian';
            txtPFJ.Type='edit';
            txtPFJ.ObjectProperty='PerturbationForJacobian';
            txtPFJ.RowSpan=[1,1];
            txtPFJ.ColSpan=[2,2];
            txtPFJ.MatlabMethod='defaultPortPropCB_ddg';
            txtPFJ.MatlabArgs={'%dialog','%source','%tag','%value'};

            chkShowSigGenPortName.Tag='port_ShowSigGenPortName';
            chkShowSigGenPortName.Type='checkbox';
            chkShowSigGenPortName.Name=DAStudio.message('Simulink:dialog:PortpropChkShowSignalGenPortName');
            chkShowSigGenPortName.ObjectProperty='ShowSigGenPortName';
            chkShowSigGenPortName.RowSpan=[2,2];
            chkShowSigGenPortName.ColSpan=[1,2];
            chkShowSigGenPortName.MatlabMethod='defaultPortPropCB_ddg';
            chkShowSigGenPortName.MatlabArgs={'%dialog','%source','%tag','%value'};


            disableMustResolveToSignalObject=isempty(portObj.Name)||...
            strcmp(sourceBlockType,'BusSelector')||...
            (strcmp(sourceBlockType,'Inport')&&...
            strcmp(get_param(sourceBlock,'IsBusElementPort'),'on'));
            chkResSigObj.Tag='port_MustResolveToSignalObject';
            chkResSigObj.Type='checkbox';
            chkResSigObj.Name=DAStudio.message('Simulink:dialog:SigpropChkResSigObjName');
            chkResSigObj.ToolTip=DAStudio.message('Simulink:dialog:SigpropChkResSigObjName');
            chkResSigObj.PreferredSize=[200,-1];
            chkResSigObj.ObjectProperty='MustResolveToSignalObject';
            chkResSigObj.Visible=isValidProperty(portObj,'MustResolveToSignalObject');
            chkResSigObj.Enabled=~disableMustResolveToSignalObject;
            chkResSigObj.RowSpan=[3,3];
            chkResSigObj.ColSpan=[1,2];
            chkResSigObj.MatlabMethod='defaultPortPropCB_ddg';
            chkResSigObj.MatlabArgs={'%dialog','%source','%tag','%value'};

            chkShowSigProp.Tag='port_ShowPropagatedSignals';
            chkShowSigProp.Type='checkbox';
            chkShowSigProp.Name=DAStudio.message('Simulink:dialog:SigpropLblShowSigPropName');
            chkShowSigProp.Value=~strcmpi(portObj.ShowPropagatedSignals,'off');

            chkShowSigProp.RowSpan=[4,4];
            chkShowSigProp.ColSpan=[1,2];
            chkShowSigProp.MatlabMethod='defaultPortPropCB_ddg';
            chkShowSigProp.MatlabArgs={'%dialog','%source','%tag','%value'};







            chkLogSigData.Tag='port_DataLogging';
            chkLogSigData.Type='checkbox';
            chkLogSigData.Name=DAStudio.message('Simulink:dialog:SigpropChkLogSigDataName');
            chkLogSigData.ObjectProperty='DataLogging';
            chkLogSigData.RowSpan=[1,1];
            chkLogSigData.ColSpan=[1,1];
            chkLogSigData.MatlabMethod='defaultPortPropCB_ddg';
            chkLogSigData.MatlabArgs={'%dialog','%source','%tag','%value'};


            chkTestPoint.Tag='port_TestPoint';
            chkTestPoint.Type='checkbox';
            chkTestPoint.Name=DAStudio.message('Simulink:dialog:SigpropChkTestPointName');
            chkTestPoint.ObjectProperty='TestPoint';
            chkTestPoint.RowSpan=[1,1];
            chkTestPoint.ColSpan=[2,2];
            chkTestPoint.MatlabMethod='defaultPortPropCB_ddg';
            chkTestPoint.MatlabArgs={'%dialog','%source','%tag','%value'};






            cmbLog.Tag='port_DataLoggingNameMode';
            cmbLog.Type='combobox';
            cmbLog.ObjectProperty='DataLoggingNameMode';
            cmbLog.Values=[0,1];
            cmbLog.Entries={DAStudio.message('Simulink:dialog:SigpropCmbLogEntryUseSignalName'),...
            DAStudio.message('Simulink:dialog:SigpropCmbLogEntryCustom')};
            cmbLog.Enabled=convertToBool(portObj.dataLogging);
            cmbLog.MatlabMethod='defaultPortPropCB_ddg';
            cmbLog.MatlabArgs={'%dialog','%source','%tag','%value'};

            txtName.Tag='port_UserSpecifiedLogName';
            txtName.Type='edit';
            txtName.ObjectProperty='UserSpecifiedLogName';
            txtName.Enabled=convertToBool(portObj.dataLogging)&&~(strcmp(portObj.DataLoggingNameMode,'SignalName'));
            txtName.MatlabMethod='defaultPortPropCB_ddg';
            txtName.MatlabArgs={'%dialog','%source','%tag','%value'};

            grpLog.Tag='port_grpLog';
            grpLog.Type='group';
            grpLog.Name=DAStudio.message('Simulink:dialog:SigpropGrpLogName');
            grpLog.LayoutGrid=[2,1];
            grpLog.Items={cmbLog,txtName};
            grpLog.RowSpan=[2,2];
            grpLog.ColSpan=[1,2];





            chkDataPoints.Tag='port_DataLoggingLimitDataPoints';
            chkDataPoints.Type='checkbox';
            chkDataPoints.Name=[DAStudio.message('Simulink:dialog:SigpropLblDataPointsName'),' '];
            chkDataPoints.RowSpan=[1,1];
            chkDataPoints.ColSpan=[1,1];
            chkDataPoints.ObjectProperty='DataLoggingLimitDataPoints';
            chkDataPoints.Enabled=convertToBool(portObj.dataLogging);
            chkDataPoints.MatlabMethod='defaultPortPropCB_ddg';
            chkDataPoints.MatlabArgs={'%dialog','%source','%tag','%value'};

            txtDataPoints.Tag='port_DataLoggingMaxPoints';
            txtDataPoints.Type='edit';
            txtDataPoints.ObjectProperty='DataLoggingMaxPoints';
            txtDataPoints.PreferredSize=[50,-1];
            txtDataPoints.RowSpan=[1,1];
            txtDataPoints.ColSpan=[2,2];
            txtDataPoints.MatlabMethod='defaultPortPropCB_ddg';
            txtDataPoints.MatlabArgs={'%dialog','%source','%tag','%value'};
            txtDataPoints.Enabled=convertToBool(portObj.dataLogging)&&convertToBool(portObj.DataLoggingLimitDataPoints);

            chkDecimation.Tag='port_DataLoggingDecimateData';
            chkDecimation.Type='checkbox';
            chkDecimation.Name=[DAStudio.message('Simulink:dialog:SigpropLblDecimationName'),' '];
            chkDecimation.ObjectProperty='DataLoggingDecimateData';
            chkDecimation.RowSpan=[2,2];
            chkDecimation.ColSpan=[1,1];
            chkDecimation.MatlabMethod='defaultPortPropCB_ddg';
            chkDecimation.MatlabArgs={'%dialog','%source','%tag','%value'};
            chkDecimation.Enabled=convertToBool(portObj.dataLogging);

            txtDecimation.Tag='port_DataLoggingDecimation';
            txtDecimation.Type='edit';
            txtDecimation.ObjectProperty='DataLoggingDecimation';
            txtDecimation.PreferredSize=[50,-1];
            txtDecimation.RowSpan=[2,2];
            txtDecimation.ColSpan=[2,2];
            txtDecimation.MatlabMethod='defaultPortPropCB_ddg';
            txtDecimation.MatlabArgs={'%dialog','%source','%tag','%value'};
            txtDecimation.Enabled=convertToBool(portObj.DataLoggingDecimateData)&&convertToBool(portObj.dataLogging);


            lblSampleTime.Tag='port_lblSampleTime';
            lblSampleTime.Name=DAStudio.message('Simulink:dialog:SigpropLblSampleTime');
            lblSampleTime.Type='text';
            lblSampleTime.RowSpan=[3,3];
            lblSampleTime.ColSpan=[1,1];
            lblSampleTime.Enabled=convertToBool(portObj.dataLogging);

            txtSampleTime.Tag='port_DataLoggingSampleTime';
            txtSampleTime.Type='edit';
            txtSampleTime.ObjectProperty='DataLoggingSampleTime';
            txtSampleTime.PreferredSize=[50,-1];
            txtSampleTime.RowSpan=[3,3];
            txtSampleTime.ColSpan=[2,2];
            txtSampleTime.MatlabMethod='defaultPortPropCB_ddg';
            txtSampleTime.MatlabArgs={'%dialog','%source','%tag','%value'};
            txtSampleTime.Enabled=convertToBool(portObj.dataLogging);

            grpData.Tag='port_grpData';
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

            signalLoggingTogglePanel.Tag='port_LoggingTogglePanel';
            signalLoggingTogglePanel.Type='togglepanel';
            signalLoggingTogglePanel.Expand=obj.toggleStateMap('LoggingTogglePanel');
            signalLoggingTogglePanel.Name=DAStudio.message('Simulink:dialog:SigpropTabOneName');
            signalLoggingTogglePanel.Items={chkLogSigData,chkTestPoint,grpLog,grpData,groupspacer};
            signalLoggingTogglePanel.LayoutGrid=[4,2];
            signalLoggingTogglePanel.RowStretch=[0,0,0,1];
            signalLoggingTogglePanel.RowSpan=[5,5];
            signalLoggingTogglePanel.ColSpan=[1,2];

            sourceBlock=portObj.Parent;
            sourceModel=bdroot(sourceBlock);

            dlgstruct.DialogTitle='';
            dlgstruct.DialogTag=name;
            dlgstruct.DialogMode='Slim';
            dlgstruct.Source=portObj;

            if strcmp(portType,'inport')
                dlgstruct.Items={lblPFJ,txtPFJ,chkShowSigGenPortName};
            elseif strcmp(portType,'outport')
                dlgstruct.Items={lblPortName,txtPortName,chkResSigObj,chkShowSigProp,signalLoggingTogglePanel};
            end

            dlgstruct.LayoutGrid=[6,2];
            dlgstruct.RowStretch=[0,0,0,0,1,1];
            dlgstruct.StandaloneButtonSet={''};
            dlgstruct.EmbeddedButtonSet={''};
        end


        function dlgstruct=getPortInfoSchema(obj,name)
            portObj=obj.source;
            assert(~isempty(portObj));


            lblDescription.Tag='port_lblDescription';
            lblDescription.Type='text';
            lblDescription.Name=DAStudio.message('Simulink:dialog:SigpropLblDescriptionName');
            lblDescription.RowSpan=[1,1];
            lblDescription.RowSpan=[1,2];

            txtDescription.Tag='port_Description';
            txtDescription.Type='editarea';
            txtDescription.RowSpan=[2,2];
            txtDescription.ColSpan=[1,2];
            txtDescription.ObjectProperty='Description';
            txtDescription.PreferredSize=[200,100];
            txtDescription.MatlabMethod='defaultPortPropCB_ddg';
            txtDescription.MatlabArgs={'%dialog','%source','%tag','%value'};

            hypLink.Tag='port_hypLink';
            hypLink.Type='hyperlink';
            hypLink.Name=DAStudio.message('Simulink:dialog:SigpropHyplinkName');
            hypLink.MatlabMethod='eval';
            hypLink.MatlabArgs={portObj.documentLink};
            hypLink.RowSpan=[3,3];
            hypLink.ColSpan=[1,1];

            txtLink.Tag='port_DocumentLink';
            txtLink.Type='edit';
            txtLink.ObjectProperty='DocumentLink';
            txtLink.RowSpan=[3,3];
            txtLink.RowSpan=[2,2];
            txtLink.MatlabMethod='defaultPortPropCB_ddg';
            txtLink.MatlabArgs={'%dialog','%source','%tag','%value'};


            spacer.Type='panel';
            spacer.RowSpan=[4,4];
            spacer.ColSpan=[1,2];

            dlgstruct.DialogTitle='';
            dlgstruct.DialogTag=name;
            dlgstruct.DialogMode='Slim';
            dlgstruct.Source=portObj;
            dlgstruct.Items={lblDescription,txtDescription,hypLink,txtLink,spacer};
            dlgstruct.LayoutGrid=[4,2];
            dlgstruct.RowStretch=[0,0,0,1];
            dlgstruct.StandaloneButtonSet={''};
            dlgstruct.EmbeddedButtonSet={''};
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

function fullClassname_cmbbox_cb(dialog,cmbTag,portObj,cmbEntries)
    selectedItem=cmbEntries{dialog.getWidgetValue(cmbTag)+1};
    oldVal=loc_comboboxIndexOfProp(portObj,'SignalObjectClass');
    if strcmp(selectedItem,DAStudio.message('Simulink:Signals:SIMULINK_OBJECT_LIST_CUSTOMIZE_MENU_ITEM'))
        dialog.setWidgetValue(cmbTag,oldVal);
        portObj.setPropValue('SignalObjectClass',selectedItem);
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



