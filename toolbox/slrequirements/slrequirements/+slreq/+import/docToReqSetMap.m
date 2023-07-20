function out=docToReqSetMap(in,arg)



    persistent docReqSet
    if isempty(docReqSet)
        if exist(userMapFile(),'file')==2
            loaded=load(userMapFile());
            docReqSet=loaded.docReqSet;
        else
            docReqSet=containers.Map('KeyType','char','ValueType','char');
            docReqSet('DOC_NAME')='REQ_SET_NAME';
        end
    end

    if nargin==1
        if nargout>0
            if isKey(docReqSet,in)
                out=docReqSet(in);
            else
                out='';
            end
        elseif strcmpi(in,'clearAll')
            docReqSet=containers.Map('KeyType','char','ValueType','char');
            docReqSet('DOC_NAME')='REQ_SET_NAME';
            save(userMapFile(),'docReqSet');
        end
    elseif nargin==2
        if nargout==0
            if strcmp(arg,'clear')

                if docReqSet.isKey(in)
                    remove(docReqSet,in);
                    save(userMapFile(),'docReqSet');
                end
            else
                if docReqSet.isKey(in)&&strcmp(docReqSet(in),arg)
                    return;
                else
                    docReqSet(in)=arg;
                    save(userMapFile(),'docReqSet');
                end
            end
        else




            reqSetPaths=docReqSet.values();
            reqSetIdx=find(strcmp(reqSetPaths,in));
            lookupName=slreq.uri.getShortNameExt(arg);
            if isempty(reqSetIdx)
                out='';
            else
                lostDocs={};
                docs=docReqSet.keys();
                reqSetDocs=docs(reqSetIdx);
                for i=1:numel(reqSetDocs)
                    oneDoc=reqSetDocs{i};
                    shortDocName=slreq.uri.getShortNameExt(oneDoc);
                    if strcmp(shortDocName,lookupName)
                        if exist(oneDoc,'file')
                            out=oneDoc;
                            return;
                        else
                            lostDocs{end+1}=oneDoc;%#ok<AGROW>
                            continue;
                        end
                    end
                end
                out='';
                if~isempty(lostDocs)

                    docReqSet.remove(reqSetDocs);
                    save(userMapFile(),'docReqSet');
                end


            end
        end
    else
        error('Invalid usage: nargin=%d, nargout=%d',nargin,nargout);
    end
end

function out=userMapFile()
    out=fullfile(prefdir,'rmi_imported.mat');
end

