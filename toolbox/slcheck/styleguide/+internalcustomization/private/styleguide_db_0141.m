function styleguide_db_0141

    rec=Advisor.Utils.getDefaultCheckObject('mathworks.maab.db_0141',false,@hCheckAlgo,'None');

    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='mathworks.maab.db_0141';

    inputParamList{1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';
    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='graphical';

    rec.setInputParametersLayoutGrid([1,4]);
    rec.setInputParameters(inputParamList);

    rec.setLicense({styleguide_license});
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.register(rec);

end

function violations=hCheckAlgo(system)

    checker=ModelAdvisor.internal.ModelLayoutChecker(system);
    checker.init();

    violations=checker.check();

end