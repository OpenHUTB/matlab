function propertyList=getCCPropertyList




    i=1;
    propertyList=pm.sli.internal.ConfigsetProperty();
    propertyList(i).Name='ExplicitSolverDiagnosticOptions';
    propertyList(i).IgnoreCompare=false;
    propertyList(i).Label='Explicit solver used in model containing Physical Networks blocks';
    propertyList(i).DataType='NE_PNSIM_OPTIONS';
    propertyList(i).RowWithButton=false;



    propertyList(i).DisplayStrings={};
    propertyList(i).Group='Physical Networks Model-Wide Simulation Diagnostics';
    propertyList(i).GroupDesc='';
    propertyList(i).Visible=true;
    propertyList(i).Enabled=true;
    propertyList(i).DefaultValue='';
    propertyList(i).MatlabMethod='';

    propertyList(i).Listener.Event={'PropertyPostSet'};
    propertyList(i).Listener.Callback=@propertyCallback_errorOptions;
    propertyList(i).Listener.CallbackTarget=@NetworkEngine.PhysicalNetworksSimulationOptions;

    propertyList(i).SetFcn=@NetworkEngine.PhysicalNetworksSimulationOptions.propertySetFcn_errorOptions;

    i=i+1;
    propertyList(i).Name='GlobalZcOffDiagnosticOptions';
    propertyList(i).IgnoreCompare=false;
    propertyList(i).Label='Zero-crossing control is globally disabled in Simulink';
    propertyList(i).DataType='NE_PNSIM_OPTIONS_NO_NONE';
    propertyList(i).RowWithButton=false;



    propertyList(i).DisplayStrings={};
    propertyList(i).Group='Physical Networks Model-Wide Simulation Diagnostics';
    propertyList(i).GroupDesc='';
    propertyList(i).Visible=true;
    propertyList(i).Enabled=true;
    propertyList(i).DefaultValue='';
    propertyList(i).MatlabMethod='';

    propertyList(i).Listener.Event={'PropertyPostSet'};
    propertyList(i).Listener.Callback=@propertyCallback_errorOptions;
    propertyList(i).Listener.CallbackTarget=@NetworkEngine.PhysicalNetworksSimulationOptions;

    propertyList(i).SetFcn=@NetworkEngine.PhysicalNetworksSimulationOptions.propertySetFcn_errorOptions;

end






