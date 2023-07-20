



classdef PluginPreCodeGen<downstream.plugin.PluginBase



    properties

        OptionList={};
        WorkflowList={};
        OptionIDList={};
        WorkflowIDList={};
        tclNewProject='';
        tclOpenProject='';
        tclCloseProject='';
        tclSetProject='';
        tclAreaObjective={};
        tclSpeedObjective={};
        tclCompileObjective={};
        tclRemoveIOBuffer='';
        tclDoNotTrimUnconnected='';


    end

    methods

        function addOption(obj,hOption)
            obj.OptionList{end+1}=hOption;
            obj.OptionIDList{end+1}=hOption.OptionID;
        end

        function addWorkflow(obj,hWorkflow)
            obj.WorkflowList{end+1}=hWorkflow;
            obj.WorkflowIDList{end+1}=hWorkflow.WorkflowID;
        end

        function parsePluginFile(obj,hToolDriver)

            hToolDriver.OptionList=[hToolDriver.OptionList,obj.OptionList];
            hToolDriver.OptionIDList=[hToolDriver.OptionIDList,obj.OptionIDList];

            hToolDriver.WorkflowList=obj.WorkflowList;
            hToolDriver.WorkflowIDList=obj.WorkflowIDList;

            hToolDriver.hEmitter.tclNewProject=obj.tclNewProject;
            hToolDriver.hEmitter.tclAreaObjective=obj.tclAreaObjective;
            hToolDriver.hEmitter.tclSpeedObjective=obj.tclSpeedObjective;
            hToolDriver.hEmitter.tclCompileObjective=obj.tclCompileObjective;

            hToolDriver.hEmitter.tclOpenProject=obj.tclOpenProject;
            hToolDriver.hEmitter.tclCloseProject=obj.tclCloseProject;
            hToolDriver.hEmitter.tclSetProject=obj.tclSetProject;
            hToolDriver.hEmitter.tclRemoveIOBuffer=obj.tclRemoveIOBuffer;
            hToolDriver.hEmitter.tclDoNotTrimUnconnected=obj.tclDoNotTrimUnconnected;

        end

    end

end
