function jmaab_jc_0712


    rec=Advisor.Utils.getDefaultCheckObject('mathworks.jmaab.jc_0712',false,@CheckAlgo,'None');

    inputParamList{1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';

    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='Graphical';

    rec.setInputParametersLayoutGrid([2,4]);
    rec.setInputParameters(inputParamList);

    rec.setLicense({styleguide_license,'Stateflow'});

    rec.setReportStyle('ModelAdvisor.Report.TableStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.TableStyle'});

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});

end

function[resultDetail]=CheckAlgo(system)

    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    resultDetail=[];

    flv=mdlAdvObj.getInputParameterByName('Follow links');
    lum=mdlAdvObj.getInputParameterByName('Look under masks');

    SFCharts=Advisor.Utils.Stateflow.sfFindSys...
    (system,flv.value,lum.value,{'-isa','Stateflow.Chart'},true);


    SFCharts=mdlAdvObj.filterResultWithExclusion(SFCharts);

    for countCharts=1:length(SFCharts)

        if~SFCharts{countCharts}.ExecuteAtInitialization
            continue;
        end

        vObj=ModelAdvisor.ResultDetail;
        ModelAdvisor.ResultDetail.setData(vObj,'Custom',...
        DAStudio.message('ModelAdvisor:jmaab:jc_0712_col1'),...
        SFCharts{countCharts})

        resultDetail=[resultDetail,vObj];

    end

end

