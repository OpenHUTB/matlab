





function[Results]=ExecCheckSubsysCodeReuse(system)

    Results={};
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);

    inputParams=mdladvObj.getInputParameters;

    mdladvObj.setCheckResultStatus(true);


    if any(strcmp(system,find_system('SearchDepth',0)))
        load_system(system);
    end


    subSystemName=find_system(system,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks',inputParams{1}.Value,...
    'LookUnderMasks',inputParams{2}.Value,...
    'type','block','BlockType','SubSystem');
    subSystemName=subSystemName(cellfun(@(x)~(Stateflow.SLUtils.isStateflowBlock(x)),subSystemName));


    subSystemInfo=[];
    subSystemInfo.Name=[];
    subSystemInfo.compiledInfo=[];
    subSystemInfo.compiledCommonSampleTime=[];
    subSystemInfo.calcCheckSum=[];


    allSubSystemInfo=[];
    allSubSystemInfo.calcCheckSum=[];




    refMdls=find_mdlrefs(system,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
    for idx1=1:length(refMdls)

        if~strcmp(system,refMdls{idx1})&&any(strcmp(refMdls{idx1},find_system('SearchDepth',0)))
            load_system(refMdls{idx1});
        end



        allSubSystemName=find_system(refMdls{idx1},...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'FollowLinks','on',...
        'LookUnderMasks','all',...
        'type','block','BlockType','SubSystem');
        allSubSystemName=allSubSystemName(cellfun(@(x)~(Stateflow.SLUtils.isStateflowBlock(x)),allSubSystemName));
    end


    for idx2=1:length(subSystemName)












        subSystemInfo(idx2).Name=subSystemName{idx2};%#ok<AGROW>
        subSystemInfo(idx2).compiledInfo=get_param(subSystemInfo(idx2).Name,'CompiledRTWSystemInfo');%#ok<AGROW>
        subSystemInfo(idx2).compiledCommonSampleTime=...
        hLocalGetCommonCompiledTimes(subSystemInfo(idx2).Name);%#ok<AGROW>
    end
    for idx1=1:numel(allSubSystemName)
        try

            newsys=new_system;
            compiledInfo=get_param(allSubSystemName{idx1},'CompiledRTWSystemInfo');

            if~isempty(compiledInfo)




                Simulink.SubSystem.copyContentsToBlockDiagram(allSubSystemName{idx1},newsys);
                [~,calcDetails]=Simulink.BlockDiagram.getChecksum(newsys);
                Simulink.BlockDiagram.deleteContents(get_param(newsys,'name'));
                allSubSystemInfo(idx1).calcCheckSum=calcDetails.ContentsChecksum.Value;%#ok<AGROW>
            else
                allSubSystemInfo(idx1).calcCheckSum=[];%#ok<AGROW>
            end
            close_system(newsys,0);
        catch
            close_system(newsys,0);
        end
    end

    totalReusableSubsys=numel([allSubSystemInfo.calcCheckSum])/4;
    violationObj=[];
    filteredSubSys=mdladvObj.filterResultWithExclusion({subSystemInfo.Name});

    for idx3=1:length({subSystemInfo.Name})


        if isempty(subSystemInfo(idx3).Name)
            continue;
        end
        if~ismember(subSystemInfo(idx3).Name,filteredSubSys)
            continue;
        end

        if~isempty(subSystemInfo(idx3).compiledInfo)&&...
...
            (subSystemInfo(idx3).compiledInfo(1)==2)&&...
...
...
...
            ~(subSystemInfo(idx3).compiledInfo(3)==totalReusableSubsys)&&...
...
...
            (numel(subSystemInfo(idx3).compiledCommonSampleTime)>1)

            nonreuseSubsys=subSystemInfo(idx3).Name;
            vObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(vObj,'SID',nonreuseSubsys);
            violationObj=[violationObj;vObj];%#ok<AGROW>

        end
    end


    if~isempty(violationObj)
        Results=violationObj;
    end
end


function[commonCompiledTimes]=hLocalGetCommonCompiledTimes(sysName)



    contentHdls=find_system(sysName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','on','FindAll','on');

    collatedTimes=[];
    for i=1:length(contentHdls)
        if iscell(contentHdls)
            currentHdl=contentHdls{i};
        else
            currentHdl=contentHdls(i);
        end
        try

            tempSampleAndOffset=get_param(currentHdl,'CompiledSampleTime');
            collatedTimes(end+1)=tempSampleAndOffset(1);%#ok
        catch


        end
    end



    commonCompiledTimes=[];
    for i=1:length(collatedTimes)
        forBlock=collatedTimes(i);

        found=0;
        for k=1:length(commonCompiledTimes)
            if forBlock==commonCompiledTimes(k)
                found=1;
                break;
            end
        end
        if~found
            commonCompiledTimes(end+1)=forBlock;%#ok
        end
    end
end

