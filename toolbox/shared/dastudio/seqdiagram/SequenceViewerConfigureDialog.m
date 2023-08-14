classdef SequenceViewerConfigureDialog<handle





    properties(Access=private)
        mBlockDiagram;
        dlgInstance={};
    end


    methods


        function this=SequenceViewerConfigureDialog(modelHandle)

            this.mBlockDiagram=get_param(modelHandle,'Object');
        end


        function showConfigureDialog(this)


            if isempty(this.dlgInstance)
                this.dlgInstance=DAStudio.Dialog(this);
            else
                this.dlgInstance.show;
            end
        end



        function closeDialog(this,~)
            if~isempty(this.dlgInstance)
                delete(this.dlgInstance);
                this.dlgInstance=[];
            end
        end


        function schema=getDialogSchema(this)


            dialogDesc=this.getDialogDescriptionSchema();
            mainTab=this.getMainTabSchema();


            tabCont.Type='tab';
            tabCont.Tabs={mainTab};
            tabCont.Name=DAStudio.message('SimulinkEventLogging:MessageViewer:Main');
            tabCont.RowSpan=[2,2];
            tabCont.ColSpan=[1,1];

            schema.DialogTitle=DAStudio.message('SimulinkEventLogging:MessageViewer:SequenceViewerParameters');
            schema.Items={dialogDesc,tabCont};
            schema.DialogTag='';
            schema.Source=this.mBlockDiagram;
            schema.SmartApply=false;
            schema.HelpMethod='handleClickHelp';
            schema.HelpArgs={this};
            schema.CloseCallback='closeDialog';
            schema.CloseArgs={this,'%dialog'};


        end


        function schema=getDialogDescriptionSchema(~)



            dialogDesc.Type='text';
            dialogDesc.Name=DAStudio.message('SimulinkEventLogging:MessageViewer:BlockDescription');
            dialogDesc.WordWrap=true;

            schema.Type='group';
            schema.Name='Sequence Viewer';
            schema.Items={dialogDesc};
            schema.RowSpan=[1,1];
            schema.ColSpan=[1,1];
        end


        function schema=getMainTabSchema(this)


            rowIdx=1;


            wTimePrecision.Type='edit';
            wTimePrecision.Name=DAStudio.message('SimulinkEventLogging:MessageViewer:VariableStepTimePrecision');
            wTimePrecision.NameLocation=2;
            wTimePrecision.Tag='SequenceViewerTimePrecision';
            wTimePrecision.ObjectProperty='SequenceViewerTimePrecision';
            wTimePrecision.Source=this.mBlockDiagram;
            wTimePrecision.RowSpan=[rowIdx,rowIdx];
            wTimePrecision.ColSpan=[1,2];
            wTimePrecision.Mode=false;
            wTimePrecision.DialogRefresh=false;

            rowIdx=rowIdx+1;


            wHistory.Type='edit';
            wHistory.Name=DAStudio.message('SimulinkEventLogging:MessageViewer:History');
            wHistory.NameLocation=2;
            wHistory.Tag='SequenceViewerHistory';
            wHistory.ObjectProperty='SequenceViewerHistory';
            wHistory.Source=this.mBlockDiagram;
            wHistory.RowSpan=[rowIdx,rowIdx];
            wHistory.ColSpan=[1,2];
            wHistory.Mode=false;
            wHistory.DialogRefresh=false;



            schema.Name=DAStudio.message(...
            'SimulinkEventLogging:MessageViewer:Main');
            schema.Items={wTimePrecision,wHistory};
            schema.ShowGrid=true;
            schema.LayoutGrid=[length(schema.Items),1];
            schema.RowStretch=[zeros(1,length(schema.Items)),1];
            schema.ColStretch=[1,1];
        end



        function handleClickHelp(~)
            if license('test','Stateflow')
                helpview(fullfile(docroot,'stateflow','stateflow.map'),'SequenceViewerParameters_ug');
            elseif license('test','System_Composer')
                helpview(fullfile(docroot,'systemcomposer','helptargets.map'),'SequenceViewerParameters_ug');
            end
        end


    end
end


