classdef ResultsSection<handle



    properties
        SDIButton matlab.ui.internal.toolstrip.Button
Tag
    end

    properties(Access=private)
Tab
    end

    events
OpenSDI
    end

    methods



        function obj=ResultsSection(tab)
            obj.Tab=tab;
            obj.createWidgtes();
            obj.addButtons();
            obj.Tag='ResultsSection';
        end
    end




    methods(Access=private)
        function createWidgtes(obj)

            obj.createSDIButton();
        end


        function addButtons(obj)

            section=addSection(obj.Tab,"Analyze");
            section.Tag='ResultsSection';

            column=section.addColumn();
            column.add(obj.SDIButton);

        end



        function createSDIButton(obj)

            import matlab.ui.internal.toolstrip.Icon.*;
            icon=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
            'images','ResultSimDataInspector.png');
            label1="Simulation";
            label2="Data Inspector";
            label=join([label1,label2],newline);
            obj.SDIButton=matlab.ui.internal.toolstrip.Button(label,icon);
            obj.SDIButton.Tag='openSDIBtn';
            obj.SDIButton.Description="Open SDI";
            obj.SDIButton.Enabled=false;
        end

    end
end