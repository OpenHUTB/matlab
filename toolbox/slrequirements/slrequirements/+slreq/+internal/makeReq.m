function reqStruct=makeReq(linkTarget,refObj)



    if nargin>1&&~isempty(refObj)&&strcmp(rmipref('DocumentPathReference'),'modelRelative')
        if ishandle(refObj)

            try
                refObj=get_param(rmisl.getmodelh(refObj),'FileName');
            catch ME %#ok<NASGU>
                refObj='';
            end
        elseif ischar(refObj)

            refObj=strtok(refObj,'|');

            if exist(refObj,'file')

            elseif rmisl.isSidString(refObj)
                mdlName=strtok(refObj,':');
                refObj=get_param(mdlName,'FileName');
            else
                refObj='';
            end
        else

            refObj='';
        end
    else


        refObj='';
    end

    reqStruct=rmi.createEmptyReqs(1);


    reqStruct.reqsys='linktype_rmi_slreq';
    reqStruct.id=sprintf('%d',linkTarget.sid);


    if strcmp(rmipref('DocumentPathReference'),'absolute')
        reqStruct.doc=linkTarget.getReqSet.filepath;
    elseif~isempty(refObj)
        refType=exist(refObj,'file');
        if refType==7
            reqStruct.doc=rmiut.relative_path(linkTarget.getReqSet.filepath,refObj);
        elseif refType>0
            reqStruct.doc=rmiut.relative_path(linkTarget.getReqSet.filepath,fileparts(refObj));
        else
            reqStruct.doc=[linkTarget.getReqSet.name,'.slreqx'];
        end
    else
        reqStruct.doc=[linkTarget.getReqSet.name,'.slreqx'];
    end

    reqSet=linkTarget.getReqSet();
    if~isempty(reqSet.parent)
        reqStruct.id=[linkTarget.getReqSet.name,'.slreqx~',num2str(linkTarget.sid)];
        [fPath,~,~]=fileparts(reqStruct.doc);
        reqStruct.doc=fullfile(fPath,reqSet.parent);
    end


    reqStruct.description='';




end
