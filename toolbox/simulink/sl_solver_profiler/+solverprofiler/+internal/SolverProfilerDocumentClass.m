classdef SolverProfilerDocumentClass<handle


    properties(SetAccess=private)

HStatistics
HStatisticsPanel


HStepSize


HDiagnostics
HException
HReset
HZeroCrossing
HJacobian
HInaccurateState
HSscStiff




LastOpenedDoc
    end

    methods

        function obj=SolverProfilerDocumentClass(h)
            import matlab.ui.container.internal.AppContainer;
            import matlab.ui.internal.*;
            import solverprofiler.util.*


            h.DocumentGridDimensions=[1,2];
            h.DocumentRowWeights=[0.53,0.47];


            group=FigureDocumentGroup();
            group.Tag='SolverProfilerDocument';
            group.Title=utilDAGetString('Diagnostic');
            h.add(group);


            obj.HStepSize=obj.createDocument(h,group,'Stepsize',1,'on');
            obj.HZeroCrossing=obj.createDocument(h,group,'Zerocrossing',2,'off');
            obj.HException=obj.createDocument(h,group,'Solverexception',2,'off');
            obj.HDiagnostics=obj.createDocument(h,group,'Diagnostics',2,'on');
            obj.HJacobian=obj.createDocument(h,group,'JacobianAnalysis',2,'off');
            obj.HReset=obj.createDocument(h,group,'Solverreset',2,'off');
            obj.HInaccurateState=obj.createDocument(h,group,'InaccurateState',2,'off');
            obj.HSscStiff=obj.createDocument(h,group,'SscStiff',2,'off');


            panelOptions.Title=utilDAGetString('Statistics');
            panelOptions.Region="left";
            panelOptions.PreferredHeight=0.999;
            panelOptions.PreferredWidth=0.23;
            panel=FigurePanel(panelOptions);
            h.add(panel);
            obj.HStatisticsPanel=panel;
            obj.HStatistics=panel.Figure;


            hTable=obj.createUITable(obj.HStatistics,{'',''},[],...
            {'auto','auto'},'StatisticsTable','off');



            contextMenu=uicontextmenu(obj.HStatistics);
            hTable.UIContextMenu=contextMenu;




            obj.createUITable(obj.HZeroCrossing.Figure,{'',''},...
            {utilDAGetString('number'),utilDAGetString('block')},...
            {'fit','auto'},'ZCTable','off');


            obj.createUITable(obj.HInaccurateState.Figure,{'','','',''},...
            {utilDAGetString('xmin'),utilDAGetString('xmax'),...
            utilDAGetString('abstol'),utilDAGetString('state')},...
            {'fit','fit','fit','auto'},'InacurateStateTable',...
            'off');


            obj.createUITable(obj.HJacobian.Figure,{'',''},...
            {utilDAGetString('likelihood'),utilDAGetString('limitingStates')},...
            {'fit','auto'},'JacobianTable','off');


            obj.createUITable(obj.HSscStiff.Figure,{'','',''},...
            {utilDAGetString('stiffTimes'),utilDAGetString('stiffness'),...
            utilDAGetString('stiffStates')},...
            {'fit','auto','auto'},'SscStiffTable','off');


            data={'','','','','','','',''};
            columnname={sprintf(utilDAGetString('resetColumnName1')),...
            sprintf(utilDAGetString('resetColumnName2')),...
            sprintf(utilDAGetString('resetColumnName3')),...
            sprintf(utilDAGetString('resetColumnName4')),...
            sprintf(utilDAGetString('resetColumnName5')),...
            sprintf(utilDAGetString('resetColumnName6')),...
            sprintf(utilDAGetString('resetColumnName7')),...
            sprintf(utilDAGetString('resetColumnName8'))};
            columnWidth={'fit','fit','fit','fit','fit','fit','fit','auto'};
            obj.createUITable(obj.HReset.Figure,data,columnname,...
            columnWidth,'ResetTable','off');


            data={'','','','','','',''};
            columnname={sprintf(utilDAGetString('exceptionColumnName1')),...
            sprintf(utilDAGetString('exceptionColumnName2')),...
            sprintf(utilDAGetString('exceptionColumnName3')),...
            sprintf(utilDAGetString('exceptionColumnName4')),...
            sprintf(utilDAGetString('exceptionColumnName5')),...
            sprintf(utilDAGetString('exceptionColumnName6')),...
            sprintf(utilDAGetString('modelState'))};

            columnWidth={'fit','fit','fit','fit','fit','fit','auto'};
            hTable=obj.createUITable(obj.HException.Figure,data,columnname,...
            columnWidth,'ExceptionTable','off');
            hTable.ColumnSortable=true;



            contextMenu=uicontextmenu(obj.HException.Figure);
            hTable.UIContextMenu=contextMenu;




            grid=uigridlayout(obj.HDiagnostics.Figure,[1,1]);
            grid.Padding=0;
            uihtml(grid);
            obj.HDiagnostics.Figure.Children.Children.HTMLSource=" ";


            obj.LastOpenedDoc=obj.HDiagnostics;
        end


        function delete(obj)
            delete(obj.HReset);
            delete(obj.HZeroCrossing);
            delete(obj.HException);
            delete(obj.HJacobian);
            delete(obj.HDiagnostics);
            delete(obj.HStatistics);
            delete(obj.HStepSize);
            delete(obj.HInaccurateState);
            delete(obj.HSscStiff);
        end




        function value=getStepSizePlotHandle(obj)
            value=[];
            if~isvalid(obj.HStepSize)
                return;
            end

            value=obj.HStepSize.Figure;
        end


        function type=getExceptionTableRankingType(obj)
            type=1;
        end


        function handle=getFigureHandle(obj,name)
            import solverprofiler.util.*
            if strcmp(name,utilDAGetString('Zerocrossing'))
                handle=obj.HZeroCrossing.Figure;
            elseif strcmp(name,utilDAGetString('Solverexception'))
                handle=obj.HException.Figure;
            elseif strcmp(name,utilDAGetString('JacobianAnalysis'))
                handle=obj.HJacobian.Figure;
            elseif strcmp(name,utilDAGetString('Solverreset'))
                handle=obj.HReset.Figure;
            elseif strcmp(name,utilDAGetString('InaccurateState'))
                handle=obj.HInaccurateState.Figure;
            elseif strcmp(name,utilDAGetString('Statistics'))
                handle=obj.HStatistics;
            elseif strcmp(name,utilDAGetString('SscStiff'))
                handle=obj.HSscStiff.Figure;
            else
                handle='';
            end
        end




        function attachFigureZoomPanPostCallback(obj,fhandle)
            hobj=zoom(obj.HStepSize.Figure);
            hobj.ActionPostCallback=fhandle;
            hobj=pan(obj.HStepSize.Figure);
            hobj.ActionPostCallback=fhandle;
        end


        function attachStatisticsTableSelectCallback(obj,fhandle)
            set(findobj(obj.HStatistics.Children,'RowName',''),...
            'CellSelectionCallback',fhandle);
        end


        function attachTableSelectCallback(obj,fhandle)
            set(findobj(obj.HZeroCrossing.Figure.Children,'RowName',''),...
            'CellSelectionCallback',fhandle);
            set(findobj(obj.HException.Figure.Children,'RowName',''),...
            'CellSelectionCallback',fhandle);
            set(findobj(obj.HJacobian.Figure.Children,'RowName',''),...
            'CellSelectionCallback',fhandle);
            set(findobj(obj.HReset.Figure.Children,'RowName',''),...
            'CellSelectionCallback',fhandle);
            set(findobj(obj.HInaccurateState.Figure.Children,'RowName',''),...
            'CellSelectionCallback',fhandle);
            set(findobj(obj.HSscStiff.Figure.Children,'RowName',''),...
            'CellSelectionCallback',fhandle);
        end


        function moveFocusToDiagnostics(obj)
            obj.HDiagnostics.Selected=true;
        end

        function moveFocusToStatisticsTable(obj)
            obj.HStatisticsPanel.Selected=true;
        end

        function moveFocusToZeroCrossingTable(obj)
            obj.HZeroCrossing.Selected=true;
        end

        function moveFocusToExceptionTable(obj)
            obj.HException.Selected=true;
        end

        function moveFocusToResetTable(obj)
            obj.HReset.Selected=true;
        end

        function moveFocusToJacobianTable(obj)
            obj.HJacobian.Selected=true;
        end

        function moveFocusToSscStiffTable(obj)
            obj.HSscStiff.Selected=true;
        end

        function moveFocusToStepSizePlot(obj)
            obj.HStepSize.Selected=true;
        end

        function moveFocusToHInaccurateStateTable(obj)
            obj.HInaccurateState.Selected=true;
        end




        function turnOnZoom(obj,direction)
            pan(obj.HStepSize.Figure,'off');
            hobj=zoom(obj.HStepSize.Figure);
            hobj.direction=direction;
            hobj.enable='on';
        end

        function turnOffZoom(obj)
            hobj=zoom(obj.HStepSize.Figure);
            hobj.enable='off';
        end

        function turnOnPan(obj)
            pan(obj.HStepSize.Figure,'on');
        end

        function turnOffPan(obj)
            pan(obj.HStepSize.Figure,'off');
        end


        function deletePointsFromStepSizePlot(obj,tag)
            h=findobj(obj.HStepSize.Figure,'Tag',tag);
            h.YData=[];
            h.XData=[];
        end




        function populateStatisticsTable(obj,content)
            h=findobj(obj.HStatistics.Children,'RowName','');
            set(h,'data',content,'visible','on');
            makeBlue=uistyle('FontColor','blue');
            makeBold=uistyle('FontWeight','bold');
            addStyle(h,makeBold,'cell',[1,1]);
            addStyle(h,makeBold,'cell',[11,1]);
            addStyle(h,makeBold,'cell',[20,1]);
            for i=3:1:17
                if(str2double(content{i+20,2})>0)
                    addStyle(h,makeBlue,'cell',[i+20,2]);
                end
            end
        end

        function populateZeroCrossingTable(obj,content)
            if isempty(content)
                obj.HZeroCrossing.Phantom=1;
            else
                obj.HZeroCrossing.Phantom=0;
                h=findobj(obj.HZeroCrossing.Figure.Children,'RowName','');
                set(h,'data',content,'visible','on');
                obj.LastOpenedDoc=obj.HZeroCrossing;
            end
        end

        function populateJacobianTable(obj,content)
            if isempty(content)
                obj.HJacobian.Phantom=1;
            else
                obj.HJacobian.Phantom=0;
                h=findobj(obj.HJacobian.Figure.Children,'RowName','');
                set(h,'data',content,'visible','on');
                obj.LastOpenedDoc=obj.HJacobian;
            end
        end

        function populateSscStiffTable(obj,content)
            if isempty(content)
                obj.HSscStiff.Phantom=1;
            else
                obj.HSscStiff.Phantom=0;
                h=findobj(obj.HSscStiff.Figure.Children,'RowName','');
                set(h,'data',content,'visible','on');
                obj.LastOpenedDoc=obj.HSscStiff;
            end
        end

        function populateExceptionTable(obj,content)
            if isempty(content)
                obj.HException.Phantom=1;
            else
                obj.HException.Phantom=0;
                h=findobj(obj.HException.Figure.Children,'RowName','');
                set(h,'data',content,'visible','on');
                obj.LastOpenedDoc=obj.HException;
            end
        end

        function populateResetTable(obj,content)
            if isempty(content)
                obj.HReset.Phantom=1;
            else
                obj.HReset.Phantom=0;
                h=findobj(obj.HReset.Figure.Children,'RowName','');
                set(h,'data',content,'visible','on');
                obj.LastOpenedDoc=obj.HReset;
            end
        end

        function populateInaccurateStateTable(obj,content)
            if isempty(content)
                obj.HInaccurateState.Phantom=1;
            else
                obj.HInaccurateState.Phantom=0;
                h=findobj(obj.HInaccurateState.Figure.Children,'RowName','');
                set(h,'data',content,'visible','on');
                obj.LastOpenedDoc=obj.HInaccurateState;
            end
        end

        function refreshAllTables(obj)
            if(obj.HZeroCrossing.Phantom==0)
                h=findobj(obj.HZeroCrossing.Figure.Children,'RowName','');
                set(h,'data',h.Data);
            end

            if(obj.HJacobian.Phantom==0)
                h=findobj(obj.HJacobian.Figure.Children,'RowName','');
                set(h,'data',h.Data);
            end

            if(obj.HSscStiff.Phantom==0)
                h=findobj(obj.HSscStiff.Figure.Children,'RowName','');
                set(h,'data',h.Data);
            end

            if(obj.HException.Phantom==0)
                h=findobj(obj.HException.Figure.Children,'RowName','');
                set(h,'data',h.Data);
            end

            if(obj.HReset.Phantom==0)
                h=findobj(obj.HReset.Figure.Children,'RowName','');
                set(h,'data',h.Data);
            end

            if(obj.HInaccurateState.Phantom==0)
                h=findobj(obj.HInaccurateState.Figure.Children,'RowName','');
                set(h,'data',h.Data);
            end
        end

        function resetLastOpenedDoc(obj)

            obj.LastOpenedDoc=obj.HDiagnostics;
        end


        function setExceptionTableRankTypeTo(obj,type)

        end



        function populateDiagnostics(obj,contents)
            if isempty(contents)
                return;
            end

            content=[];
            for i=1:length(contents)
                if(isempty(contents{i}))
                    content=[content,'<br>'];
                else
                    content=[content,' ',contents{i}];
                end
            end

            obj.HDiagnostics.Figure.Children.Children.HTMLSource=content;
        end


        function doc=createDocument(obj,h,group,xmlKey,tile,visibility)
            import matlab.ui.internal.*
            import solverprofiler.util.*

            documentOptions.Title=utilDAGetString(xmlKey);
            documentOptions.DocumentGroupTag=group.Tag;
            documentOptions.Tile=tile;
            documentOptions.Closable=false;
            documentOptions.Description="";
            doc=FigureDocument(documentOptions);

            fig=doc.Figure;
            fig.NumberTitle='off';
            fig.WindowKeyReleaseFcn=@obj.DoNothing;
            fig.HandleVisibility='off';
            if strcmp(visibility,'on')
                doc.Phantom=0;
            else
                doc.Phantom=1;
            end
            h.addDocument(doc);
        end

    end

    methods(Static)


        function DoNothing(~,~)
            return;
        end


        function ExceptionCSH(~,~)
            helpview(fullfile(docroot,'toolbox','simulink','helptargets.map'),'exceptionPane');
        end

        function StatisticsCSH(~,~)
            helpview(fullfile(docroot,'toolbox','simulink','helptargets.map'),'statisticsPane');
        end


        function table=createUITable(fig,data,columnName,columnWidth,tag,visibility)
            grid=uigridlayout(fig,[1,1]);
            grid.Padding=0;
            columnEditable(1:length(data(1,:)))=false;

            table=uitable(grid,...
            'Data',data,...
            'RowName','',...
            'ColumnFormat',{'char'},...
            'ColumnName',columnName,...
            'ColumnWidth',columnWidth,...
            'ColumnEditable',columnEditable,...
            'Tag',tag,...
            'FontSize',12,...
            'Visible',visibility);

            s=uistyle;
            s.HorizontalAlignment='left';
            addStyle(table,s);

            drawnow;
        end

    end

end
