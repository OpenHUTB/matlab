function[reqSet,isNewReqSet]=validateReqSetArg(destinationReqSet,doProxy,docPath,subDoc)

    reqSet=[];
    isNewReqSet=false;
    if nargin<4
        subDoc='';
    end

    if ischar(destinationReqSet)
        [reqSetDir,~,reqSetExt]=fileparts(destinationReqSet);
        if isempty(reqSetDir)
            if isempty(reqSetExt)
                destinationReqSetPath=fullfile(pwd,[destinationReqSet,'.slreqx']);
            else
                destinationReqSetPath=fullfile(pwd,destinationReqSet);
            end
        else
            destinationReqSetPath=destinationReqSet;
        end
        if doProxy
            if slreq.import.isWrongReqSet(destinationReqSetPath,docPath,subDoc)
                return;
            end
        else
            slreq.import.docToReqSetMap(docPath,destinationReqSetPath);
        end

        reqSet=slreq.data.ReqData.getInstance.getReqSet(destinationReqSetPath);
        if isempty(reqSet)
            reqSet=slreq.data.ReqData.getInstance.createReqSet(destinationReqSetPath);
            isNewReqSet=true;
        end
    else
        reqSet=destinationReqSet;
        destinationReqSetPath=reqSet.filepath;
        if doProxy
            if slreq.import.isWrongReqSet(destinationReqSetPath,docPath,subDoc)
                return;
            end
        else
            slreq.import.docToReqSetMap(docPath,destinationReqSetPath);
        end
    end
end
