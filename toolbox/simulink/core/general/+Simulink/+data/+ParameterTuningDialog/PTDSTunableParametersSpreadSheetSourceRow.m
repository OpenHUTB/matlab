classdef PTDSTunableParametersSpreadSheetSourceRow<handle
    properties

        name;
        storageClass='Model default';
        storageTypeQualifier;
    end
    methods
        function this=PTDSTunableParametersSpreadSheetSourceRow(name,storageClass,storageTypeQualifier)
            this.name=name;
            this.storageClass=storageClass;
            if isequal(storageTypeQualifier,'')
                this.storageTypeQualifier=' ';
            else
                this.storageTypeQualifier=storageTypeQualifier;
            end
        end
        function label=getDisplayLabel(obj)
            label='';
        end

        function iconFile=getDisplayIcon(~)
            iconFile='toolbox/shared/dastudio/resources/info.png';
        end

        function propValue=getPropValue(obj,propName)
            switch propName
            case 'Name'
                propValue=obj.name;
            case 'Storage class'
                propValue=obj.storageClass;
            case 'Storage type qualifier'
                propValue=obj.storageTypeQualifier;
            otherwise
                propValue='';
            end
        end

        function isHyperlink=propertyHyperlink(~,propName,clicked)
            isHyperlink=false;
            if strcmp(propName,'<hyperlink-column-name>')
                isHyperlink=true;
            end
            if clicked

            end
        end

        function isValid=isValidProperty(~,propName)
            isValid=false;
            switch propName
            case 'Name'
                isValid=true;
            case 'Storage class'
                isValid=true;
            case 'Storage type qualifier'
                isValid=true;
            otherwise
                isValid=false;
            end
        end


        function setPropValue(obj,propName,propVal)
            switch propName
            case 'Name'
                if~obj.validate(propVal)

                    error=MSLException([],message('Simulink:dialog:InvalidVarMustBeMatVar',propVal));
                    sldiagviewer.reportError(error);
                else
                    obj.name=propVal;
                end
            case 'Storage class'
                obj.storageClass=propVal;
            case 'Storage type qualifier'
                obj.storageTypeQualifier=propVal;
            otherwise

            end
        end

        function varType=getPropDataType(obj,propName)
            switch propName
            case 'Name'
                varType='string';
            case 'Storage class'
                varType='enum';
            case 'Storage type qualifier'
                varType='string';
            otherwise
                varType='string';
            end
        end

        function propValues=getPropAllowedValues(this,aPropName)
            propValues={};
            try
                switch(aPropName)
                case 'Storage class'
                    propValues={'Model default','ExportedGlobal','ImportedExtern','ImportedExternPointer'};
                case 'Storage type qualifier'
                    propValues={' ','const'};
                otherwise
                    propValues={};
                end
            catch me
                this.reportError(this,me);
            end
        end





        function valid=validate(obj,var)
            valid=isvarname(var);
        end


    end
end
