classdef(Sealed)Message<matlab.mixin.CustomDisplay&coder.Location





























































    properties(SetAccess={?coder.ScreenerInfo})
        Identifier char=''
        Type char=''
        Text char=''
        Category char=''
        SubCategory char=''
        File coder.File=coder.File.empty()
    end

    methods(Access={?codergui.internal.CodegenInfoBuilder,?coder.ScreenerInfo})
        function obj=Message(identifier,type,text,file,category,subCategory,varargin)
            obj@coder.Location(varargin{:});
            if nargin==0
                return
            end
            if nargin>6
                narginchk(12,12)
            else
                narginchk(6,6)
            end
            obj.Identifier=identifier;
            obj.Type=type;
            obj.Text=text;
            obj.Category=category;
            obj.SubCategory=subCategory;
            obj.File=file;
        end
    end

    methods(Access=protected)
        function propgrp=getPropertyGroups(obj)
            if~isscalar(obj)
                propgrp=getPropertyGroups@matlab.mixin.CustomDisplay(obj);
            else
                propList=struct('Identifier',obj.Identifier,...
                'Type',obj.Type,...
                'Text',obj.Text);
                if~isempty(obj.Category)
                    propList.Category=obj.Category;
                end
                if~isempty(obj.SubCategory)
                    propList.SubCategory=obj.SubCategory;
                end
                propList.File=obj.File;
                propList.StartIndex=obj.StartIndex;
                propList.EndIndex=obj.EndIndex;
                propgrp=matlab.mixin.util.PropertyGroup(propList);
            end
        end
    end
end
