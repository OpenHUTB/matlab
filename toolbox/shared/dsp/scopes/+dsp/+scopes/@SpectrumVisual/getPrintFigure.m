function printFig=getPrintFigure(this)








    printFig=setupPrintFigure(this);
    set(printFig,'DefaultTextColor',get(this.Axes(1,1),'XColor'));


    function printFig=setupPrintFigure(this)









        hScope=this.Application;
        scopeFig=hScope.Parent;

        scopeCmap=get(scopeFig,'Colormap');


        printFig=figure('Visible','off',...
        'Units','pixels',...
        'Colormap',scopeCmap,...
        'PaperPositionMode','auto',...
        'Tag','ScopePrintToFigure');


        scopePos=get(scopeFig,'Position');
        printPos=get(printFig,'Position');



        printPos(2)=printPos(2)-(scopePos(4)-printPos(4))/2;
        figCentre=[printPos(1)+printPos(3)/2,printPos(2)+printPos(4)/2];

        printPos(1)=figCentre(1)-scopePos(3)/2;
        printPos(2)=figCentre(2)-scopePos(3)/2;

        set(printFig,'Position',[printPos(1),printPos(2),scopePos(3),scopePos(4)]);


        if isCombinedViewMode(this)
            scopeAxes=this.Axes;
        elseif isSpectrogramMode(this)
            scopeAxes=this.Axes(1,2);
        else
            scopeAxes=this.Axes(1,1);
        end

        if~isempty(scopeAxes)


            printAxes=copyobj(scopeAxes,printFig);


            set(printAxes,...
            'XLimMode','manual','XTickMode','manual','XTickLabelMode','manual',...
            'YLimMode','manual','YTickMode','manual','YTickLabelMode','manual',...
            'ZLimMode','manual','ZTickMode','manual','ZTickLabelMode','manual');


            removeInteractiveBehaviors(this,printAxes);


            if~isCombinedViewMode(this)
                removeAppData(printAxes(1,1));
            else
                removeAppData(printAxes(1,1));
                removeAppData(printAxes(2,1));
            end


            updatePrintAxes(this,printFig);
        end


        function removeAppData(printAxes)

            if isappdata(printAxes,'MWBYPASS_axis')
                rmappdata(printAxes,'MWBYPASS_grid');
                rmappdata(printAxes,'MWBYPASS_title');
                rmappdata(printAxes,'MWBYPASS_xlabel');
                rmappdata(printAxes,'MWBYPASS_ylabel');
                rmappdata(printAxes,'MWBYPASS_axis');
            end
