classdef UIComponentFactory

    methods(Static)
        function grid=createGridLayout(parent,gridOptions)
            grid=uigridlayout(parent,[1,1],gridOptions);
        end

        function tree=createTree(parent,treeOptions)
            tree=uitree(parent,treeOptions);
        end

        function out=createTable(parent,tableOptions)
            out=uitable('Parent',parent,tableOptions);
        end

        function out=createLabel(parent,widgetOptions)

            supportedOptions={'Enable','Tag','Text','Visible'};
            labelOptions=rmfield(widgetOptions,setdiff(fieldnames(widgetOptions),supportedOptions));
            out=uilabel(parent,labelOptions);
        end

        function out=createDropdown(parent,widgetOptions)

            supportedOptions={'Enable','Items','Tag','Value','ValueChangedFcn','Visible'};
            dropdownOptions=rmfield(widgetOptions,setdiff(fieldnames(widgetOptions),supportedOptions));

            if~any(matches(dropdownOptions.Items,dropdownOptions.Value))
                dropdownOptions.Value=dropdownOptions.Items{1};
            end
            out=uidropdown(parent,dropdownOptions);
        end

        function out=createEditText(parent,widgetOptions)

            supportedOptions={'Enable','Tag','Value','ValueChangedFcn','Visible'};
            editTextOptions=rmfield(widgetOptions,setdiff(fieldnames(widgetOptions),supportedOptions));
            out=uieditfield(parent,editTextOptions);
        end

        function out=createCheckbox(parent,widgetOptions)

            supportedOptions={'Enable','Tag','Text','Value','ValueChangedFcn','Visible'};
            checkboxOptions=rmfield(widgetOptions,setdiff(fieldnames(widgetOptions),supportedOptions));
            if~islogical(checkboxOptions.Value)
                checkboxOptions.Value=logical(str2double(checkboxOptions.Value));
            end
            out=uicheckbox(parent,checkboxOptions);
            out.Layout.Column=widgetOptions.Column;
        end

        function out=createPanel(parent,widgetOptions)
            supportedOptions={'Title','Tag','Visible'};
            panelOptions=rmfield(widgetOptions,setdiff(fieldnames(widgetOptions),supportedOptions));
            out=uipanel(parent,panelOptions);
        end

        function out=createAccordian(parent)
            out=matlab.ui.container.internal.Accordion('Parent',parent);
        end

        function out=createAccordianPanel(parent,widgetOptions)
            supportedOptions={'Title','Tag','Visible'};
            panelOptions=rmfield(widgetOptions,setdiff(fieldnames(widgetOptions),supportedOptions));

            out=matlab.ui.container.internal.AccordionPanel('Parent',parent,panelOptions);
        end
    end
end