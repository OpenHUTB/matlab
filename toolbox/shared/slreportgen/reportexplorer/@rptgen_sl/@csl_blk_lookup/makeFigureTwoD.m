function h=makeFigureTwoD(c,xVal,xName,yVal,yName,tVal,tName)




    if length(xVal)~=size(tVal,1)
        xVal=1:size(tVal,1);
        xName=[xName,' [indices]'];
    end

    if length(yVal)~=size(tVal,2)
        yVal=1:size(tVal,2);
        yName=[yName,' [indices]'];
    end




    h=rptgen_hg.makeTempCanvas;
    set(h,'Color','white','InvertHardcopy','off');

    axHandle=axes('Parent',h,...
    'Box','off',...
    'Color',[1,1,1],...
    'Xgrid','on',...
    'Ygrid','on',...
    'Zgrid','on',...
    'ZlimMode','auto',...
    'XlimMode','auto',...
    'YlimMode','auto');

    if strcmp(c.DoublePlotType,'surfaceplot')
        try
            set(axHandle,'View',[-37.5,30]);



            surface(double(xVal),double(yVal),double(tVal'),...
            'FaceColor','interp',...
            'Parent',axHandle);
            ok=true;
        catch
            ok=false;
        end
    else
        try
            plotHandles=plot(xVal,tVal,'parent',axHandle);

            legendLabels=cellstr(num2str(double(yVal(:))));

            legend(plotHandles,legendLabels,'Location','NorthEastOutside');

            ok=true;
        catch
            ok=false;
        end
    end

    if ok
        locSetupLabel(axHandle,get(axHandle,'xlabel'),xName)

        if strcmp(c.DoublePlotType,'surfaceplot')
            locSetupLabel(axHandle,get(axHandle,'zlabel'),tName)
            locSetupLabel(axHandle,get(axHandle,'ylabel'),yName)
        else
            locSetupLabel(axHandle,get(axHandle,'ylabel'),tName)
        end
    else
        h=[];
    end

    function locSetupLabel(axHandle,labelHandle,label)

        set(labelHandle,'FontAngle',get(axHandle,'FontAngle'));
        set(labelHandle,'FontName',get(axHandle,'FontName'));
        set(labelHandle,'FontSize',get(axHandle,'FontSize'));
        set(labelHandle,'FontWeight',get(axHandle,'FontWeight'));
        set(labelHandle,'Interpreter','none');
        set(labelHandle,'String',label);

