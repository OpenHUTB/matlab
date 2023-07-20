classdef SpreadSheetComponent<handle


    properties
        DASspreadSheetComp=[];
        DDGDialogSource=[];
        DDGComponent=[];
        ProfilerAppController=[];
        Studio=[];
        FlameGraphController=[];
        WindowTitle='';



        shouldBeVisible=false;
    end

    methods(Access=public)
        function this=SpreadSheetComponent(studio,controller,N,spreadSheetFactory,ddgDialogGetter)
            this.ProfilerAppController=controller;
            this.Studio=studio;
            name=['SimulinkProfiler',num2str(N)];
            this.WindowTitle=DAStudio.message('Simulink:Profiler:ReportTitle',DAStudio.message('Simulink:Profiler:NoData'));

            if slfeature('slProfilerFlameGraph')>0
                this.FlameGraphController=...
                Simulink.internal.SimulinkProfiler.FlameGraphController(this);

                this.DDGDialogSource=...
                Simulink.internal.SimulinkProfiler.DDGComponentSource(this);

                this.DDGComponent=GLUE2.DDGComponent(...
                this.Studio,name,this.DDGDialogSource);
                this.Studio.registerComponent(this.DDGComponent);
                this.Studio.moveComponentToDock(this.DDGComponent,this.WindowTitle,'Bottom','stacked');
                this.shouldBeVisible=true;
            else

                this.DASspreadSheetComp=spreadSheetFactory.create(this.Studio,name);
                this.Studio.registerComponent(this.DASspreadSheetComp);

                this.DASspreadSheetComp.removeEventListener("propertychangedevent");
                this.Studio.moveComponentToDock(this.DASspreadSheetComp,this.WindowTitle,'Bottom','stacked');
                this.DASspreadSheetComp.setMinimizeTabTitle(...
                DAStudio.message('Simulink:Profiler:ReportTitle',num2str(N)));


                this.DASspreadSheetComp.setColumns(...
                {DAStudio.message('Simulink:Profiler:BlockPath'),...
                DAStudio.message('Simulink:Profiler:TimePlot'),...
                DAStudio.message('Simulink:Profiler:TotalTime'),...
                DAStudio.message('Simulink:Profiler:SelfTime'),...
                DAStudio.message('Simulink:Profiler:NumCalls')},...
                DAStudio.message('Simulink:Profiler:TotalTime'),'',false);




                this.DASspreadSheetComp.setEmptyListMessage(DAStudio.message('Simulink:Profiler:EmptyListMessage'));
                this.DASspreadSheetComp.onCloseClicked=@(comp)Simulink.internal.SimulinkProfiler.SpreadSheetComponent.onCloseClicked(comp,this);


                this.DDGDialogSource=Simulink.internal.SimulinkProfiler.SpreadSheetToolBar(ddgDialogGetter);
                this.DDGDialogSource.component=this;
                this.DASspreadSheetComp.setTitleViewSource(this.DDGDialogSource);
                this.FlameGraphController=[];
            end

            this.ProfilerAppController.incrementOpenSpreadSheetCount();
            this.shouldBeVisible=true;
        end






        function setSource(this,runLabel,viewMode)



            if strcmp(runLabel,DAStudio.message('Simulink:Profiler:NoData'))
                this.setSourceAndUpdateTitle(this.ProfilerAppController.emptySource,runLabel);
                return;
            end

            if nargin<3


                viewMode=this.DDGDialogSource.viewMode;
                src=this.getSourceForViewMode(runLabel,viewMode);
                this.setSourceAndUpdateTitle(src,runLabel);
            else

                src=this.getSourceForViewMode(runLabel,viewMode);
                this.setSourceAndUpdateTitle(src,runLabel);
            end
        end

        function show(this)
            if~this.shouldBeVisible
                if slfeature('slProfilerFlameGraph')>0
                    this.Studio.showComponent(this.DDGComponent);
                else
                    this.Studio.showComponent(this.DASspreadSheetComp);
                end
                this.shouldBeVisible=true;
                this.ProfilerAppController.incrementOpenSpreadSheetCount();
            end
        end

        function hide(this)
            if this.shouldBeVisible
                if slfeature('slProfilerFlameGraph')>0
                    if this.DDGComponent.isVisible
                        this.Studio.hideComponent(this.DDGComponent);
                    end
                else
                    this.Studio.hideComponent(this.DASspreadSheetComp);
                end
                this.shouldBeVisible=false;
                this.ProfilerAppController.decrementOpenSpreadSheetCount();
            end
        end

        function tf=isVisible(this)
            if slfeature('slProfilerFlameGraph')==0
                tf=this.DASspreadSheetComp.isVisible;
            else
                tf=this.DDGComponent.isVisible();
            end
        end

        function setActive(this)
            if slfeature('slProfilerFlameGraph')==0
                this.Studio.setActiveComponent(this.DASspreadSheetComp);
            else
                this.Studio.setActiveComponent(this.DDGComponent);
            end
        end

        function src=getSource(this)
            if slfeature('slProfilerFlameGraph')==0
                src=this.DASspreadSheetComp.getSource();
            else
                src=this.DDGDialogSource.sheetSource;
            end
        end

    end


    methods(Access=private)

        function src=getSourceForViewMode(this,runLabel,viewMode)
            switch viewMode
            case Simulink.internal.SimulinkProfiler.ViewMode.UI
                src=this.ProfilerAppController.uiNodeSrc(runLabel);
            otherwise
                assert(viewMode==Simulink.internal.SimulinkProfiler.ViewMode.EXEC)
                src=this.ProfilerAppController.execNodeSrc(runLabel);
            end
        end

        function setSourceAndUpdateTitle(this,source,runLabel)
            if slfeature('slProfilerFlameGraph')==0
                this.DASspreadSheetComp.setSource(source);
                this.DASspreadSheetComp.setTitle(DAStudio.message('Simulink:Profiler:ReportTitle',runLabel));
            else

                this.DDGDialogSource.sheetSource=source;
                this.DDGDialogSource.runLabel=runLabel;

                if~this.DDGDialogSource.isSpreadsheet
                    this.FlameGraphController.refresh();
                end

                if strcmp(runLabel,DAStudio.message('Simulink:Profiler:NoData'))
                    dialog=this.DDGDialogSource.getToolbarWidget();
                    dialog.setWidgetValue('simulink_profiler_open_viz_button',0);
                end

                this.Studio.setDockComponentTitle(this.DDGComponent,...
                DAStudio.message('Simulink:Profiler:ReportTitle',runLabel));
            end




            this.DDGDialogSource.setCurrentRunLabel(runLabel);
        end

        function json=getStandardColumnConfigJSON(~)
            name={DAStudio.message('Simulink:Profiler:BlockPath'),...
            DAStudio.message('Simulink:Profiler:TotalTime'),...
            DAStudio.message('Simulink:Profiler:SelfTime'),...
            DAStudio.message('Simulink:Profiler:NumCalls'),...
            DAStudio.message('Simulink:Profiler:TimePlot')};
            minsize={0,0,0,0,0};
            maxsize={1e4,100,100,100,200};
            columns=struct('name',name,'minsize',minsize,'maxsize',maxsize);
            json.columns=columns;
            json=jsonencode(json);
        end
    end

    methods(Static)
        function onCloseClicked(glue2comp,spreadSheetComp)
            spreadSheetComp.ProfilerAppController.decrementOpenSpreadSheetCount();
            spreadSheetComp.shouldBeVisible=false;
            if slfeature('slProfilerFlameGraph')>0
                spreadSheetComp.flamegraphController.close();
            end
        end
    end
end
