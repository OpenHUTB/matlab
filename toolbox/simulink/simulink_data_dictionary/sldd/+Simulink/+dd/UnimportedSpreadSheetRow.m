classdef UnimportedSpreadSheetRow<handle





    properties
        prop;
        type;
        details;
    end

    methods
        function obj=UnimportedSpreadSheetRow(prop,type,details)


            obj.prop=prop;
            obj.type=type;
            obj.details=details;
        end

        function propValue=getPropValue(obj,propName)
            switch propName
            case DAStudio.message('SLDD:sldd:Unimported_Vars_ColumnName')
                propValue=obj.prop;
            case DAStudio.message('SLDD:sldd:Unimported_Reason_ColumnName')
                propValue=obj.type;
            case DAStudio.message('SLDD:sldd:Unimported_AdditionalDetails_ColumnName')
                propValue=obj.details;
            otherwise
                propValue='';
            end
        end

        function getPropertyStyle(obj,propName,propertyStyle)

        end

        function isValid=isValidProperty(~,propName)
            switch propName
            case DAStudio.message('SLDD:sldd:Unimported_Vars_ColumnName')
                isValid=true;
            case DAStudio.message('SLDD:sldd:Unimported_Reason_ColumnName')
                isValid=true;
            case DAStudio.message('SLDD:sldd:Unimported_AdditionalDetails_ColumnName')
                isValid=true;
            otherwise
                isValid=false;
            end
        end
    end
end


