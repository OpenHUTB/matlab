


classdef WorkflowBase<handle






    properties(SetAccess=protected,Hidden)
        TargetWorkflow;
        SynthesisTool;
    end

    properties

        RunTaskCreateProject=true;

        Objective=hdlcoder.Objective.None;
        ProjectFolder='hdl_prj';
        AdditionalProjectCreationTclFiles='';
        AllowUnsupportedToolVersion=false;
    end

    properties(SetAccess=protected)

        Tasks;
        Properties;




        HiddenProperties;
    end





    methods
        function obj=WorkflowBase(workflow,tool)
            obj.TargetWorkflow=workflow;
            obj.SynthesisTool=tool;
            obj.Objective=hdlcoder.Objective.None;
            obj.ProjectFolder='hdl_prj';
            obj.AdditionalProjectCreationTclFiles='';
            obj.RunTaskCreateProject=true;
            obj.AllowUnsupportedToolVersion=false;
            if(isempty(obj.Properties))
                obj.Properties=containers.Map('RunTaskCreateProject',{'Objective','AdditionalProjectCreationTclFiles'},'UniformValues',false);
            end

            obj.Properties('TopLevelTasks')={'ProjectFolder','AllowUnsupportedToolVersion'};


            obj.HiddenProperties=containers.Map();
        end
    end





    methods
        function set.RunTaskCreateProject(obj,val)
            obj.errorCheckTask('RunTaskCreateProject',val);
            obj.RunTaskCreateProject=val;
        end

        function set.ProjectFolder(obj,val)
            if(~ischar(val))
                error(message('hdlcoder:workflow:ParamValueNotString','ProjectFolder'));
            else
                downstream.tool.checkNonASCII(val,'ProjectFolder');
            end
            obj.ProjectFolder=val;
        end

        function set.Objective(obj,val)
            if strcmp(obj.SynthesisTool,'Microchip Libero SoC')
                if(strcmp(val,'AreaOptimized')||strcmp(val,'SpeedOptimized')||strcmp(val,'CompileOptimized'))
                    error(message('hdlcommon:workflow:SynthesisObjectiveNotSupported'))
                end
            end
            if(~isa(val,'hdlcoder.Objective'))
                error(message('hdlcoder:workflow:InvalidObjective'));
            end
            obj.Objective=val;
        end

        function set.AdditionalProjectCreationTclFiles(obj,val)
            if(~ischar(val))
                error(message('hdlcoder:workflow:ParamValueNotString','AdditionalProjectCreationTclFiles'));
            else
                downstream.tool.checkNonASCII(val,'AdditionalProjectCreationTclFiles');
            end
            obj.AdditionalProjectCreationTclFiles=val;
        end

        function setAllTasks(obj)
            for i=1:length(obj.Tasks)
                task=obj.Tasks{i};
                obj.(task)=true;
            end
        end

        function clearAllTasks(obj)
            for i=1:length(obj.Tasks)
                task=obj.Tasks{i};
                obj.(task)=false;
            end
        end

        function errorCheckTask(obj,task,val)





            if~isempty(obj.Tasks)&&~ismember(task,obj.Tasks)
                error(message('hdlcoder:workflow:TaskNotMemberOfActiveWorkflow',task));
            end


            isOn=strcmpi(val,'On');
            isOff=strcmpi(val,'Off');
            isTrue=(islogical(val)&&val==true);
            isFalse=(islogical(val)&&val==false);

            if isOn||isOff||isTrue||isFalse

            else
                error(message('hdlcoder:workflow:InvalidToggleValue',task));
            end
        end
    end

end

