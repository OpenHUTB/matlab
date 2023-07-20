function removeTaggedFiles(obj,tag)




    tagVector=strncmp({obj.FileInfo.Tag},tag,length(tag));
    if any(tagVector)
        obj.FileInfo(tagVector)=[];

        obj.CachedSortedFileInfo={};
        obj.TimeStamp=now;
        obj.Dirty=true;
    end
end
