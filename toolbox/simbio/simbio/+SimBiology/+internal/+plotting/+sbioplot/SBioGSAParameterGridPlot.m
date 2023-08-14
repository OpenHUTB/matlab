classdef SBioGSAParameterGridPlot<SimBiology.internal.plotting.sbioplot.SBioGSAPlot




    methods(Access=public)
        function plotStyle=getPlotStyle(obj)
            plotStyle=SimBiology.internal.plotting.sbioplot.definition.PlotDefinition.GSA_PARAMETER_GRID;
        end
    end




    methods(Access=protected)
        function createElementaryEffectsPlot(obj,gsaObj)
            gsaObj.plotGrid(obj.figure.handle,'Parameters',obj.getParameters(),...
            'Color',obj.convertHexToRGB(obj.definition.props.EEOptions.GridColor));
        end
    end



    methods(Access=protected)
        function updateAxesFromFigure(obj)

            tiledLayoutObj=findobj(obj.figure.handle,'-depth',1,'type','tiledLayout');
            obj.tiledLayout=tiledLayoutObj;
            axesParent=tiledLayoutObj;
            gridDimensions=tiledLayoutObj.GridSize;

            obj.numTrellisCols=gridDimensions(2);
            obj.numTrellisRows=gridDimensions(1);


            obj.preserveFormats=obj.preserveFormats&&...
            obj.figure.props.Column==gridDimensions(2)&&...
            obj.figure.props.Row==gridDimensions(1);


            plotAxes=SimBiology.internal.plotting.hg.AxesInfo.getAllPlotAxesHandles(axesParent);


            settings=struct;
            settings.Box='on';
            settings.Color='white';
            settings.PickableParts='all';
            settings.Units='pixels';
            settings.NextPlot='replacechildren';
            settings.LooseInset=[5,5,5,5];
            settings.Toolbar=[];
            settings.TickLabelInterpreter='none';

            set(plotAxes,settings);


            p=gridDimensions(1);
            lastIdx=0;
            for i=1:p
                numAxesInRow=p-(i-1);
                lastBlankAxesIdx=i*p-numAxesInRow;
                axesArray((i-1)*p+1:lastBlankAxesIdx)=deal(-1);
                axesArray(lastBlankAxesIdx+1:(i*p))=deal(plotAxes(lastIdx+1:lastIdx+numAxesInRow));
                lastIdx=lastIdx+numAxesInRow;
            end
            plotAxes=transpose(reshape(axesArray,obj.numTrellisRows,obj.numTrellisCols));

            if obj.preserveFormats
                obj.axes.updateHandles(handle(plotAxes));
            else
                obj.axes=SimBiology.internal.plotting.hg.AxesInfo(handle(plotAxes));
            end


            obj.figure.props.Column=obj.numTrellisCols;
            obj.figure.props.Row=obj.numTrellisRows;
            obj.figure.props.AxGrid=plotAxes;
        end
    end
end