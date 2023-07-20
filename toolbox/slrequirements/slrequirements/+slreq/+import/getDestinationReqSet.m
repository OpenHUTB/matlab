function reqSet=getDestinationReqSet(reqSetArg,docId)




    reqSet=[];


    if isempty(reqSetArg)
        [~,reqSetArg]=fileparts(docId);
    end

    if ischar(reqSetArg)
        reqSet=slreq.data.ReqData.getInstance.getReqSet(reqSetArg);
        if isempty(reqSet)

            if contains(reqSetArg,'.slreqx')
                reqSetFile=fullfile(pwd,reqSetArg);
            else
                reqSetFile=fullfile(pwd,[reqSetArg,'.slreqx']);
            end
            if slreq.import.isWrongReqSet(reqSetFile,docId)
                return;
            else
                reqSet=slreq.internal.newReqSet(reqSetFile);
            end
        elseif slreq.import.isWrongReqSet(reqSet.filepath,docId)

            reqSet=[];
            return;
        end
    elseif isa(reqSetArg,'slreq.data.RequirementSet')
        if slreq.import.isWrongReqSet(reqSetArg.filepath,docId)
            return;
        else
            reqSet=reqSetArg;
        end
    elseif isa(reqSetArg,'slreq.ReqSet')
        if slreq.import.isWrongReqSet(reqSetArg.Filepath,docId)
            return;
        else
            reqSet=slreq.data.ReqData.getInstance.getReqSet(reqSetArg.Filename);
        end
    end
end

