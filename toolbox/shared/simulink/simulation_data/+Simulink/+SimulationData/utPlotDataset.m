function utPlotDataset(ds,dsLabel)






    if~isscalar(ds)
        Simulink.SimulationData.utError('plotMustBeScalar');
    end

    try
        if~isSimulinkSignalFormat(ds)
            Simulink.SimulationData.utError('unsupportedSimulinkFormats');
        end

    catch ME
        if(strcmp(ME.identifier,'MATLAB:UndefinedFunction')||strcmp(ME.identifier,'MATLAB:undefinedVarOrClass'))
            Simulink.SimulationData.utError('simulinkNotInstalled');
        else
            throwAsCaller(ME);
        end

    end

    gotIt=Simulink.SimulationData.utSlLicenseCheck();
    if~gotIt
        Simulink.SimulationData.utError('simulinkNotInstalled');
    end

    if isempty(dsLabel)

        if~isempty(ds.Name)&&isvarname(ds.Name)
            dsLabel=ds.Name;
        else



            dsLabel='ans';
        end
    end

    in.(dsLabel)=ds;

    aEditorDlg=Simulink.sta.Editor('EditMode',false,'ViewInput',in);
    show(aEditorDlg);

end


