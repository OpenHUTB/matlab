classdef FaultSpreadsheetInnerRow < autosar.ui.bsw.SpreadsheetRow

    properties ( SetAccess = private, GetAccess = public )
        Parent
    end

    properties ( Access = public )
        Fault autosar.ui.bsw.Fault
    end

    properties ( Access = public, Constant = true )
        NameColumn = DAStudio.message( 'autosarstandard:ui:uiFaultName' );
        TypeColumn = DAStudio.message( 'autosarstandard:ui:uiFaultType' );
    end

    methods
        function this = FaultSpreadsheetInnerRow( dlgSource, parent, fault )
            arguments
                dlgSource
                parent autosar.ui.bsw.FaultSpreadsheetRow
                fault autosar.ui.bsw.Fault
            end
            this = this@autosar.ui.bsw.SpreadsheetRow( dlgSource, false );
            this.Parent = parent;
            this.Fault = fault;
        end

        function aLabel = getDisplayLabel( this )
            aLabel = this.Fault.FaultName;
        end

        function bIsValid = isValidPropertyImpl( this, aPropName )
            switch aPropName
                case { this.NameColumn, this.TypeColumn }
                    bIsValid = true;
                otherwise
                    bIsValid = false;
            end
        end

        function bIsReadOnly = isReadonlyPropertyImpl( this, aPropName )%#ok<INUSD>
            bIsReadOnly = false;
        end

        function propType = getPropDataTypeImpl( this, aPropName )
            switch aPropName
                case this.TypeColumn
                    propType = 'enum';
                otherwise
                    propType = 'text';
            end
        end

        function propValues = getPropAllowedValuesImpl( this, aPropName )
            switch aPropName
                case this.TypeColumn
                    propValues = { 'Override', 'Inject' };
                otherwise
                    propValues = {  };
            end
        end

        function aPropValue = getPropValueImpl( this, aPropName )
            switch aPropName
                case this.NameColumn
                    aPropValue = this.Fault.FaultName;
                case this.TypeColumn
                    aPropValue = this.Fault.FaultType;
                otherwise
                    assert( false, 'Accessing unexpected property' );
            end
        end

        function setPropValueImpl( this, aPropName, aPropValue )
            switch aPropName
                case this.NameColumn
                    this.Fault.FaultName = aPropValue;
                case this.TypeColumn
                    this.Fault.FaultType = aPropValue;
                    dialog = DAStudio.ToolRoot.getOpenDialogs( this.DlgSource );
                    autosar.ui.bsw.FaultSpreadsheet.onItemClicked( 'faultTagfaultSpreadsheet', { this }, this.TypeColumn, dialog );
                otherwise
                    assert( false, 'Accessing unexpected property' );
            end
        end
    end
end


