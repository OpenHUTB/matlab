classdef RTCSplitItem<handle




    properties(Access=private)
        m_displayLabel;
        m_enabled;
        m_tag;
        m_icon;
        m_checked;
        m_isMultiChoice;
    end

    methods
        function obj=RTCSplitItem(label,tag,isEnabled,isChecked,icon,isMultiChoice)
            obj.m_displayLabel=label;
            obj.m_tag=tag;
            obj.m_icon=icon;
            obj.m_enabled=isEnabled;
            obj.m_checked=isChecked;
            obj.m_isMultiChoice=isMultiChoice;
        end

        function setEnabled(this,enabled)
            this.m_enabled=enabled;
        end

        function setChecked(this,checked)
            this.m_checked=checked;
        end

        function boolRes=isMultiChoiceItem(this)
            boolRes=this.m_isMultiChoice;
        end

        function txt=getDisplayLabel(this)
            txt=this.m_displayLabel;
        end

        function icon=getDisplayIcon(this)
            icon=this.m_icon;
        end

        function enabled=getEnabled(this)
            enabled=this.m_enabled;
        end

        function checked=getChecked(this)
            checked=this.m_checked;
        end

        function tag=getTag(this)
            tag=this.m_tag;
        end

        function checkable=getCheckable(this)
            checkable=true;
        end
    end
end
