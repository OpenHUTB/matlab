function removeView(ddFile)




    if ischar(ddFile)

        ddFilePath=which(ddFile);
        if~isempty(ddFilePath)
            ddFile=ddFilePath;
        end
    end
    simulinkcoder.internal.app.DictionaryViewManager.instance.removeView(ddFile);

end

