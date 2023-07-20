


classdef Workflow<handle



    properties

        WorkflowID='';
        TclTemplate={};

        Skipped=false;

    end

    methods

        function obj=Workflow(WorkflowID,TclTemplate)

            obj.WorkflowID=WorkflowID;
            obj.TclTemplate=TclTemplate;

        end

    end


end