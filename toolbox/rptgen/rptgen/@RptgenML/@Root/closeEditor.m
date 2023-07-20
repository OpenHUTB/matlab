function varargout=closeEditor(this,forceClose)





    if nargin<2
        forceClose=false;
    end

    continueClose=this.closeAllReports(forceClose);

    if(continueClose)
        if isa(this.Editor,'DAStudio.Explorer')
            if forceClose
                delete(this.Editor);
                this.Editor=[];
            else
                hide(this.Editor);
            end
        end


        this.getDisplayClient('-hide');
    else


        if isa(this.Editor,'DAStudio.Explorer')
            show(this.Editor);
        end
    end

    if nargout>0
        varargout{1}=continueClose;
    end
