function jmaab_jc_0737

    rec=ModelAdvisor.Check('mathworks.jmaab.jc_0737');
    rec.Title=DAStudio.message('ModelAdvisor:jmaab:jc_0737_title');
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='jc_0737';
    rec.setCallbackFcn(@(system,checkObj)Advisor.Utils.genericCheckCallback(...
    system,checkObj,'ModelAdvisor:jmaab:jc_0737',@checkAlgo),...
    'None','DetailStyle');
    rec.setReportStyle('ModelAdvisor.Report.ExpressionStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.ExpressionStyle'});

    rec.TitleTips=DAStudio.message('ModelAdvisor:jmaab:jc_0737_tip');
    rec.setLicense({styleguide_license,'Stateflow'});
    rec.Value=true;
    rec.SupportHighlighting=true;
    rec.SupportLibrary=false;
    rec.SupportExclusion=true;
    rec.setInputParametersLayoutGrid([1,4]);

    inputParamList{1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';
    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='graphical';

    rec.setInputParameters(inputParamList);
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,sg_jmaab_group);

end

function violations=checkAlgo(system)
    violations=[];
    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    flv=mdlAdvObj.getInputParameterByName('Follow links');
    lum=mdlAdvObj.getInputParameterByName('Look under masks');
    sfstates=Advisor.Utils.Stateflow.sfFindSys(system,flv.Value,lum.Value,...
    {'-isa','Stateflow.State','-or','-isa','Stateflow.Transition'});
    sfstates=mdlAdvObj.filterResultWithExclusion(sfstates);

    if isempty(sfstates)
        return;
    end



    for index=1:length(sfstates)
        currState=sfstates{index};

        if isempty(currState.LabelString)
            continue;
        end

        codeStringToSearch=currState.LabelString;
        [startIndices,endIndices]=ModelAdvisor.internal.styleguide_jmaab_0737(...
        codeStringToSearch,currState.Chart.ActionLanguage);

        if~isempty([startIndices,endIndices])

            for idx=1:length(startIndices)




                highlighted=codeStringToSearch;
                highlighted=Advisor.Utils.Naming.formatFlaggedName(highlighted,...
                false,[startIndices(idx),endIndices(idx)],'');

                MAText=ModelAdvisor.Text(highlighted);
                MAText.RetainReturn=true;
                MAText.RetainSpaceReturn=true;

                tempObj=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(tempObj,'SID',currState,'Expression',MAText.emitHTML);
                violations=[violations;tempObj];%#ok<AGROW>            
            end
        end
    end

end