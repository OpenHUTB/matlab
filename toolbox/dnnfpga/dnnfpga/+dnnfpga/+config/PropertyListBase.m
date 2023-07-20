


classdef(Abstract)PropertyListBase<handle


    properties



    end

    properties(Access=protected)






        Properties=[];




        HiddenProperties=[];

    end

    properties(Hidden)

        ShowHidden=false;
    end

    properties(Constant,Access=protected)

        ColumnNum=49;
        IndentNum=5;


    end


    methods
        function obj=PropertyListBase()



            obj.Properties=containers.Map('UniformValues',false);


            obj.HiddenProperties=containers.Map();

        end

    end

    methods(Access=protected)
        function propertyList=getVisiblePropertyList(obj)

            propertyList={};
            propertyGroups=obj.Properties.keys;
            for ii=1:length(propertyGroups)
                aPropertyGroup=propertyGroups{ii};
                properties=obj.Properties(aPropertyGroup);
                for jj=1:length(properties)
                    property=properties{jj};

                    if obj.HiddenProperties.isKey(property)&&~obj.ShowHidden
                        continue;
                    end
                    propertyList{end+1}=property;%#ok<AGROW>
                end
            end
        end
    end


    methods(Access=protected)


    end


    methods(Access=protected)

        function dispProperties(obj,propertyGroup,skipReturnSymbol)

            if nargin<3
                skipReturnSymbol=false;
            end


            properties=obj.Properties(propertyGroup);
            for ii=1:length(properties)
                property=properties{ii};

                if obj.HiddenProperties.isKey(property)&&~obj.ShowHidden
                    continue;
                end

                if(isprop(obj,'ModuleGeneration')&&~obj.ModuleGeneration)...
                    &&~strcmp(property,'ModuleGeneration')
                    continue;
                end
                dispParameter(obj,property);
            end

            if~skipReturnSymbol
                fprintf('\n');
            end

        end














        function dispHeading(obj,name)


            strongBegin='';strongEnd='';
            if matlab.internal.display.isHot()
                strongBegin=getString(message('MATLAB:table:localizedStrings:StrongBegin'));
                strongEnd=getString(message('MATLAB:table:localizedStrings:StrongEnd'));
            end
            fmt=[strongBegin,'%s',strongEnd];

            spaces=repmat(' ',1,obj.ColumnNum-obj.IndentNum-length(name));
            fprintf('%s',spaces);
            fprintf(fmt,name);
            fprintf('\n');

        end
        function dispParameter(obj,property)


            spaces=repmat(' ',1,obj.ColumnNum-obj.IndentNum-length(property));

            propertyValue=dnnfpga.config.getPropertyValue(obj,property);

            [value,fmt]=dnnfpga.config.refineValueForDisplay(propertyValue);
            fprintf(fmt,spaces,property,value);
        end

    end


end


