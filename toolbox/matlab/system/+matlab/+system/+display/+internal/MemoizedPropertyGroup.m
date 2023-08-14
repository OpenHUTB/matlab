classdef(Sealed,Hidden)MemoizedPropertyGroup<handle




    properties(Access=private)
        pPropertyGroup;
        pDisplayProperties;
        pSections;
    end

    properties(Dependent,SetAccess=private)

        IsSection;
        IsSectionGroup;
        IsDataTypesGroup;
        IsFiSettings;


        Title;
        TitleSource;
        Description;
        Actions;
        Image;
        DependOnPrivatePropertyList;
        Sections;
        NumSections;
        Type;
        Row;
        AlignPrompts;
        IncludeInShortDisplay;
    end

    methods
        function v=get.IsSection(obj)
            v=isa(obj.pPropertyGroup,'matlab.system.display.Section');
        end

        function v=get.IsSectionGroup(obj)
            v=isa(obj.pPropertyGroup,'matlab.system.display.SectionGroup');
        end

        function v=get.IsDataTypesGroup(obj)
            v=isa(obj.pPropertyGroup,'matlab.system.display.internal.DataTypesGroup');
        end

        function v=get.IsFiSettings(obj)
            v=obj.IsSectionGroup&&obj.pPropertyGroup.IsFiSettings;
        end

        function v=get.Title(obj)
            v=obj.pPropertyGroup.Title;
        end

        function v=get.TitleSource(obj)
            v=obj.pPropertyGroup.TitleSource;
        end

        function v=get.Description(obj)
            v=obj.pPropertyGroup.Description;
        end

        function v=get.Actions(obj)
            v=obj.pPropertyGroup.Actions;
        end

        function v=get.Image(obj)
            v=obj.pPropertyGroup.Image;
        end

        function v=get.DependOnPrivatePropertyList(obj)
            v=obj.pPropertyGroup.DependOnPrivatePropertyList;
        end

        function v=get.Sections(obj)
            v=obj.pSections;
        end

        function v=get.NumSections(obj)
            v=obj.pPropertyGroup.NumSections;
        end

        function v=get.Type(obj)
            v=obj.pPropertyGroup.Type;
        end

        function v=get.Row(obj)
            v=obj.pPropertyGroup.Row;
        end

        function v=get.AlignPrompts(obj)
            v=obj.pPropertyGroup.AlignPrompts;
        end

        function v=get.IncludeInShortDisplay(obj)
            v=obj.IsSectionGroup&&obj.pPropertyGroup.IncludeInShortDisplay;
        end
    end

    methods
        function obj=MemoizedPropertyGroup(propertyGroup)
            obj.pPropertyGroup=propertyGroup;
            if isa(propertyGroup,'matlab.system.display.SectionGroup')
                obj.pSections=matlab.system.display.internal.Memoizer.memoize(propertyGroup.Sections);
            end
            mlock;
        end

        function propNames=getPropertyNames(obj)
            propNames=obj.pPropertyGroup.getPropertyNames;
        end

        function properties=getDisplayProperties(obj,metaClassData,varargin)

            p=inputParser;
            p.addParameter('SetDescription',false);
            p.parse(varargin{:});
            inputs=p.Results;

            if~isempty(obj.pDisplayProperties)
                properties=obj.pDisplayProperties;
            else
                properties=getDisplayProperties(obj.pPropertyGroup,metaClassData);
                obj.pDisplayProperties=properties;
            end


            if inputs.SetDescription
                for property=properties
                    if isempty(property.Description)&&~property.IsUserDefinedDescription
                        property.Description=matlab.system.ui.DialogManager.getPropertyPrompt(metaClassData.Name,property.Name);
                    end
                end
            end
        end
    end
end
