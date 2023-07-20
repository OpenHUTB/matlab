function ax=validateAxes(allAxes,modeName)




    ax=[];
    if isempty(allAxes)
        return;
    end


    for i=1:length(allAxes)
        b=hggetbehavior(allAxes(i),modeName,'-peek');
        if strcmpi(get(allAxes(i),'HandleVisibility'),'off')

        elseif~isempty(b)&&isobject(b)&&~get(b,'Enable')



        elseif isa(allAxes(i),'matlab.graphics.chart.Chart')

        elseif isa(allAxes(i),'matlab.graphics.axis.GeographicAxes')

        elseif~isappdata(allAxes(i),'NonDataObject')
            ax=allAxes(i);
            break;
        end
    end
    ax=matlab.graphics.interaction.vectorizePlotyyAxes(ax);
