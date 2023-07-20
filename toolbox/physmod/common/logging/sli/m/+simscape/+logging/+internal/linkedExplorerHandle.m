function e=linkedExplorerHandle(h)





    mlock;

    persistent pExplorerHandle;

    if nargin==1
        pExplorerHandle=h;
    end

    if~isempty(pExplorerHandle)&&ishandle(pExplorerHandle)&&~pExplorerHandle.isvalid
        pExplorerHandle=[];
    end
    e=pExplorerHandle;

end
