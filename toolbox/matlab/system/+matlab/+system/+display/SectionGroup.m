classdef(Sealed)SectionGroup<matlab.system.display.PropertyGroup
































    properties



        Sections;
        Type;
        Row;
        AlignPrompts;
    end

    properties(Hidden,Dependent,SetAccess=private)
        NumSections;
    end

    properties(Hidden)
        IncludeInShortDisplay;


        IsFiSettings;
    end

    methods
        function obj=set.Sections(obj,v)
            if~isa(v,'matlab.system.display.Section')||~isempty(v)
                validateattributes(v,{'matlab.system.display.Section'},{'row'},'','Sections');
            end
            obj.Sections=v;
        end

        function obj=set.Type(obj,v)
            obj.Type=v;
        end

        function obj=set.Row(obj,v)
            obj.Row=v;
        end

        function obj=set.AlignPrompts(obj,v)
            obj.AlignPrompts=v;
        end

        function v=get.NumSections(obj)
            v=numel(obj.Sections);
        end

        function obj=SectionGroup(varargin)


            if mod(numel(varargin),2)~=0
                systemName=varargin{1};
                if~matlab.system.display.isSystem(systemName)
                    error(message('MATLAB:system:unknownSystem',systemName));
                end

                PVArgs=varargin(2:end);
                defaultTitleSource='Auto';
                defaultSections=matlab.system.display.Section(systemName);
            else
                PVArgs=varargin;
                defaultTitleSource='Property';
                defaultSections=matlab.system.display.Section.empty;
            end
            defaultType=matlab.system.display.SectionType.tab;

            p=inputParser;
            p.FunctionName='matlab.system.display.SectionGroup';
            p.addParameter('Title','');
            p.addParameter('Description','');
            p.addParameter('PropertyList',{});
            p.addParameter('TitleSource',defaultTitleSource);
            p.addParameter('Sections',defaultSections);
            p.addParameter('Actions',matlab.system.display.Action.empty);
            p.addParameter('Image',matlab.system.display.Image.empty);
            p.addParameter('DependOnPrivatePropertyList',{});
            p.addParameter('IncludeInShortDisplay',false);
            p.addParameter('IsFiSettings',false);
            p.addParameter('Type',defaultType);
            p.addParameter('Row','');
            p.addParameter('AlignPrompts',true);
            p.parse(PVArgs{:});
            results=p.Results;


            obj.Title=results.Title;
            obj.Description=results.Description;
            obj.PropertyList=results.PropertyList;
            obj.TitleSource=results.TitleSource;
            obj.Sections=results.Sections;
            obj.Actions=results.Actions;
            obj.Image=results.Image;
            if~isempty(results.DependOnPrivatePropertyList)
                obj.DependOnPrivatePropertyList=results.DependOnPrivatePropertyList;
            end
            obj.IncludeInShortDisplay=results.IncludeInShortDisplay;
            obj.IsFiSettings=results.IsFiSettings;
            obj.Type=results.Type;
            obj.Row=results.Row;
            obj.AlignPrompts=results.AlignPrompts;
        end
    end
end

