function figH=makeFigureTwoD(xVal,xName,yVal,yName,tVal,tName,plotType)



    if length(xVal)~=size(tVal,1)
        xVal=1:size(tVal,1);
        xName=[xName,' [indices]'];
    end

    if length(yVal)~=size(tVal,2)
        yVal=1:size(tVal,2);
        yName=[yName,' [indices]'];
    end

    figH=figure(...
    'Visible','off',...
    'CloseRequestFcn','set(gcbf,''Visible'',''off'')',...
    'Name','Report Generator Temporary Drawing Canvas');

    set(figH,'Color','white','InvertHardcopy','off');

    axHandle=axes('Parent',figH,...
    'Box','off',...
    'Color',[1,1,1],...
    'Xgrid','on',...
    'Ygrid','on',...
    'Zgrid','on',...
    'ZlimMode','auto',...
    'XlimMode','auto',...
    'YlimMode','auto');


    set(axHandle,'View',[-37.5,30]);

    if strcmp(plotType,"Surface Plot")


        surface(double(xVal),double(yVal),double(tVal'),...
        'FaceColor','interp',...
        'Parent',axHandle);
    elseif strcmp(plotType,"Mesh Plot")
        mesh(double(xVal),double(yVal),double(tVal'),...
        'Parent',axHandle);
    end

    set(get(axHandle,'xlabel'),'String',xName);
    set(get(axHandle,'ylabel'),'String',yName);
    set(get(axHandle,'zlabel'),'String',tName);

end
