


classdef Option<handle



    properties

        WorkflowID='';
        OptionID='';
        Value='';
        AllChoice={};
        DisplayName='';
    end

    methods

        function obj=Option(WorkflowID,OptionID,Value,AllChoice,DisplayName)


            if nargin<5
                DisplayName=OptionID;
            end

            if nargin<4
                AllChoice={};
            end

            obj.WorkflowID=WorkflowID;
            obj.OptionID=OptionID;
            obj.Value=Value;
            obj.AllChoice=AllChoice;
            obj.DisplayName=DisplayName;


        end

    end


end