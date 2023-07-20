function fileChangedCallback(this,src,event)




    if~isempty(this)&&isvalid(this)

        notify(this.EventHandler,'FileOnDiskChange',...
        evolutions.internal.ui.GenericEventData(struct('Src',...
        src,'event',event)));
        if strcmp(event,'SelfRemoved')&&doesFileExist(this.FilePathMap,src)


            this.ChangeListener.clearListener(this.FilePathMap(src));
            this.ChangeListener.addListener(this.FilePathMap(src),@this.fileChangedCallback);
        end
    end

end

function tf=doesFileExist(filePathMap,src)
    tf=isKey(filePathMap,src)&&isfile(filePathMap(src));
end