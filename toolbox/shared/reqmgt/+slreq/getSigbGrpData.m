



















function[grpReqCnt,groupIdx,reqs]=getSigbGrpData(sigbH,doConvert)
    if nargin<2
        doConvert=true;
    end

    grpReqCnt=[];
    groupIdx=[];
    reqs=[];

    if ischar(sigbH)
        sigbSID=sigbH;
    else
        sigbSID=Simulink.ID.getSID(sigbH);
    end

    [modelName,itemId]=strtok(sigbSID,':');

    if rmisl.isComponentHarness(modelName)

        sigbObj=get_param(sigbH,'Object');
        if Simulink.harness.internal.sidmap.isObjectOwnedByCUT(sigbObj)
            sigbObj=rmisl.harnessToModelRemap(sigbObj);
            sigbSID=Simulink.ID.getSID(sigbObj);
            [modelName,itemId]=strtok(sigbSID,':');
        else
            harnessInfo=Simulink.harness.internal.getHarnessInfoForHarnessBD(modelName);
            modelName=harnessInfo.model;
            itemId=[':',harnessInfo.uuid,itemId];
        end
    end

    artifactUri=get_param(modelName,'FileName');
    linkSet=slreq.data.ReqData.getInstance.getLinkSet(artifactUri);

    if~isempty(linkSet)

        filter={'id',['^',itemId,'\.\d']};
        groupItems=linkSet.getLinkedItems(filter);
        if isempty(groupItems)
            return;
        end

        for i=1:numel(groupItems)
            links=groupItems(i).getLinks;
            if isempty(links)
                continue;
            end
            id=groupItems(i).id;
            dot=find(id=='.');
            grpIdx=str2num(id(dot(end)+1:end));%#ok<ST2NM>
            groupIdx=[groupIdx;ones(numel(links),1)*grpIdx];%#ok<AGROW>
            if nargout>2
                if doConvert
                    reqs=[reqs;slreq.utils.linkToStruct(links)];%#ok<AGROW>
                else
                    reqs=[reqs;links'];%#ok<AGROW>
                end
            end
        end

        if~isempty(groupIdx)


            lastGroup=max(groupIdx);
            grpReqCnt=zeros(1,lastGroup);
            for i=1:lastGroup
                grpReqCnt(i)=sum(groupIdx==i);
            end


            [groupIdx,permute]=sort(groupIdx);
            if nargout>2
                reqs=reqs(permute);
            end
        end
    end

end



