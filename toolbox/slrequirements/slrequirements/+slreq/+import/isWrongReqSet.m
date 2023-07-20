function tf=isWrongReqSet(destinationReqSetPath,docPath,subDoc)




    tf=false;
    if contains(destinationReqSetPath,'SCRATCH.slreqx')


        return;
    end

    if nargin<3


        subDoc='';
    end


    [~,fName,~]=fileparts(docPath);


    if~isempty(subDoc)
        fName=[fName,'!',subDoc];
    end



    sameDocReqSet=false;
    reqSet=slreq.data.ReqData.getInstance.getReqSet(destinationReqSetPath);
    if~isempty(reqSet)
        topItems=reqSet.children;
        for n=1:length(topItems)
            topItem=topItems(n);



            if topItem.external&&strcmp(topItem.customId,fName)
                sameDocReqSet=true;
                break;
            end
        end
    end

    if sameDocReqSet
        tf=true;
        msgBody=getString(message('Slvnv:slreq_import:ImportingSameDocSameReqSetError'));
        errordlg(msgBody,getString(message('Slvnv:slreq:Error')))
        return;
    end

    previousReqSet=slreq.import.docToReqSetMap(docPath);
    if isempty(previousReqSet)
        slreq.import.docToReqSetMap(docPath,destinationReqSetPath);
    elseif~strcmp(previousReqSet,destinationReqSetPath)
        response=questdlg({...
        getString(message('Slvnv:slreq_import:DocWasImportedInto',docPath,previousReqSet)),...
        getString(message('Slvnv:slreq_import:ConsiderReusing')),...
        '',...
        getString(message('Slvnv:slreq_import:DisregardAndContinueQ'))},...
        getString(message('Slvnv:slreq_import:DocToReqSetMismatchTitle')),...
        getString(message('Slvnv:slreq_import:Continue')),...
        getString(message('Slvnv:slreq_import:Cancel')),...
        getString(message('Slvnv:slreq_import:Cancel')));
        if isempty(response)||strcmp(response,'Cancel')
            tf=true;
        else

            slreq.import.docToReqSetMap(docPath,destinationReqSetPath);
        end
    end
end
