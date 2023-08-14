function emlObj=getEMLParentOfReferencedFile(FileRef)


    if contains(FileRef.ReferenceLocation,':')
        try
            ids=strsplit(FileRef.ReferenceLocation,':');

            parentCh=idToHandle(sfroot,sfprivate('block2chart',get_param(ids{1},'handle')));
            emlObj=parentCh.find('SSIdNumber',str2double(ids{end}));
        catch
            emlObj=[];
        end
    else
        try
            blockH=get_param(FileRef.ReferenceLocation,'Handle');
            emlObj=idToHandle(sfroot,sfprivate('block2chart',blockH));
        catch
            emlObj=[];
        end
    end
end