function postSetReqsUpdates(modelH,objH,isSf,oldReqs,newReqs)




    isLocked=~rmisl.isUnlocked(modelH,0);
    if isLocked
        Simulink.harness.internal.setBDLock(modelH,false);
    end


    if~isSf&&isDiagram(objH)
        state_of_dirty=get_param(modelH,'dirty');
        labelsOnly=(length(oldReqs)==length(newReqs));
        rmidispblock('updatesys',objH,~labelsOnly);
        if strcmp(state_of_dirty,'off')
            set_param(modelH,'dirty','off');
        end
    end





    if length(newReqs)~=length(oldReqs)
        rmisl.blockTable(modelH,'clear',[]);
    end


    rmi_highlighting_on=strcmp(get_param(modelH,'ReqHilite'),'on');
    if~rmi_highlighting_on

        action_highlight('clear');
    end





    if objH~=modelH
        if rmi_highlighting_on
            if hasRealReqLink(oldReqs)||hasRealReqLink(newReqs)
                rmisl.highlightReqChanges(objH,isSf,newReqs,rmi_highlighting_on);
                if isLocked



                    if isSf
                        sfrt=sfroot;
                        object=sfrt.idToHandle(objH);
                    else
                        object=get_param(objH,'Object');
                    end
                    harnessObjSid=Simulink.harness.internal.sidmap.getOwnerObjectSIDInHarness(object);
                    if~isempty(harnessObjSid)
                        harnessObj=Simulink.ID.getHandle(harnessObjSid);
                        if isSf
                            harnessObj=harnessObj.Id;
                        end
                        rmisl.highlightReqChanges(harnessObj,isSf,newReqs,rmi_highlighting_on);
                    end
                end
            end
        else
            rmiut.hiliteAndFade(objH);
        end
    end


    if exist('rmi.Informer','class')==8&&rmi.Informer.isVisible()
        rmi.Informer.updateEntry(objH,newReqs,isSf);
        rmi.Informer.invalidateSummary(objH,isSf);
    end

    if isLocked
        Simulink.harness.internal.setBDLock(modelH,true);
    end

end

function result=isDiagram(objH)
    blockType=get_param(objH,'Type');
    switch blockType
    case 'block_diagram'
        result=true;
    case 'annotation'
        result=false;
    otherwise
        if strcmp(get_param(objH,'BlockType'),'SubSystem')
            result=true;
        else
            result=false;
        end
    end
end


function result=hasRealReqLink(reqs)

    if isempty(reqs)
        result=false;
    elseif length(reqs)>1
        result=true;
    elseif reqs(1).linked;
        result=true;
    else
        result=false;
    end
end
