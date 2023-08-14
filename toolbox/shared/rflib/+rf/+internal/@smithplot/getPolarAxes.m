function pInUse=getPolarAxes(p,forceReset)









    if nargin<2
        forceReset=false;
    end




    if~isPolariAxes(p)||forceReset


        initAxesForPolari(p);
        pInUse=p;
    elseif nargout>0

        pInUse=internal.polari.getCurrentPlot(p.hAxes);
    end

end

function initAxesForPolari(p)










    axesIndexInUse=getappdata(p.hFigure,'SmithplotAxesIndexInUse');
    axesIndex=find(~axesIndexInUse,1,'first');
    if isempty(axesIndex)


        axesIndex=numel(axesIndexInUse)+1;
    end
    axesIndexInUse(axesIndex)=true;
    setappdata(p.hFigure,'SmithplotAxesIndexInUse',axesIndexInUse);

    p.pAxesIndex=axesIndex;
    assert(~isempty(axesIndex))








    pAll=getAndCleanupUiscopesManagerInstances();
    if~any(pAll==p)
        internal.manager('smithplotInstance','add',p);
    end



    ax=p.hAxes;
    assert(~isempty(ax))
    cla(ax,'reset');
    set(ax,...
    'Parent',p.Parent,...
    'XTick',[],...
    'YTick',[],...
    'Units','norm',...
    'Visible','off',...
    'Interruptible','off',...
    'LooseInset',[0,0,0,0],...
    'Tag','smithplot');
    axis(ax,'equal','tight');


    bh=hggetbehavior(ax,'Plotedit');
    bh.Enable=false;
    bh=hggetbehavior(ax,'Zoom');
    bh.Enable=true;
    bh=hggetbehavior(ax,'Pan');
    bh.Enable=true;
    bh=hggetbehavior(ax,'Rotate3d');
    bh.Enable=false;





    setappdata(ax,'SmithplotAxesIndex',axesIndex);



    ax.Camera.TransparencyMethodHint='objectsort';



    oldpos=getappdata(ax,'PolariAxesPositionPreView');
    if isempty(oldpos)
        cacheChangeInAxesPosition(p);
    else


        ax.Position=oldpos;
    end


    createListeners(p);
    enableListeners(p,true);
    changeMouseBehavior(p,'general');
    create_context_menus(p);

end