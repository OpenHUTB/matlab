classdef SpreadsheetRow<autosar.ui.bsw.SpreadsheetBase




    properties(SetAccess=private)
        IsHierarchical=false;
        Children={};
    end

    methods(Abstract)
        aLabel=getDisplayLabel(this);

        bIsValid=isValidPropertyImpl(this,aPropName)
        bIsReadOnly=isReadonlyPropertyImpl(this,aPropName)


        propType=getPropDataTypeImpl(this,aPropName)

        aPropValue=getPropValueImpl(this,aPropName)
        setPropValueImpl(this,aPropName,aPropValue)
    end

    methods
        function this=SpreadsheetRow(dlgSource,isHierarchical)
            this=this@autosar.ui.bsw.SpreadsheetBase(dlgSource);
            this.IsHierarchical=isHierarchical;
        end

        function aIcon=getDisplayIcon(~)
            aIcon='';
        end

        function propValue=getPropAllowedValuesImpl(this,aPropName)%#ok<INUSD>
            propValue={};
        end

        function isHierarchical=isHierarchical(this)
            isHierarchical=this.IsHierarchical;
        end
    end

    methods(Sealed)
        function children=getHierarchicalChildren(this)
            if this.IsHierarchical
                children=this.Children;
            else
                children=[];
            end
        end

        function addHierarchicalChild(this,child)
            this.Children=[this.Children;child];
        end

        function removeChild(this,child)
            this.Children(this.Children==child)=[];
        end

        function bIsValid=isValidProperty(this,aPropName)
            try
                bIsValid=this.isValidPropertyImpl(aPropName);
            catch me
                this.reportError(me);
            end
        end

        function bIsReadOnly=isReadonlyProperty(this,aPropName)
            try
                bIsReadOnly=this.isReadonlyPropertyImpl(aPropName);
            catch me
                this.reportError(me);
            end
        end

        function propType=getPropDataType(this,aPropName)
            try
                propType=this.getPropDataTypeImpl(aPropName);
            catch me
                this.reportError(me);
            end
        end

        function aPropValue=getPropValue(this,aPropName)
            try
                aPropValue=this.getPropValueImpl(aPropName);
            catch me
                this.reportError(me);
            end
        end

        function propValue=getPropAllowedValues(this,aPropName)
            try
                propValue=this.getPropAllowedValuesImpl(aPropName);
            catch me
                this.reportError(me);
            end
        end

        function setPropValue(this,aPropName,aPropValue)
            try
                this.setPropValueImpl(aPropName,aPropValue);
            catch me
                this.reportError(me);
            end

            aDlgs=DAStudio.ToolRoot.getOpenDialogs(this.DlgSource);
            assert(numel(aDlgs)==1,'Expected only one open dialog');
            aDlgs.enableApplyButton(true);
        end
    end
end
