function result=dictHasChanges(obj)




    if ischar(obj)
        [dName,fName,fExt]=fileparts(obj);
        if isempty(dName)
            if isempty(fExt)
                fExt='.sldd';
            end
            pathToDict=rmide.resolveDict([fName,fExt]);
        else
            pathToDict=obj;
        end
    else
        pathToDict=rmide.resolveEntry(obj);
    end

    linkSet=slreq.utils.getLinkSet(pathToDict,'linktype_rmi_data',false);
    result=~isempty(linkSet)&&linkSet.dirty;
end
