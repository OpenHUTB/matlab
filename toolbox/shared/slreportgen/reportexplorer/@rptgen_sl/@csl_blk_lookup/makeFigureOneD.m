function h=makeFigureOneD(c,xData,xLabel,yData,yLabel)




    if length(xData)~=length(yData)
        xData=1:length(yData);
        xLabel=[xLabel,' [indices]'];
    end

    h=rptgen_hg.makeTempCanvas;
    set(h,...
    'Color','white',...
    'InvertHardcopy','off',...
    'HandleVisibility','on');

    axHandle=axes('Parent',h,...
    'HandleVisibility','on',...
    'Box','on',...
    'Color',[1,1,1],...
    'XlimMode','auto',...
    'YlimMode','auto');

    ok=false;

    switch c.SinglePlotType
    case 'lineplot'
        try
            line('Parent',axHandle,...
            'Xdata',xData,...
            'Ydata',yData,...
            'Color',[0,0,1],...
            'LineWidth',2,...
            'Marker','.');
            ok=true;
        catch ME
            c.status(getString(message('RptgenSL:rsl_csl_blk_lookup:cannotDrawLineLabel')),2);
            c.status(ME.message,5);
        end
    case 'barplot'
        try
            bar(double(xData),double(yData));
            ok=true;
        catch ME
            c.status(getString(message('RptgenSL:rsl_csl_blk_lookup:cannotDrawBarLabel')),2);
            c.status(ME.message,5);
        end
    otherwise
        c.status(getString(message('RptgenSL:rsl_csl_blk_lookup:unrecognizedPlotType')),1);
    end

    set(h,'HandleVisibility','off');

    if ok

        locSetupLabel(axHandle,get(axHandle,'xlabel'),xLabel)
        locSetupLabel(axHandle,get(axHandle,'ylabel'),yLabel)

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
