classdef HelpSection<handle



    properties
        HelpButton matlab.ui.internal.toolstrip.Button
Tag
    end

    properties(Access=private)
Tab
    end

    methods



        function obj=HelpSection(tab)
            obj.Tab=tab;
            obj.createWidgtes();
            obj.addButtons();
            obj.Tag='HelpSection';
        end
    end




    methods(Access=private)
        function createWidgtes(obj)

            obj.createHelpButton();

        end


        function addButtons(obj)

            section=addSection(obj.Tab,"Resources");
            section.Tag='HelpSection';

            column=section.addColumn();
            column.add(obj.HelpButton);

        end


        function createHelpButton(obj)

            import matlab.ui.internal.toolstrip.Icon.*;
            icon=HELP_24;
            label="Workflow Help";
            obj.HelpButton=matlab.ui.internal.toolstrip.Button(label,icon);
            obj.HelpButton.Tag='HelpBtn';
            obj.HelpButton.Description="Workflow for building a virtual vehicle";
        end
    end
end