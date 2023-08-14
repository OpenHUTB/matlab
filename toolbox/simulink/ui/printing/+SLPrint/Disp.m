classdef Disp<handle
    properties(SetAccess=private)
        DisplayString;
        Object;
    end

    methods
        function this=Disp(obj)
            this.Object=obj;
            displayString=evalc('builtin(''disp'',obj)');

            this.DisplayString=regexprep(displayString,'\n$','');
        end

        function display(this)
            disp(this.DisplayString);
        end

        function propDisp=getPropDisp(this,propName)
            propDisp=regexp(this.DisplayString,...
            ['([^\n]+',propName,': [^\n]*)\n'],'tokens','once');
            if(~isempty(propDisp)&&iscell(propDisp))
                propDisp=propDisp{1};
            end
        end

        function propValueDisp=getPropValueDisp(this,propName)
            propValueDisp=regexp(this.DisplayString,...
            ['[^\n]+',propName,': ([^\n]*)\n'],'tokens','once');
            if(~isempty(propValueDisp)&&iscell(propValueDisp))
                propValueDisp=propValueDisp{1};
            end
        end

        function removeProps(this,propNames)
            if iscell(propNames)
                cellfun(@(x)this.updateProp(x,''),propNames);
            else
                this.updateProp(propNames,'');
            end
        end

        function appendPropValue(this,propName,appendText)
            this.updateProp(propName,['$1$2$3$4',appendText,'\n']);
        end

        function prependPropValue(this,propName,appendText)
            this.updateProp(propName,['$1$2$3',appendText,'$4\n']);
        end

        function updatePropValue(this,propName,newPropValue)
            replacement=strtrim(newPropValue);
            this.updateProp(propName,['$1$2$3',replacement,'\n']);
        end

        function updateProp(this,propName,replacement)





            this.DisplayString=regexprep(this.DisplayString,...
            ['([^\n]+)(',propName,')(: )([^\n]*)\n'],...
            replacement);
        end

        function showAllEnumValues(this)


            cls=metaclass(this.Object);
            enumProps=findobj([cls.Properties{:}],...
            'Hidden',false,...
            'HasDefault',true,...
            '-function',@(x)~isempty(enumeration(x.DefaultValue)));

            for enumProp=enumProps
                this.showEnumValue(enumProp);
            end
        end

        function showEnumValue(this,prop,allEnumNames)


            if(isa(prop,'meta.property'))
                propName=prop.Name;
                propValue=this.Object.(propName);
                [~,allEnumNames]=enumeration(propValue);
            else
                propName=prop;
                propValue=this.Object.(propName);
            end
            propValue=char(propValue);






            propLabel=sprintf(' %s |',allEnumNames{:});
            propLabel=sprintf('[%s]\n',propLabel(1:end-1));



            propLabel=strrep(propLabel,...
            sprintf(' %s ',propValue),...
            sprintf(' {%s} ',propValue));


            this.updatePropValue(propName,propLabel);
        end
    end
end