function appData=getApplicationData(model)







    dataArchive=get_param(model,'MinMaxOverflowArchiveData');


    dirty_restorer=Simulink.PreserveDirtyFlag(model,'blockDiagram');%#ok<NASGU>


    if(~(isfield(dataArchive,'ApplicationData'))||...
        ~isa(dataArchive.ApplicationData,'SimulinkFixedPoint.ApplicationData'))
        dataArchive.ApplicationData=SimulinkFixedPoint.ApplicationData(model);
        set_param(model,'MinMaxOverflowArchiveData',dataArchive);
    end

    appData=dataArchive.ApplicationData;
end