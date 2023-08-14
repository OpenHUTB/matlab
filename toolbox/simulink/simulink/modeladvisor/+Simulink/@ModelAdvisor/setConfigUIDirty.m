function valueStored=setConfigUIDirty(this,valueProposed)





    valueStored=valueProposed;
    if isa(this.ConfigUIWindow,'DAStudio.Explorer')
        if valueProposed
            if length(this.ConfigUIWindow.Title)>1&&~strcmp(this.ConfigUIWindow.Title(end-1:end),' *')
                this.ConfigUIWindow.Title=[this.ConfigUIWindow.Title,' *'];
            end
        elseif~valueProposed
            if length(this.ConfigUIWindow.Title)>1&&strcmp(this.ConfigUIWindow.Title(end-1:end),' *')
                this.ConfigUIWindow.Title=this.ConfigUIWindow.Title(1:end-2);
            end
        end
    end
