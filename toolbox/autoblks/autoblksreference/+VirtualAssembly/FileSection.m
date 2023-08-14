classdef FileSection<handle



    properties
        NewButton matlab.ui.internal.toolstrip.Button

        OpenButton matlab.ui.internal.toolstrip.Button

        SaveButton matlab.ui.internal.toolstrip.Button

Tag
    end

    properties(Access=private)
Tab
    end

    methods



        function obj=FileSection(tab)
            obj.Tab=tab;
            obj.createWidgtes();
            obj.addButtons();
            obj.Tag='FileSection';
        end
    end




    methods(Access=private)
        function createWidgtes(obj)

            obj.createNewButton();
            obj.createOpenButton();
            obj.createSaveButton();
        end


        function addButtons(obj)

            section=addSection(obj.Tab,"File");
            section.Tag='FileSection';

            column=section.addColumn();
            column.add(obj.NewButton);

            column=section.addColumn();
            column.add(obj.OpenButton);

            column=section.addColumn();
            column.add(obj.SaveButton);
        end


        function createNewButton(obj)

            import matlab.ui.internal.toolstrip.Icon.*;
            icon=NEW_24;
            label="New";
            obj.NewButton=matlab.ui.internal.toolstrip.Button(label,icon);
            obj.NewButton.Tag='newBtn';
            obj.NewButton.Description="Create a new session and specify the project path";
        end


        function createOpenButton(obj)

            import matlab.ui.internal.toolstrip.Icon.*;
            icon=OPEN_24;
            label="Open";
            obj.OpenButton=matlab.ui.internal.toolstrip.Button(label,icon);
            obj.OpenButton.Tag='openBtn';
            obj.OpenButton.Description="Open a saved session";
        end

        function createSaveButton(obj)

            import matlab.ui.internal.toolstrip.Icon.*;
            icon=SAVE_24;
            label="Save";

            obj.SaveButton=matlab.ui.internal.toolstrip.Button(label,icon);
            obj.SaveButton.Tag='saveBtn';
            obj.SaveButton.Description="Save session";
            obj.SaveButton.Enabled=false;
        end
    end
end