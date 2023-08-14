classdef(Sealed)Section<matlab.system.display.PropertyGroup

































    properties(Hidden)




        Type;
        Row;
        AlignPrompts;
    end

    methods
        function obj=Section(varargin)


            defaultTitle='';
            defaultDescription='';
            defaultPropertyList={};
            defaultDependOnPrivatePropertyList={};
            defaultType=matlab.system.display.SectionType.group;


            if mod(numel(varargin),2)~=0
                systemName=varargin{1};
                if~matlab.system.display.isSystem(systemName)
                    error(message('MATLAB:system:unknownSystem',systemName));
                end

                PVArgs=varargin(2:end);
                defaultTitleSource='Auto';

                metaClassData=meta.class.fromName(systemName);
                defaultPropertyList=matlab.system.display.Section.getDefaultPropertyList(metaClassData.PropertyList);
            else
                PVArgs=varargin;
                defaultTitleSource='Property';
            end


            p=inputParser;
            p.FunctionName='matlab.system.display.Section';
            p.addParameter('Title',defaultTitle);
            p.addParameter('Description',defaultDescription);
            p.addParameter('PropertyList',defaultPropertyList);
            p.addParameter('TitleSource',defaultTitleSource);
            p.addParameter('Actions',matlab.system.display.Action.empty);
            p.addParameter('Image',matlab.system.display.Image.empty);
            p.addParameter('DependOnPrivatePropertyList',defaultDependOnPrivatePropertyList);
            p.addParameter('Type',defaultType);
            p.addParameter('Row','');
            p.addParameter('AlignPrompts',true);
            p.parse(PVArgs{:});
            results=p.Results;


            obj.Title=results.Title;
            obj.Description=results.Description;
            obj.PropertyList=results.PropertyList;
            obj.TitleSource=results.TitleSource;
            obj.Actions=results.Actions;
            obj.Image=results.Image;
            if~isempty(results.DependOnPrivatePropertyList)
                obj.DependOnPrivatePropertyList=results.DependOnPrivatePropertyList;
            end
            obj.Type=results.Type;
            obj.Row=results.Row;
            obj.AlignPrompts=results.AlignPrompts;
        end
    end

    methods(Static,Hidden)
        function propertyList=getDefaultPropertyList(metaProperties)

            propertyList={};
            datatypeProps=matlab.system.display.internal.DataTypesGroup.getDataTypePropertyList(metaProperties);

            for propInd=1:numel(metaProperties)
                metaProp=metaProperties(propInd);
                propName=metaProp.Name;


                if~matlab.system.SystemProp.isPublicGetProp(metaProp)||...
                    metaProp.Hidden||metaProp.Abstract||ismember(propName,datatypeProps)
                    continue;
                end


                propertyList{end+1}=propName;%#ok<AGROW>
            end
        end
    end
end

