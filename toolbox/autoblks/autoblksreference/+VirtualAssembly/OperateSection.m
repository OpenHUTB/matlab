classdef OperateSection<handle



    properties
        RunButton matlab.ui.internal.toolstrip.Button

Tag
    end

    properties(Access=private)
Tab
    end

    events
RunSimulation
    end

    methods



        function obj=OperateSection(tab)
            obj.Tab=tab;
            obj.createWidgtes();
            obj.addButtons();
            obj.Tag='OperateSection';
        end
    end




    methods(Access=private)
        function createWidgtes(obj)

            obj.createRunButton();
        end


        function addButtons(obj)

            section=addSection(obj.Tab,"Operate");
            section.Tag='OperateSection';

            column=section.addColumn();
            column.add(obj.RunButton);
        end


        function createRunButton(obj)

            import matlab.ui.internal.toolstrip.Icon.*;
            icon=PLAY_24;
            label1="Run";
            label2="Test Plan";
            label=join([label1,label2],newline);
            obj.RunButton=matlab.ui.internal.toolstrip.Button(label,icon);
            obj.RunButton.Tag='runBtn';
            obj.RunButton.Description="Run simulation";
            obj.RunButton.Enabled=false;
        end

    end
end