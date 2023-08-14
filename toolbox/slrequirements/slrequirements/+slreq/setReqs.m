




























function setReqs(varargin)

    [modelH,objH,isSf,isSigBuilder]=rmisl.resolveObj(varargin{1},true);
    newReqs=varargin{2};

    if nargin==3

        oldReqs=localSetReqs(objH,newReqs,varargin{3});
    elseif~isSigBuilder


        if nargin==4&&varargin{3}>0
            [oldReqs,replacedIdx]=localSetReqs(objH,newReqs,varargin{3:end});
            oldIdx=1:length(oldReqs);
            keptIdx=~ismember(oldIdx,replacedIdx);
            newReqs=[oldReqs(keptIdx);newReqs];


        else
            oldReqs=localSetReqs(objH,newReqs);
        end
    else



        [perGrpCnt,grpIdx,allReqs]=slreq.getSigbGrpData(objH);
        switch nargin
        case 4
            offset=varargin{3};
            cnt=varargin{4};
            if offset==-1&&cnt==-1&&isempty(newReqs)

                oldReqs=localSetReqs(objH,[],0);
            elseif offset>0&&cnt==-1

                oldReqs=localSetReqs(objH,newReqs,offset);
            else
                if offset>sum(perGrpCnt)


                    targetGroup=signalbuilder(objH,'activegroup');
                elseif cnt>0
                    targetGroup=grpIdx(offset);
                else








                    activeGroup=signalbuilder(objH,'activegroup');


                    if offset>sum(perGrpCnt(1:activeGroup-1))&&...
                        offset<=sum(perGrpCnt(1:activeGroup))+1
                        targetGroup=activeGroup;
                    else
                        targetGroup=grpIdx(offset);
                    end
                end
                cntBefore=length(find(grpIdx<targetGroup));
                if targetGroup>length(perGrpCnt)
                    cntHere=0;
                else
                    cntHere=perGrpCnt(targetGroup);
                end
                if cnt==0||(cnt==cntHere&&targetGroup==grpIdx(offset+cnt-1))

                    oldReqs=allReqs(grpIdx==targetGroup);
                    localSetReqs(objH,newReqs,targetGroup);
                elseif cnt==1&&length(newReqs)==1



                    inGroupOffset=offset-cntBefore;
                    oldReqs=allReqs(grpIdx==targetGroup);
                    updatedReqs=oldReqs;
                    updatedReqs(inGroupOffset)=newReqs;
                    oldReqs=oldReqs(inGroupOffset);
                    localSetReqs(objH,updatedReqs,targetGroup);
                elseif cnt==1&&isempty(newReqs)


                    oldReqs=allReqs(grpIdx==targetGroup);
                    newReqs=oldReqs;
                    newReqs(offset-cntBefore)=[];
                    localSetReqs(objH,newReqs,targetGroup);
                elseif offset==1&&cnt>0&&cnt==length(allReqs)&&cnt==length(newReqs)



                    oldReqs=allReqs;
                    localUpdateAllReqsInAllGroups(objH,newReqs,grpIdx);
                else
                    warning('Unsupported use case in setReqs() for Signal Builder (%d->%d:%d)',...
                    length(newReqs),offset,cnt);
                    return;
                end
            end
        case 2


            if length(newReqs)==length(allReqs)
                oldReqs=allReqs;
                localUpdateAllReqsInAllGroups(objH,newReqs,grpIdx);
            else
                warning(message('Slvnv:rmidata:setReqs:GroupsInfoMissing'));
                activeGroup=signalbuilder(objH,'activegroup');
                oldReqs=allReqs(grpIdx==activeGroup);
                localSetReqs(objH,newReqs,activeGroup);
            end
        otherwise
            warning('Unsupported use case in setReqs() for Signal Builder (%d args)',nargin);
            return;
        end
    end

    rmisl.postSetReqsUpdates(modelH,objH,isSf,oldReqs,newReqs);
    if isSigBuilder
        vnv_panel_mgr('sbUpdateReq',objH);
    end
end

function localUpdateAllReqsInAllGroups(objH,newReqs,grpIdx)
    groupsWithLinks=unique(grpIdx);
    for i=1:length(groupsWithLinks)
        thisGroup=groupsWithLinks(i);
        localSetReqs(objH,newReqs(grpIdx==thisGroup),thisGroup);
    end
end

function[oldReqs,replacedIdx]=localSetReqs(srcH,newReqs,varargin)
    src=slreq.utils.getRmiStruct(srcH);
    newReqs=slreq.uri.correctDestinationUriAndId(newReqs);
    switch length(varargin)
    case 0

        oldReqs=slreq.internal.setLinks(src,newReqs);
        replacedIdx=1:length(oldReqs);
    case 1

        grpNumber=varargin{1};
        if grpNumber>0
            src.id=sprintf('%s.%d',src.id,grpNumber);
            oldReqs=slreq.internal.setLinks(src,newReqs);
            replacedIdx=1:length(oldReqs);
        else


            [~,~,~,grpNames]=signalbuilder(srcH);
            oldReqs=[];
            updatedReqs=[];
            parentId=src.id;
            for i=1:length(grpNames)
                src.id=sprintf('%s.%d',parentId,i);
                updatedReqs=[updatedReqs;newReqs(:)];%#ok<AGROW>
                grpReqs=slreq.internal.setLinks(src,newReqs);
                oldReqs=[oldReqs;grpReqs(:)];%#ok<AGROW>
            end
            replacedIdx=1:length(oldReqs);
        end
    case 2

        oldReqs=slreq.internal.setLinks(src,newReqs,varargin{:});
        replacedIdx=varargin{1}:varargin{1}+varargin{2}-1;
    otherwise
        error('Unsupported use case in setReqs() for Signal Builder (%d optional args)',...
        length(varargin));
    end
end

