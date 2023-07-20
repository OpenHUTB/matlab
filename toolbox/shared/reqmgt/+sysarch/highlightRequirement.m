

function highlightRequirement(selections)
    resolved={};
    reqData=slreq.data.ReqData.getInstance();

    try
        appmgr=slreq.app.MainManager.getInstance;
        [~,~,currentCanvasModel]=slreq.utils.DAStudioHelper.getCurrentBDHandle;
        spObj=appmgr.getCurrentSpreadSheetObject(currentCanvasModel);


        if isempty(spObj)
            return;
        end

        for n=1:length(selections)
            selection=selections{n};










            if Simulink.harness.internal.sidmap.isObjectOwnedByCUT(selection)
                try
                    selection=rmisl.harnessToModelRemap(selection);
                catch Mex %#ok<NASGU>




                end
            end



            selectHandle=selection.Handle;
            selection=slreq.utils.getRMISLTarget(selectHandle,false,true);
            selection=get(selection,'Object');

            if isa(selection,'Simulink.Block')
                linkInfo=slreq.utils.getRmiStruct(selection.Handle);
                linkSet=reqData.getLinkSet(linkInfo.artifact);
            else
                linkSet=[];
            end
            if~isempty(linkSet)
                srcItem=linkSet.getLinkedItem(linkInfo.id);
                if~isempty(srcItem)
                    links=srcItem.getLinks;
                    for m=1:length(links)
                        link=links(m);
                        dasLink=link.getDasObject();
                        if~isempty(dasLink)
                            resolved{end+1}=dasLink;%#ok<AGROW>
                        end
                        linkDest=link.dest;

                        if~isempty(linkDest)
                            dasReq=linkDest.getDasObject();
                            if~isempty(dasReq)
                                resolved{end+1}=dasReq;%#ok<AGROW>
                            end
                        end
                    end
                end
            end

        end


        spObj.mComponent.highlight(resolved);

    catch ex %#ok<NASGU>

    end


end

