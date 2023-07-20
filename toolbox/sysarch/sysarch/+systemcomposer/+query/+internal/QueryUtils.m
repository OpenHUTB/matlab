classdef QueryUtils<handle
    methods(Static)
        function topModelElements=getTopModelElements(modelElems,varargin)
            import systemcomposer.query.internal.QueryUtils.*;

            intModelElems=[];
            resolver=varargin{1};
            for modelElem=modelElems
                proxyMap=resolver.Proxies;
                proxy=proxyMap.getByKey(get(modelElem,'UUID'));
                if~size(proxy,1)
                    continue;
                end
                for source=proxy.Source.toArray
                    intModelElems=[intModelElems...
                    ,systemcomposer.internal.getWrapperForImpl(source.realElement)];%#ok<AGROW>
                end
            end


            resolvers=varargin{:};
            if numel(resolvers)>1
                topModelElements=getTopModelElements(intModelElems,resolvers(:,2:end));
            else
                topModelElements=intModelElems;
            end
        end

        function connElems=getTopModelConnElems(modelElems,flattenReferences,varargin)
            import systemcomposer.query.internal.QueryUtils.*;



            if~isempty(varargin{1})&&flattenReferences
                connElems=getTopModelElements(modelElems,varargin{1});
            elseif isempty(varargin{1})
                connElems=modelElems;
            end
            connElems=uniquifyConnectorElems(connElems);
        end

        function portElems=getTopModelPortElems(modelElems,flattenReferences,varargin)
            import systemcomposer.query.internal.QueryUtils.*;



            if~isempty(varargin{1})&&~flattenReferences
                portElems=getTopModelElements(modelElems,varargin{:});



                portElems=getComponentPorts(portElems);
            elseif~isempty(varargin{1})&&flattenReferences
                refPortsTopModel=getTopModelElements(modelElems,varargin{:});



                portElems=getComponentPorts(modelElems);


                portElems=[refPortsTopModel,getTopModelElements(portElems,varargin{:})];
            else



                portElems=getComponentPortsAndRootArchitecturePorts(modelElems);
            end
        end

        function compElems=getTopModelCompElems(modelElems,flattenReferences,varargin)
            import systemcomposer.query.internal.QueryUtils.*;



            if~isempty(varargin{1})&&~flattenReferences
                compElems=getTopModelElements(modelElems,varargin{:});



                compElems=getComponents(compElems);
            elseif~isempty(varargin{1})&&flattenReferences
                refCompsTopModel=getTopModelElements(modelElems,varargin{:});



                compElems=getComponents(modelElems);


                compElems=[refCompsTopModel,getTopModelElements(compElems,varargin{:})];
            else



                compElems=getComponents(modelElems);
            end
        end

        function portElems=getComponentPortsAndRootArchitecturePorts(modelElems)
            portElems=[];
            for modelElem=modelElems
                if isa(modelElem,'systemcomposer.arch.ArchitecturePort')
                    compPort=modelElem.getImpl.getParentComponentPort;
                    if size(compPort,1)
                        portElems=[portElems...
                        ,systemcomposer.internal.getWrapperForImpl(compPort)];%#ok<AGROW>
                    else
                        portElems=[portElems,modelElem];%#ok<AGROW>
                    end
                else
                    portElems=[portElems,modelElem];%#ok<AGROW>
                end
            end
        end

        function compPortElems=getComponentPorts(modelElems)
            compPortElems=[];
            for modelElem=modelElems
                if isa(modelElem,'systemcomposer.arch.ArchitecturePort')
                    compPort=modelElem.getImpl.getParentComponentPort;
                    if size(compPort,1)
                        compPortElems=[compPortElems...
                        ,systemcomposer.internal.getWrapperForImpl(compPort)];%#ok<AGROW>
                    end
                else
                    compPortElems=[compPortElems,modelElem];%#ok<AGROW>
                end
            end
        end

        function comps=getComponents(modelElems)
            comps=[];
            for modelElem=modelElems
                if isa(modelElem,'systemcomposer.arch.Architecture')&&...
                    ~size(modelElem.Parent,1)
                    continue;
                elseif isa(modelElem,'systemcomposer.arch.Architecture')
                    comps=[comps,modelElem.Parent];%#ok<AGROW>
                else
                    comps=[comps,modelElem];%#ok<AGROW>
                end
            end
        end

        function uniquePortElems=uniquifyPortElems(portElems)
            uniquePortElems=[];
            compPortElems=[];
            archPortElems=[];
            for idx=1:numel(portElems)
                portElem=portElems(idx);
                if isa(portElem,'systemcomposer.arch.ComponentPort')
                    compPortElems=[compPortElems,portElem];%#ok<AGROW>
                else
                    archPortElems=[archPortElems,portElem];%#ok<AGROW>
                end
            end
            uniquePortElems=[uniquePortElems,unique(compPortElems),unique(archPortElems)];
        end

        function uniqueConnElems=uniquifyConnectorElems(connElems)
            uniqueConnElems=[];
            binaryConnElems=[];
            physConnElems=[];
            for idx=1:numel(connElems)
                connElem=connElems(idx);
                if isa(connElem,'systemcomposer.arch.Connector')
                    binaryConnElems=[binaryConnElems,connElem];%#ok<AGROW>
                else
                    physConnElems=[physConnElems,connElem];%#ok<AGROW>
                end
            end
            uniqueConnElems=[uniqueConnElems,unique(binaryConnElems),unique(physConnElems)];
        end
    end
end