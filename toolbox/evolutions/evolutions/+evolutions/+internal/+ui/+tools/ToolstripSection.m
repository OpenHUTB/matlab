classdef(Abstract)ToolstripSection<handle









    properties(Abstract,Constant)

Title

Name
    end

    properties(SetAccess=immutable,GetAccess=public)
Section
Parent
        IconsFilePath=fullfile(matlabroot,'toolbox','evolutions',...
        'web','evolutionTree','release','images');
    end

    methods(Abstract,Access=protected)
        createSectionComponents(this);
        layoutSection(this);
    end

    methods
        function this=ToolstripSection(parent)


            this.Parent=parent;

            this.Section=matlab.ui.internal.toolstrip.Section;
            tag=strcat(getTagPrefix(parent),'section_',lower(this.Name));
            this.Section.Tag=tag;
            this.Section.Title=this.Title;


            createSectionComponents(this);
            layoutSection(this);
        end

        function toolSection=getSection(this)
            toolSection=this.Section;
        end

        function title=getAppTitle(this)
            title=getAppTitle(this.Parent);
        end

        function tagPrefix=getTagPrefix(this)
            tagPrefix=getTagPrefix(this.Parent);
        end

        function tag=createChildTag(this,childName)
            tag=strcat(getTagPrefix(this),'widget_',lower(childName));
        end
    end

    methods(Access=protected)
        function column=addColumn(this,varargin)

            column=this.Section.addColumn(varargin{:});
        end
    end

    methods(Static)
        function setTooltipText(component,tooltipStr)
            component.Description=tooltipStr;
        end

        function button=createButton(label,icon,tag,tooltipStr)
            label=evolutions.internal.ui.tools.ToolstripSection.splitAtFirstWord(label);
            button=matlab.ui.internal.toolstrip.Button(label,icon);
            button.Tag=tag;
            button.Description=tooltipStr;
        end

        function splitButton=createSplitButton(label,icon,tag,tooltipStr)
            splitButton=matlab.ui.internal.toolstrip.SplitButton(...
            label,icon);
            splitButton.Tag=tag;
            splitButton.Description=tooltipStr;
        end

        function popup=createPopupList(tag)
            popup=matlab.ui.internal.toolstrip.PopupList();
            popup.Tag=tag;
        end

        function popup=createPopupListHeader(label,tag)
            popup=matlab.ui.internal.toolstrip.PopupListHeader(label);
            popup.Tag=tag;
        end

        function button=createDropDownButton(label,icon,tag,tooltipStr)
            button=matlab.ui.internal.toolstrip.DropDownButton(...
            label,icon);
            button.Tag=tag;
            button.Description=tooltipStr;
        end

        function toggleButton=createToggleButton(label,icon,tag,varargin)
            toggleButton=matlab.ui.internal.toolstrip.ToggleButton(...
            label,icon);
            toggleButton.Tag=tag;
            if length(varargin)>=1
                toggleButton.Description=varargin{1};
            end
        end

        function label=createLabel(labelString)
            label=matlab.ui.internal.toolstrip.Label(labelString);
        end

        function radioButton=createRadioButton(group,label,tag,tooltipStr)
            radioButton=matlab.ui.internal.toolstrip.RadioButton(...
            group,label);
            radioButton.Tag=tag;
            radioButton.Description=tooltipStr;
        end

        function checkBox=createCheckBox(label,tag,tooltipStr)
            checkBox=matlab.ui.internal.toolstrip.CheckBox(label);
            checkBox.Tag=tag;
            checkBox.Description=tooltipStr;
        end

        function dropDown=createDropDown(list,tag,tooltipStr)
            assert(iscell(list)&&iscolumn(list),'List should be a column of strings.')
            dropDown=matlab.ui.internal.toolstrip.DropDown(list);
            dropDown.Tag=tag;
            dropDown.SelectedIndex=1;
            dropDown.Description=tooltipStr;
        end

        function slider=createSlider(range,startVal,tag,tooltipStr)
            slider=matlab.ui.internal.toolstrip.Slider(range,startVal);
            slider.Tag=tag;
            slider.Description=tooltipStr;
        end

        function spinner=createSpinner(range,startVal,tag,tooltipStr)
            spinner=matlab.ui.internal.toolstrip.Spinner(range,startVal);
            spinner.Tag=tag;
            spinner.Description=tooltipStr;
        end

        function editField=createEditField(str,tag,tooltipStr)
            editField=matlab.ui.internal.toolstrip.EditField(str);
            editField.Tag=tag;
            editField.Description=tooltipStr;
        end

        function newStr=splitAtFirstWord(str)
            newStr=strtrim(str);
            wpaceIdx=find(isstrprop(newStr,'wspace'),1);
            if~isempty(wpaceIdx)
                newStr=replaceBetween(newStr,wpaceIdx,wpaceIdx,newline);
            end
        end
    end
end


