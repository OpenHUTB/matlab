function breakDisabled(obj)






    [modelH,objH,isSf,isSigBuilder]=rmisl.resolveObj(obj);
    if rmidata.isExternal(modelH)&&~isSf

        srcSID=get_param(objH,'BlockCopiedFrom');
        if isempty(srcSID)
            return;
        else

            [reqs,grps]=rmidata.getDataForSid(srcSID,isSigBuilder);

            if~isempty(reqs)
                if license('test','Simulink_Requirements')
                    if isSigBuilder
                        groupsWithLinks=unique(grps);
                        for i=1:length(groupsWithLinks)
                            slreq.setReqs(objH,reqs(grps==i),i);
                        end
                        slreq.utils.clearAllForSrc(srcSID,true);
                    else
                        slreq.setReqs(objH,reqs);
                        slreq.utils.clearAllForSrc(srcSID,false);
                    end
                else





                    if isSigBuilder
                        slreq.utils.clearAllForSrc(srcSID,true);
                    else
                        slreq.utils.clearAllForSrc(srcSID,false);
                    end
                end
            end
        end
    end

    if~rmidata.isExternal(modelH)


        set_param(modelH,'GUIDTable',[]);
    end
end




