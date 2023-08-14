classdef VirtualAssemblyComponents<handle



    properties
Name
Options
Constraints
Path
Model
Variants
OptionVariantName
ConnectedComponents
VariantType
ActivationDependency
ConflictDependency
    end

    methods
        function obj=VirtualAssemblyComponents(input_model,input_name,input_path,varianttype,activationdependency,conflictdependency,ProductCatalogData)

            obj.Name=input_name;
            obj.Options=[];
            obj.OptionVariantName=[];
            obj.Path=input_path;
            obj.Model=input_model;
            obj.ConnectedComponents=[];
            obj.VariantType=varianttype;
            obj.ActivationDependency=activationdependency;
            obj.ConflictDependency=conflictdependency;


            if~contains(obj.VariantType,'none')&&~contains(obj.VariantType,'mask')&&~contains(obj.VariantType,'dataset')&&~contains(obj.VariantType,'label')
                input_path=input_path(1);

                for i=1:length(ProductCatalogData.FeatureParameters)
                    if strcmp(ProductCatalogData.FeatureParameters{i}.Feature,input_name)
                        obj.Options=ProductCatalogData.FeatureParameters{i}.FeatureVariant;
                        break;
                    end
                end

                obj.OptionVariantName=obj.Options;




                for i=1:length(obj.Options)
                    obj.Constraints{i}=VirtualAssembly.VirtualAssemblyConstraints(obj.Options{i});
                    var=struct('Name',obj.Options{i},...
                    'BlockName',[char(input_path),'/',obj.Options{i}]);
                    if isempty(obj.Variants)
                        obj.Variants=var;
                    else
                        obj.Variants(end+1)=var;
                    end
                end
            else
                obj.Variants=[];
                for i=1:length(ProductCatalogData.FeatureParameters)
                    if strcmp(ProductCatalogData.FeatureParameters{i}.Feature,input_name)
                        obj.Options=ProductCatalogData.FeatureParameters{i}.FeatureVariant;
                        break;
                    end
                end
                for i=1:length(obj.Options)
                    obj.Constraints{i}=VirtualAssembly.VirtualAssemblyConstraints(obj.Options{i});
                end
            end

        end

        function addConstraints(obj,self_option,flag,component,option,resolution)
            for i=1:length(obj.Options)
                option_name=obj.Options{i};
                if strcmp(option_name,self_option)
                    switch flag
                    case 'required'
                        obj.Constraints{i}.addRequiredOptions(component,option,resolution);
                        if isempty(obj.ConnectedComponents)
                            obj.ConnectedComponents=convertCharsToStrings(component.Name);
                        else
                            if isempty(find(obj.ConnectedComponents==component.Name,1))
                                obj.ConnectedComponents=[obj.ConnectedComponents,convertCharsToStrings(component.Name)];
                            end
                        end
                    case 'exclusive'
                        obj.Constraints{i}.addExclusiveOptions(component,option,resolution);
                        if isempty(obj.ConnectedComponents)
                            obj.ConnectedComponents=convertCharsToStrings(component.Name);
                        else
                            if isempty(find(obj.ConnectedComponents==component.Name,1))
                                obj.ConnectedComponents=[obj.ConnectedComponents,convertCharsToStrings(component.Name)];
                            end
                        end
                    otherwise
                        error(message('autoblks_reference:autoerrVirtualAssembly:invalidRequiredOrFlag'));
                    end
                    break;
                end
            end
        end

        function removeConstraints(obj,self_option,flag,component,option)
            for i=1:length(obj.Options)
                option_name=obj.Options{i};
                if strcmp(option_name,self_option)
                    switch flag
                    case 'required'
                        obj.Constraints{i}.removeRequiredOptions(component,option);
                    case 'exclusive'
                        obj.Constraints{i}.removeExclusiveOptions(component,option);
                    otherwise
                        error(message('autoblks_reference:autoerrVirtualAssembly:invalidRequiredOrFlag'));
                    end
                    break;
                end
            end
        end

        function removeOptions(obj,deletedOption)
            n=find(obj.Options==deletedOption);
            obj.Options(n)=[];
            obj.Constraints(n)=[];
            obj.OptionVariantName(n)=[];
        end
    end
end