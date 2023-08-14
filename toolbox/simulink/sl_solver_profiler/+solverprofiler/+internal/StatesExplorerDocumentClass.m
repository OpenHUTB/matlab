classdef StatesExplorerDocumentClass<handle

















    properties(SetAccess=private)
HFig
HStateFig
HDerivFig
HCustomRank
UITable
FirstOpen
RankStatePanelFigure
    end

    methods

        function SEDocument=StatesExplorerDocumentClass(h)
            import matlab.ui.container.internal.AppContainer;
            import matlab.ui.internal.*;

            strStateDeriv=DAStudio.message('Simulink:solverProfiler:stateDeriv');
            strRankedStates=DAStudio.message('Simulink:solverProfiler:rankedStates');
            strDeriv=DAStudio.message('Simulink:solverProfiler:derivative');
            strState=DAStudio.message('Simulink:solverProfiler:state');
            strLoading=DAStudio.message('Simulink:solverProfiler:loading');

            SEDocument.HCustomRank=[];
            SEDocument.FirstOpen=true;


            group=FigureDocumentGroup();
            group.Tag='stateExplorerDocument';
            h.add(group);


            documentOptions.Title=strStateDeriv;
            documentOptions.DocumentGroupTag=group.Tag;
            documentOptions.Closable=false;
            documentOptions.Description="";
            docState=FigureDocument(documentOptions);

            SEDocument.HFig=docState.Figure;
            SEDocument.HFig.NumberTitle='off';
            SEDocument.HFig.HandleVisibility='off';
            SEDocument.HFig.WindowKeyReleaseFcn=@SEDocument.doNothing;
            h.add(docState);


            docState.Figure.AutoResizeChildren='off';
            SEDocument.HStateFig=subplot(2,1,1,'Parent',docState.Figure);
            SEDocument.HDerivFig=subplot(2,1,2,'Parent',docState.Figure);



            SEDocument.HStateFig.Toolbar.Visible='off';
            SEDocument.HDerivFig.Toolbar.Visible='off';


            linkaxes([SEDocument.HDerivFig,SEDocument.HStateFig],'x')

            drawnow;


            panelOptions.Title=strRankedStates;
            panelOptions.Region="left";
            panelOptions.PreferredHeight=0.999;
            panelOptions.PreferredWidth=0.25;
            panel=FigurePanel(panelOptions);
            h.add(panel);


            SEDocument.RankStatePanelFigure=panel.Figure;
            loadingContent={strLoading,strLoading};
            ColumnNames={strDeriv,strState};
            SEDocument.UITable=SEDocument.createUITable(panel.Figure,loadingContent,ColumnNames);
            SEDocument.UITable.Visible='on';

        end


        function delete(SEDocument)

            if~isempty(SEDocument.HCustomRank)&&isvalid(SEDocument.HCustomRank)
                SEDocument.HCustomRank.delete;
            end
            delete(SEDocument.HFig);
        end


        function launchCustomRankWindow(SEDocument)
            import solverprofiler.util.*

            strCustomRankTitle=utilDAGetString('customRankAlgTitle');
            strCustomRankRemove=utilDAGetString('customRankRemove');
            strCustomRankName=utilDAGetString('customRankName');
            buttonAdd=utilDAGetString('Add');
            buttonRemove=utilDAGetString('Remove');
            buttonClose=utilDAGetString('Close');

            try
                SEDocument.HCustomRank=figure(double(intmax*rand));
            catch
                SEDocument.HCustomRank=figure;
            end
            h=SEDocument.HCustomRank;

            set(h,'MenuBar','none','ToolBar','none','NumberTitle','off',...
            'Name',strCustomRankTitle,'Resize','off','HandleVisibility','off');
            h.Position(3)=380;
            h.Position(4)=200;

            columnname={strCustomRankRemove,strCustomRankName};
            data={'',''};
            hTable=uitable(h,'Data',data,'ColumnName',columnname,...
            'ColumnEditable',[true,false],'RowName',[],'Unit',...
            'Normalized','Position',[0.08,0.25,0.84,0.65],...
            'ColumnWidth',{65,250},'Tag','customRankTable');

            uicontrol(h,'Style','pushbutton','String',buttonAdd,...
            'Unit','Normalized','Position',[0.48,0.05,0.11,0.13],...
            'Tag','customRankAddButton');
            uicontrol(h,'Style','pushbutton','String',buttonRemove,...
            'Unit','Normalized','Position',[0.6,0.05,0.18,0.13],...
            'Tag','customRankRemoveButton');
            uicontrol(h,'Style','pushbutton','String',buttonClose,'Unit',...
            'Normalized','Position',[0.79,0.05,0.14,0.13],...
            'Callback',{@closeCallback,h});


            contextMenu=uicontextmenu(h);
            hTable.UIContextMenu=contextMenu;
            h.UIContextMenu=contextMenu;
            strWhatThis=DAStudio.message('Simulink:solverProfiler:whatisthis');
            uimenu('Parent',contextMenu,'Label',strWhatThis,...
            'Callback',@SEDocument.customRankCSH);

            function closeCallback(~,~,h)
                h.delete;
            end
        end


        function populateCustomRankTable(SEDocument,tableContent)
            hObj=findobj(SEDocument.HCustomRank,'Tag','customRankTable');
            hObj.Data=tableContent;
        end


        function populate(SEDocument,content,jColumnName)








            if(SEDocument.FirstOpen)
                SEDocument.UITable.Data=content;
                SEDocument.UITable.ColumnName=jColumnName;
                SEDocument.FirstOpen=false;
            else
                newTable=SEDocument.createUITable(SEDocument.RankStatePanelFigure,content,jColumnName);
                newTable.Visible='on';
                SEDocument.UITable.delete;
                SEDocument.UITable=newTable;
            end
            SEDocument.removeTableHighlight;
        end


        function attachUItableSelectionCallback(SEDocument,fhandle)
            SEDocument.UITable.CellSelectionCallback=fhandle;
        end

        function attachCustomRankRemoveButtonCallback(SEDocument,fhandle)
            hObj=findobj(SEDocument.HCustomRank,'Tag','customRankRemoveButton');
            set(hObj,'Callback',fhandle);
        end

        function attachCustomRankAddButtonCallback(SEDocument,fhandle)
            hObj=findobj(SEDocument.HCustomRank,'Tag','customRankAddButton');
            set(hObj,'Callback',fhandle);
        end

        function disableRemoveRankButton(SEDocument)
            hObj=findobj(SEDocument.HCustomRank,'Tag','customRankRemoveButton');
            set(hObj,'Enable','off');
        end

        function enableRemoveRankButton(SEDocument)
            hObj=findobj(SEDocument.HCustomRank,'Tag','customRankRemoveButton');
            set(hObj,'Enable','on');
        end


        function tableHilightRow(SEDocument,n)
            SEDocument.removeTableHighlight();
            SEDocument.UITable.BackgroundColor(n,:)=[0.8,1,1];
        end


        function removeTableHighlight(SEDocument)
            statesNum=size(SEDocument.UITable.Data,1);
            SEDocument.UITable.BackgroundColor=ones(statesNum,3);
        end


        function handle=getStatePlotHandle(SEDocument)
            handle=SEDocument.HStateFig;
        end

        function handle=getDerivPlotHandle(SEDocument)
            handle=SEDocument.HDerivFig;
        end

        function handle=getPlotHandle(SEDocument)
            handle=SEDocument.HFig;
        end


        function turnOnZoom(SEDocument,direction)
            hobj=zoom(SEDocument.HStateFig);
            hobj.Enable='on';
            hobj=zoom(SEDocument.HDerivFig);
            hobj.Enable='on';
            fig=ancestor(SEDocument.HStateFig,'figure');

            if strcmp(direction,'out')
                z=zoom(fig);
                z.Direction='out';
                zoom(SEDocument.HStateFig,'on');
                zoom(SEDocument.HDerivFig,'on');
            else
                z=zoom(fig);
                z.Direction='in';
                zoom(SEDocument.HStateFig,'on');
                zoom(SEDocument.HDerivFig,'on');
            end
        end

        function turnOffZoom(SEDocument)
            hobj=zoom(SEDocument.HStateFig);
            hobj.Enable='off';
            hobj=zoom(SEDocument.HDerivFig);
            hobj.Enable='off';

            zoom(SEDocument.HStateFig,'off');
            zoom(SEDocument.HDerivFig,'off');
        end

        function turnOnPan(SEDocument)
            pan(SEDocument.HStateFig,'on');
            pan(SEDocument.HDerivFig,'on');
            drawnow;
        end

        function turnOffPan(SEDocument)
            pan(SEDocument.HStateFig,'off');
            pan(SEDocument.HDerivFig,'off');
        end


        function attachFigureZoomPanPostCallback(obj,fhandle)
            hobj=zoom(obj.HStateFig);
            hobj.ActionPostCallback=fhandle;

            hobj=pan(obj.HFig);
            hobj.ActionPostCallback=fhandle;

            hobj=zoom(obj.HDerivFig);
            hobj.ActionPostCallback=fhandle;
        end


        function updateDensityPlotBinWidth(obj)
            drawnow;
            hObj=findobj(obj.HStateFig,'-property','BinWidth');
            if~isempty(hObj)
                xlims=obj.HStateFig.XLim;
                hObj.BinLimits=xlims;
                hObj.NumBins=80;
                obj.HStateFig.YLim(1)=0;
                obj.HStateFig.YLim(2)=max(hObj.Values)+0.1*diff(obj.HStateFig.YLim);
            end
        end


        function flag=isHighlightedRow(SEDocument,n)
            if(SEDocument.UITable.BackgroundColor(n,1)==0.8)
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
            'ColumnWidth',{'fit','1x'},...
            'ColumnFormat',{'char'},...
            'ColumnName',columnNames,...
            'FontSize',15,...
            'Visible','off');

            drawnow;
        end


        function doNothing(~,~)
            return;
        end

        function customRankCSH(~,~)
            helpview(fullfile(docroot,'toolbox','simulink','helptargets.map'),...
            'customRank');
        end

    end

end
