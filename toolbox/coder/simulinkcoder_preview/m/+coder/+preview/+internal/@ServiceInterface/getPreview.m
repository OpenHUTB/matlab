function out=getPreview(obj)




    contents={
    obj.getDeclaration
    obj.getDefinition
    obj.getUsage
    };

    contents=contents(~cellfun(@isempty,contents));
    if isempty(contents)

        out=obj.getPreviewNotAvailable;
    else
        out=obj.getPreviewSection(strjoin(contents,'<br/>'),obj.EntryType);
    end


