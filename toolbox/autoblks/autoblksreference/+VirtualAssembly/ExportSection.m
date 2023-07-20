classdef ExportSection<handle



    properties

        ConfirmButton matlab.ui.internal.toolstrip.Button

Tag

    end

    properties(Access=private)
Tab
    end

    events
GenerateScript
    end

    methods



        function obj=ExportSection(tab)
            obj.Tab=tab;
            obj.createWidgtes();
            obj.addButtons();
            obj.Tag='ExportSection';
        end
    end




    methods(Access=private)
        function createWidgtes(obj)

            obj.createConfirmButton();
        end


        function addButtons(obj)

            section=addSection(obj.Tab,"Build");
            section.Tag='ExportSection';

            column=section.addColumn();
            column.add(obj.ConfirmButton);
        end

        function createConfirmButton(obj)


            import matlab.ui.internal.toolstrip.Icon.*;
            icon=EXPORT_24;
            label='Virtual Vehicle';

            obj.ConfirmButton=matlab.ui.internal.toolstrip.Button(label,icon);
            obj.ConfirmButton.Tag='exportBtn';
            obj.ConfirmButton.Description="Export configured virtual vehicle";
            obj.ConfirmButton.Enabled=false;
        end
    end
end