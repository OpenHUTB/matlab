function taggedFiles=getTaggedFiles(obj,tag)











    tagVector=strncmp({obj.FileInfo.Tag},tag,length(tag));
    fileInfo=obj.getFileInfo;
    taggedFiles=fileInfo(tagVector);
end
