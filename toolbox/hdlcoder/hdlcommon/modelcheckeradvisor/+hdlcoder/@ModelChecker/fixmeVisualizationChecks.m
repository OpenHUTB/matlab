function ResultDescription=fixmeVisualizationChecks(mdlTaskObj)






    checker=hdlcoder.ModelChecker.getModelChecker(mdlTaskObj,'runVisualizationChecks');
    model=checker.m_sys;
    List=ModelAdvisor.List;
    List.setType('bulleted');

    obj=get_param(model,'Object');
    if~strcmpi(obj.ShowPortDataTypes,'on')
        set_param(model,'ShowPortDataTypes','on');
        List.addItem(DAStudio.message('HDLShared:hdlmodelchecker:datatype_visualization_fix'));
    end

    if~strcmpi(obj.SampleTimeColors,'on')
        set_param(model,'SampleTimeColors','on');
        List.addItem(DAStudio.message('HDLShared:hdlmodelchecker:sampletime_visualization_fix'));
    end

    ResultDescription=[ModelAdvisor.Text(DAStudio.message('HDLShared:hdlmodelchecker:visualization_fix')),List];
end
