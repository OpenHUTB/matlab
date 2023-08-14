classdef ROCCurve<matlab.ui.componentcontainer.ComponentContainer






    properties

parentPanel
titleForROCCurvePlot
menuType
menuValues
xArray
yArray
tArray
aucArray
    end

    events(HasCallbackProperty,NotifyAccess=protected)
menuValueChangedEvent
    end

    properties(Access=private,Transient,NonCopyable)

uiRootGridLayout
uiMenuGridLayout


        axROCCurvePlot matlab.graphics.axis.Axes


uiMenu
uiMenuLabel
menuLabel
menuValueColors
menuCurrentValueIndexes


initGUIDone
    end

    methods(Access=protected)


        function setup(obj)


            obj.initGUIDone=false;
        end


        function update(obj)


            if~obj.initGUIDone
                obj.initGUI();
                obj.initGUIDone=true;
            end


            obj.updateGUI();
        end
    end

    methods(Access=private)
        function initGUI(obj)


            obj.menuValueColors=jet(numel(obj.menuValues));


            obj.tArray=cellfun(@(x)x',obj.tArray,'UniformOutput',false);





            if obj.menuType=="dropDown"


                obj.menuCurrentValueIndexes=1;


                obj.menuLabel=message('experiments:results:InteractionDropDownMenuLabel').getString();
            else


                obj.menuCurrentValueIndexes=1;


                obj.menuLabel=message('experiments:results:InteractionListBoxMenuLabel').getString();
            end


            obj.uiRootGridLayout=uigridlayout(obj.parentPanel,[1,4]);


            obj.axROCCurvePlot=axes(obj.uiRootGridLayout);
            obj.axROCCurvePlot.Layout.Row=1;
            obj.axROCCurvePlot.Layout.Column=[1,3];


            obj.uiMenuGridLayout=uigridlayout(obj.uiRootGridLayout,[2,1]);
            obj.uiMenuGridLayout.Layout.Row=1;
            obj.uiMenuGridLayout.Layout.Column=4;
            obj.uiMenuGridLayout.RowHeight={'fit'};


            obj.uiMenuLabel=uilabel(obj.uiMenuGridLayout,...
            'Text',obj.menuLabel,...
            'FontWeight','bold');


            obj.uiMenuLabel.Layout.Row=1;
            obj.uiMenuLabel.Layout.Column=1;


            if obj.menuType=="dropDown"


                obj.uiMenu=uidropdown(obj.uiMenuGridLayout,...
                'Items',obj.menuValues,...
                'ItemsData',1:numel(obj.menuValues),...
                'Value',obj.menuCurrentValueIndexes,...
                'ValueChangedFcn',@(dd,event)obj.menuValueChanged(dd.Value));
            else


                obj.uiMenu=uilistbox(obj.uiMenuGridLayout,...
                'Items',obj.menuValues,...
                'ItemsData',1:numel(obj.menuValues),...
                'Value',obj.menuCurrentValueIndexes,...
                'Multiselect','on',...
                'ValueChangedFcn',@(dd,event)obj.menuValueChanged(dd.Value));
            end


            obj.uiMenu.Layout.Row=2;
            obj.uiMenu.Layout.Column=1;
        end


        function updateGUI(obj)


            rocCurvePlotLegends=strings(1,numel(obj.menuCurrentValueIndexes));
            for i=1:numel(obj.menuCurrentValueIndexes)


                xValues=obj.xArray{obj.menuCurrentValueIndexes(i)};
                yValues=obj.yArray{obj.menuCurrentValueIndexes(i)};


                colorROCCurvePlot=obj.menuValueColors(obj.menuCurrentValueIndexes(i),:);


                rocCurvePlot=plot(obj.axROCCurvePlot,xValues,yValues,'Color',colorROCCurvePlot,'LineWidth',2);
                rocCurvePlotLegends(i)=sprintf("%s (AUC = %0.2f)",...
                obj.menuValues(obj.menuCurrentValueIndexes(i)),...
                obj.aucArray(obj.menuCurrentValueIndexes(i)));


                newRow=dataTipTextRow('Threshold',obj.tArray{obj.menuCurrentValueIndexes(i)});
                rocCurvePlot.DataTipTemplate.DataTipRows(end+1)=newRow;


                if(i==1)
                    hold(obj.axROCCurvePlot,'on');
                end
            end


            plot(obj.axROCCurvePlot,[0,1],[0,1],"--k",'LineWidth',1);


            axesRange=[-0.1,1.1];
            obj.axROCCurvePlot.XLim=axesRange;
            obj.axROCCurvePlot.YLim=axesRange;
            obj.axROCCurvePlot.DataAspectRatio=[1,1,1];
            obj.axROCCurvePlot.ClippingStyle='rectangle';
            grid(obj.axROCCurvePlot,'on');
            set(obj.axROCCurvePlot.Toolbar,'Visible','on');


            xlabel(obj.axROCCurvePlot,'False positive rate');
            ylabel(obj.axROCCurvePlot,'True positive rate');


            rocLegend=legend(obj.axROCCurvePlot,[rocCurvePlotLegends,"Base Line"]);
            rocLegend.Location='southeast';
            title(obj.axROCCurvePlot,obj.titleForROCCurvePlot);


            hold(obj.axROCCurvePlot,'off');
        end


        function menuValueChanged(obj,newValue)
            obj.menuCurrentValueIndexes=newValue;
            drawnow;
            notify(obj,'menuValueChangedEvent');
        end

        function colors=getRandomColorValues(n)
            colors=jet(n);
        end
    end
end