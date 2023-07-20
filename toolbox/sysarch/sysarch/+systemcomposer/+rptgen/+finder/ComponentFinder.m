classdef ComponentFinder<mlreportgen.finder.Finder
























    properties(Constant,Hidden)
        InvalidPropertyNames={};
    end

    properties(Access=private)
CompObj
        CompList=[]
        CompCount{mustBeInteger}=0
        NextCompIndex{mustBeInteger}=0
        IsIterating{mlreportgen.report.validators.mustBeLogical}=false
    end

    properties

        Query;



        Recurse=true;




        IncludeReferenceModels=false;
    end

    methods(Static,Access=private,Hidden)
        function componentPath=extractComponentPath(this,componentName)

            import systemcomposer.query.Property;
            model=systemcomposer.loadModel(this.Container);
            constraint=contains(systemcomposer.query.Property('Name'),componentName);
            [path,obj]=find(model,constraint);
            for i=1:length(obj)
                if strcmp(string(obj(i).Name),componentName)
                    componentPath=path(i);
                end
            end
        end

        function interfaceNames=extractSpecificInterfaces(this,componentName)

            interfaceNames=[];
            path=systemcomposer.rptgen.finder.ComponentFinder.extractComponentPath(this,componentName);
            hdl=cell2mat(get_param(path,'Handle'));
            for j=1:length(hdl)

                components=systemcomposer.internal.getWrapperForImpl...
                (systemcomposer.utils.getArchitecturePeer(hdl(j)),...
                'systemcomposer.arch.Component');
                for comp=components
                    for port=comp.Ports
                        if~isempty(port.InterfaceName)
                            interfaceNames=[interfaceNames,string(port.InterfaceName)];%#ok<*AGROW>
                        end
                    end
                end
            end
        end

        function componentInformation=createComponentStruct(this,component)






            componentInformation.obj=component.UUID;
            componentInformation.Name=string(component.Name);
            if isempty(component.Parent)
                componentInformation.Parent="-";
            else
                componentInformation.Parent=string(component.Parent.Name);
            end
            componentInformation.Interfaces=systemcomposer.rptgen.finder.ComponentFinder.extractSpecificInterfaces(this,component.Name);
            componentInformation.Children=mlreportgen.finder.Result.empty();
            if component.isReference()
                componentInformation.ReferenceName=component.ReferenceName;
            else
                componentInformation.ReferenceName="";
            end
            componentInformation.Ports=component.Ports;

            modelHandle=load_system(this.Container);
            isARM=Simulink.internal.isArchitectureModel(modelHandle,"AUTOSARArchitecture");
            if isARM
                kind=autosar.composition.pi.PropertyHandler.getPropertyValue(...
                component.SimulinkHandle,'ComponentKind');
                componentInformation.Kind=kind;
            end
            componentInformation.FullName=component.getQualifiedName;

            if~isempty(component.OwnedArchitecture)
                if~isempty(component.OwnedArchitecture.Components)

                    componentInformation.Children=arrayfun(@(subcomp)systemcomposer.rptgen.finder.ComponentFinder.createComponentStruct(this,subcomp),...
                    component.OwnedArchitecture.Components,'UniformOutput',false);
                end
            end
            n=numel(componentInformation.Children);
            resultsArray=mlreportgen.finder.Result.empty(0,n);
            for i=1:n
                temp=componentInformation.Children{i};
                resultsArray(i)=systemcomposer.rptgen.finder.ComponentResult(temp.obj);
                resultsArray(i).Name=temp.Name;
                resultsArray(i).Parent=temp.Parent;
                resultsArray(i).Interfaces=temp.Interfaces;
                resultsArray(i).Children=temp.Children;
                resultsArray(i).Ports=temp.Ports;
                resultsArray(i).ReferenceName=temp.ReferenceName;
                resultsArray(i).ModelName=this.Container;
                resultsArray(i).FullName=temp.FullName;
                resultsArray(i).Interfaces=systemcomposer.rptgen.finder.ComponentFinder.extractSpecificInterfaces(this,temp.Name);
            end
            componentInformation.Children=resultsArray;
        end

        function componentNamesList=extractComponentsFromModel(this)

            componentNamesList=[];
            model=systemcomposer.loadModel(this.Container);
            constraint=AnyComponent();
            components=find(model,constraint);
            len=length(components);
            for i=1:len
                componentPath=split(components(i),"/");
                componentNamesList=[componentNamesList,string(componentPath(end))];
            end
        end

        function validateInput(this,componentName)
            componentNamesList=systemcomposer.rptgen.finder.ComponentFinder.extractComponentsFromModel(this);
            for component=componentName
                if~ismember(component,componentNamesList)
                    msgObj=message('SystemArchitecture:ReportGenerator:ComponentNotFound',component);
                    warning(msgObj);
                end
            end
        end

        function components=extractSpecificComponents(this,componentNamesList)

            components=[];
            import systemcomposer.query.Property;
            model=systemcomposer.loadModel(this.Container);
            len=length(componentNamesList);
            for i=1:len
                constraint=contains(systemcomposer.query.Property('Name'),componentNamesList(i));
                [path,component]=find(model,constraint);
                pathLength=length(path);
                for j=1:pathLength
                    s=split(path(j),"/");
                    if strcmp(string(s(end)),componentNamesList(i))
                        components=[components,component(j)];
                    end
                end
            end
        end
    end

    methods(Hidden)
        function results=getResultsArrayFromStruct(this,componentsInformation)
            n=numel(componentsInformation);
            results=mlreportgen.finder.Result.empty(0,n);
            for i=1:n
                temp=componentsInformation(i);
                results(i)=systemcomposer.rptgen.finder.ComponentResult(temp.obj);
                results(i).Name=temp.Name;
                results(i).Parent=temp.Parent;
                results(i).Description=get_param(temp.FullName,'Description');
                modelHandle=load_system(this.Container);
                isARM=Simulink.internal.isArchitectureModel(modelHandle,"AUTOSARArchitecture");
                if isARM
                    results(i).Kind=temp.Kind;
                end
                results(i).Interfaces=temp.Interfaces;
                results(i).Children=temp.Children;
                results(i).Ports=temp.Ports;
                results(i).ReferenceName=temp.ReferenceName;
                results(i).FullName=temp.FullName;
                results(i).ModelName=this.Container;
            end
            this.CompList=results;
            this.CompCount=numel(results);
        end



        function results=findComponents(this,varargin)
            results=[];
            componentsInformation=[];
            model=systemcomposer.loadModel(this.Container);
            if~isempty(this.Query)
                [~,components]=model.find(this.Query,'Recurse',this.Recurse,...
                'IncludeReferenceModels',this.IncludeReferenceModels);
                numel=length(components);
                for i=1:numel
                    if isa(components(i),"systemcomposer.arch.Component")
                        if components(i).IsAdapterComponent==0
                            componentsInformation=[componentsInformation,systemcomposer.rptgen.finder.ComponentFinder.createComponentStruct(this,components(i))];
                        end
                    else
                        componentsInformation=[componentsInformation,systemcomposer.rptgen.finder.ComponentFinder.createComponentStruct(this,components(i))];
                    end

                end
                results=getResultsArrayFromStruct(this,componentsInformation);
            end
        end
    end

    methods
        function this=ComponentFinder(varargin)
            this@mlreportgen.finder.Finder(varargin{:});
            reset(this)
        end

        function results=find(this)










            results=findComponents(this);
        end

        function tf=hasNext(this)





















            if this.IsIterating
                if this.NextCompIndex<=this.CompCount
                    tf=true;
                else
                    tf=false;
                end
            else
                find(this)
                if this.CompCount>0
                    this.NextCompIndex=1;
                    this.IsIterating=true;
                    tf=true;
                else
                    tf=false;
                end
            end
        end

        function result=next(this)













            if hasNext(this)

                result=this.CompList(this.NextCompIndex);

                this.NextCompIndex=this.NextCompIndex+1;
            else
                result=systemcomposer.rptgen.finder.ComponentResult.empty();
            end
        end
    end

    methods(Access=protected)
        function reset(this)






            this.IsIterating=false;
            this.CompCount=0;
            this.CompList=[];
            this.NextCompIndex=0;
        end

        function tf=isIterating(this)






            tf=this.IsIterating;
        end
    end
end