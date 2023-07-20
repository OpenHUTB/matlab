function jmaab_db_0043




    SubCheckCfg(1).Type='Normal';
    SubCheckCfg(1).subcheck.ID='slcheck.jmaab.db_0043_a';
    SubCheckCfg(2).Type='Normal';
    SubCheckCfg(2).subcheck.ID='slcheck.jmaab.db_0043_b';
    SubCheckCfg(3).Type='Normal';
    SubCheckCfg(3).subcheck.ID='slcheck.jmaab.db_0043_c';
    SubCheckCfg(4).Type='Normal';
    SubCheckCfg(4).subcheck.ID='slcheck.jmaab.db_0043_d';

    rec=slcheck.Check('mathworks.jmaab.db_0043',SubCheckCfg,{sg_jmaab_group,sg_maab_group});
    rec.LicenseString={styleguide_license,'Stateflow'};
    rec.relevantEntities=@getRelevantEntity;
    inputParamList=rec.setDefaultInputParams(false);

    rowSpan=inputParamList{end}.RowSpan+1;
    inputParamList{end+1}=ModelAdvisor.InputParameter;
    inputParamList{end}.Name=DAStudio.message('ModelAdvisor:jmaab:db_0043_SimulinkFontName');
    inputParamList{end}.Type='Combobox';
    inputParamList{end}.Description=DAStudio.message('ModelAdvisor:jmaab:db_0043_SimulinkFontNameInputDesc');
    inputParamList{end}.Entries=['Default';MG2.Font.getInstalledFontNames];
    inputParamList{end}.RowSpan=rowSpan;
    inputParamList{end}.setColSpan([1,2]);
    inputParamList{end}.Visible=false;
    inputParamList{end}.Enable=true;
    inputParamList{end}.Value='Default';

    rowSpan=inputParamList{end}.RowSpan+1;
    inputParamList{end+1}=ModelAdvisor.InputParameter;
    inputParamList{end}.Name=DAStudio.message('ModelAdvisor:jmaab:db_0043_SimulinkFontStyle');
    inputParamList{end}.Type='Enum';
    inputParamList{end}.Entries={'Default','normal','bold','italic','bold italic'};
    inputParamList{end}.Description=DAStudio.message('ModelAdvisor:jmaab:db_0043_SimulinkFontStyleInputDesc');
    inputParamList{end}.RowSpan=rowSpan;
    inputParamList{end}.setColSpan([1,2]);
    inputParamList{end}.Visible=false;
    inputParamList{end}.Enable=true;
    inputParamList{end}.Value='Default';

    rowSpan=inputParamList{end}.RowSpan+1;
    inputParamList{end+1}=ModelAdvisor.InputParameter;
    inputParamList{end}.Name=DAStudio.message('ModelAdvisor:jmaab:db_0043_SimulinkFontSize');
    inputParamList{end}.Type='Combobox';
    inputParamList{end}.Entries={'Default','6','8','9','10','12','14','16','18','24','36','48'};
    inputParamList{end}.Description=DAStudio.message('ModelAdvisor:jmaab:db_0043_SimulinkFontSizeInputDesc');
    inputParamList{end}.RowSpan=rowSpan;
    inputParamList{end}.setColSpan([1,2]);
    inputParamList{end}.Visible=false;
    inputParamList{end}.Enable=true;
    inputParamList{end}.Value='Default';

    rowSpan=inputParamList{end}.RowSpan+1;
    inputParamList{end+1}=ModelAdvisor.InputParameter;
    inputParamList{end}.Name=DAStudio.message('ModelAdvisor:jmaab:db_0043_StateflowFontName');
    inputParamList{end}.Type='Combobox';
    inputParamList{end}.Entries=['Default';MG2.Font.getInstalledFontNames];
    inputParamList{end}.Description=DAStudio.message('ModelAdvisor:jmaab:db_0043_StateflowFontNameInputDesc');
    inputParamList{end}.RowSpan=rowSpan;
    inputParamList{end}.setColSpan([1,2]);
    inputParamList{end}.Visible=false;
    inputParamList{end}.Enable=true;
    inputParamList{end}.Value='Default';

    rowSpan=inputParamList{end}.RowSpan+1;
    inputParamList{end+1}=ModelAdvisor.InputParameter;
    inputParamList{end}.Name=DAStudio.message('ModelAdvisor:jmaab:db_0043_StateflowFontStyle');
    inputParamList{end}.Type='Enum';
    inputParamList{end}.Entries={'Default','NORMAL','BOLD','ITALIC','BOLD ITALIC'};
    inputParamList{end}.Description=DAStudio.message('ModelAdvisor:jmaab:db_0043_StateflowFontStyleInputDesc');
    inputParamList{end}.RowSpan=rowSpan;
    inputParamList{end}.setColSpan([1,2]);
    inputParamList{end}.Visible=false;
    inputParamList{end}.Enable=true;
    inputParamList{end}.Value='Default';

    rowSpan=inputParamList{end}.RowSpan+1;
    inputParamList{end+1}=ModelAdvisor.InputParameter;
    inputParamList{end}.Name=DAStudio.message('ModelAdvisor:jmaab:db_0043_StateflowFontSize');
    inputParamList{end}.Type='Combobox';
    inputParamList{end}.Entries={'Default','6','8','9','10','12','14','16','18','24','36','48'};
    inputParamList{end}.Description=DAStudio.message('ModelAdvisor:jmaab:db_0043_StateflowFontSizeInputDesc');
    inputParamList{end}.RowSpan=rowSpan;
    inputParamList{end}.setColSpan([1,2]);
    inputParamList{end}.Visible=false;
    inputParamList{end}.Enable=true;
    inputParamList{end}.Value='Default';
    rec.setInputParameters(inputParamList);

    modifyAction=ModelAdvisor.Action;
    modifyAction.setCallbackFcn(@modifyFontProperties);
    modifyAction.Name=DAStudio.message('ModelAdvisor:jmaab:db_0043_ModifyButtonText');
    modifyAction.Description=DAStudio.message('ModelAdvisor:jmaab:db_0043_ModifyButtonDesc');
    modifyAction.Enable=true;
    rec.setAction(modifyAction);
    rec.register();
end

function entities=getRelevantEntity(system,FollowLinks,LookUnderMasks)



    slList=find_system(system,'FindAll','on','Regexp','on','FollowLinks',FollowLinks,'LookUnderMasks',LookUnderMasks,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'type','block|line|annotation');

    slList=Advisor.Utils.Simulink.standardFilter(system,slList,'Shipping');

    slList=slList(arrayfun(@(x)~(Stateflow.SLUtils.isChildOfStateflowBlock(x)),slList));
    slObjs=get_param(slList,'Object');

    sfsObjs=Advisor.Utils.Stateflow.sfFindSys(system,'on','all',...
    {'-isa','Stateflow.State','-or','-isa','Stateflow.Box','-or',...
    '-isa','Stateflow.SLFunction','-or','-isa','Stateflow.EMFunction','-or',...
    '-isa','Stateflow.Annotation','-or','-isa','Stateflow.TruthTable','-or',...
    '-isa','Stateflow.AtomicSubchart','-or','-isa','Stateflow.Transition','-or','-isa','Stateflow.SimulinkBasedState'},false);

    if~iscell(slObjs)
        slObjs={slObjs};
    end
    if~iscell(sfsObjs)
        sfsObjs={sfsObjs};
    end
    entities=[slObjs;sfsObjs];
end

function result=modifyFontProperties(taskobj)
    result=ModelAdvisor.Paragraph();
    mdladvObj=taskobj.MAObj;
    system=mdladvObj.System;

    ResultData=mdladvObj.getCheckResult(taskobj.MAC);

    groupedStatesPath=getGroupedEntitiesPaths(bdroot(system));

    [modifiedObjs,exceptionObjs]=modifyFontFormatting(ResultData,system,groupedStatesPath);

    if~isempty(modifiedObjs)

        tmpText=ModelAdvisor.Text(DAStudio.message('ModelAdvisor:jmaab:db0043_ModificationUpdateText'));
        modText=ModelAdvisor.Text(DAStudio.message('ModelAdvisor:jmaab:db0043_PostModificationUpdateText'));
        tmpText.setColor('pass');
        modText.setColor('warn');

        result.addItem(tmpText);
        result.addItem(ModelAdvisor.Text(mat2str(length(modifiedObjs))));
        result.addItem(ModelAdvisor.LineBreak);
        resultList=ModelAdvisor.List;
        for i=1:length(modifiedObjs)


            if length(modifiedObjs(i).getFullName)>=1
                resultList.addItem(modifiedObjs(i).getFullName);
            end
        end
        result.addItem(resultList);
        result.addItem(ModelAdvisor.LineBreak);
        result.addItem(modText);
    end


    if~isempty(exceptionObjs)
        if~isempty(modifiedObjs)
            result.addItem(ModelAdvisor.LineBreak);
            result.addItem(ModelAdvisor.LineBreak);
        end

        tmpText=ModelAdvisor.Text(DAStudio.message('ModelAdvisor:jmaab:db0043_ExceptionBlocksModification'));
        tmpText.setColor('fail');

        result.addItem(tmpText);

        result.addItem(ModelAdvisor.LineBreak);
        exceptionList=ModelAdvisor.List;

        for i=1:length(exceptionObjs)


            if length(exceptionObjs(i).getFullName)>=1
                exceptionList.addItem(exceptionObjs(i).getFullName);
            end
        end

        result.addItem(exceptionList);
        result.addItem(ModelAdvisor.LineBreak);
        msg=ModelAdvisor.Text(DAStudio.message('ModelAdvisor:jmaab:db0043_PostExceptionBlocksModification'));
        msg.setColor('warn');
        result.addItem(msg);
    end



    mdladvObj.setActionEnable(false);
end


function[objs,exceptionObjs]=modifyFontFormatting(ResultData,system,groupedEntitiesPath)
    exceptionObjs=[];


    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    modifyObjs=cellfun(@(x)x.ListObj,ResultData,'UniformOutput',false);
    modifyObjs=[modifyObjs{:}];

    objSid=modifyObjs(cellfun(@(x)ischar(x),modifyObjs));
    objHndl=modifyObjs(cellfun(@(x)~ischar(x),modifyObjs));

    objSid=unique(objSid);
    objHndl=unique([objHndl{:}]);

    lineObjs=get_param(objHndl,'Object')';

    blkChartObjs=Simulink.ID.getHandle(objSid);

    blkObjs=blkChartObjs(cellfun(@(x)isnumeric(x),blkChartObjs));
    chartObjs=blkChartObjs(cellfun(@(x)~isnumeric(x),blkChartObjs));

    blkObjs=[blkObjs{:}];
    blkObjs=get_param(blkObjs,'Object')';

    if iscell(lineObjs)
        lineObjs=[lineObjs{:}];
    end
    if iscell(blkObjs)
        blkObjs=[blkObjs{:}];
    end
    if iscell(chartObjs)
        chartObjs=[chartObjs{:}];
    end
    objs=[lineObjs,blkObjs,chartObjs];

    for idx=1:length(ResultData)
        switch ResultData{idx}.SubTitle.Content
        case DAStudio.message('ModelAdvisor:jmaab:db_0043_a_subtitle')
            modifySimulinkFontFormat(ResultData{idx},mdlAdvObj,1);
        case DAStudio.message('ModelAdvisor:jmaab:db_0043_b_subtitle')
            modifySimulinkFontFormat(ResultData{idx},mdlAdvObj,2);
        case DAStudio.message('ModelAdvisor:jmaab:db_0043_c_subtitle')
            [groupedObjs,lockedObjs]=modifyStateflowFontFormat(...
            ResultData{idx},mdlAdvObj,1,groupedEntitiesPath);
            exceptionObjs=[groupedObjs;lockedObjs];
            objs=setdiff(objs,exceptionObjs);
        case DAStudio.message('ModelAdvisor:jmaab:db_0043_d_subtitle')
            [groupedObjs,lockedObjs]=modifyStateflowFontFormat(...
            ResultData{idx},mdlAdvObj,2,groupedEntitiesPath);
            exceptionObjs=[groupedObjs;lockedObjs];
            objs=setdiff(objs,exceptionObjs);
        end
    end
end


function modifySimulinkFontFormat(ResultData,mdladv,format)

    blkObj=ResultData.ListObj(cellfun(@(x)ischar(x),ResultData.ListObj));
    lineObj=ResultData.ListObj(~cellfun(@(x)ischar(x),ResultData.ListObj));
    blkObj=Simulink.ID.getHandle(blkObj);
    slObj=[blkObj,lineObj];
    inputParams=mdladv.getInputParameters;
    system=bdroot;
    defaultModelFont=getSimulinkBlkFontProperties(system);
    for i=1:length(slObj)
        if isa(get_param(slObj{i},'Object'),'Simulink.Line')
            defIdx=2;
        else
            defIdx=1;
        end


        if format==1

            if isequal(inputParams{5}.Value,'Default')
                set_param(slObj{i},'FontName',defaultModelFont{defIdx,1});
            else
                set_param(slObj{i},'FontName',inputParams{5}.Value);
            end

            switch inputParams{6}.Value
            case 'bold'
                set_param(slObj{i},'FontWeight','bold');
                set_param(slObj{i},'FontAngle','normal');
            case 'italic'
                set_param(slObj{i},'FontWeight','normal');
                set_param(slObj{i},'FontAngle','italic');
            case 'bold italic'
                set_param(slObj{i},'FontWeight','bold');
                set_param(slObj{i},'FontAngle','italic');
            case 'Default'
                set_param(slObj{i},'FontWeight',defaultModelFont{defIdx,2});
                set_param(slObj{i},'FontAngle',defaultModelFont{defIdx,3});
            end

        elseif format==2
            if~isa(inputParams{7}.Value,'char')
                fontsize=mat2str(inputParams{7}.Value);
            else
                fontsize=inputParams{7}.Value;
            end
            if isequal(fontsize,'Default')||...
                isnan(str2double(fontsize))
                set_param(slObj{i},'FontSize',defaultModelFont{defIdx,4});
            elseif str2double(fontsize)<=0
                set_param(slObj{i},'FontSize','10');
            else
                set_param(slObj{i},'FontSize',int8(str2double(fontsize)));
            end
        end
    end
end


function[groupedObjs,lockedObjs]=modifyStateflowFontFormat(ResultData,mdladv,format,groupedEntitiesPath)
    groupedObjs=[];
    lockedObjs=[];


    sfObj=Simulink.ID.getHandle(ResultData.ListObj);
    inputParams=mdladv.getInputParameters;
    for i=1:length(sfObj)


        currSfObj=sfObj{i};
        defaultStateflowFont=getStateflowFontProperties(currSfObj);
        if format==1
            if isequal(inputParams{8}.Value,'Default')
                fontName=defaultStateflowFont{1};
            else
                fontName=inputParams{8}.Value;
            end

            switch inputParams{9}.Value
            case 'BOLD'
                fontWeight='BOLD';
                fontAngle='NORMAL';
            case 'ITALIC'
                fontWeight='NORMAL';
                fontAngle='ITALIC';
            case 'BOLD ITALIC'
                fontWeight='BOLD';
                fontAngle='ITALIC';
            case 'Default'
                fontWeight=defaultStateflowFont{2};
                fontAngle=defaultStateflowFont{3};
            end

            if~isa(currSfObj,'Stateflow.Transition')&&...
                ~isa(currSfObj,'Stateflow.Annotation')

                currSfObj.Chart.StateFont.Name=fontName;
                currSfObj.Chart.StateFont.Weight=fontWeight;
                currSfObj.Chart.StateFont.Angle=fontAngle;

            elseif~isa(currSfObj,'Stateflow.Transition')&&...
                isa(currSfObj,'Stateflow.Annotation')


                if~currSfObj.Chart.Locked
                    currSfObj.Chart.StateFont.Name=fontName;
                    currSfObj.Font.Weight=fontWeight;
                    currSfObj.Font.Angle=fontAngle;
                else
                    lockedObjs=[lockedObjs;currSfObj];%#ok<AGROW>
                end
            else
                currSfObj.Chart.TransitionFont.Name=fontName;
                currSfObj.Chart.TransitionFont.Weight=fontWeight;
                currSfObj.Chart.TransitionFont.Angle=fontAngle;
            end
        elseif format==2
            if~isa(inputParams{10}.Value,'char')
                size=mat2str(inputParams{10}.Value);
            else
                size=inputParams{10}.Value;
            end

            if isequal(size,'Default')||...
                isnan(str2double(size))
                size=defaultStateflowFont{4};
            elseif str2double(size)<=0
                size=12;
            else
                size=int8(str2double(size));
            end

            if~isa(currSfObj,'Stateflow.Annotation')
                if isGroupedUpstream(currSfObj.Path,groupedEntitiesPath)
                    groupedObjs=[groupedObjs;currSfObj];%#ok<AGROW>
                else
                    currSfObj.FontSize=size;
                end
            end
        end
    end
end


function defaultModelFont=getSimulinkBlkFontProperties(system)

    defaultModelFont={
    get_param(system,'DefaultBlockFontName'),...
    get_param(system,'DefaultBlockFontWeight'),...
    get_param(system,'DefaultBlockFontAngle'),...
    get_param(system,'DefaultBlockFontSize');...
    get_param(system,'DefaultLineFontName'),...
    get_param(system,'DefaultLineFontWeight'),...
    get_param(system,'DefaultLineFontAngle'),...
    get_param(system,'DefaultLineFontSize')
    };

end


function defaultStateflowFont=getStateflowFontProperties(sfObj)

    chart=sfObj.Chart;
    if isa(sfObj,'Stateflow.Annotation')
        defaultStateflowFont={chart.StateFont.Name,sfObj.Font.Weight,sfObj.Font.Angle,sfObj.Font.Size};
    elseif isa(sfObj,'Stateflow.Transition')
        defaultStateflowFont={chart.StateFont.Name,chart.StateFont.Weight,...
        chart.StateFont.Angle,chart.StateFont.Size};
    else
        defaultStateflowFont={chart.TransitionFont.Name,chart.TransitionFont.Weight,...
        chart.TransitionFont.Angle,chart.TransitionFont.Size};
    end
end


function groupedEntitiesPath=getGroupedEntitiesPaths(system)
    groupedEntitiesPath=[];
    groupedEntities=Advisor.Utils.Stateflow.sfFindSys(system,'on','all',...
    {'-isa','Stateflow.State','-or','-isa','Stateflow.Function'});
    if isempty(groupedEntities)
        return;
    end
    groupedEntitiesPath=cellfun(@getPathIfEntityGrouped,groupedEntities,'UniformOutput',false);
    groupedEntitiesPath=groupedEntitiesPath(~cellfun('isempty',groupedEntitiesPath));
    function ret=getPathIfEntityGrouped(entity)
        ret=[];


        if any(contains(fieldnames(entity),'IsGrouped'))&&...
            entity.IsGrouped
            ret=[entity.Path,'/',entity.Name];
        end
    end
end

function ret=isGroupedUpstream(path,patterns)
    ret=false;
    for idx=1:length(patterns)
        if 1==strfind(path,patterns{idx})
            ret=true;
            return;
        end
    end
end

