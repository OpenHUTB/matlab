function[docs,items,reqsys]=getLinkedItems(linkSource)




    docs={};
    if nargout>1
        items={};
        reqsys={};
    end

    if~rmiml.hasData(linkSource)

        if~rmiml.loadIfExists(linkSource)
            return;
        end
    end


    if slreq.hasChanges(linkSource)






        if isMigrating(linkSource)

        else
            disp(getString(message('Slvnv:rmiml:UnsavedChangesFor',linkSource)));
            return;
        end
    end

    if nargout==1

        docs=rmidata.getLinkedItems(linkSource);
    else

        [docs,items,reqsys]=rmidata.getLinkedItems(linkSource);
    end

end

function yesno=isMigrating(linkSource)
    if rmisl.isSidString(linkSource)
        linkSource=get_param(strtok(linkSource,':'),'FileName');
    end
    [sPath,sName]=fileparts(linkSource);
    reqFilePath=fullfile(sPath,[sName,'.req']);
    linkFilePath=fullfile(sPath,[sName,'.slmx']);
    yesno=(exist(reqFilePath,'file')==2&&exist(linkFilePath,'file')~=2);
end

