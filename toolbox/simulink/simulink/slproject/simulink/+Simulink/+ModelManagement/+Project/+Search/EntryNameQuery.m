classdef EntryNameQuery<Simulink.ModelManagement.Project.Search.AbstractEntryQuery




    properties(Constant=true)
        ValueQuery=Simulink.loadsave.Query('//DataSource/Object/Name');
        PathQuery=Simulink.loadsave.Query('//DataSource/Object/Name');
    end

end
