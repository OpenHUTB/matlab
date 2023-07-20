





classdef LayoutSection<handle

    properties

        DefaultLayoutButton matlab.ui.internal.toolstrip.Button
Tag

    end

    properties(Access=private)
Tab
    end

    methods



        function this=LayoutSection(tab)
            this.Tab=tab;
            this.createWidgtes();
            this.addButtons();
            this.Tag='LayoutSection';
        end
    end




    methods(Access=private)
        function createWidgtes(this)

            this.createDefaultLayoutButton();
        end


        function addButtons(this)

            section=addSection(this.Tab,'Layout');
            section.Tag='LayoutSection';

            column=section.addColumn();
            column.add(this.DefaultLayoutButton);

        end


        function createDefaultLayoutButton(this)

            import matlab.ui.internal.toolstrip.Icon.*;

            icon=LAYOUT_24;
            label1="Default";
            label2="Layout";
            label=join([label1,label2],newline);
            this.DefaultLayoutButton=matlab.ui.internal.toolstrip.Button(label,icon);
            this.DefaultLayoutButton.Tag='defaultLayoutBtn';
            this.DefaultLayoutButton.Description='DefaultLayoutDescription';
        end
    end

end