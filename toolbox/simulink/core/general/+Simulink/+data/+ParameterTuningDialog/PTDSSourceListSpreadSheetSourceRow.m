classdef PTDSSourceListSpreadSheetSourceRow<handle
    properties

        name;
        hmodel;
        tunableParametersSource;
    end
    methods
        function this=PTDSSourceListSpreadSheetSourceRow(name,hmodel,tunableParametersSource)
            this.name=name;
            this.hmodel=hmodel;
            this.tunableParametersSource=tunableParametersSource;
        end
        function label=getDisplayLabel(obj)
            label='';
        end

        function iconFile=getDisplayIcon(obj)
            iconFile='toolbox/shared/dastudio/resources/info.png';
        end

        function propValue=getPropValue(obj,propName)
            switch propName
            case 'Name'
                propValue=obj.name;
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

        function noEditable=isHierarchyReadonly(~)
            noEditable=true;
        end

        function getPropertyStyle(obj,aPropName,propertyStyle)
            if isempty(obj.tunableParametersSource)
                tunableVarsName=get_param(obj.hmodel,'TunableVars');
                tunableVarsNameCellArray=strsplit(tunableVarsName,',');
                if dot(ismember(tunableVarsNameCellArray,obj.name),ones(1,numel(tunableVarsNameCellArray)))>0
                    propertyStyle.Bold=true;
                    propertyStyle.Italic=true;
                end
            else
                tunableParameters=obj.tunableParametersSource.getAllRows;
                for i=1:numel(tunableParameters)
                    if isequal(tunableParameters(i).name,obj.name)
                        propertyStyle.Bold=true;
                        propertyStyle.Italic=true;
                    end
                end
            end
        end

        function isValid=isValidProperty(~,propName)
            isValid=false;
            switch propName
            case 'Name'
                isValid=true;
            otherwise
                isValid=false;
            end
        end
    end
end
