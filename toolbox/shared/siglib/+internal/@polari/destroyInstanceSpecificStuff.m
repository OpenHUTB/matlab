function destroyInstanceSpecificStuff(p,ax)





    t=p.hBannerMessage;
    p.hBannerMessage=[];
    if~isempty(t)&&isvalid(t)

        delete(t);
    end

    t=p.hToolTip;
    p.hToolTip=[];
    if~isempty(t)&&isvalid(t)

        delete(t);
    end







    if~isempty(ax)&&ishghandle(ax)&&isappdata(ax,'PolariAxesIndex')
        rmappdata(ax,'PolariAxesIndex');
    end






    fig=ancestor(ax,'figure');
    if~isempty(fig)&&ishghandle(fig)&&isappdata(fig,'PolariAxesIndexInUse')


        axesIndexInUse=getappdata(fig,'PolariAxesIndexInUse');
        axesIndexInUse(p.pAxesIndex)=false;
        setappdata(fig,'PolariAxesIndexInUse',axesIndexInUse);
    end






    internal.manager('polariInstance','remove',p);
    getAndCleanupUiscopesManagerInstances();
