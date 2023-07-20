function[busObjHandleAndICList,busObjNameSet]=hGetAllBusObjHandleAndICListFromSigH(h,sigH,ICValue,isNonVirtualBus,busObjHandleMap,busObjNameSet)





    if nargin<6
        busObjNameSet=containers.Map();



    end

    ICValue=getCompressedICValue(ICValue);
    [busObjHandleAndICList,busObjNameSet]=getAllBusObjHandleAndICListFromSigH(h,sigH,ICValue,isNonVirtualBus,busObjHandleMap,busObjNameSet);


    function[busObjHandleAndICList,busObjNameSet]=getAllBusObjHandleAndICListFromSigH(h,sigH,ICValue,isNonVirtualBus,busObjHandleMap,busObjNameSet)


        busObjHandleAndICList=[];

        busObjectName=h.hCleanDTOPrefix(sigH.BusObject);


        if~isempty(busObjectName)


            if~busObjHandleMap.isKey(busObjectName)
                errorID='SimulinkFixedPoint:autoscaling:BusObjectHandleNotFoundInMap';
                DAStudio.error(errorID,busObjectName);
            end
            busObjHandle=busObjHandleMap.getDataByKey(h.hCleanDTOPrefix(sigH.BusObject));


            if isempty(ICValue)
                IC=[];

                if~busObjNameSet.isKey(busObjectName)

                    busObjHandleAndICList(1).busObjectHandle=busObjHandle;
                    busObjHandleAndICList(1).initCondition=IC;
                    busObjNameSet(busObjectName)=true;
                end
            else
                IC.value=ICValue;
                if isstruct(ICValue)&&~isNonVirtualBus
                    ICMapping=findLeafElementICMapping(busObjHandle,sigH);
                else
                    ICMapping=[];
                end
                IC.mapping=ICMapping;

                busObjHandleAndICList(1).busObjectHandle=busObjHandle;
                busObjHandleAndICList(1).initCondition=IC;
                if~busObjNameSet.isKey(busObjectName)

                    busObjNameSet(busObjectName)=true;
                end
            end


            nonLeafChildIndices=busObjHandle.nonLeafChildIndices;
        else


            numbOfChildren=length(sigH.Children);
            leafChildIndices=cellfun(@isempty,{sigH.Children.Children});
            nonLeafEle=ones(1,numbOfChildren)*true;
            nonLeafEle(leafChildIndices)=false;
            nonLeafChildIndices=find(nonLeafEle);
        end


        for i_nonLeafChildIndex=1:length(nonLeafChildIndices)
            nonLeafChildIndex=nonLeafChildIndices(i_nonLeafChildIndex);

            subSigH=sigH.Children(nonLeafChildIndex);


            if~isempty(ICValue)
                if isstruct(ICValue)



                    if isNonVirtualBus




                        fieldNameForSubIC=busObjHandle.elementNames{...
                        nonLeafChildIndex};
                    else
                        fieldNameForSubIC=sigH.Children(...
                        nonLeafChildIndex).SignalName;
                    end


                    if isfield(ICValue,fieldNameForSubIC)
                        subICValue=ICValue.(fieldNameForSubIC);
                    else
                        subICValue=[];
                    end
                else

                    subICValue=ICValue;
                end
            else

                subICValue=[];
            end




            [subBusObjHandleAndICList,busObjNameSet]=getAllBusObjHandleAndICListFromSigH(...
            h,subSigH,subICValue,isNonVirtualBus,busObjHandleMap,...
            busObjNameSet);


            busObjHandleAndICList=h.hAppendList(busObjHandleAndICList,...
            subBusObjHandleAndICList);

        end


        function ICMapping=findLeafElementICMapping(busObjHandle,sigH)


            ICMapping=[];

            leafChildIndices=busObjHandle.leafChildIndices;

            if isempty(leafChildIndices)
                return
            end

            leafBusEleNames=busObjHandle.elementNames(leafChildIndices);

            leafSigHChildren=sigH.Children(leafChildIndices);
            [leafSigNames{1:length(leafChildIndices)}]=deal(leafSigHChildren.SignalName);

            ICMapping=containers.Map(leafBusEleNames,leafSigNames);



            function y=getCompressedICValue(x)














                y=x;
                if isempty(x)||(isscalar(x)&&~isstruct(x))
                    return;
                end

                x_vec=x(:);

                if~isstruct(x_vec(1))
                    return;
                else
                    cStruct=struct();
                    fnames=fieldnames(x_vec(1));
                    nFields=length(fnames);

                    for i_field=1:nFields
                        cStruct.(fnames{i_field})=[];
                    end
                end

                arrayLength=length(x_vec);
                for arrayIndex=1:arrayLength
                    x_i=x_vec(arrayIndex);
                    for i_field=1:nFields
                        cStruct.(fnames{i_field})=[cStruct.(fnames{i_field}),x_i.(fnames{i_field})];
                    end
                end

                for i_field=1:nFields
                    cStruct.(fnames{i_field})=getCompressedICValue(cStruct.(fnames{i_field}));
                end

                y=cStruct;

