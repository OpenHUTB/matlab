classdef ProjectContext<dig.CustomContext










    properties(SetAccess=immutable)
        ModelHandle(1,1)double;
    end

    properties(SetAccess=private,SetObservable=true)
        ProjectRoot(1,1)string;
        ProjectOpen(1,1)logical;
        InProject(1,1)logical;
        NotInProject(1,1)logical;
        RefreshTrigger(1,1)logical;
    end

    methods
        function obj=ProjectContext(modelHandle)
            app=struct;
            app.name='slprojectApp';
            app.defaultContextType='';
            app.defaultTabName='';
            app.priority=0;

            obj@dig.CustomContext(app);
            obj.ModelHandle=modelHandle;
            obj.refresh;
        end

        function refresh(obj)
            file=get_param(obj.ModelHandle,'FileName');
            mapper=matlab.internal.project.util.FileToProjectMapper(file);

            if mapper.InAProject
                obj.TypeChain={'slprojectContext'};
                obj.ProjectRoot=mapper.ProjectRoot;
                obj.ProjectOpen=mapper.InRootOfALoadedProject;
                obj.InProject=mapper.InALoadedProject;
                obj.NotInProject=mapper.InRootOfALoadedProject&&~mapper.InALoadedProject;
            else
                obj.TypeChain={};
                obj.ProjectRoot="";
                obj.ProjectOpen=false;
                obj.InProject=false;
                obj.NotInProject=false;
            end

            obj.RefreshTrigger=~obj.RefreshTrigger;
        end
    end

end
