classdef StepperBreakpointList<handle




    properties
        mData;
        mMdl;
        mColumns;
        mComponent;
    end
    properties(Constant)
        mName='Conditional Breakpoints';
    end
    methods(Static,Access=public)
        function result=handleSelectionChange(comp,sels)




            result=true;
        end
        function handleHelpClicked(~)
            helpview(...
            fullfile(docroot,'simulink','helptargets.map'),'SimStepper_cond');
        end
        function createSpreadSheetComponent(studio,forceshow,~)
            comp=studio.getComponent('GLUE2:SpreadSheet',SLStudio.StepperBreakpointList.mName);
            if isempty(comp)
                comp=GLUE2.SpreadSheetComponent(studio,SLStudio.StepperBreakpointList.mName);
                studio.registerComponent(comp);
                bdHandle=studio.App.blockDiagramHandle;
                mdlName=get_param(bdHandle,'Name');
                compTitle=DAStudio.message(...
                'Simulink:studio:ConditionalPauseList');
                comp.ExplicitShow=~forceshow;

                obj=SLStudio.StepperBreakpointList(mdlName,comp);
                studio.moveComponentToDock(comp,compTitle,'Bottom','Tabbed');
                comp.PersistState=true;
                comp.DestroyOnHide=true;
                comp.CreateCallback='SLStudio.StepperBreakpointList.createSpreadSheetComponent';
                comp.setTitleViewSource(obj);
            else
                if~comp.isVisible
                    studio.showComponent(comp);
                    studio.focusComponent(comp);
                else
                    studio.hideComponent(comp);
                end
            end
        end
    end
    methods
        function this=StepperBreakpointList(modelname,comp)
            this.mColumns={'Id','Enabled','Source','Type','Condition','Hits'};
            this.mMdl=modelname;
            this.mComponent=comp;
            this.mComponent.setColumns(this.mColumns,'Id','',true);
            this.mComponent.setSource(this);
            this.mComponent.setEmptyListMessage(DAStudio.message(...
            'Simulink:studio:ConditionalPauseListIsEmpty'));


            this.mComponent.onHelpClicked=@SLStudio.StepperBreakpointList.handleHelpClicked;

            this.mComponent.show;
        end

        function children=getChildren(this,component)



            if isempty(this.mData)
                children=[];
                BPs=get_param(this.mMdl,'ConditionalPauseList');
                count=numel(BPs);

                for bdx=1:count
                    handle=BPs(bdx).portHandle;
                    data=BPs(bdx).data;
                    childObj=SLStudio.StepperBreakpointSingle(bdx,handle,data);
                    children=[children,childObj];
                end
                this.mData=children;
            else
                children=this.mData;
            end
        end
        function aResolved=resolveComponentSelection(this)
            aResolved={};
        end
        function aResolved=resolveSourceSelection(this,aSelections,~,~)


            aResolved={};
            if isempty(aSelections)||isempty(this.mData)
                return;
            end
            if isa(aSelections,'Simulink.Line')
                cnt=numel(aSelections);
                phSels=zeros(1,cnt);
                for sdx=1:cnt
                    phSels(sdx)=aSelections(sdx).getSourcePort.Handle;
                end
                phSels=unique(phSels);
                for sdx=1:numel(phSels)
                    for idx=1:numel(this.mData)
                        if isequal(this.mData(idx).mSrc,phSels(sdx))
                            aResolved{end+1}=this.mData(idx);
                        end
                    end
                end
            end
            if isa(aSelections,'Simulink.Block')

                for sdx=1:numel(aSelections)
                    bh=aSelections(sdx).Handle;
                    for idx=1:numel(this.mData)
                        blk=get_param(this.mData(idx).mSrc,'Parent');
                        sh=get_param(blk,'Handle');
                        if isequal(bh,sh)
                            aResolved{end+1}=this.mData(idx);
                        end
                    end
                end
            end
        end
        function columns=getColumns(obj)
            columns=obj.mColumns;
        end
        function comp=getComponent(obj)
            comp=obj.mComponent;
        end
        function dlgStruct=getDialogSchema(this,~)

            addBPButton.Type='pushbutton';
            addBPButton.Tag='bplist_new_bp';
            addBPButton.ToolTip=DAStudio.message('Simulink:studio:AddConditionalPause');
            addBPButton.FilePath=fullfile(matlabroot,'toolbox',...
            'shared','dastudio','resources','add.png');
            addBPButton.RowSpan=[1,1];
            addBPButton.ColSpan=[1,1];
            addBPButton.ObjectMethod='';
            addBPButton.MethodArgs={'%dialog'};
            addBPButton.ArgDataTypes={'handle'};
            addBPButton.Enabled=true;

            previousButton.Type='pushbutton';
            previousButton.Tag='bplist_previous_active_bp';
            previousButton.ToolTip='Previous active breakpoint';
            previousButton.FilePath=fullfile(matlabroot,'toolbox',...
            'shared','dastudio','resources','previous.png');
            previousButton.RowSpan=[1,1];
            previousButton.ColSpan=[2,2];
            previousButton.ObjectMethod='';
            previousButton.MethodArgs={'%dialog'};
            previousButton.ArgDataTypes={'handle'};
            previousButton.Enabled=true;

            nextButton.Type='pushbutton';
            nextButton.Tag='bplist_previous_next_bp';
            nextButton.ToolTip='Next active breakpoint';
            nextButton.FilePath=fullfile(matlabroot,'toolbox',...
            'shared','dastudio','resources','next.png');
            nextButton.RowSpan=[1,1];
            nextButton.ColSpan=[3,3];
            nextButton.ObjectMethod='';
            nextButton.MethodArgs={'%dialog'};
            nextButton.ArgDataTypes={'handle'};
            nextButton.Enabled=true;

            deleteButton.Type='pushbutton';
            deleteButton.Tag='bplist_delete_bp';
            deleteButton.ToolTip='Delete breakpoint';
            deleteButton.FilePath=fullfile(matlabroot,'toolbox',...
            'shared','dastudio','resources','Delete_16.png');
            deleteButton.RowSpan=[1,1];
            deleteButton.ColSpan=[5,5];
            deleteButton.ObjectMethod='';
            deleteButton.MethodArgs={'%dialog'};
            deleteButton.ArgDataTypes={'handle'};
            deleteButton.Enabled=true;

            scopeButton.Type='togglebutton';
            scopeButton.Tag='bplist_scope_button';
            scopeButton.ToolTip='Change scope';
            scopeButton.FilePath=fullfile(matlabroot,'toolbox',...
            'shared','dastudio','resources','currentsystem.png');
            scopeButton.RowSpan=[1,1];
            scopeButton.ColSpan=[7,7];
            scopeButton.ObjectMethod='';
            scopeButton.MethodArgs={'%dialog','%value'};
            scopeButton.ArgDataTypes={'handle','mxArray'};
            scopeButton.Graphical=true;
            scopeButton.Enabled=true;
            scopeButton.Value=true;


            titlePanel.Type='panel';
            titlePanel.Items={addBPButton,previousButton,nextButton,deleteButton,scopeButton};
            titlePanel.LayoutGrid=[1,7];
            titlePanel.ColStretch=[0,0,0,0,0,1,0];

            dlgStruct.LayoutGrid=[1,1];
            dlgStruct.DialogTitle='';
            dlgStruct.IsScrollable=false;
            dlgStruct.Items={titlePanel};
            dlgStruct.StandaloneButtonSet={''};
            dlgStruct.EmbeddedButtonSet={''};
        end
    end
end
