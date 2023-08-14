function navigateToReq(obj,reqIndex)




    reqs=rmi.getReqs(obj);


    if reqIndex>length(reqs)

        [isSf,objH,~]=rmi.resolveobj(obj);
        if~isempty(objH)&&~isSf&&objH~=bdroot(objH)
            refBlk=get_param(objH,'ReferenceBlock');
            if~isempty(refBlk)
                refMdl=strtok(refBlk,'/');
                if~rmiut.isBuiltinNoRmi(refMdl)

                    load_system(refMdl);
                    rmi.navigateToReq(refBlk,reqIndex-length(reqs));
                    return;
                end
            elseif~isempty(get_param(bdroot(objH),'DataDictionary'))

                [ddReqs,ddNames,ddSources]=rmide.getVarReqsForObj(obj);
                if~isempty(ddReqs)&&reqIndex<=length(reqs)+length(ddReqs)
                    idx=reqIndex-length(reqs);
                    ddName=ddNames{idx};
                    myIdx=find(strcmp(ddNames,ddName));
                    otherVarCount=myIdx(1)-1;
                    ddSource=ddSources{idx};
                    ddPath=[ddSource,'|Global.',ddName];
                    rmi.navigateToReq(ddPath,reqIndex-length(reqs)-otherVarCount);
                    return;
                end
            end
        end

        error(message('Slvnv:reqmgt:rmi:InvalidRequirement'));
    end


    if rmide.isDataEntry(obj)
        if isa(obj,'Simulink.DDEAdapter')
            reference=rmide.getFilePath(obj);
        else
            fPath=rmide.resolveEntry(obj);
            reference=fileparts(fPath);
        end
    elseif rmifa.isFaultInfoObj(obj)

        modelH=rmifa.getTopModelFromObj(obj);
        safety.gui.GUIManager.getInstance.setFaultTableCurrentSelection(modelH,obj.Uuid);
        reference=modelH;
    elseif rmism.isSafetyManagerObj(obj)

        warndlg('TO BE IMPLEMENTED: navigate to safety manager');
        reference=[];
    else
        modelH=rmisl.getmodelh(obj);
        if strcmp(get_param(modelH,'reqHiLite'),'off')
            action_highlight('clear');
            [isSf,objH,~]=rmi.resolveobj(obj);
            if isSf
                updated_charts=action_highlight_sf('req',objH);
                if~isempty(updated_charts)

                    chartBlocks=sf('Private','chart2block',updated_charts);
                    for block=chartBlocks
                        action_highlight('reqInside',block);
                    end
                end
            else
                if rmisl.is_signal_builder_block(objH)
                    action_highlight('reqInside',objH);
                elseif modelH~=objH
                    action_highlight('reqHere',objH);
                end
            end
        end
        reference=modelH;
    end


    rmi.navigate(reqs(reqIndex).reqsys,reqs(reqIndex).doc,reqs(reqIndex).id,reference);
end
