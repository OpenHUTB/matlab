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







    if~isempty(ax)&&ishghandle(ax)&&isappdata(ax,'SmithplotAxesIndex')
        rmappdata(ax,'SmithplotAxesIndex');
    end






    fig=ancestor(ax,'figure');
    if~isempty(fig)&&ishghandle(fig)&&isappdata(fig,'SmithplotAxesIndexInUse')


        axesIndexInUse=getappdata(fig,'SmithplotAxesIndexInUse');
        axesIndexInUse(p.pAxesIndex)=false;
        setappdata(fig,'SmithplotAxesIndexInUse',axesIndexInUse);
    end






    internal.manager('smithplotInstance','remove',p);
    getAndCleanupUiscopesManagerInstances();
