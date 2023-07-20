classdef CircuitDisplayCanvas<handle




    properties(Access=public)
        Parent matlab.ui.Figure
        Panel matlab.ui.container.Panel


        SpaceFillerLayout matlab.ui.container.GridLayout


        CascadeLayout matlab.ui.container.GridLayout


        ComponentDetailsLayout matlab.ui.container.GridLayout

        Cascade rf.internal.apps.matchnet.ComponentView
        ComponentPanel matlab.ui.container.Panel


CircuitData

        AllContainerLayout matlab.ui.container.GridLayout
        GreyLabel matlab.ui.control.Label
        CircuitLabel matlab.ui.control.Label
    end

    events
CircuitDrawingDataRequested
    end

    properties(Access=public,Constant)
        COMPONENT_DETAILS_PER_COLUMN=2
    end

    methods(Access=public)
        function this=CircuitDisplayCanvas(parent)
            this.Parent=parent;
            this.initializeCanvas();
        end
    end


    methods(Access=public)
        function newCircuitsSelected(this,evtdata)
            cktnames=evtdata.data.CircuitNames;
            if(isempty(cktnames))
                this.clearCanvas()
                delete(this.ComponentPanel)
                this.CascadeLayout.BackgroundColor=this.CascadeLayout.Parent.BackgroundColor;
                this.GreyLabel.Visible='on';
                return;
            end


            cktname=cktnames(1);
            data.RequestedCircuits=cktname;
            this.notify('CircuitDrawingDataRequested',rf.internal.apps.matchnet.ArbitraryEventData(data));
        end

        function setCircuit(this,evtdata)

            this.CircuitData.ckt=clone(evtdata.data.CircuitObj);
            this.CircuitData.nets=evtdata.data.CircuitNets;
            this.CircuitData.values=evtdata.data.CircuitValues;
            this.CircuitData.cktname=evtdata.data.CircuitName;

            this.clearCanvas();
            this.updateCanvas();

            this.clearComponentDetails();
            if~isa(this.CircuitData.nets,'circuit')
                this.updateComponentDetails();
            end
        end

        function clearCanvas(this)
            this.CascadeLayout.Visible=matlab.lang.OnOffSwitchState.off;
            if(~isempty(this.Cascade))
                delete(this.Cascade)
            end
            delete(this.CascadeLayout.Children)
            delete(this.CircuitLabel)
            this.CascadeLayout.BackgroundColor=this.CascadeLayout.Parent.BackgroundColor;
            this.CascadeLayout.Visible=matlab.lang.OnOffSwitchState.on;
        end
    end

    methods(Access=protected)
        function initializeCanvas(this)
            this.AllContainerLayout=uigridlayout(this.Parent,[1,1],...
            'Padding',[0,0,0,0]);

            this.Panel=uipanel(this.AllContainerLayout,'BackgroundColor',[1,1,1]);
            this.Panel.Layout.Row=1;
            this.Panel.Layout.Column=1;

            this.SpaceFillerLayout=uigridlayout(this.Panel,...
            'RowHeight',{'1x','fit','1x'},...
            'ColumnWidth',{'1x','fit','fit','1x'},'Scrollable','on');

            this.CascadeLayout=uigridlayout(this.SpaceFillerLayout,...
            'RowHeight',{'fit'},'ColumnSpacing',0,'RowSpacing',0,'Padding',[10,0,10,0]);
            this.CascadeLayout.Layout.Row=2;
            this.CascadeLayout.Layout.Column=2;

            this.ComponentDetailsLayout=uigridlayout(this.SpaceFillerLayout);


            this.GreyLabel=uilabel(this.AllContainerLayout,'Text',...
            getString(message('rf:matchingnetworkgenerator:UITreeSelected')),...
            'FontSize',20,'WordWrap','on','FontColor',[0.5,0.5,0.5],...
            'HorizontalAlignment','center','Visible','off');
            this.GreyLabel.Layout.Row=1;
            this.GreyLabel.Layout.Column=1;
        end

        function updateCanvas(this)
            this.CascadeLayout.Visible=matlab.lang.OnOffSwitchState.off;
            this.CascadeLayout.BackgroundColor='w';
            this.GreyLabel.Visible='off';
            numComponents=length(this.CircuitData.ckt.Elements);
            this.CascadeLayout.ColumnWidth(1:numComponents)={'fit'};
            if isa(this.CircuitData.nets,'circuit')
                this.Cascade=rf.internal.apps.matchnet.ComponentView(this.CascadeLayout,[]);
                this.Cascade.initialize();
            else
                try
                    for j=1:numComponents
                        switch this.CircuitData.nets(j)
                        case rf.internal.apps.matchnet.Controller_1.SER_CAP
                            this.Cascade(j)=rf.internal.apps.matchnet.CapacitorComponentView(this.CascadeLayout,this.CircuitData.ckt.Elements(j),'series');
                        case rf.internal.apps.matchnet.Controller_1.SHNT_CAP
                            this.Cascade(j)=rf.internal.apps.matchnet.CapacitorComponentView(this.CascadeLayout,this.CircuitData.ckt.Elements(j),'shunt');
                        case rf.internal.apps.matchnet.Controller_1.SER_INDCT
                            this.Cascade(j)=rf.internal.apps.matchnet.InductorComponentView(this.CascadeLayout,this.CircuitData.ckt.Elements(j),'series');
                        case rf.internal.apps.matchnet.Controller_1.SHNT_INDCT
                            this.Cascade(j)=rf.internal.apps.matchnet.InductorComponentView(this.CascadeLayout,this.CircuitData.ckt.Elements(j),'shunt');
                        case rf.internal.apps.matchnet.Controller_1.SER_RES
                            this.Cascade(j)=rf.internal.apps.matchnet.ResistorComponentView(this.CascadeLayout,this.CircuitData.ckt.Elements(j),'series');
                        case rf.internal.apps.matchnet.Controller_1.SHNT_RES
                            this.Cascade(j)=rf.internal.apps.matchnet.ResistorComponentView(this.CascadeLayout,this.CircuitData.ckt.Elements(j),'shunt');
                        otherwise
                            this.Cascade(j)=rf.internal.apps.matchnet.ComponentView(this.CascadeLayout,this.CircuitData.ckt.Elements(j));
                        end
                        this.Cascade(j).initialize();
                    end
                catch
                    clearCanvas(this)
                    clearComponentDetails(this)
                    this.Cascade=rf.internal.apps.matchnet.ComponentView(this.CascadeLayout,[]);
                    this.Cascade.initialize();
                    this.CircuitData.nets=this.CircuitData.ckt;
                end
            end
            this.Cascade(~isvalid(this.Cascade))=[];
            this.CascadeLayout.Visible=matlab.lang.OnOffSwitchState.on;
        end



        function clearComponentDetails(this)
            delete(this.ComponentDetailsLayout.Children);
        end

        function updateComponentDetails(this)
            this.ComponentDetailsLayout.Visible=matlab.lang.OnOffSwitchState.off;
            numcomponents=length(this.Cascade);
            numcols=ceil(numcomponents/this.COMPONENT_DETAILS_PER_COLUMN);

            this.ComponentDetailsLayout.RowHeight(1:this.COMPONENT_DETAILS_PER_COLUMN)={'fit'};
            this.ComponentDetailsLayout.ColumnWidth(1:numcols)={'fit'};


            for j=1:numcols
                for k=1:this.COMPONENT_DETAILS_PER_COLUMN
                    i=(j-1)*this.COMPONENT_DETAILS_PER_COLUMN+k;
                    if(i>length(this.Cascade))
                        continue;
                    end
                    componentPanel=this.Cascade(i).getEditableControls(this.ComponentDetailsLayout);
                    componentPanel.Layout.Row=k;
                    componentPanel.Layout.Column=j;
                    this.ComponentPanel(i)=componentPanel;
                end
            end
            this.CircuitLabel=uilabel(this.SpaceFillerLayout,...
            'Text',this.CircuitData.cktname,...
            'HorizontalAlignment','center',...
            'VerticalAlignment','bottom',...
            'Visible',matlab.lang.OnOffSwitchState.off);
            this.CircuitLabel.Layout.Row=1;
            this.CircuitLabel.Layout.Column=2;

            this.ComponentDetailsLayout.Visible=matlab.lang.OnOffSwitchState.on;
            this.CircuitLabel.Visible=matlab.lang.OnOffSwitchState.on;
        end
    end
end
