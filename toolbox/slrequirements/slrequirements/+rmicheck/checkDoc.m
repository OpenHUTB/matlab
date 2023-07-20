function success=checkDoc(sys,doc,refSrc)




    try
        linkType=rmi.getLinktype(sys,doc);
    catch ME %#ok<NASGU>



        if rmiut.isCompletePath(doc)
            success=(exist(doc,'file')==2);
        else
            resolvedPath=rmi.locateFile(doc,get_param(bdroot,'FileName'));
            success=~isempty(resolvedPath)&&(exist(resolvedPath,'file')==2);
        end
        return;
    end

    if linkType.IsFile
        if rmisl.isDocBlockPath(doc)

            docPath=rmisl.docBlockTempPath(doc,true);
        else

            if ischar(refSrc)&&exist(refSrc,'file')==2
                refSrc=fileparts(refSrc);
            end
            docPath=rmisl.locateFile(doc,refSrc);
        end
        if isempty(docPath)
            success=false;
        else
            success=true;
        end

    elseif~isempty(linkType.IsValidDocFcn)
        success=feval(linkType.IsValidDocFcn,doc,refSrc);

    else

        success=~isempty(doc);
    end

end
