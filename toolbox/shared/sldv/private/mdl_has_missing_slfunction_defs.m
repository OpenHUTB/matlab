function[hasMissingFunctions,errMsg]=mdl_has_missing_slfunction_defs(mRootModel)









    hasMissingFunctions=false;
    errMsg=[];





    assert(strcmp(get_param(mRootModel,'type'),'block_diagram'),...
    'Input should be of type block_diagram');



    existingStubbedSubSytem=Simulink.findBlocksOfType(mRootModel,'SubSystem','Tag','_Harness_SLFunc_Stub_');
    if~isempty(existingStubbedSubSytem)
        return;
    end

    if~isa(mRootModel,'double')
        mRootModel=get_param(mRootModel,'Handle');
    end




    models=find_mdlrefs(mRootModel,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'KeepModelsLoaded',true);
    fcnCallerBlkHs=[];

    for i=1:numel(models)


        fOpts=Simulink.FindOptions('MatchFilter',@Sldv.utils.findBSWServiceComponentBlks,...
        'IncludeCommented',false,'FollowLinks',true);
        existingServiceComponent=Simulink.findBlocksOfType(models{i},'SubSystem',fOpts);
        if~isempty(existingServiceComponent)
            errMsg.identifier='Sldv:Compatibility:UnsupportedServiceComponentBlock';
            errMsg.message=getString(message(errMsg.identifier,getfullname(models{i})));
            return;
        end

        fOpts=Simulink.FindOptions("IncludeCommented",false,'FollowLinks',true);




        fcnCallerBlkHs=[fcnCallerBlkHs;Simulink.findBlocksOfType(models{i},'FunctionCaller',fOpts)];%#ok<AGROW> 
    end

    fcnPrototypes=get_param(fcnCallerBlkHs,'FunctionPrototype');
    fcnPrototypes=string(fcnPrototypes);
    hasQualifier=false(1,numel(fcnPrototypes));
    for fcnIdx=1:numel(fcnPrototypes)

        fcnPrototypes(fcnIdx)=regexprep(fcnPrototypes(fcnIdx),'\s','');

        if contains(fcnPrototypes(fcnIdx),'.')




            hasQualifier(fcnIdx)=true;
        end
    end
    fcnPrototypes(hasQualifier)=[];


    existingFcns=checkForDefinedFunctions(models);


    missingFcnIdx=~ismember(fcnPrototypes,existingFcns);
    hasMissingFunctions=any(missingFcnIdx);
end

function existingFcnDefs=checkForDefinedFunctions(models)

    mdlFcns=cell(1,numel(models));
    fOpts=Simulink.FindOptions("IncludeCommented",false);
    fcnCount=0;
    for mIdx=1:numel(models)
        mdlH=get_param(models{mIdx},'Handle');
        ssBlks=Simulink.findBlocksOfType(mdlH,'SubSystem',fOpts);
        fcnDefs=cell(1,numel(ssBlks)+1);

        fcnDefs{1}=Simulink.harness.internal.getFunctionPrototypeStrings(mdlH,-1);
        currMdlFcnCount=numel(fcnDefs{1});
        for idx=1:numel(ssBlks)
            fcnDefs{idx+1}=Simulink.harness.internal.getFunctionPrototypeStrings(mdlH,ssBlks(idx));
            currMdlFcnCount=currMdlFcnCount+numel(fcnDefs{idx+1});
        end
        mdlFcns{mIdx}=fcnDefs;
        fcnCount=fcnCount+currMdlFcnCount;
    end



    existingFcnDefs=cell(1,fcnCount);
    currCount=0;
    for idx=1:numel(mdlFcns)
        currMdlFcns=mdlFcns{idx};
        for lvlIdx=1:numel(currMdlFcns)
            if isempty(currMdlFcns{lvlIdx})
                continue;
            end
            currLvlFcns=currMdlFcns{lvlIdx};
            for fIdx=1:numel(currLvlFcns)
                existingFcnDefs{currCount+1}=string(currLvlFcns{fIdx});
                currCount=currCount+1;
            end
        end
    end

    existingFcnDefs=regexprep(string(existingFcnDefs),'\s','');
end


