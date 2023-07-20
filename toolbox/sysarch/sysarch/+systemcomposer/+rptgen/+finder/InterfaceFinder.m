classdef InterfaceFinder<mlreportgen.finder.Finder































    properties(Constant,Hidden)
        InvalidPropertyNames={};
    end

    properties(Access=private)
InterfaceObj
        InterfaceList=[]
        InterfaceCount{mustBeInteger}=0
        NextInterfaceIndex{mustBeInteger}=0
        IsIterating{mlreportgen.report.validators.mustBeLogical}=false
    end

    properties





        SearchIn="Model";





        Filter="All";
    end

    methods(Static,Access=private,Hidden)





        function ports=getPortsStruct(this,components,interfaceName)
            ports=struct.empty(0,1);
            portcount=1;
            len=length(components);
            for i=1:len
                componentPorts=components(i).Ports;
                numel=length(componentPorts);
                for p=1:numel
                    if strcmp(componentPorts(p).InterfaceName,interfaceName)
                        ports(portcount).InterfaceName=string(interfaceName);
                        componentPath=systemcomposer.rptgen.finder.InterfaceFinder.extractComponentPath(this,components(i).Name);
                        ports(portcount).PortName=string(componentPorts(p).Name);
                        ports(portcount).FullPortName=string(componentPath+"/"+componentPorts(p).Name);
                        ports(portcount).Direction=string(componentPorts(p).Direction);
                        portcount=portcount+1;
                    end
                end
            end
        end

        function componentPath=extractComponentPath(this,componentName)

            import systemcomposer.query.Property;
            model=systemcomposer.loadModel(this.Container);
            constraint=contains(systemcomposer.query.Property('Name'),componentName);
            path=find(model,constraint);
            len=length(path);
            for j=1:len
                s=split(path(j),"/");
                if strcmp(string(s(end)),componentName)
                    componentPath=path(j);
                end
            end
        end



        function interfaceElements=getInterfaceElementsStruct(elements)

            interfaceElements=struct.empty(0,1);
            n=length(elements);
            for j=1:n

                interfaceElements(j).Name=(elements(j).Name);
                if isa(elements,"systemcomposer.interface.DataElement")
                    if isempty(elements(j).Type.Name)
                        interfaceElements(j).Type=(elements(j).Type.DataType);
                        if isempty(elements(j).Type.Description)
                            interfaceElements(j).Description=("-");
                        else
                            interfaceElements(j).Description=(elements(j).Type.Description);
                        end
                        interfaceElements(j).Complexity=(elements(j).Type.Complexity);
                        interfaceElements(j).Dimensions=(elements(j).Type.Dimensions);
                        interfaceElements(j).Maximum=(elements(j).Type.Maximum);
                        interfaceElements(j).Minimum=(elements(j).Type.Minimum);
                    else
                        interfaceElements(j).Type="Bus:"+elements(j).Type.Name;


                        interfaceElements(j).Description=("-");
                        interfaceElements(j).Complexity=("-");
                        interfaceElements(j).Dimensions=("-");
                        interfaceElements(j).Maximum=("-");
                        interfaceElements(j).Minimum=("-");
                    end
                end
            end
        end

        function interfaceElements=getInterfaceElementsStructForServiceInterface(elements)
            interfaceElements=struct.empty(0,1);
            n=length(elements);
            for j=1:n
                interfaceElements(j).Name=elements(j).Name;
                interfaceElements(j).FunctionPrototype=elements(j).FunctionPrototype;
                arguments=elements(j).FunctionArguments;
                interfaceArguments=[];
                for k=1:length(arguments)
                    interfaceArguments(k).Name=arguments(k).Name;
                    interfaceArguments(k).Type=arguments(k).Type.DataType;
                    if~isempty(arguments(k).Dimensions)
                        interfaceArguments(k).Dimensions=arguments(k).Dimensions;
                    else
                        interfaceArguments(k).Dimensions="-";
                    end
                    if~isempty(arguments(k).Description)
                        interfaceArguments(k).Description=arguments(k).Description;
                    else
                        interfaceArguments(k).Description="-";
                    end
                end
                interfaceElements(j).FunctionArguments=interfaceArguments;
            end
        end

        function interface=getInterfaceElementsStructForValueType(elements)
            interface=struct.empty(0,1);
            numel=length(elements);
            for j=1:numel
                interface(j).Name=elements(j).Name;
                interface(j).DataType=elements(j).DataType;
                if isempty(elements(j).Description)
                    interface(j).Description="-";
                else
                    interface(j).Description=elements(j).Description;
                end
                interface(j).Dimensions=elements(j).Dimensions;







                interface(j).Complexity=elements(j).Complexity;
                interface(j).Maximum=elements(j).Maximum;
                interface(j).Minimum=elements(j).Minimum;
            end
        end

        function interfaceElements=getInterfaceElementsStructForPhysicalInterface(elements)
            interfaceElements=struct.empty(0,1);
            numel=length(elements);
            for j=1:numel
                interfaceElements(j).Name=elements(j).Name;
                if~isempty(elements(j).Type)
                    interfaceElements(j).Domain=elements(j).Type.Domain;
                else
                    interfaceElements(j).Domain="-";
                end

            end
        end

        function[interfaceToElementsMap,interfaceToPortsMap]=createInterfaceMap(this)


            import systemcomposer.rptgen.finder.*;
            model=systemcomposer.loadModel(this.Container);
            dict=model.InterfaceDictionary;
            interfaceNames=dict.getInterfaceNames;
            components=model.Architecture.Components;
            interfaceToElementsMap=containers.Map('KeyType','char','ValueType','any');
            interfaceToPortsMap=containers.Map('KeyType','char','ValueType','any');
            numel=length(interfaceNames);
            for i=1:numel
                if isa(dict.Interfaces(i),"systemcomposer.interface.DataInterface")
                    interfaceToPortsMap(char(interfaceNames(i)))=systemcomposer.rptgen.finder.InterfaceFinder.getInterfaceElementsStruct(dict.Interfaces(i).Elements);
                elseif isa(dict.Interfaces(i),"systemcomposer.ValueType")
                    interfaceToPortsMap(char(interfaceNames(i)))=systemcomposer.rptgen.finder.InterfaceFinder.getInterfaceElementsStructForValueType(dict.Interfaces(i));
                elseif isa(dict.Interfaces(i),"systemcomposer.interface.ServiceInterface")
                    interfaceToPortsMap(char(interfaceNames(i)))=systemcomposer.rptgen.finder.InterfaceFinder.getInterfaceElementsStructForServiceInterface(dict.Interfaces(i).Elements);
                elseif isa(dict.Interfaces(i),"systemcomposer.interface.PhysicalInterface")
                    interfaceToPortsMap(char(interfaceNames(i)))=systemcomposer.rptgen.finder.InterfaceFinder.getInterfaceElementsStructForPhysicalInterface(dict.Interfaces(i).Elements);
                end
                interfaceToElementsMap(char(interfaceNames(i)))=systemcomposer.rptgen.finder.InterfaceFinder.getPortsStruct(this,components,interfaceNames(i));
            end
        end

        function interfaceInformation=createInterfaceStruct(this,interfaceName,elementsStruct,portsStruct)


            model=systemcomposer.loadModel(this.Container);
            interfaceObject=model.InterfaceDictionary.getInterface(string(interfaceName));
            interfaceInformation.obj=interfaceObject.UUID;
            interfaceInformation.InterfaceName=string(interfaceName);
            interfaceInformation.Elements=elementsStruct;
            interfaceInformation.Ports=portsStruct;
        end

        function interfaceName=validateInput(interfaceName,interfaceNamesList)
            for name=interfaceName
                if~ismember(name,interfaceNamesList)
                    interfaceName(strcmp(interfaceName,name))=[];
                    msgObj=message('SystemArchitecture:ReportGenerator:InterfaceNotFound',name);
                    warning(msgObj);
                end
            end
        end

        function scope=isModelScope(this)


            model=systemcomposer.loadModel(this.Container);
            scope=true;
            for interface=model.InterfaceDictionary.Interfaces
                if isequal(interface.Owner.getImpl.getStorageContext,systemcomposer.architecture.model.interface.Context.DICTIONARY)
                    scope=false;
                end
            end
        end

        function interfaceNames=extractSpecificInterfaces(this,componentNamesList)

            interfaceNames=[];
            len=length(componentNamesList);
            for i=1:len
                path=systemcomposer.rptgen.finder.InterfaceFinder.extractComponentPath(this,componentNamesList(i));
                hdl=cell2mat(get_param(path,'Handle'));
                for j=1:length(hdl)

                    components=systemcomposer.internal.getWrapperForImpl...
                    (systemcomposer.utils.getArchitecturePeer(hdl(j)),...
                    'systemcomposer.arch.Component');
                    for comp=components
                        for port=comp.Ports
                            if~isempty(port.InterfaceName)
                                interfaceNames=[interfaceNames,string(port.InterfaceName)];
                            end
                        end
                    end
                end
            end
        end
    end


    methods(Hidden)



        function results=getResultsArrayFromStruct(this,interfaceInformation)
            n=numel(interfaceInformation);
            results=mlreportgen.finder.Result.empty(0,n);
            for i=1:n
                temp=interfaceInformation(i);
                results(i)=systemcomposer.rptgen.finder.InterfaceResult(temp.obj);
                results(i).InterfaceName=temp.InterfaceName;
                results(i).Elements=temp.Elements;
                results(i).Ports=temp.Ports;
            end
            this.InterfaceList=results;
            this.InterfaceCount=numel(results);
        end


        function results=findInterfaces(this,varargin)
            import systemcomposer.rptgen.finder.*;

            [interfaceToElementsMap,interfaceToPortsMap]=systemcomposer.rptgen.finder.InterfaceFinder.createInterfaceMap(this);
            interfaceNamesList=[];%#ok<*NASGU>
            interfacesInformation=[];
            query=this.Filter;
            if nargin==2
                interfaceNamesList=varargin{1};
            else
                if query=="All"
                    interfaceNamesList=keys(interfaceToElementsMap);

                else
                    interfaceNamesList=systemcomposer.rptgen.finder.InterfaceFinder.validateInput(query,keys(interfaceToElementsMap));
                end
            end
            len=length(interfaceNamesList);
            for i=1:len
                interfacesInformation=[interfacesInformation,systemcomposer.rptgen.finder.InterfaceFinder.createInterfaceStruct(this,interfaceNamesList(i),...
                interfaceToPortsMap(string(interfaceNamesList(i))),...
                interfaceToElementsMap(string(interfaceNamesList(i))))];%#ok<*AGROW>
            end
            results=getResultsArrayFromStruct(this,interfacesInformation);
        end


        function interfacesInformation=findInterfacesOnPortsInComponent(this)
            import systemcomposer.rptgen.fnder.*;
            import systemcomposer.query.AnyComponent;
            interfacesInformation=[];
            if this.Filter=="All"
                interfaceNamesList=[];
                model=systemcomposer.loadModel(this.Container);
                components=model.Architecture.Components;
                for component=components
                    portsInComponent=component.Ports;
                    for port=portsInComponent
                        if~isempty(port.InterfaceName)
                            interfaceNamesList=[interfaceNamesList,string(port.InterfaceName)];
                        end
                    end
                end
                interfaceNamesList=unique(interfaceNamesList);
                interfacesInformation=[interfacesInformation,findInterfaces(this,interfaceNamesList)];
            else
                componentName=this.Filter;
                modelObj=systemcomposer.loadModel(this.Container);
                componentsInModel=find(modelObj,AnyComponent(),'Recurse',true,'IncludeReferenceModels',true);


                comp=find_system(this.Container,...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'Name',componentName);
                if isempty(ismember(comp,componentsInModel))
                    msgObj=message('SystemArchitecture:ReportGenerator:ComponentNotFound',componentName);
                    warning(msgObj);
                else
                    interfaceNames=systemcomposer.rptgen.finder.InterfaceFinder.extractSpecificInterfaces(this,string(componentName));
                    if~isempty(interfaceNames)
                        interfaceNames(cellfun('isempty',interfaceNames))=[];
                        interfacesInformation=[interfacesInformation,findInterfaces(this,interfaceNames)];
                    else
                        msgObj=message('SystemArchitecture:ReportGenerator:InterfacesNotFound',componentName);
                        warning(msgObj);
                    end
                end
            end
        end

        function results=helper(this)
            switch this.SearchIn
            case "Model"
                results=findInterfaces(this);
            case "Component"
                results=findInterfacesOnPortsInComponent(this);
            end
        end
    end

    methods
        function this=InterfaceFinder(varargin)
            this@mlreportgen.finder.Finder(varargin{:});
            reset(this);
        end

        function results=find(this)










            results=helper(this);
        end

        function tf=hasNext(this)





















            if this.IsIterating
                if this.NextInterfaceIndex<=this.InterfaceCount
                    tf=true;
                else
                    tf=false;
                end
            else
                helper(this);
                if this.InterfaceCount>0
                    this.NextInterfaceIndex=1;
                    this.IsIterating=true;
                    tf=true;
                else
                    tf=false;
                end
            end
        end

        function result=next(this)













            if hasNext(this)

                result=this.InterfaceList(this.NextInterfaceIndex);

                this.NextInterfaceIndex=this.NextInterfaceIndex+1;
            else
                result=systemcomposer.rptgen.finder.InterfaceResult.empty();
            end
        end
    end

    methods(Access=protected)
        function reset(this)






            this.IsIterating=false;
            this.InterfaceCount=0;
            this.InterfaceList=[];
            this.NextInterfaceIndex=0;
        end

        function tf=isIterating(this)






            tf=this.IsIterating;
        end
    end
end