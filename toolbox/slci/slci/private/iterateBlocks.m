function ftFinalList=iterateBlocks(system,blockTypes)



    ftFinalList={};
    modelObj=getSLCIModelObj();
    finalResult=true;
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    for i=1:numel(blockTypes)
        [result,ft]=getSubcheckForBlockType(blockTypes{i},modelObj,mdladvObj);
        ftFinalList=[ftFinalList,ft];%#ok
        finalResult=finalResult&&result;
    end
    ftFinalList{end}.setSubBar(false);
    mdladvObj.setCheckResultStatus(finalResult);
end

function[result,ftList]=getSubcheckForBlockType(blockType,modelObj,mdladvObj)
    ftList={};
    blks=modelObj.getBlockType(blockType);
    constraintsToBlocksMap=containers.Map;
    blks=applyMAExclusions(mdladvObj,blks);
    for i=1:numel(blks)
        constraints=blks{i}.getConstraints;
        for j=1:numel(constraints)
            if constraints{j}.isOwnerVirtualBlock()


                continue;
            end

            [failure,~]=constraints{j}.checkCompatibility();
            if~isempty(failure)
                key=constraints{j}.getID;
                if~isKey(constraintsToBlocksMap,key)
                    failureTypes=containers.Map;
                    failureTypes(generateCode(failure,constraints{j}))=...
                    {failure,constraints{j},constraints{j}.ParentBlock.getSID};
                    constraintsToBlocksMap(key)=failureTypes;
                else
                    failureTypes=constraintsToBlocksMap(key);
                    if~isKey(failureTypes,generateCode(failure,constraints{j}))
                        failureTypes(generateCode(failure,constraints{j}))=...
                        {failure,constraints{j},constraints{j}.ParentBlock.getSID};
                    else
                        temp=failureTypes(generateCode(failure,constraints{j}));
                        temp{end+1}=constraints{j}.ParentBlock.getSID;%#ok<AGROW>;
                        failureTypes(generateCode(failure,constraints{j}))=temp;
                    end
                    constraintsToBlocksMap(key)=failureTypes;
                end
            end
        end
    end
    blockType=slci.compatibility.BlocktypeToName(blockType);
    if isempty(constraintsToBlocksMap)
        ft=ModelAdvisor.FormatTemplate('ListTemplate');
        SID=cell(numel(blks),1);
        ID=[];
        for i=1:numel(blks)
            SID{i}=blks{i}.getSID;
            constraints=blks{i}.getConstraints;
            constraintID=cell(numel(constraints),1);
            for j=1:numel(constraints)
                constraintID{j}=constraints{j}.getID;
            end
            ID=[ID',constraintID']';
        end
        ft.UserData.Sid=SID;
        ft.UserData.ID=ID;
        ft.setSubResultStatus('Pass');
        if~isempty(blks)
            ft.setSubResultStatusText(DAStudio.message('Slci:compatibility:AllBlocksCompatible',blockType));
        else
            ft.setSubResultStatusText(DAStudio.message('Slci:compatibility:NoBlocksFound',blockType));
        end
        ftList{end+1}=ft;
        result=true;
    else
        keys=constraintsToBlocksMap.keys;
        for i=1:numel(keys)
            failureTypes=constraintsToBlocksMap(keys{i});
            failureCodeKeys=failureTypes.keys;
            for j=1:numel(failureCodeKeys)
                ft=ModelAdvisor.FormatTemplate('ListTemplate');
                failureInfo=failureTypes(failureCodeKeys{j});
                failures=failureInfo{1};
                tConstraint=failureInfo{2};
                ft.UserData.Sid=failureInfo(3:end);
                ft.UserData.ID=tConstraint.getID;
                ft.UserData.Constraint=tConstraint;
                isPreReqFail=failures(1).getpreReqFailureFlag();

                [SubTitle,Information,~,~]=tConstraint.getMAStrings(true);%#ok<ASGLU>


                if isPreReqFail
                    StatusText=DAStudio.message('Slci:compatibility:PrereqConstraintsWarn');
                    RecAction='';
                    for k=1:numel(failures)
                        [~,~,tempstatusText,tempRecAction]=failures(k).getMAStrings();
                        StatusText=[StatusText,' ',tempstatusText];%#ok
                        RecAction=[RecAction,' ',tempRecAction];%#ok
                    end
                else
                    [SubTitle,Information,StatusText,RecAction]=tConstraint.getMAStrings(false,failureInfo{1});%#ok<ASGLU>
                end
                ft.setSubResultStatus('Warn');
                ft.setSubResultStatusText(StatusText);
                ft.setRecAction(RecAction);
                ft.setListObj(failureInfo(3:end));
                ft.setSubBar(false);
                ftList{end+1}=ft;%#ok<AGROW>
            end
        end
        result=false;
    end

    ftList{1}.setSubTitle(DAStudio.message('Slci:compatibility:BlocksCheckSubtitle',blockType));
    ftList{1}.setInformation(DAStudio.message('Slci:compatibility:BlocksCheckDescription',blockType));
    ftList{end}.setSubBar(true);
end

function code=generateCode(failure,constraint)
    code='';
    for i=1:numel(failure)
        failuresCode=failure.getCode;





        if failure.getpreReqFailureFlag()
            preReqFailures=constraint.getPreRequisiteConstraintsFailures();
            for j=1:numel(preReqFailures)
                failuresCode=[failuresCode,'_',preReqFailures{j}.getID];%#ok
            end
        end
        code=[code,'_',failuresCode];%#ok
    end
end

function blks=applyMAExclusions(mdladvObj,blks)
    tBlks={};
    for i=1:numel(blks)
        if~isempty(mdladvObj.filterResultWithExclusion(blks{i}.getSID));
            tBlks{end+1}=blks{i};%#ok
        end
    end
    blks=tBlks;
end


