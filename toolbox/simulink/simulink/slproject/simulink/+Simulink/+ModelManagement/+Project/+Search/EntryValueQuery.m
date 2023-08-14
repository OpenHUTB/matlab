classdef EntryValueQuery<Simulink.ModelManagement.Project.Search.AbstractEntryQuery




    properties(Constant=true)
        ValueQuery=Simulink.loadsave.Query('//DataSource/Object[Name=* and Value=*]/Value');
        PathQuery=Simulink.loadsave.Query('//DataSource/Object[Name=* and Value=*]/Name');
    end

end

