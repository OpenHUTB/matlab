function[yesno,opcPartName]=isEmbeddedLinkSet(linksetData)

    if isa(linksetData,'slreq.data.LinkSet')
        linksetFilePath=linksetData.filepath;
    else
        linksetFilePath=convertStringsToChars(linksetData);
    end

    [opcFileName,opcPartName]=slreq.utils.getEmbeddedLinksetName();
    [~,fname]=fileparts(linksetFilePath);
    yesno=strcmp(fname,opcFileName);

end