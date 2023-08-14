function wasClosed=closeAllReports(this,forceClose)










    if nargin<2
        forceClose=false;
    end

    wasClosed=true;
    toClose=this.down;
    while~isempty(toClose)&&(forceClose||wasClosed)
        toCloseNext=toClose.right;
        try
            wasClosed=doClose(toClose,forceClose);
            if~wasClosed
                this.viewChild(toClose);
                return;
            end
        catch ME
            wasClosed=true;
            warning(ME.message);
            disconnect(toClose);
        end
        toClose=toCloseNext;
    end

    if isa(this.Editor,'DAStudio.Explorer')



        view(this.Editor,this);
    end
