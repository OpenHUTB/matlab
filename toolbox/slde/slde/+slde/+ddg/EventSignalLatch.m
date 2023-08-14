classdef EventSignalLatch<handle





    properties
        mBlock;
        mUddParent;
    end


    methods


        function this=EventSignalLatch(blk,udd)


            this.mBlock=get_param(blk,'Object');
            this.mUddParent=udd;
        end


        function schema=getDialogSchema(this)


            blockDesc=this.getBlockDescriptionSchema();
            mainTab=this.getMainTabSchema();
            statsTab=this.getStatisticsSchema();


            tabCont.Type='tab';
            tabCont.Tabs={mainTab,statsTab};
            tabCont.Name='';
            tabCont.RowSpan=[2,2];
            tabCont.ColSpan=[1,1];

            schema.DialogTitle=DAStudio.message('Simulink:dialog:BlockParameters',this.mBlock.Name);
            schema.Items={blockDesc,tabCont};
            schema.DialogTag=this.mBlock.BlockType;
            schema.Source=this.mUddParent;
            schema.SmartApply=false;
            schema.HelpMethod='slhelp';
            schema.HelpArgs={this.mBlock.Handle};
            schema.HelpArgsDT={'double'};
            schema.CloseMethod='closeCallback';
            schema.CloseMethodArgs={'%dialog'};
            schema.CloseMethodArgsDT={'handle'};
            schema.PreApplyCallback='preApplyCallback';
            schema.PreApplyArgs={'%source','%dialog'};
            schema.PreApplyArgsDT={'handle','handle'};
        end
    end


    methods(Access=private)


        function schema=getBlockDescriptionSchema(this)



            blockDesc.Type='text';
            blockDesc.Name=this.mBlock.BlockDescription;
            blockDesc.WordWrap=true;

            schema.Type='group';
            schema.Name='Event Signal Latch';
            schema.Items={blockDesc};
            schema.RowSpan=[1,1];
            schema.ColSpan=[1,1];
        end


        function schema=getMainTabSchema(this)


            dlgParams=this.mBlock.IntrinsicDialogParameters;
            widgetIdx=0;


            rowIdx=1;
            initValue.Type='edit';
            initValue.Name=DAStudio.message('SimulinkDiscreteEvent:dialog:InitialValue');
            initValue.NameLocation=2;
            initValue.Tag='InitialValue';
            initValue.ObjectProperty='InitialValue';
            initValue.Source=this.mBlock;
            initValue.RowSpan=[rowIdx,rowIdx];
            initValue.ColSpan=[1,2];
            initValue.Mode=false;
            initValue.DialogRefresh=false;
            initValue.MatlabMethod='handleEditEvent';
            initValue.MatlabArgs={this.mUddParent,'%value',widgetIdx,'%dialog'};


            rowIdx=rowIdx+1;widgetIdx=widgetIdx+1;
            writeEvent.Type='combobox';
            writeEvent.Name=DAStudio.message('SimulinkDiscreteEvent:dialog:EventTypeForWrite');
            writeEvent.Entries=dlgParams.EventTypeForWrite.Enum;
            writeEvent.Tag='EventTypeForWrite';
            writeEvent.ObjectProperty='EventTypeForWrite';
            writeEvent.Source=this.mBlock;
            writeEvent.RowSpan=[rowIdx,rowIdx];
            writeEvent.ColSpan=[1,1];
            writeEvent.Mode=true;
            writeEvent.DialogRefresh=true;
            writeEvent.MatlabMethod='handleComboSelectionEvent';
            writeEvent.MatlabArgs={this.mUddParent,'%value',widgetIdx,'%dialog'};


            widgetIdx=widgetIdx+1;
            zeroCrossWrite.Type='checkbox';
            zeroCrossWrite.Name=DAStudio.message('SimulinkDiscreteEvent:dialog:ZeroCrossingOnlyWrite');
            zeroCrossWrite.Tag='ZeroCrossingOnlyWrite';
            zeroCrossWrite.ObjectProperty='ZeroCrossingOnlyWrite';
            zeroCrossWrite.Source=this.mBlock;
            zeroCrossWrite.RowSpan=[rowIdx,rowIdx];
            zeroCrossWrite.ColSpan=[2,2];
            zeroCrossWrite.Mode=true;
            zeroCrossWrite.DialogRefresh=false;
            zeroCrossWrite.MatlabMethod='handleCheckEvent';
            zeroCrossWrite.MatlabArgs={this.mUddParent,'%value',widgetIdx,'%dialog'};
            zeroCrossWrite.Enabled=any(strcmp(...
            this.mBlock.EventTypeForWrite,...
            {DAStudio.message('SimulinkDiscreteEvent:dialog:RisingValue'),...
            DAStudio.message('SimulinkDiscreteEvent:dialog:FallingValue'),...
            DAStudio.message('SimulinkDiscreteEvent:dialog:ChangingValue')}));


            rowIdx=rowIdx+1;widgetIdx=widgetIdx+1;
            readEvent.Type='combobox';
            readEvent.Name=DAStudio.message('SimulinkDiscreteEvent:dialog:EventTypeForRead');
            readEvent.Entries=dlgParams.EventTypeForRead.Enum;
            readEvent.Tag='EventTypeForRead';
            readEvent.ObjectProperty='EventTypeForRead';
            readEvent.Source=this.mBlock;
            readEvent.RowSpan=[rowIdx,rowIdx];
            readEvent.ColSpan=[1,1];
            readEvent.Mode=true;
            readEvent.DialogRefresh=true;
            readEvent.MatlabMethod='handleComboSelectionEvent';
            readEvent.MatlabArgs={this.mUddParent,'%value',widgetIdx,'%dialog'};


            widgetIdx=widgetIdx+1;
            zeroCrossRead.Type='checkbox';
            zeroCrossRead.Name=DAStudio.message('SimulinkDiscreteEvent:dialog:ZeroCrossingOnlyRead');
            zeroCrossRead.Tag='ZeroCrossingOnlyRead';
            zeroCrossRead.ObjectProperty='ZeroCrossingOnlyRead';
            zeroCrossRead.Source=this.mBlock;
            zeroCrossRead.RowSpan=[rowIdx,rowIdx];
            zeroCrossRead.ColSpan=[2,2];
            zeroCrossRead.Mode=true;
            zeroCrossRead.DialogRefresh=false;
            zeroCrossRead.MatlabMethod='handleCheckEvent';
            zeroCrossRead.MatlabArgs={this.mUddParent,'%value',widgetIdx,'%dialog'};
            zeroCrossRead.Enabled=any(strcmp(...
            this.mBlock.EventTypeForRead,...
            {DAStudio.message('SimulinkDiscreteEvent:dialog:RisingValue'),...
            DAStudio.message('SimulinkDiscreteEvent:dialog:FallingValue'),...
            DAStudio.message('SimulinkDiscreteEvent:dialog:ChangingValue')}));


            schema.Name=DAStudio.message(...
            'SimulinkDiscreteEvent:dialog:Main');
            schema.Items={...
            initValue,...
            writeEvent,...
            zeroCrossWrite,...
            readEvent,...
zeroCrossRead...
            };
            schema.LayoutGrid=[length(schema.Items)+1,2];
            schema.RowStretch=[zeros(1,length(schema.Items)),1];
            schema.ColStretch=[1,1];
        end


        function schema=getStatisticsSchema(this)



            rowIdx=1;
            lastAction.Type='checkbox';
            lastAction.Name=DAStudio.message('SimulinkDiscreteEvent:dialog:LastBlockAction');
            lastAction.Mode=true;
            lastAction.RowSpan=[rowIdx,rowIdx];
            lastAction.ColSpan=[1,1];
            lastAction.Tag='LastBlockAction';
            lastAction.ObjectProperty='LastBlockAction';
            lastAction.Source=this.mBlock;

            schema.Name=DAStudio.message('SimEvents:dialog:Statistics');
            schema.Items={lastAction};
            schema.LayoutGrid=[length(schema.Items)+1,1];
            schema.RowStretch=[zeros(1,length(schema.Items)),1];
        end

    end
end


