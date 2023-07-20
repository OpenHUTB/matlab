function[objH,parentIdx,isSf,isAnnotation]=getObjectHierarchy(modelH)




    allBlocks=find_system(modelH,'LookUnderMasks','all','MatchFilter',@Simulink.match.allVariants,...
    'IncludeCommented','on');


    if rmisl.isComponentHarness(modelH)
        cutSID=[get_param(modelH,'Name'),':1'];
        cutH=Simulink.ID.getHandle(cutSID);
        cutBlocks=find_system(cutH,'LookUnderMasks','all','MatchFilter',@Simulink.match.allVariants,...
        'IncludeCommented','on');
        allBlocks=setdiff(allBlocks,cutBlocks);
    end


    maskType=get_param(allBlocks(2:end),'MaskType');
    isSysReq=[false;strcmp(maskType,'System Requirements')];
    reqDispList=[];
    if any(isSysReq)
        dispBlockIdx=find(isSysReq);
        for idx=dispBlockIdx(:)'
            dispBlk=allBlocks(idx);


            dispConts=find_system(dispBlk,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all');
            dispBlkUD=get_param(dispBlk,'UserData');
            if isempty(dispBlkUD)
                childList=[];
            else
                childList=dispBlkUD.curReq;
            end
            if iscell(childList)
                childList=[childList{:}];
            end

            reqDispList=[reqDispList;dispConts(:);childList(:)];%#ok
        end

        [~,reqDispIdx]=rmiut.findidx(reqDispList,allBlocks);
        allBlocks(reqDispIdx)=[];

    end

    slBlockCnt=length(allBlocks);
    if slBlockCnt==2
        allBlockParents=[-1;get_param(get_param(allBlocks(2),'parent'),'Handle')];
    else
        allBlockParents=[{-1};get_param(get_param(allBlocks(2:end),'parent'),'Handle')];
        allBlockParents=[allBlockParents{:}]';
    end

    isSfBlks=slprivate('is_stateflow_based_block',allBlocks);
    sfIdx=find(isSfBlks);






    sfRefIdx=findSFRefs(allBlocks,sfIdx);

    objH=[];
    parH=[];
    isSf=false(0);
    startIdx=1;
    blocks2filter=[];

    for i=1:length(sfIdx)
        objH=[objH;allBlocks(startIdx:sfIdx(i))];%#ok
        parH=[parH;allBlockParents(startIdx:sfIdx(i))];%#ok
        isSf=[isSf;false(sfIdx(i)-startIdx+1,1)];%#ok


        startIdx=sfIdx(i)+1;





        if any(sfRefIdx==i)

            continue;
        end


        sfBlockH=objH(end);
        chartId=sf('Private','block2chart',sfBlockH);



        if isempty(chartId)||chartId<=0
            continue;
        end

        if~sf('Private','is_eml_chart',chartId)&&~sf('Private','is_truth_table_chart',chartId)...
            &&~sf('Private','is_requirement_chart',chartId)
            [sfObjH,sfParH]=sf_descendents(chartId);


            sfParH(sfParH==chartId)=sfBlockH;

            objH=[objH;sfObjH];%#ok
            parH=[parH;sfParH];%#ok
            isSf=[isSf;true(length(sfObjH),1)];%#ok
        end

        sfMaskChildren=find_system(sfBlockH,'LookUnderMasks','all','SearchDepth',1);
        sfMaskChildrenType=get_param(sfMaskChildren,'BlockType');
        sfMaskChildIsSubsys=strcmp(sfMaskChildrenType,'SubSystem');
        blocks2filter=[blocks2filter;sfMaskChildren(~sfMaskChildIsSubsys)];%#ok


        if any(strcmp(rmisf.sfBlockType(sfBlockH),{'Test Sequence','State Transition Table'}))
            keep=true(size(sfObjH));
            for j=1:length(sfObjH)

                if sf('get',sfObjH(j),'.isa')~=4
                    keep(j)=false;
                end
            end
            blocks2filter=[blocks2filter;sfObjH(~keep)];%#ok
        end
    end


    objH=[objH;allBlocks(startIdx:end)];
    parH=[parH;allBlockParents(startIdx:end)];
    isSf=[isSf;false(slBlockCnt-startIdx+1,1)];


    [~,filtIdx]=rmiut.findidx(blocks2filter,objH);
    objH(filtIdx)=[];
    parH(filtIdx)=[];
    isSf(filtIdx)=[];




    isAnnotation=false(size(objH));


    if rmipref('DoorsSyncAnnotations')
        modelObj=get_param(modelH,'Object');
        annotationsAndAreas=modelObj.find('-isa','Simulink.Annotation');
        if~isempty(annotationsAndAreas)
            for i=1:numel(annotationsAndAreas)
                anParentSys=annotationsAndAreas(i).Parent;
                anParentH=get_param(anParentSys,'Handle');
                anParentIdx=find(objH==anParentH);
                if isempty(anParentIdx)
                    continue;
                end
                objH=[objH(1:anParentIdx);annotationsAndAreas(i).Handle;objH(anParentIdx+1:end)];
                parH=[parH(1:anParentIdx);anParentH;parH(anParentIdx+1:end)];
                isSf=[isSf(1:anParentIdx);false;isSf(anParentIdx+1:end)];
                isAnnotation=[isAnnotation(1:anParentIdx);true;isAnnotation(anParentIdx+1:end)];
            end
        end



    end


    [uniquePar,~,idx2]=unique(parH(2:end));
    [~,uIdx]=rmiut.findidx(uniquePar,objH);
    parentIdx=[-1;uIdx(idx2)];

end

function[obj,par]=sf_descendents(objId)
    obj=[];
    par=[];

    substates=sf('AllSubstatesOf',objId);
    trans=sf('TransitionsOf',objId);
    trans=filter_virtual_trans(trans);


    [transPar,subTrans]=sf('get',trans,'.parent','.firstSubWire');
    trans(transPar~=objId)=[];
    subTrans(transPar~=objId)=[];





    trans(subTrans>0)=subTrans(subTrans>0);

    for state=substates(:)'
        obj=[obj;state];%#ok
        par=[par;objId];%#ok
        [decObj,decPar]=sf_descendents(state);
        obj=[obj;decObj];%#ok
        par=[par;decPar];%#ok
    end

    obj=[obj;trans(:)];
    par=[par;objId*ones(length(trans),1)];
end

function transIds=filter_virtual_trans(ids)
    simtrans=sf('find',ids,'transition.type','SIMPLE');
    supertrans=sf('find',ids,'transition.type','SUPER');
    transIds=[simtrans,supertrans]';
end















function slRefIdx=findSFRefs(allBlocks,sfIdx)

    refBlocks=get_param(allBlocks(sfIdx),'ReferenceBlock');
    isLibRef=~strcmp(refBlocks,'');
    slRefIdx=find(isLibRef);
end
