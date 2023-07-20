function pairList=hGetLeafChildBusEleAndSrcPairList(h,...
    sigH,virBusSource,busObjHandleMap,alternateBusObjName)






















    pairList={};



    if isempty(alternateBusObjName)
        if isempty(sigH.BusObject)
            return;
        else
            busObjHandle=hGetBusObjHandleFromMap(h,...
            h.hCleanDTOPrefix(sigH.BusObject),busObjHandleMap);
        end
    else
        busObjHandle=hGetBusObjHandleFromMap(h,...
        alternateBusObjName,busObjHandleMap);
    end


    if isa(virBusSource,'containers.Map')

        leafChildIndices=busObjHandle.leafChildIndices;


        for i=1:length(leafChildIndices)

            leafSigName=sigH.Children(leafChildIndices(i)).SignalName;

            if virBusSource.isKey(leafSigName)

                hSource=virBusSource(leafSigName);


                portObj=get_param(hSource(1),'Object');
                if size(hSource,2)>3&&hSource(1,4)~=-1
                    attributes=portObj.getCompiledAttributes(hSource(1,4));
                    srcInfo.busObjectName=h.hCleanDTOPrefix(attributes.parentBusObjectName);
                    srcInfo.busElementName=attributes.eName;
                else
                    srcInfo=[];
                end


                if get_param(hSource(1),'CompiledPortBusMode')~=1





                    busSrcSigID=[];
                    [busSrcSigID.blkObj,busSrcSigID.pathItem,busSrcSigID.srcInfo]=...
                    getSourceSignal(h,portObj,true);
                    if~isempty(busSrcSigID.blkObj)&&~isempty(busSrcSigID.pathItem)
                        busObjSigID.pathItem=...
                        busObjHandle.elementNames{leafChildIndices(i)};
                        busObjSigID.blkObj=busObjHandle;
                        pair={busSrcSigID,busObjSigID};
                        pairList=h.hAppendToSharedLists(pairList,pair);
                    end

                else













                    hidSrc=hGetHiddenNonVirBusSrc(h,portObj,true);
                    if~isempty(hidSrc)
                        hidSrc.srcInfo=srcInfo;
                        pairList=h.hAppendToSharedLists(pairList,{hidSrc});
                    end
                end
            else


                errorID='SimulinkFixedPoint:autoscaling:UnRecognizedSigNameInVirBusSource';
                DAStudio.error(errorID,leafSigName);
            end
        end
    end


    nonLeafChildIndices=busObjHandle.nonLeafChildIndices;
    for i=1:length(nonLeafChildIndices)

        nonLeafSigH=sigH.Children(nonLeafChildIndices(i));
        nonLeafSigName=nonLeafSigH.SignalName;
        nonLeafSigBusObjName=h.hCleanDTOPrefix(nonLeafSigH.BusObject);


        subAlternateBusName=busObjHandle.specifiedDTs{nonLeafChildIndices(i)};
        subAlternateBusName=h.hCleanBusName(subAlternateBusName);


        if strcmp(subAlternateBusName,nonLeafSigBusObjName)||...
            isempty(nonLeafSigBusObjName)






            if isa(virBusSource,'containers.Map')
                if virBusSource.isKey(nonLeafSigName)

                    nonLeafVirtualBusSrc=virBusSource(nonLeafSigName);


                    subPairList=hGetLeafChildBusEleAndSrcPairList(h,...
                    nonLeafSigH,nonLeafVirtualBusSrc,busObjHandleMap,...
                    subAlternateBusName);


                    pairList=h.hAppendToSharedLists(pairList,subPairList);
                else


                    errorID='SimulinkFixedPoint:autoscaling:UnRecognizedSigNameInVirBusSource';
                    DAStudio.error(errorID,nonLeafSigName);
                end
            end
        else




            pairList=h.hAppendToSharedLists(pairList,...
            hGetMatchingPairListForTwoBusObjects(h,...
            nonLeafSigBusObjName,subAlternateBusName,busObjHandleMap)...
            );
        end
    end
end


