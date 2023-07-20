function obj=getInspector(type,slxcFile)




    switch(type)
    case 'REPORT'
        obj=Simulink.packagedmodel.inspect.ReportView(slxcFile);
    case 'QUERY'
        obj=Simulink.packagedmodel.inspect.QueryView(slxcFile);
    case 'TRANSLATE'
        obj=Simulink.packagedmodel.inspect.TranslateView(slxcFile);
    otherwise
        assert(false,'Invalid type specified');
    end
end
