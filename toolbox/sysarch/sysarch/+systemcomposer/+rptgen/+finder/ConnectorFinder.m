classdef ConnectorFinder<mlreportgen.finder.Finder















































    properties(Constant,Hidden)
        InvalidPropertyNames={};
    end

    properties
        Filter="Architecture";
        ComponentName;
    end

    properties(Access=private)
ConnectorObj
        ConnectorList=[]
        ConnectorCount{mustBeInteger}=0
        NextConnectorIndex{mustBeInteger}=0
        IsIterating{mlreportgen.report.validators.mustBeLogical}=false
    end

    methods(Static,Access=private,Hidden)








        function connectorStruct=createConnectorStruct(connector)
            connectorStruct.obj=connector.UUID;
            connectorStruct.Name=connector.Name;

            if isa(connector,'systemcomposer.arch.PhysicalConnector')
                ports=connector.Ports;
                portNames=[];
                for(port=ports)
                    portNames=[portNames,strcat(string(port.Parent.Name),filesep,string(port.Name))];
                end
                connectorStruct.SourcePort=portNames(1);
                connectorStruct.DestinationPort=portNames(2);
            else
                connectorStruct.SourcePort=connector.SourcePort.Name;
                connectorStruct.DestinationPort=connector.DestinationPort.Name;
            end

            connectorStruct.Parent=connector.Parent.Name;
            stereotypes=connector.getStereotypes;
            stereotypeNames=[];
            for s=stereotypes
                stereotypeNames=[stereotypeNames,string(s)];
            end
            connectorStruct.Stereotypes=stereotypeNames;

        end

        function componentNamesList=extractComponentsFromModel(this)

            componentNamesList=[];
            model=systemcomposer.loadModel(this.Container);
            constraint=systemcomposer.query.AnyComponent();
            components=find(model,constraint);
            len=length(components);
            for i=1:len

                componentNamesList=[componentNamesList,string(components(i))];
            end
        end

        function validateInput(this,componentName)
            componentNamesList=systemcomposer.rptgen.finder.ConnectorFinder.extractComponentsFromModel(this);
            if~ismember(componentName,componentNamesList)
                msgObj=message('SystemArchitecture:ReportGenerator:ComponentNotFound',componentName);
                warning(msgObj);
            end
        end
    end

    methods(Hidden)



        function results=getResultsArrayFromStruct(this,connectorInformation)
            n=numel(connectorInformation);
            results=mlreportgen.finder.Result.empty(0,n);
            for i=1:n
                temp=connectorInformation(i);
                results(i)=systemcomposer.rptgen.finder.ConnectorResult(temp.obj);
                results(i).Name=temp.Name;
                results(i).SourcePort=temp.SourcePort;
                results(i).DestinationPort=temp.DestinationPort;
                results(i).Parent=temp.Parent;
                results(i).Stereotypes=temp.Stereotypes;
            end
            this.ConnectorList=results;
            this.ConnectorCount=numel(results);
        end

        function results=findConnectors(this)
            connectorInformation=[];
            model=systemcomposer.loadModel(this.Container);
            if this.Filter=="Architecture"
                if isempty(this.ComponentName)
                    connectors=model.Architecture.get('Connectors');
                else
                    connectors=[];
                end
            elseif this.Filter=="Component"
                systemcomposer.rptgen.finder.ConnectorFinder.validateInput(this,this.ComponentName);
                hdl=get_param(this.ComponentName,'Handle');
                comp=systemcomposer.internal.getWrapperForImpl...
                (systemcomposer.utils.getArchitecturePeer(hdl),...
                'systemcomposer.arch.Component');

                connectors=comp.OwnedArchitecture.Connectors;
            end
            if~isempty(connectors)
                for connector=connectors
                    connectorInformation=[connectorInformation,systemcomposer.rptgen.finder.ConnectorFinder.createConnectorStruct(connector)];
                end
            end
            results=getResultsArrayFromStruct(this,connectorInformation);
        end
    end

    methods
        function this=ConnectorFinder(varargin)
            this@mlreportgen.finder.Finder(varargin{:});
            reset(this)
        end

        function results=find(this)










            results=findConnectors(this);
        end

        function tf=hasNext(this)





















            if this.IsIterating
                if this.NextConnectorIndex<=this.ConnectorCount
                    tf=true;
                else
                    tf=false;
                end
            else
                findConnectors(this)
                if this.ConnectorCount>0
                    this.NextConnectorIndex=1;
                    this.IsIterating=true;
                    tf=true;
                else
                    tf=false;
                end
            end
        end

        function result=next(this)













            if hasNext(this)

                result=this.ConnectorList(this.NextConnectorIndex);

                this.NextConnectorIndex=this.NextConnectorIndex+1;
            else
                result=systemcomposer.rptgen.finder.ConnectorResult.empty();
            end
        end
    end

    methods(Access=protected)
        function reset(this)






            this.IsIterating=false;
            this.ConnectorCount=0;
            this.ConnectorList=[];
            this.NextConnectorIndex=0;
        end

        function tf=isIterating(this)






            tf=this.IsIterating;
        end
    end
end