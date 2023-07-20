function wasSaved=close(dictFile,force)




    dictFile=convertStringsToChars(dictFile);

    wasSaved=false;

    if nargin<2
        force=false;
    end

    if~slreq.data.ReqData.exists()
        return;
    end

    if~any(dictFile==filesep)

        dictFile=rmide.resolveDict(dictFile);
    end

    if~force&&rmide.dictHasChanges(dictFile)
        reply=' ';
        while lower(reply(1))~='y'&&lower(reply(1))~='n'
            escapedPath=strrep(dictFile,'\','\\');
            questionString=getString(message('Slvnv:rmiml:UnsavedChangesSaveNowQuestion',escapedPath));
            reply=lower(input(['  ',questionString,'  '],'s'));
            if isempty(reply)
                return;
            end
        end
        if reply(1)=='y'
            rmide.save(dictFile);
            wasSaved=true;
        end
    end
    rmide.discard(dictFile);
end
