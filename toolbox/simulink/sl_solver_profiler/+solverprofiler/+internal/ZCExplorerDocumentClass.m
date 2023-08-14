classdef ZCExplorerDocumentClass<handle

    properties(SetAccess=private)
HFig
HValuePlot
HDensityPlot
UITable
FirstOpen
PanelFigure
    end

    methods

        function obj=ZCExplorerDocumentClass(h)
            import matlab.ui.container.internal.AppContainer;
            import matlab.ui.internal.*;
            import solverprofiler.util.*

            strLoading=DAStudio.message('Simulink:solverProfiler:loading');
            strZCPanelTitle=utilDAGetString('zcPanelTitle');
            strZCTableNumber=utilDAGetString('zcTableNumber');
            strZCTableSignal=utilDAGetString('zcTableSignal');
            obj.FirstOpen=true;


            group=FigureDocumentGroup();
            group.Tag='ZCExlporerDocument';
            h.add(group);




            documentOptions.Title='zero crossing signal';
            documentOptions.DocumentGroupTag=group.Tag;
            documentOptions.Closable=false;
            documentOptions.Description="";
            docState=FigureDocument(documentOptions);

            obj.HFig=docState.Figure;
            obj.HFig.NumberTitle='off';
            obj.HFig.WindowKeyReleaseFcn=@obj.doNothing;
            obj.HFig.HandleVisibility='off';
            h.add(docState);


            docState.Figure.AutoResizeChildren='off';
            obj.HValuePlot=subplot(2,1,1,'Parent',docState.Figure);
            obj.HDensityPlot=subplot(2,1,2,'Parent',docState.Figure);

            linkaxes([obj.HValuePlot,obj.HDensityPlot],'x');

            drawnow;


            panelOptions.Title=strZCPanelTitle;
            panelOptions.Region="left";
            panelOptions.PreferredHeight=0.999;
            panelOptions.PreferredWidth=0.3;
            panel=FigurePanel(panelOptions);
            h.add(panel);

            obj.PanelFigure=panel.Figure;


            loadingContent={strLoading,strLoading};
            columnName={strZCTableNumber,strZCTableSignal};
            obj.UITable=obj.createUITable(obj.PanelFigure,loadingContent,columnName);
            obj.UITable.Visible='on';
        end


        function delete(obj)
            delete(obj.HFig);
        end


        function hFig=getFigureHandle(obj)
            hFig=obj.HFig;
        end


        function hAxes=getValuePlot(obj)
            hAxes=obj.HValuePlot;
        end


        function hAxes=getDensityPlot(obj)
            hAxes=obj.HDensityPlot;
        end


        function populate(obj,content,jColumnName)








            if(obj.FirstOpen)
                obj.UITable.Data=content;
                obj.UITable.ColumnName=jColumnName;
                obj.FirstOpen=false;
            else
                newTable=obj.createUITable(obj.PanelFigure,content,jColumnName);
                newTable.Visible='on';
                obj.UITable.delete;
                obj.UITable=newTable;
            end
            obj.removeTableHighlight;
        end


        function attachUITableSelectionCallback(obj,fhandle)
            obj.UITable.CellSelectionCallback=fhandle;
        end


        function attachDataCursorCallback(obj,fHandle)
            dataCursorObj=datacursormode(obj.HFig);
            set(dataCursorObj,'UpdateFcn',fHandle);
            set(dataCursorObj,'Enable','on');
        end


        function enableDataCursor(obj)
            dataCursorObj=datacursormode(obj.HFig);
            set(dataCursorObj,'Enable','on');
        end


        function attachFigureZoomPanPostCallback(obj,fhandle)
            hobj=zoom(obj.HValuePlot);
            hobj.ActionPostCallback=fhandle;
            hobj=pan(obj.HFig);
            hobj.ActionPostCallback=fhandle;
            hobj=zoom(obj.HDensityPlot);
            hobj.ActionPostCallback=fhandle;
        end

        function handle=getPlotHandle(obj)
            handle=obj.HFig;
        end


        function turnOnZoom(obj,direction)

            hobj=zoom(obj.HValuePlot);
            hobj.Enable='on';
            hobj=zoom(obj.HDensityPlot);
            hobj.Enable='on';
            fig=ancestor(obj.HValuePlot,'figure');

            if strcmp(direction,'out')
                zoomMode=['zoom',direction];
                z=zoom(fig);
                z.Direction='out';
                zoom(obj.HValuePlot,'on');
                zoom(obj.HDensityPlot,'on');
            else
                zoomMode='zoom';
                z=zoom(fig);
                z.Direction='in';
                zoom(obj.HValuePlot,'on');
                zoom(obj.HDensityPlot,'on');
            end
        end

        function turnOffZoom(obj)

            hobj=zoom(obj.HValuePlot);
            hobj.Enable='off';
            hobj=zoom(obj.HDensityPlot);
            hobj.Enable='off';

            zoom(obj.HValuePlot,'off');
            zoom(obj.HDensityPlot,'off');
        end

        function turnOnPan(obj)
            pan(obj.HFig,'on');
        end

        function turnOffPan(obj)
            pan(obj.HFig,'off');
        end


        function updateDensityPlotBinWidth(obj)
            drawnow;
            hObj=findobj(obj.HDensityPlot,'-property','BinWidth');
            if~isempty(hObj)
                xlims=obj.HDensityPlot.XLim;
                hObj.BinLimits=xlims;
                hObj.NumBins=80;
                obj.HDensityPlot.YLim(1)=0;
                obj.HDensityPlot.YLim(2)=max(hObj.Values)+0.1*diff(obj.HDensityPlot.YLim);
            end
        end


        function removeTableHighlight(obj)
            statesNum=size(obj.UITable.Data,1);
            obj.UITable.BackgroundColor=ones(statesNum,3);
        end


        function highlightRow(obj,n)
            obj.removeTableHighlight();
            obj.UITable.BackgroundColor(n,:)=[0.8,1,1];
        end


        function flag=isHighlightedRow(obj,n)
            if(obj.UITable.BackgroundColor(n,1)==0.8)
                flag=true;
            else
                flag=false;
            end
        end

    end

    methods(Static)

        function UITable=createUITable(figurePanel,content,columnNames)
            grid=uigridlayout(figurePanel,[1,1]);
            grid.Padding=0;

            UITable=uitable(grid,...
            'Data',content,...
            'RowName','',...
            'ColumnFormat',{'char'},...
            'ColumnName',columnNames,...
            'FontSize',15,...
            'Visible','off');

            drawnow;
        end


        function doNothing(~,~)
            return;
        end


        function value=DAGetString(key)
            value=DAStudio.message(['Simulink:solverProfiler:',key]);
        end
    end

end