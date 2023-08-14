classdef EntityOutputSwitch<handle






    properties(Access=public)
        mBlock;
        mUddParent;
        mChildErrorDlgs;
        mEditTimeAttribs;
    end


    methods


        function this=EntityOutputSwitch(blk,udd)


            this.mBlock=get_param(blk,'Object');
            this.mUddParent=udd;

            this.mChildErrorDlgs=[];
            this.mEditTimeAttribs={};
        end


        function schema=getDialogSchema(this)


            blockDesc=this.getBlockDescriptionSchema();
            this.mEditTimeAttribs=slde.ddg.GetEditTimeAttributesHelper(...
            this.getSigHierFromPort(),'');

            mainTab=this.getMainTabSchema();

            schema.DialogTitle=DAStudio.message('Simulink:dialog:BlockParameters',this.mBlock.Name);
            schema.Items={blockDesc,mainTab};
            schema.DialogTag=this.mBlock.BlockType;
            schema.Source=this.mUddParent;
            schema.SmartApply=false;
            schema.HelpMethod='slhelp';
            schema.HelpArgs={this.mBlock.Handle};
            schema.HelpArgsDT={'double'};
            schema.CloseMethod='doCloseCallback';
            schema.CloseMethodArgs={'%dialog','%closeaction'};
            schema.CloseMethodArgsDT={'handle','string'};
            schema.PreApplyCallback='doPreApplyCallback';
            schema.PreApplyArgs={'%source','%dialog'};
            schema.PreApplyArgsDT={'handle','handle'};
            schema.ExplicitShow=true;
        end


        function[status,msg]=preApplyCallback(this,dialog)

            try
                [status,msg]=this.mUddParent.preApplyCallback(dialog);
            catch me
                status=0;
                msg=me.message;
            end
        end


        function closeCallback(this,dialog,closeAction)



            for idx=1:length(this.mChildErrorDlgs)
                errDlg=this.mChildErrorDlgs(idx);
                if ishandle(errDlg)
                    delete(errDlg);
                end
            end
            this.mChildErrorDlgs=[];
            this.mUddParent.closeCallback(dialog);
        end



        function sigHier=getSigHierFromPort(this)
            pHandles=get_param(this.mBlock.Handle,'PortHandles');
            sigHier=get_param(pHandles.Inport(1),...
            'SignalHierarchy');
        end



        function launchPortSelectionActionWidget(this,dialog)

            unused_variable(this);
            pttrnAssistant=slde.ddg.PatternAssistant(dialog,...
            'PortSelectionFcn',this);
            pttrnDlg=DAStudio.Dialog(pttrnAssistant);

        end



    end



    methods(Access=private)


        function schema=getBlockDescriptionSchema(this)



            blockDesc.Type='text';
            blockDesc.Name=this.mBlock.BlockDescription;
            blockDesc.WordWrap=true;

            schema.Type='group';
            schema.Name='Entity Output Switch';
            schema.Items={blockDesc};
            schema.RowSpan=[1,1];
            schema.ColSpan=[1,1];
        end



        function schema=getMainTabSchema(this)



            rowIdx=1;
            wNumOutputPorts.Type='edit';
            wNumOutputPorts.Name=DAStudio.message('SimulinkDiscreteEvent:OutputSwitch:NumberOutputPorts');
            wNumOutputPorts.Tag='NumberOutputPorts';
            wNumOutputPorts.ObjectProperty='NumberOutputPorts';
            wNumOutputPorts.Source=this.mBlock;
            wNumOutputPorts.RowSpan=[rowIdx,rowIdx];
            wNumOutputPorts.ColSpan=[1,1];
            wNumOutputPorts.MatlabMethod='handleEditEvent';
            wNumOutputPorts.MatlabArgs={this.mUddParent,'%value',rowIdx-1,'%dialog'};
            wNumOutputPorts.Mode=false;
            wNumOutputPorts.DialogRefresh=false;


            rowIdx=rowIdx+1;
            wSwitchingCriterion.Type='combobox';
            wSwitchingCriterion.Name=DAStudio.message(...
            'SimulinkDiscreteEvent:OutputSwitch:SwitchingCriterion');
            wSwitchingCriterion.Entries={...
            DAStudio.message(...
            'SimulinkDiscreteEvent:OutputSwitch:SC_FirstPortNotBlocked_CB'),...
            DAStudio.message(...
            'SimulinkDiscreteEvent:OutputSwitch:SC_RoundRobin_CB'),...
            DAStudio.message(...
            'SimulinkDiscreteEvent:dialog:FromControlPort'),...
            DAStudio.message(...
            'SimulinkDiscreteEvent:OutputSwitch:SC_Attribute_CB'),...
            DAStudio.message(...
            'SimulinkDiscreteEvent:OutputSwitch:SC_Equiprobable_CB')...
            };

            if(slfeature('NewDESMatlabActionRouting')>0)
                wSwitchingCriterion.Entries(end+1)={DAStudio.message(...
                'SimulinkDiscreteEvent:dialog:EventAction')
                };
            end
            wSwitchingCriterion.Tag='SwitchingCriterion';
            wSwitchingCriterion.ObjectProperty='SwitchingCriterion';
            wSwitchingCriterion.Source=this.mBlock;
            wSwitchingCriterion.RowSpan=[rowIdx,rowIdx];
            wSwitchingCriterion.ColSpan=[1,1];
            wSwitchingCriterion.Mode=true;
            wSwitchingCriterion.DialogRefresh=true;
            wSwitchingCriterion.MatlabMethod='handleComboSelectionEvent';
            wSwitchingCriterion.MatlabArgs={this.mUddParent,'%value',...
            rowIdx-1,'%dialog'};


            rowIdx=rowIdx+1;
            wInitialSeed.Type='edit';
            wInitialSeed.Name=DAStudio.message('SimulinkDiscreteEvent:OutputSwitch:Seed');
            wInitialSeed.Tag='InitialSeed';
            wInitialSeed.ObjectProperty='Seed';
            wInitialSeed.Source=this.mBlock;
            wInitialSeed.RowSpan=[rowIdx,rowIdx];
            wInitialSeed.ColSpan=[1,1];
            wInitialSeed.MatlabMethod='handleEditEvent';
            wInitialSeed.MatlabArgs={this.mUddParent,'%value',rowIdx-1,'%dialog'};
            wInitialSeed.Mode=false;
            wInitialSeed.DialogRefresh=false;


            rowIdx=rowIdx+1;
            wSwitchAttribName.Type='combobox';
            wSwitchAttribName.Name=DAStudio.message('SimulinkDiscreteEvent:OutputSwitch:AttributeName');
            wSwitchAttribName.Tag='AttributeName';
            wSwitchAttribName.ObjectProperty='SwitchAttributeName';
            wSwitchAttribName.Entries=this.mEditTimeAttribs;
            wSwitchAttribName.Source=this.mBlock;
            wSwitchAttribName.RowSpan=[rowIdx,rowIdx];
            wSwitchAttribName.ColSpan=[1,1];
            wSwitchAttribName.MatlabMethod='handleComboSelectionEvent';
            wSwitchAttribName.MatlabArgs={this.mUddParent,'%value',rowIdx-1,'%dialog'};
            wSwitchAttribName.DialogRefresh=false;
            wSwitchAttribName.Editable=true;


            rowIdx=rowIdx+1;
            wInitPortSelection.Type='edit';
            wInitPortSelection.Name=DAStudio.message('SimulinkDiscreteEvent:OutputSwitch:InitialConditions');
            wInitPortSelection.Tag='InitialConditions';
            wInitPortSelection.ObjectProperty='InitialPortSelection';
            wInitPortSelection.Source=this.mBlock;
            wInitPortSelection.RowSpan=[rowIdx,rowIdx];
            wInitPortSelection.ColSpan=[1,1];
            wInitPortSelection.MatlabMethod='handleEditEvent';
            wInitPortSelection.MatlabArgs={this.mUddParent,'%value',rowIdx-1,'%dialog'};
            wInitPortSelection.Mode=false;
            wInitPortSelection.DialogRefresh=false;


            rowIdx=rowIdx+1;
            wPortSelectionEditor.Type='matlabeditor';
            wPortSelectionEditor.Name=DAStudio.message('SimulinkDiscreteEvent:OutputSwitch:PortSelectionAction');
            wPortSelectionEditor.Tag='PortSelectionFcn';
            wPortSelectionEditor.Mode=false;
            wPortSelectionEditor.ToolTip=DAStudio.message('SimulinkDiscreteEvent:OutputSwitch:PortSelectionActionTooltip');
            wPortSelectionEditor.ObjectProperty='PortSelectionAction';
            wPortSelectionEditor.Source=this.mBlock;
            wPortSelectionEditor.MatlabMethod='handleEditEvent';
            wPortSelectionEditor.MatlabArgs={this.mUddParent,'%value',...
            rowIdx-1,'%dialog'};
            wPortSelectionEditor.MatlabEditorFeatures={'SyntaxHilighting',...
            'LineNumber','GoToLine','TabCompletion'};
            wPortSelectionEditor.RowSpan=[rowIdx,rowIdx];
            wPortSelectionEditor.ColSpan=[1,1];
            wPortSelectionEditor.Visible=Simulink.isParameterVisible(...
            this.mBlock.Handle,wPortSelectionEditor.ObjectProperty);
            wPortSelectionEditor.Enabled=strcmpi(get_param(bdroot(...
            this.mBlock.getFullName),'SimulationStatus'),'stopped');

            rowIdx=rowIdx+1;
            btnPttrnAsst.Type='pushbutton';
            btnPttrnAsst.Tag='PttrnAsstPortSelectionAction';
            btnPttrnAsst.Name='Insert pattern ...';
            btnPttrnAsst.ToolTip='Open pattern assistant';
            btnPttrnAsst.ObjectMethod='launchPortSelectionActionWidget';
            btnPttrnAsst.Source=this;
            btnPttrnAsst.MethodArgs={'%dialog'};
            btnPttrnAsst.ArgDataTypes={'handle'};
            btnPttrnAsst.DialogRefresh=false;
            btnPttrnAsst.Graphical=true;
            btnPttrnAsst.Visible=wPortSelectionEditor.Visible;
            btnPttrnAsst.RowSpan=[rowIdx,rowIdx];
            btnPttrnAsst.ColSpan=[1,1];
            btnPttrnAsst.Alignment=10;
            btnPttrnAsst.Visible=wPortSelectionEditor.Visible;
            btnPttrnAsst.Enabled=strcmpi(get_param(bdroot(...
            this.mBlock.getFullName),'SimulationStatus'),'stopped');


            schema.Type='group';
            schema.Name=DAStudio.message('SimulinkDiscreteEvent:dialog:Parameters');
            schema.Items={wNumOutputPorts,wSwitchingCriterion,wInitialSeed,...
            wSwitchAttribName,wInitPortSelection};

            if(slfeature('NewDESMatlabActionRouting')>0)
                schema.Items(end+1:end+2)={wPortSelectionEditor,btnPttrnAsst};
            end

            schema.LayoutGrid=[length(schema.Items)+1,1];
            schema.RowStretch=[zeros(1,length(schema.Items)),1];
        end



    end

end






function unused_variable(varargin)

end


