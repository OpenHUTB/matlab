function srcSigIDs=getAllSourceSignal(h,portObj,includeEmpty)





















    srcSigIDs=[];
    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.fixedPoint);
    if hIsVirtualBus(h,portObj.Handle)
        virBusSource=portObj.getActualSrcForVirtualBus;
        if~isempty(virBusSource)
            hSource=getLeafsrcList(virBusSource);
        else
            hSource=portObj.getActualSrc;
        end
    else
        hSource=portObj.getActualSrc;
    end

    if~isempty(hSource)
        portObjVec=get_param(hSource(:,1),'Object');
        if~iscell(portObjVec)
            [srcSigID.blkObj,srcSigID.pathItem,srcSigID.srcInfo]=...
            getSourceSignal(h,portObjVec,true);
            if size(hSource,2)>3&&hSource(1,4)~=-1
                srcPortObj=portObjVec(1);
                attributes=srcPortObj.getCompiledAttributes(hSource(1,4));
                srcSigID.srcInfo=getSrcInfoFromAttributes(h,attributes);
            end
            if~isempty(srcSigID.blkObj)&&~isempty(srcSigID.pathItem)
                srcSigIDs{1}=srcSigID;
            end
        else
            srcIdx=1;
            for i=1:length(portObjVec)
                srcSigID=[];
                [srcSigID.blkObj,srcSigID.pathItem,srcSigID.srcInfo]=...
                getSourceSignal(h,portObjVec{i},true);
                if size(hSource(i,:),2)>3&&hSource(i,4)~=-1
                    srcPortObj=portObjVec{i};
                    attributes=srcPortObj.getCompiledAttributes(hSource(i,4));
                    srcSigID.srcInfo=getSrcInfoFromAttributes(h,attributes);
                end
                if includeEmpty||(~isempty(srcSigID.blkObj)&&...
                    ~isempty(srcSigID.pathItem))
                    srcSigIDs{srcIdx}=srcSigID;%#ok
                    srcIdx=srcIdx+1;
                end
            end
        end
    end




    function leafSrcList=getLeafsrcList(virBusSource)

        if isa(virBusSource,'containers.Map')
            myKeys=virBusSource.keys();
            leafSrcList=[];
            for i=1:length(myKeys)
                leafSrcList=[leafSrcList;...
                getLeafsrcList(virBusSource(myKeys{i}))];%#ok
            end
        else
            leafSrcList=virBusSource;
        end



        function srcInfo=getSrcInfoFromAttributes(h,attributes)

            srcInfo.busObjectName=h.hCleanDTOPrefix(attributes.parentBusObjectName);
            srcInfo.busElementName=attributes.eName;
