classdef VirtualAssemblyConstraints<handle



    properties
OptionName
RequiredComponents
RequiredOptions
RequiredOptionIndex
ExclusiveComponents
ExclusiveOptions
ExclusiveOptionIndex
ReqConflitResolution
ExcConflitResolution
    end

    methods(Static)
        function Index=findOptionIndex(component,option)
            if~isempty(find(strcmp(component.Options,option),1))
                Index=find(strcmp(component.Options,option));
            else
                error(message('autoblks_reference:autoerrVirtualAssembly:invalidOptionInputs'));
            end

        end
    end

    methods
        function obj=VirtualAssemblyConstraints(input_name)
            obj.OptionName=input_name;
            obj.RequiredComponents=[];
            obj.RequiredOptions=[];
            obj.RequiredOptionIndex=[];
            obj.ExclusiveComponents=[];
            obj.ExclusiveOptions=[];
            obj.ExclusiveOptionIndex=[];
            obj.ReqConflitResolution=[];
            obj.ExcConflitResolution=[];
        end

        function addRequiredOptions(obj,component,option,resolution)
            obj.RequiredComponents=[obj.RequiredComponents,convertCharsToStrings(component.Name)];
            obj.RequiredOptions=[obj.RequiredOptions,convertCharsToStrings(option)];
            obj.ReqConflitResolution=[obj.ReqConflitResolution,convertCharsToStrings(resolution)];
            optionindex=obj.findOptionIndex(component,option);
            obj.RequiredOptionIndex=[obj.RequiredOptionIndex,optionindex];
        end

        function addExclusiveOptions(obj,component,option,resolution)
            obj.ExclusiveComponents=[obj.ExclusiveComponents,convertCharsToStrings(component.Name)];
            obj.ExclusiveOptions=[obj.ExclusiveOptions,convertCharsToStrings(option)];
            obj.ExcConflitResolution=[obj.ExcConflitResolution,convertCharsToStrings(resolution)];
            optionindex=obj.findOptionIndex(component,option);
            obj.ExclusiveOptionIndex=[obj.ExclusiveOptionIndex,optionindex];
        end

        function removeRequiredOptions(obj,component,option)
            n=find(obj.RequiredOptions==option);
            m=find(obj.RequiredComponents==component.Name);
            index_delete=intersect(n,m);
            obj.RequiredOptions(index_delete)=[];
            obj.RequiredComponents(index_delete)=[];
            obj.RequiredOptionIndex(index_delete)=[];
            obj.ReqConflitResolution(index_delete)=[];
        end

        function removeExclusiveOptions(obj,component,option)
            n=find(obj.ExclusiveOptions==option);
            m=find(obj.ExclusiveComponents==component.Name);
            index_delete=intersect(n,m);
            obj.ExclusiveOptions(index_delete)=[];
            obj.ExclusiveComponents(index_delete)=[];
            obj.ExclusiveOptionIndex(index_delete)=[];
            obj.ExcConflitResolution(index_delete)=[];
        end
    end
end
