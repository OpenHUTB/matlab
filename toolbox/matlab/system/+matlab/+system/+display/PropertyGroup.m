classdef(Abstract,Hidden)PropertyGroup<matlab.mixin.Heterogeneous




    properties



        Title;






        TitleSource;



        Description;




        PropertyList;



        Actions;
        Image;
    end

    properties(Hidden)





        DependOnPrivatePropertyList;
    end

    methods
        function obj=set.Title(obj,v)
            if isstring(v)&&isscalar(v)
                v=char(v);
            end
            validateattributes(v,{'char'},{},'','Title');
            obj.Title=v;
        end

        function obj=set.TitleSource(obj,v)
            validstr=validatestring(v,{'Auto','Property'},'','TitleSource');
            obj.TitleSource=validstr;
        end

        function obj=set.Description(obj,v)
            if isstring(v)&&isscalar(v)
                v=char(v);
            end
            validateattributes(v,{'char'},{},'','Description');
            obj.Description=v;
        end

        function obj=set.PropertyList(obj,v)
            if isstring(v)
                v=cellstr(v);
            end
            validateattributes(v,{'cell'},{},'','PropertyList');
            obj.PropertyList=v;
        end

        function obj=set.Actions(obj,v)
            if~isa(v,'matlab.system.display.Action')||~isempty(v)
                validateattributes(v,{'matlab.system.display.Action'},{'row'},'','Actions');
            end
            obj.Actions=v;
        end

        function obj=set.Image(obj,v)
            if~isa(v,'matlab.system.display.Image')||~isempty(v)
                validateattributes(v,{'matlab.system.display.Image'},{'row'},'','Image');
            end
            obj.Image=v;
        end

        function obj=set.DependOnPrivatePropertyList(obj,v)
            validateattributes(v,{'cell'},{},'','DependOnPrivatePropertyList');
            obj.DependOnPrivatePropertyList=v;
        end
    end

    methods(Hidden)
        function propNames=getPropertyNames(obj)

            propNames=obj.PropertyList;

            for propInd=1:numel(propNames)
                propOrName=propNames{propInd};
                if isa(propOrName,'matlab.system.display.internal.Property')
                    propNames{propInd}=propOrName.Name;
                end
            end
        end

        function properties=getDisplayProperties(obj,metaClassData)

            metaProperties=metaClassData.PropertyList;

            propList=obj.PropertyList;
            properties=matlab.system.display.internal.Property.empty;

            for propInd=1:numel(propList)
                prop=propList{propInd};

                if isa(prop,'matlab.system.display.internal.Property')
                    property=prop;
                else
                    property=matlab.system.display.internal.Property(prop);
                end
                property=property.setAttributes(metaProperties);



                if ismember(property.Name,obj.DependOnPrivatePropertyList)
                    property.IsDependent=false;
                end

                properties(end+1)=property;%#ok<AGROW>
            end
        end
    end
end

