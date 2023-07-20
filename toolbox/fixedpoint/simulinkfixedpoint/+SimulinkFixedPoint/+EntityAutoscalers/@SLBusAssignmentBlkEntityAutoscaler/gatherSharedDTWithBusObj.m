function sharedLists=gatherSharedDTWithBusObj(h,blkObj,pathItem,busObjHandleMap)%#ok




    sharedLists={};






    assignedSignalStr=blkObj.AssignedSignals;
    listOfAssignedSignals=regexp(assignedSignalStr,',','split');


    ph=blkObj.PortHandles;


    inportHandles=ph.Inport;
    targetBusSigHier=get_param(inportHandles(1),'SignalHierarchy');



    for assignListIdx=1:length(listOfAssignedSignals)

        busSignalName=listOfAssignedSignals{assignListIdx};

        assignmentInportHandle=inportHandles(assignListIdx+1);
        assignmentInportObject=get_param(assignmentInportHandle,'Object');

        if assignmentInportObject.CompiledPortBusMode==1

            if hIsNonVirtualBus(h,assignmentInportHandle)
                hidSrc=hGetHiddenNonVirBusSrc(h,assignmentInportObject,false);
                if~isempty(hidSrc)

                    sharedLists=h.hAppendToSharedLists(sharedLists,{hidSrc});
                end
            else
                virBusSource=assignmentInportObject.getActualSrcForVirtualBus;




                assignmentInportSigH=get_param(assignmentInportHandle,'SignalHierarchy');
                pairList=hGetLeafChildBusEleAndSrcPairList(h,...
                assignmentInportSigH,virBusSource,busObjHandleMap,[]);
                sharedLists=h.hAppendToSharedLists(sharedLists,pairList);
            end
        else





            busObjID=hGetAssociatedBusObjElementForLeafSigName(h,targetBusSigHier,...
            busSignalName,busObjHandleMap);



            if~isempty(busObjID)


                assignmentInportObject=get_param(assignmentInportHandle,'Object');


                [srcSigID.blkObj,srcSigID.pathItem,srcSigID.srcInfo]=...
                getSourceSignal(h,assignmentInportObject);


                oneList={busObjID,srcSigID};
                sharedLists=h.hAppendToSharedLists(sharedLists,oneList);
            end
        end
    end




