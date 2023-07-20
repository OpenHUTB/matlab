function claNotify(ax,varargin)






















    hax=handle(ax);

    if~isempty(hax.Children)
        fig=ancestor(hax,'figure');

        matlab.graphics.internal.clearNotify(fig,hax);
    end


    notify(hax,'Cla');
    if~isempty(varargin)&&ischar(varargin{1})&&strcmp(varargin{1},'reset')
        notify(hax,'ClaPreReset')
        notify(hax,'ClaReset')
    end


    hax.setNextSeriesIndex(1);


    codeGenAppData=getappdata(ax,'MCodeGeneration');
    if~isempty(codeGenAppData)
        rmappdata(ax,'MCodeGeneration');
    end

