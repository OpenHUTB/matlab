function docUtil=docUtilObj(docPath,autosave,minimize)



    persistent docUtilObjects
    if isempty(docUtilObjects)
        docUtilObjects=containers.Map('KeyType','char','ValueType','any');
    end

    if nargin<2
        autosave=false;
    end

    if nargin<3
        minimize=false;
    end

    if any(strcmp(docPath,{'clearAll','clearExcel','clearWord'}))

        allKeys=keys(docUtilObjects);
        for i=1:length(allKeys)
            key=allKeys{i};
            obj=docUtilObjects(key);
            if strcmp(docPath,'clearAll')
                doRemove=true;
            else
                [~,~,fExt]=fileparts(key);
                doRemove=(strcmp(docPath,'clearExcel')&&any(strcmp(fExt,{'.xls','.xlsx'})))...
                ||(strcmp(docPath,'clearWord')&&any(strcmp(fExt,{'.doc','.docx','.rtf'})));
            end
            if doRemove
                delete(obj);
                remove(docUtilObjects,key);
            end
        end
        docUtil=[];
        return;
    end

    if isKey(docUtilObjects,docPath)


        docUtil=docUtilObjects(docPath);

        if isUsable(docUtil)

            if isa(docUtil,'rmidotnet.MSExcel')

                origSheet=docUtil.iSheet;
                if~isempty(origSheet)

                    docUtil.setActiveSheet(origSheet);
                end
            else

                if minimize



                    docUtil.setMinimized(true);
                end
            end

            if autosave





                docUtil.saveDocClearTimestamp();
            end

            if~docUtil.validate()

                docUtil=[];




            end

            return;
        end
    end




    docUtilObjects(docPath)=makeNew(docPath,minimize);
    docUtil=docUtilObjects(docPath);

end

function tf=isUsable(docObj)
    try
        docObj.hDoc.Name;
        tf=true;
    catch
        tf=false;
    end
end

function docUtil=makeNew(docPath,minimize)
    docType=slreq.utils.resolveDocType(docPath);
    switch docType
    case 'word'
        docUtil=rmidotnet.MSWord(docPath);
        if~docUtil.hDoc.Saved()

            warning(['MS Word API malfunction: document dirty upon open: ',docPath]);
        end
        if minimize

            docUtil.setMinimized(true);
        end
        docUtil.refresh();
    case 'excel'
        docUtil=rmidotnet.MSExcel(docPath);
    otherwise
        error('cannot make utilObj for type %s',docType);
    end
end



