classdef PreScaleTool<handle




    properties
ScaleViewPanel
ScaleViewEditor
Figure
    end

    properties(Access=protected)

    end


    methods

        function this=PreScaleTool(sys,xfocus)

            ni=nargin;


            build(this)



            MinWidth=110;
            MinHeight=4*8;
            Pos=get(this.Figure,'Position');
            Pos0=Pos;
            Pos(3)=max(Pos(3),MinWidth);
            Pos(4)=max(Pos(4),MinHeight);

            Pos(2)=Pos(2)-(Pos(4)-Pos0(4));
            set(this.Figure,'Position',Pos);



            layout(this)


            if ni>1&&~isempty(xfocus)

                this.ScaleViewPanel.setSystem(sys,xfocus);
            else
                this.ScaleViewPanel.setSystem(sys);
            end


            set(this.Figure,'Visible','on')
        end


        function setSystem(this,Target,focus)
            if nargin>2
                this.ScaleFocus=focus;
            end
            this.System=Target;
            update(this)

        end


        function layout(this)

            p=get(this.Figure,'Position');
            fw=p(3);fh=p(4);
            hBorder=1;vBorder=.5;
            vGap=.2;
            PanelWidth=fw-2*hBorder;
            if PanelWidth<=0
                PanelWidth=fw;
            end



            y0=vBorder;
            P1Height=7.2;
            set(this.ScaleViewEditor.HG.Panel,'Position',[hBorder,y0,PanelWidth,P1Height])
            this.ScaleViewEditor.layout;


            y0=y0+P1Height+vGap;
            set(this.ScaleViewPanel.HG.Panel,'Position',[hBorder,y0,PanelWidth,max(fh-y0-vBorder,1)])
            this.ScaleViewPanel.layout;

        end


        function close(this,es)
            if isequal(ancestor(es,'Figure'),this.Figure)
                set(this.Figure,'CloseRequestFcn',[]);
                set(this.Figure,'DeleteFcn',[]);
                delete(this.Figure)
                delete(this)
            end
        end

    end


    methods(Access=private)


        function build(this)

            Color=get(0,'DefaultUIControlBackground');
            fig=figure(...
            'Parent',groot,...
            'Color',Color,...
            'IntegerHandle','off',...
            'Menubar','None',...
            'Toolbar','None',...
            'Name',ctrlMsgUtils.message('Control:scalegui:ScalingToolTitle'),...
            'NumberTitle','off',...
            'Visible','off',...
            'Tag','ScalingTool',...
            'HandleVisibility','off',...
            'ResizeFcn',@(x,y)layout(this),...
            'CloseRequestFcn',@(x,y)close(this,x),...
            'DeleteFcn',@(x,y)close(this,x));
            set(fig,'Units','characters')

            set(fig,'PaperPositionMode','auto')

            this.Figure=fig;




            setappdata(this.Figure,'PreScaleToolObj',this)


            t=uitoolbar(this.Figure,'HandleVisibility','off');


            z(1)=uitoolfactory(t,'Standard.PrintFigure');
            z(2)=uitoolfactory(t,'Exploration.ZoomIn');
            set(z(2),'Separator','on');
            z(3)=uitoolfactory(t,'Exploration.ZoomOut');
            z(4)=uitoolfactory(t,'Exploration.Pan');
            z(5)=uitoolfactory(t,'Annotation.InsertLegend');
            set(z(5),'ClickedCallback',@(es,ed)localLegendCallback(fig))
            set(z(5),'Separator','on');




            this.ScaleViewPanel=scalingtool.ScalingViewPanel(fig);
            this.ScaleViewEditor=scalingtool.ScalingViewEditor(this.ScaleViewPanel,fig);


            set(this.ScaleViewEditor.HG.Save,'Callback',{@localSaveDialogCallback,this})
            set(this.ScaleViewEditor.HG.Close,'Callback',@(x,y)close(this,x))
            set(this.ScaleViewEditor.HG.Help,'Callback',{@localHelpCallback})
        end



        function exportDialog(this)


            checkLabels={ctrlMsgUtils.message('Control:scalegui:SaveDialogLabel1'),...
            ctrlMsgUtils.message('Control:scalegui:SaveDialogLabel2')};
            varNames={'ScaledSys','ScaledInfo'};

            ScaleFocus=this.ScaleViewPanel.getScaleFocus;
            if isempty(ScaleFocus)
                [ScaledModel,ScaledInfo]=prescale(this.ScaleViewPanel.System);
            else
                [ScaledModel,ScaledInfo]=prescale(this.ScaleViewPanel.System,{ScaleFocus(1),ScaleFocus(2)});
            end

            items={ScaledModel,ScaledInfo};


            export2wsdlg(checkLabels,varNames,items,ctrlMsgUtils.message('Control:scalegui:SaveDialogTitle'));
        end


    end

    methods(Static,Hidden)

        function setLegendContextMenu(lh)

            try %#ok<TRYNC>

                Tags={...
                'scribe:legend:location:northwestoutside',...
                'scribe:legend:location:northeastoutside'};
                ucm=get(lh,'UIContextMenu');
                for ct=1:length(Tags)
                    set(findall(ucm,'Tag',Tags{ct}),'Enable','off')
                end
            end
        end
    end

end


function localSaveDialogCallback(~,~,this)

    this.exportDialog;

end

function localHelpCallback(~,~)

    MapFile=ctrlguihelp;
    helpview(MapFile,'ScalingTool','CSHelpWindow')

end

function localLegendCallback(fig)

    insertmenufcn(fig,'Legend')
    ax=get(fig,'CurrentAxes');
    if~isempty(ax)
        lh=get(ax,'Legend');
        if~isempty(lh)
            scalingtool.PreScaleTool.setLegendContextMenu(lh);
        end
    end
end

