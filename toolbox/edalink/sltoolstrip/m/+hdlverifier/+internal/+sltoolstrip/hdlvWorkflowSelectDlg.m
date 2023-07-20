

classdef hdlvWorkflowSelectDlg<handle



    properties(Constant)
        id=DAStudio.message('EDALink:SLToolstrip:General:HDLVWorkflowDlgTitle');
        title=DAStudio.message('EDALink:SLToolstrip:General:HDLVWorkflowDlgTitle');
        comp='GLUE2:DDG Component';
    end

    properties(SetObservable=true,AbortSet=true)
        selectedWorkflowContext;
    end

    properties
        cbInfoObj;
        tag_prefix='hdlvWorkflowSelectDlg_';
        hndl=[];
    end


    methods(Static)

        function description=workflowContextMappingToDescription(workflow)

            persistent currentDescriptionMap
            keySet={'hdlvCosimContext','hdlvFILContext','hdlvDPIContext',...
            'hdlvUVMContext','hdlvTLMGContext','hdlvAXIMasterContext','hdlvFDCContext'};
            valueSet={
            message('EDALink:SLToolstrip:General:workflowCosimTextDescription').getString,...
            message('EDALink:SLToolstrip:General:workflowFilTextDescription').getString,...
            message('EDALink:SLToolstrip:General:workflowDpiTextDescription').getString,...
            message('EDALink:SLToolstrip:General:workflowUvmTextDescription').getString,...
            message('EDALink:SLToolstrip:General:workflowTlmTextDescription').getString,...
            message('EDALink:SLToolstrip:General:workflowAximTextDescription').getString,...
            message('EDALink:SLToolstrip:General:workflowFdcTextDescription').getString
            };
            if isempty(currentDescriptionMap)
                currentDescriptionMap=containers.Map(keySet,valueSet);
            end

            description=currentDescriptionMap(workflow);
        end

        function contextLabel=radioEntryToWorkflowContextMapping(radioSelectionIndx)



            persistent currentRadioMap
            keySet=[0,1];
            valueSet={'hdlvCosimContext','hdlvDPIContext'};



            if isempty(currentRadioMap)
                currentRadioMap=containers.Map(keySet,valueSet);
            end

            contextLabel=currentRadioMap(radioSelectionIndx);
        end

        function radioValue=WorkflowContextToRadioEntryMapping(workflow)



            persistent currentWorkflowMap;
            valueSet=[0,1];
            keySet={'hdlvCosimContext','hdlvDPIContext'};



            if isempty(currentWorkflowMap)
                currentWorkflowMap=containers.Map(keySet,valueSet);
            end

            radioValue=currentWorkflowMap(workflow);

        end
    end


    methods

        function dlgObj=hdlvWorkflowSelectDlg(cbInfoObj)
            dlgObj.cbInfoObj=cbInfoObj;
            dlgObj.selectedWorkflowContext=dlgObj.getDefaultContext();
        end

        function context=getDefaultContext(obj)

            target=get_param(obj.cbInfoObj.model.Name,'SystemTargetFile');
            tlc=target(1:end-4);
            switch tlc
            case{'systemverilog_dpi_ert','systemverilog_dpi_grt'}
                context='hdlvDPIContext';


            otherwise
                context='hdlvCosimContext';

            end
        end

        function schema=getDialogSchema(obj)

            textDescription.Type='text';
            textDescription.Tag=[obj.tag_prefix,'textDescription'];
            textDescription.Name=hdlverifier.internal.sltoolstrip.hdlvWorkflowSelectDlg.workflowContextMappingToDescription(obj.selectedWorkflowContext);
            textDescription.Visible=true;
            textDescription.Mode=1;
            textDescription.WordWrap=true;
            textDescription.ListenToProperties={'selectedWorkflowContext'};

            textGroup.Type='group';
            textGroup.Tag=[obj.tag_prefix,'textGroup'];
            textGroup.Name=message('EDALink:SLToolstrip:General:workflowTextGroup').getString;
            textGroup.Visible=true;
            textGroup.RowSpan=[5,6];
            textGroup.ColSpan=[1,1];
            textGroup.Items={textDescription};

            radioSelectionGroup.Type='radiobutton';
            radioSelectionGroup.Name='';
            radioSelectionGroup.Tag=[obj.tag_prefix,'radioSelectionGroup'];
            radioSelectionGroup.OrientHorizontal=false;
            radioSelectionGroup.Entries={...
            message('EDALink:SLToolstrip:General:workflowRadioButtonCosimLabel').getString,...
            message('EDALink:SLToolstrip:General:workflowRadioButtonDPILabel').getString,...
            };









            radioSelectionGroup.Value=0;
            radioSelectionGroup.ObjectMethod='selectWorkflowRadioCB';
            radioSelectionGroup.MethodArgs={'%value'};
            radioSelectionGroup.ArgDataTypes={'mxArray'};
            radioSelectionGroup.DialogRefresh=true;

            selectionPanel.Type='panel';
            selectionPanel.Tag=[obj.tag_prefix,'selectionPanel'];
            selectionPanel.Items={radioSelectionGroup};
            selectionPanel.RowSpan=[1,4];
            selectionPanel.ColSpan=[1,1];



            schema.DialogTitle='';
            schema.StandaloneButtonSet={''};
            schema.EmbeddedButtonSet={''};

            schema.Items={selectionPanel,textGroup};
            schema.LayoutGrid=[6,1];
            schema.OpenCallback=@obj.OpenCallback;
        end

        function widget=createSpacing(obj,rowSpan,colSpan)


            widget.Type='panel';
            widget.Tag=[obj.tag_prefix,'invisDummyPanel'];
            widget.RowSpan=rowSpan;
            widget.ColSpan=colSpan;
        end

        function selectWorkflowRadioCB(obj,radioSelectionIndx)

            obj.selectedWorkflowContext=hdlverifier.internal.sltoolstrip.hdlvWorkflowSelectDlg.radioEntryToWorkflowContextMapping(radioSelectionIndx);
        end


        function OpenCallback(obj,h)

            h.setWidgetValue('hdlvWorkflowSelectDlg_radioSelectionGroup',...
            hdlverifier.internal.sltoolstrip.hdlvWorkflowSelectDlg.WorkflowContextToRadioEntryMapping(obj.selectedWorkflowContext));
            obj.hndl=h;
        end

    end

end
