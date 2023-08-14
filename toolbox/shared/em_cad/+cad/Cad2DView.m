classdef Cad2DView<cad.View




    properties
        Figure;
        Axes;
InstructionalText
    end
    methods
        function self=Cad2DView(Parent)
            if isempty(Parent)
                Parent=uifigure;
            end
            self.Figure=Parent;
            self.Axes=uiaxes(self.Figure);
            self.InstructionalText=text(self.Axes,'String',...
            'Select a shape from the Gallery','FontSize',22,...
            'Visible','on','HitTest','off','PickableParts','none','tag','InstructionalText');
            decorateAxes(self);
        end





        function fig=getFigure(self)
            fig=self.Figure;
        end

        function ax=getAxes(self)
            ax=self.Axes;

        end

        function tag=getTag(self)
            tag=self.Figure.Tag;
        end

        function name=getName(self)
            name=self.Figure.Name;
        end



        function BBox=getBBoxFromAxLim(self)
            BBox=[];
            if~isempty(self.Axes)
                width=self.Axes.XLim(2)-self.Axes.XLim(1);
                height=self.Axes.YLim(2)-self.Axes.YLim(1);
                center=[mean(self.Axes.XLim),mean(self.Axes.YLim)];
                scalefactor=0.3;
                sizeVal=scalefactor*[width,height];
                BBox=[center-(sizeVal/2),sizeVal];
            end
        end
        function decorateAxes(self)

            box(self.Axes,'on');
            grid(self.Axes,'on');
            axis(self.Axes,'equal');
            self.Axes.LooseInset=[0.1,0.1,0.1,0.1];
            cm=uicontextmenu(self.Figure);
            cm.ContextMenuOpeningFcn=@(src,evt)createContextMenu(self,src,evt);
            self.Axes.ContextMenu=cm;
            cm.Tag='Axes';
            disableDefaultInteractivity(self.Axes);
            self.Axes.MinorGridLineStyle=':';
            self.Axes.GridLineStyle='-';
            grid(self.Axes,'minor');
            axis(self.Axes,'equal');

            self.Axes.Units='normalized';
            self.Axes.Position=[0.03,0.03,0.95,0.95];
            xlabel(self.Axes,'X (mm)')
            ylabel(self.Axes,'Y (mm)')
            ax=self.Axes;
            self.InstructionalText.Position=[ax.XLim(1)+0.1*(ax.XLim(2)-ax.XLim(1)),(ax.YLim(2)+ax.YLim(1))/2,0];
        end


        function setModel(self,Model)
            self.Controller=cad.Cad2DController(self,Model);
            addListeners(self.Controller);
        end



    end

end
