classdef VariantContent<matlab.mixin.SetGet

    properties(Access=public)
        type='';
        name='';
        value=[];
    end


    methods(Access=public)
        function obj=VariantContent(values)
            if nargin>0
                numObj=numel(values);
                if numObj==0
                    obj=SimBiology.internal.plotting.categorization.binvalue.VariantContent.empty;
                    return;
                end

                obj=arrayfun(@(~)SimBiology.internal.plotting.categorization.binvalue.VariantContent(),transpose(1:numObj));

                if iscell(values)
                    arrayfun(@(content,value)set(content,'type',value{1}{1},...
                    'name',value{1}{2},...
                    'value',value{1}{4}),...
                    obj,values);
                else
                    arrayfun(@(content,value)set(content,'type',value.type,'name',value.name,'value',value.value),obj,values);
                end
            end
        end

        function variantContents=getStruct(obj)
            variantContents=arrayfun(@(content)struct('type',content.type,...
            'name',content.name,...
            'value',content.value),...
            obj);
        end

        function displayString=getDisplayString(obj)
            displayStringFirst=obj(1).getDisplayStringForSingleObject;
            displayStringRest=arrayfun(@(c)[';',c.getDisplayStringForSingleObject],obj(2:end),'UniformOutput',false);
            displayString=[displayStringFirst,displayStringRest{:}];
        end

        function displayString=getDisplayStringForSingleObject(obj)
            displayString=[obj.name,'=',num2str(obj.value)];
        end
    end
end