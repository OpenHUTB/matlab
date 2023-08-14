classdef(Abstract)BaseTask<handle






    properties(Transient)

        UIFigure matlab.ui.Figure
    end

    events(NotifyAccess=protected)

Changed
    end


    methods(Abstract)


        [code,outputs]=generateScript(app)




        code=generateVisualizationScript(app)



        summary=generateSummary(app)



        state=getState(app)



        setState(app,state)



        reset(app)
    end



    methods(Static,Hidden)
        function fig=createFigureWindow(appTitle,tag)

            fig=uifigure('Name',appTitle,'Visible','off',...
            'Tag',join([tag,"window"],'_'));
        end

        function grid=createMainGrid(parent,numRows,tag)



            grid=uigridlayout('Parent',parent,...
            'RowHeight',repmat({'fit'},1,numRows),...
            'ColumnWidth',{'1x'},...
            'RowSpacing',15,'Scrollable','off',...
            'Tag',join([tag,"maingrid"],'_'));
        end

        function grid=createSubGrid(parentGrid,numRows,numCols,tag)


            grid=uigridlayout('Parent',parentGrid,...
            'RowHeight',repmat({'fit'},1,numRows),...
            'ColumnWidth',repmat({'fit'},1,numCols),...
            'Padding',[0,0,0,0],'RowSpacing',6,'ColumnSpacing',5,...
            'Tag',join([tag,"grid"],'_'));
        end

        function grid=createAccordionPanelSubGrid(parentGrid,numRows,numCols,tag)

            grid=signal.task.internal.BaseTask.createSubGrid(parentGrid,numRows,numCols,tag);
            grid.Padding=[0,15,0,10];
        end

        function acc=createAccordion(parent,tag)

            import matlab.ui.container.internal.*
            acc=Accordion('Parent',parent,'Tag',join([tag,"accordion"],'_'));
        end

        function panel=createAccordionPanel(parentAccordion,title,tag)


            import matlab.ui.container.internal.*
            panel=AccordionPanel('Parent',parentAccordion,'Title',title,...
            'Tag',join([tag,"accordionpanel"],'_'));
        end

        function label=createHeader(parentGrid,text,tag,rowLoc)


            label=uilabel(parentGrid,'Text',text,...
            'FontWeight','bold','Tag',join([tag,"header"],'_'));
            if nargin>3
                label.Layout.Row=rowLoc;
                label.Layout.Column=[1,length(parentGrid.ColumnWidth)];
            end
        end

        function label=createSubHeader(parentGrid,text,tag,rowLoc,colLoc)

            label=uilabel(parentGrid,'Text',text,...
            'FontWeight','bold','Tag',join([tag,"subheader"],'_'));
            if nargin>3
                label.Layout.Row=rowLoc;
                label.Layout.Column=colLoc;
            end
        end

        function label=createLabel(parentGrid,text,tag,rowLoc,colLoc)

            label=uilabel(parentGrid,'Text',text,'Tag',join([tag,"label"],'_'));
            if nargin>3
                label.Layout.Row=rowLoc;
                label.Layout.Column=colLoc;
            end
        end

        function setDropdownItems(dropdown,items,itemsData,value)
            dropdown.Items=items;
            dropdown.Items=itemsData;
            if nargin==3
                dropdown.Value=value;
            end
        end
    end
end
