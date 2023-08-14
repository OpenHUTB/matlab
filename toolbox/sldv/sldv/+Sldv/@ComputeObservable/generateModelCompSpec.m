




function compSpec=generateModelCompSpec(obj,idx)
    compSpec=struct([]);

    modelName=obj.CovDependency(idx).MdlName;
    if isempty(obj.CovDependency(idx).Dependency)
        return;
    end


    oc=init(modelName);%#ok<NASGU>

    specCounter_g=0;
    sortedSIDList=getSortedSIDList(obj,modelName);
    numBlks=length(sortedSIDList);




    for i=1:length(sortedSIDList)
        blkName=sortedSIDList{numBlks-i+1};
        blockH=obj.getHandle(blkName);
        [toSkip,blkIdx]=getCovDepBlkId(obj,idx,blkName);
        if toSkip
            continue;
        end
        covdep=obj.CovDependency(idx).Dependency(blkIdx);



        [covdep,nwSpecId,specCounter_g]=networkPropagationSpec(obj,idx,covdep,specCounter_g);



        [covdep,specCounter_g]=blkPropagationSpec(obj,blockH,covdep,nwSpecId,...
        specCounter_g);


        [covdep,specCounter_g]=blkCovDetectionSpec(obj,idx,blockH,covdep,...
        nwSpecId,specCounter_g);

        obj.CovDependency(idx).Dependency(blkIdx)=covdep;
    end



    compSpec=generateCompSpec(obj,idx);

end

function toSkip=skipDetectionConditions(obj,blockH)

    toSkip=false;





    if((strcmp(get_param(blockH,'BlockType'),'SubSystem')&&...
        ~obj.isSubSystemPenetrable(blockH)&&...
        ~obj.isActionSubSystem(blockH)&&...
        ~obj.isConditionalSubsystem(blockH))||...
        strcmp(get_param(blockH,'BlockType'),'DataStoreRead'))
        toSkip=true;
    end

end

function[toSkip,blkId]=getCovDepBlkId(obj,idx,blkName)
    [blkFound,blkId]=find(strcmp({obj.CovDependency(idx).Dependency.BlkName},blkName));
    if isempty(blkFound)

        toSkip=true;
        return;
    end
    blockH=obj.getHandle(blkName);
    toSkip=skipDetectionConditions(obj,blockH);
end

function out=isDetSiteBelongsToPotDetSite(detectionSites)
    out=false;
    for i=1:length(detectionSites)
        if detectionSites(i).UserProvidedDetSite
            out=true;
            return;
        end
    end
end





function detectionSites=updateDetectionSite(covdep,detectionSites)
    dsite=covdep.detectionSites;
    if~isempty(detectionSites)
        for i=1:length(dsite)
            for j=1:length(detectionSites)
                found=false;
                if strcmp(dsite(i).detectionPoint,detectionSites(j).detectionPoint)
                    if dsite(i).Port==detectionSites(j).Port
                        found=true;
                        break;
                    end
                end
            end
            if~found
                detectionSites(end+1)=dsite(i);
            end
        end
    else
        detectionSites=dsite;
    end
end



















function[covdep,nwSpecId,specCounter_g]=networkPropagationSpec(obj,idx,covdep,specCounter_g)

    numOutports=covdep.numOutports;
    outportInfo=covdep.OutportInfo;

    combineNwSpecIds=[];
    detectionSites=struct([]);
    potDeSiteForDestFound=false;
    anyOutportPotDetSite=false;
    anyOutportConnectedToStopBlk=false;

    for j=1:numOutports
        if~obj.usePotentialDetectionSites
            if~isempty(covdep.outportConnectedToStopBlock{j})&&...
                covdep.outportConnectedToStopBlock{j}
                anyOutportConnectedToStopBlk=true;
                break;
            end
        else
            if~isempty(covdep.outportPotDetSite{j})&&...
                covdep.outportPotDetSite{j}
                anyOutportPotDetSite=true;
            end
        end
        destBlks=outportInfo{j,1};
        for k=1:length(destBlks)
            blkId=destBlks(k).Id;
            port=destBlks(k).inport;


            covdepDest=obj.CovDependency(idx).Dependency(blkId);
            specId=covdepDest.nonMaskSpec(port).nonMaskSpecId;

            if specId==-1&&~obj.usePotentialDetectionSites























                combineNwSpecIds=[];
                detectionSites=updateDetectionSite(covdepDest,struct([]));
                break;
            else
                if~obj.usePotentialDetectionSites
                    combineNwSpecIds(end+1)=specId;
                    covdepDest.nonMaskSpec(port).Used=true;

                    obj.CovDependency(idx).Dependency(blkId)=covdepDest;
                    detectionSites=updateDetectionSite(covdepDest,detectionSites);
                else
                    if isDetSiteBelongsToPotDetSite(covdepDest.detectionSites)
                        if potDeSiteForDestFound


                            if specId~=-1
                                combineNwSpecIds(end+1)=specId;
                                covdepDest.nonMaskSpec(port).Used=true;
                                obj.CovDependency(idx).Dependency(blkId)=covdepDest;
                                detectionSites=updateDetectionSite(covdepDest,detectionSites);
                            else


                                combineNwSpecIds=[];
                                detectionSites=updateDetectionSite(covdepDest,struct([]));
                            end

                        else




                            combineNwSpecIds=specId;
                            covdepDest.nonMaskSpec(port).Used=true;
                            obj.CovDependency(idx).Dependency(blkId)=covdepDest;
                            detectionSites=updateDetectionSite(covdepDest,struct([]));
                            potDeSiteForDestFound=true;
                        end
                    else


                        if~potDeSiteForDestFound



                            if specId==-1


                                combineNwSpecIds=[];
                                detectionSites=updateDetectionSite(covdepDest,struct([]));
                            else
                                combineNwSpecIds(end+1)=specId;
                                covdepDest.nonMaskSpec(port).Used=true;
                                obj.CovDependency(idx).Dependency(blkId)=covdepDest;
                                detectionSites=updateDetectionSite(covdepDest,detectionSites);
                            end
                        else



                        end
                    end
                end
            end

        end
    end

    if anyOutportPotDetSite||anyOutportConnectedToStopBlk






        combineNwSpecIds=[];
        detectionSites=struct([]);
    end


    if isempty(detectionSites)




        if~obj.isGeneratedSID(covdep.BlkName)
            if numOutports>0
                for outportNum=1:numOutports
                    if obj.usePotentialDetectionSites
                        if~isempty(covdep.outportPotDetSite{outportNum})&&...
                            covdep.outportPotDetSite{outportNum}
                            if isempty(detectionSites)
                                detectionSites=struct('detectionPoint',covdep.BlkName,...
                                'Port',outportNum);
                            else
                                detectionSites(end+1).detectionPoint=covdep.BlkName;
                                detectionSites(end).Port=outportNum;
                            end
                            detectionSites(end).UserProvidedDetSite=1;
                        else
                            if~anyOutportPotDetSite
                                if isempty(detectionSites)
                                    detectionSites=struct('detectionPoint',covdep.BlkName,...
                                    'Port',outportNum);
                                else
                                    detectionSites(end+1).detectionPoint=covdep.BlkName;
                                    detectionSites(end).Port=outportNum;
                                end
                                detectionSites(end).UserProvidedDetSite=0;
                            end
                        end
                    else
                        if isempty(detectionSites)
                            detectionSites=struct('detectionPoint',covdep.BlkName,...
                            'Port',outportNum);
                        else
                            detectionSites(end+1).detectionPoint=covdep.BlkName;
                            detectionSites(end).Port=outportNum;
                        end
                    end
                end
            else
                detectionSites=struct('detectionPoint',covdep.BlkName,'Port',[]);
                if obj.usePotentialDetectionSites
                    detectionSites(end).UserProvidedDetSite=0;
                end
            end
        end
    end
    covdep.detectionSites=detectionSites;




    if~isempty(combineNwSpecIds)
        if length(combineNwSpecIds)==1
            covdep.networkSpec.nwCompSpecId=combineNwSpecIds;
            covdep.networkSpec.nwCompSpec=[];
            nwSpecId=combineNwSpecIds;
        else


            composeData.elem=[];
            composeData.compSpecIds=combineNwSpecIds;
            composeData.testObjective=false;
            composeData.conjunction=false;
            composeData.toStore=true;

            nwCompose=Sldv.ObjectiveSelection.sldvCompose(specCounter_g,composeData);

            covdep.networkSpec.nwCompSpecId=specCounter_g;
            covdep.networkSpec.nwCompSpec=nwCompose;
            nwSpecId=specCounter_g;
            specCounter_g=specCounter_g+1;
        end
    else
        nwSpecId=-1;
    end

end










function[covdep,specCounter_g]=blkPropagationSpec(obj,blockH,covdep,nwSpecId,specCounter_g)

    numInports=covdep.numInports;
    blkH=obj.getHandle(covdep.BlkName);

    for j=1:numInports
        if Sldv.ComputeObservable.blockHasSLDVCoverage(blockH,obj.testcomp)



            if~isempty(covdep.blkInputDependency(j).SrcBlk)

                elem=Sldv.ObjectiveSelection.sldvPickObjectives(...
                blkH,'covtype','blkcov','portId',j,...
                'blockType',1);%#ok<*AGROW>

                composeData=getComposeDataDefault();
                composeData.elem=elem;
                composeData.compSpecIds=nwSpecId;
                composeData.testObjective=false;
                composeData.conjunction=true;
                composeData.toStore=true;

                blockPortCompose=Sldv.ObjectiveSelection.sldvCompose(...
                specCounter_g,composeData);

                covdep.nonMaskSpec(j).nonMaskSpecId=specCounter_g;
                covdep.nonMaskSpec(j).nonMaskSpec=blockPortCompose;
                covdep.nonMaskSpec(j).Used=false;
                specCounter_g=specCounter_g+1;
            else
                covdep.nonMaskSpec(j).nonMaskSpecId=nwSpecId;
                covdep.nonMaskSpec(j).nonMaskSpec=[];
                covdep.nonMaskSpec(j).Used=false;
            end
        else
            if~obj.portSpecificStop(blockH,j)


                covdep.nonMaskSpec(j).nonMaskSpecId=nwSpecId;
            else
                covdep.nonMaskSpec(j).nonMaskSpecId=-1;
            end
            covdep.nonMaskSpec(j).nonMaskSpec=[];
            covdep.nonMaskSpec(j).Used=false;
        end
    end
end

function isSrcConditionInputDependent=checkIfSourceConditionOnInputOrOutputPorts(blkH)

    [~,~,callPerPort]=sldvprivate('getAccessInfoForObserveFunction',blkH);
    if callPerPort==1||callPerPort==0
        isSrcConditionInputDependent=true;
    else
        isSrcConditionInputDependent=false;
    end
end













function[covdep,specCounter_g]=getSourceSpec(obj,idx,blockH,covdep,specCounter_g,nwSpecId)

    numInports=covdep.numInports;
    numOutports=covdep.numOutports;
    outportInfo=covdep.OutportInfo;

    isSrcConditionInputDependent=checkIfSourceConditionOnInputOrOutputPorts(blockH);

    if isSrcConditionInputDependent
        for j=1:numInports
            elem=Sldv.ObjectiveSelection.sldvPickObjectives(...
            blockH,'covtype','blkcov','portId',j,...
            'blockType',0);%#ok<*AGROW>
            composeData=getComposeDataDefault();

            composeData.elem=elem;
            composeData.compSpecIds=nwSpecId;
            composeData.testObjective=true;
            composeData.conjunction=true;
            composeData.toStore=false;
            composeData.detectionSites=covdep.detectionSites;




            sourceSpec=Sldv.ObjectiveSelection.sldvCompose(...
            specCounter_g,composeData);

            covdep.sourceSpec(j).sourceSpecId=specCounter_g;
            covdep.sourceSpec(j).sourceSpec=sourceSpec;
            specCounter_g=specCounter_g+1;
        end
    end
    if~isSrcConditionInputDependent

        for j=1:numOutports
            destBlks=outportInfo{j,1};
            combineNwSpecIds=[];
            detectionSites=struct([]);
            for k=1:length(destBlks)

                blkId=destBlks(k).Id;
                port=destBlks(k).inport;


                covdepDest=obj.CovDependency(idx).Dependency(blkId);
                specId=covdepDest.nonMaskSpec(port).nonMaskSpecId;
                if~isempty(specId)&&specId~=-1
                    combineNwSpecIds(end+1)=specId;
                end
                detectionSites=updateDetectionSite(covdepDest,detectionSites);
            end
            if isempty(combineNwSpecIds)
                combineNwSpecIds=-1;
            end
            if isempty(detectionSites)






                if~obj.isGeneratedSID(covdep.BlkName)
                    detectionSites=struct('detectionPoint',covdep.BlkName,'Port',[]);
                end
            end
            elem=Sldv.ObjectiveSelection.sldvPickObjectives(...
            blockH,'covtype','blkcov','portId',j,...
            'blockType',0);%#ok<*AGROW>

            composeData=getComposeDataDefault();
            composeData.elem=elem;
            composeData.compSpecIds=combineNwSpecIds;
            composeData.testObjective=true;
            composeData.conjunction=true;
            composeData.toStore=false;
            composeData.detectionSites=detectionSites;




            sourceSpec=Sldv.ObjectiveSelection.sldvCompose(...
            specCounter_g,composeData);

            covdep.sourceSpec(j).sourceSpecId=specCounter_g;
            covdep.sourceSpec(j).sourceSpec=sourceSpec;
            specCounter_g=specCounter_g+1;
        end
    end

end




function[covdep,specCounter_g]=getCustomTestSpec(covdep,blockH,...
    specCounter_g,nwSpecId)

    testObjSFcnH=getCustomConditionSID(blockH);
    elem=Sldv.ObjectiveSelection.sldvPickObjectives(...
    testObjSFcnH,'covtype','','portId',1,...
    'blockType',-1);%#ok<*AGROW>

    composeData=getComposeDataDefault();

    composeData.elem=elem;
    composeData.compSpecIds=nwSpecId;
    composeData.testObjective=true;
    composeData.conjunction=true;
    composeData.toStore=false;
    composeData.detectionSites=covdep.detectionSites;
    sourceSpec=Sldv.ObjectiveSelection.sldvCompose(...
    specCounter_g,composeData);

    covdep.sourceSpec(1).sourceSpecId=specCounter_g;
    covdep.sourceSpec(1).sourceSpec=sourceSpec;
    specCounter_g=specCounter_g+1;
end













function[covdep,specCounter_g]=blkCovDetectionSpec(obj,idx,blockH,...
    covdep,nwSpecId,specCounter_g)




    if Sldv.ComputeObservable.blockHasSLDVCoverage(blockH,obj.testcomp)
        [covdep,specCounter_g]=getSourceSpec(obj,idx,blockH,...
        covdep,specCounter_g,nwSpecId);
    else
        if Sldv.ComputeObservable.isCustomAuthoredTestObjective(blockH,...
            obj.ModelName)
            [covdep,specCounter_g]=getCustomTestSpec(covdep,...
            blockH,specCounter_g,nwSpecId);
        end
    end
end

function actualBlkH=getCustomConditionSID(blkH)


    path=[get_param(blkH,'parent'),'/',get_param(blkH,'Name'),'/viewdvc/customAVTBlockSFcn'];
    actualBlkH=Simulink.ID.getSID(path);
end

function sortedHsList=getSortedList(modelName)




    sortedHsList=ExpandedSortedlist(get_param(modelName,'Handle'));
    sortedHsList=getParentForTheTestObjectiveChildren(sortedHsList);

    function sortedHs=ExpandedSortedlist(mdlH)
        sortedHs=[];
        thisObj=get_param(mdlH,'Object');
        thisList=thisObj.getSortedList;

        for i=1:length(thisList)
            sortedHs(end+1)=thisList(i);

            if strcmp(get_param(thisList(i),'BlockType'),'SubSystem')&&...
                (strcmp(get_param(thisList(i),'TreatAsAtomicUnit'),'on')||...
                strcmp(get_param(thisList(i),'IsSubsystemVirtual'),'off'))&&...
                ~slprivate('is_stateflow_based_block',thisList(i))





                childList=ExpandedSortedlist(thisList(i));
                sortedHs=[sortedHs,childList];

            end
        end
    end

    function sortedHsList=getParentForTheTestObjectiveChildren(sortedHsList)
        for idx=1:numel(sortedHsList)
            blkH=sortedHsList(idx);
            try
                parent=get_param(blkH,'Parent');
                parentH=get_param(parent,'Handle');


                if Sldv.ComputeObservable.isTestObjBlock(parentH)

                    sortedHsList(idx)=parentH;
                end
            catch Mex %#ok<NASGU>

            end
        end
    end
end

function compSpec=addToCompSpec(compSpec,newCompSpec)
    for i=1:length(newCompSpec)
        if isempty(compSpec)
            compSpec=[];
            compSpec.stmt=newCompSpec(i);
        else
            compSpec.stmt(end+1)=newCompSpec(i);
        end
    end
end


function oc=init(mdlName)

    Sldv.ComputeObservable.logDebugMsgs("ComputeObservable","generateModelCompSpec",...
    "generate Comp spec for Model::"+mdlName);

    simStatus=get_param(mdlName,'SimulationStatus');
    compStatus=strcmp(simStatus,'paused')||strcmp(simStatus,'initializing');

    if~compStatus
        feval(mdlName,[],[],[],'compile');
    end

    oc=onCleanup(@()cleanSetUp);

    function cleanSetUp()
        if~compStatus
            oc=onCleanup(@()feval(mdlName,[],[],[],'term'));
        end


        Sldv.ComputeObservable.logDebugMsgs("ComputeObservable","generateModelCompSpec",...
        "Completed generating Comp spec for Model::"+mdlName);
    end
end

function sortedSIDList=getSortedSIDList(obj,modelName)

    sortedSIDList=[];
    sortedHsList=getSortedList(modelName);
    for i=1:length(sortedHsList)
        sortedSIDList{i}=obj.getSID(sortedHsList(i));
    end

end



function compSpec=generateCompSpec(obj,idx)

    compSpec=[];
    dep=obj.CovDependency(idx).Dependency;
    for i=1:length(dep)
        covdep=dep(i);

        isSrcConditionInputDependent=checkIfSourceConditionOnInputOrOutputPorts(obj.getHandle(covdep.BlkName));
        if isSrcConditionInputDependent
            srcSpecCount=covdep.numInports;
        else
            srcSpecCount=covdep.numOutports;
        end

        for j=1:srcSpecCount
            if~isempty(covdep.sourceSpec(j).sourceSpec)
                compSpec=addToCompSpec(compSpec,covdep.sourceSpec(j).sourceSpec);
                if isSrcConditionInputDependent
                end
            end
        end
        numInports=covdep.numInports;

        for j=1:numInports
            if~isempty(covdep.nonMaskSpec(j).nonMaskSpec)&&(covdep.nonMaskSpec(j).Used)
                compSpec=addToCompSpec(compSpec,covdep.nonMaskSpec(j).nonMaskSpec);
            end
        end


        if~isempty(covdep.networkSpec.nwCompSpec)
            compSpec=addToCompSpec(compSpec,covdep.networkSpec.nwCompSpec);
        end
    end

    if~isempty(compSpec)

        stmtTable=struct2table(compSpec.stmt);
        sortedStmtTable=sortrows(stmtTable,'specId');

        compSpec.stmt=table2struct(sortedStmtTable);
    end
end

function composeData=getComposeDataDefault()
    composeData.elem=[];
    composeData.compSpecIds=[];
    composeData.testObjective=false;
    composeData.conjunction=false;
    composeData.toStore=false;
    composeData.detectionSites=[];
    composeData.specId=-1;
end


