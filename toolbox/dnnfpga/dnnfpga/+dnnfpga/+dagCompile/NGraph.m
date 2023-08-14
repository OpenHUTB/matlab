








classdef NGraph<handle&matlab.mixin.Copyable

    properties
        components=dnnfpga.dagCompile.Component.empty;
        nets=dnnfpga.dagCompile.Net.empty;
ProcessorConfig
Processor
    end

    properties(Hidden=true)
        componentMap=[];
        netMap=[];
report
digraphInner
        digraphVersion=0;
        updateVersion=0;

        nextId=uint32(0);
    end
    properties(Dependent)
digraph
    end
    methods
        function obj=NGraph(componentData,processor,activationLayer,processorConfig)








            obj.components=dnnfpga.dagCompile.Component.empty;
            obj.nets=dnnfpga.dagCompile.Net.empty;
            obj.componentMap=containers.Map('KeyType','char','ValueType','Any');
            obj.netMap=containers.Map('KeyType','char','ValueType','Any');




            if nargin==0
                return;
            end

            hasIdentityCustomLayer=false;
            try
                hasIdentityCustomLayer=processorConfig.getModuleProperty('custom','Identity');
                if dnnfpga.dagCompile.Utils.cmpChars(hasIdentityCustomLayer,'on')
                    hasIdentityCustomLayer=true;
                else
                    hasIdentityCustomLayer=false;
                end
            catch
            end


            try



                internalAnalyzeNetwork=deepapp.internal.analyzer.report.AnalyzeNetwork();


                try
                    obj.report=internalAnalyzeNetwork.doAnalysis(componentData,'zzz',false);
                catch
                    obj.report=internalAnalyzeNetwork.doAnalysis(componentData,'zzz',false,{});
                end
            catch e
                throw(e);
            end


            obj.ProcessorConfig=processorConfig;
            obj.Processor=processor;

            for i=1:length(componentData.Layers)
                layer=componentData.Layers(i);


                obj.validateNetworkLayers(layer,processor);


                component=dnnfpga.dagCompile.Component(layer,layer.Name,obj.ProcessorConfig);
                obj.addComponent(component);
                component.addPortInsts();

            end


            if isa(componentData,'DAGNetwork')
                obj.addConnectivity(componentData.Connections);
            elseif isa(componentData,'SeriesNetwork')
                obj.addConnectivity();
            elseif isa(componentData,'dlnetwork')
                obj.addConnectivity(componentData.Connections);
            else
                error(message('dnnfpga:simulation:InvalidNetwork'));
            end

            obj.propogateSizes();
            obj.removeDanglingPortinsts();
            obj.removeResizeComponents();


            obj.mergeStateComponents();


            obj.restructureLabelComponents();




            if hasIdentityCustomLayer
                obj.addMemSeparators();
            end



            obj.updateConstantValues();

            obj.removeDanglingNets();


            obj.numberComponents();
            obj.numberNets();







            if~isempty(activationLayer)
                activationLayerName=strsplit(activationLayer,'/');
                activationComponent=obj.getComponent(activationLayerName{1});


                if(~activationComponent.isOutput)

                    activationOutputLayerName='dnnfpgaActivationOutput';
                    activationOutputLayer=regressionLayer('Name',activationOutputLayerName);
                    activationOutputComponent=dnnfpga.dagCompile.Component(activationOutputLayer);
                    obj.addComponent(activationOutputComponent);


                    activationOutputComponent.addPortInsts();
                    source=obj.getOutputPortInst(activationLayer);
                    destination=obj.getInputPortInst(activationOutputLayerName);
                    net=obj.getOrCreateNet(source);
                    net.addPortInst(destination);


                    obj.numberComponents();
                    obj.numberNets();
                end


                obj.simplifyGraphForActivation(activationLayer);
            end




            obj.addDataFormat();
            obj.addDataFormatFCDirect();

            obj.numberComponents();
            obj.numberNets();



            dnnfpga.dagCompile.Layers.validateNGraphLayers(obj,processor);



            obj.removeDataFormatComponents();

            obj.numberComponents();
            obj.numberNets();


        end


        function id=uniqueId(obj,init)
            if nargin<2
                init=false;
            end
            id=obj.nextId;
            if init
                obj.nextId=uint32(0);
            else
                obj.nextId(:)=obj.nextId+uint32(1);
            end
        end



        function mergeStateComponents(obj)
            for componentRead=obj.components'
                if endsWith(componentRead.name,'__Read')
                    stateName=componentRead.name(1:end-6);
                    componentWriteName=[stateName,'__Write'];
                    componentWrite=obj.getComponent(componentWriteName);
                    netWrite=componentWrite.inputs.net;
                    netRead=componentRead.outputs.net;
                    obj.removeComponent(componentRead);
                    componentRead.name=stateName;
                    componentRead.nLayer={};
                    obj.addComponent(componentRead);
                    pinst=componentRead.outputs;
                    pinst.nameFull=[componentRead.name,'/',pinst.name];
                    obj.removeNet(netRead);
                    netRead.name=netRead.driver.nameFull;
                    obj.addNet(netRead);
                    for pinst=netWrite.receivers
                        if pinst.component==componentWrite
                            pinst.component=componentRead;
                            componentRead.inputs=pinst;
                            pinst.nameFull=[componentRead.name,'/',pinst.name];
                        end
                    end

                    for pinst=componentWrite.outputs'
                        obj.removeNet(pinst.net)
                    end
                    obj.removeComponent(componentWrite);

                end
            end
        end



        function restructureLabelComponents(obj)
            import dnnfpga.dagCompile.*
            components=obj.components';
            for component=components
                if component.hasKind(LayerKind.Label)
                    name=component.name;
                    netIn=component.inputs.net;
                    netOut=component.outputs.net;
                    for pinst=netIn.receivers
                        if pinst.component==component
                            componentNew=Component(LayerKind.Label,name);
                            pinst.component=componentNew;
                            componentNew.inputs=pinst;
                            componentNew.outputs={};
                        end
                    end
                    for pinst=netOut.receivers
                        netIn.addPortInst(pinst);
                    end

                    obj.removeComponent(component);
                    obj.addComponent(componentNew);
                    obj.removeNet(netOut);
                end
            end
        end

        function insertMemSeparator(obj,pinst)
            id=obj.uniqueId();
            name=['memSeparator_',int2str(id)];
            layer=dnnfpga.layer.identityLayer('Name',name);
            component=dnnfpga.dagCompile.Component(layer,layer.Name,obj.ProcessorConfig);
            obj.insertComponentCleanly(component,pinst);
        end





        function addMemSeparators(obj)
            import dnnfpga.dagCompile.*

            pinstCount=uint16(0);
            allPinsts=[];




            function initPortinst(pinst)
                if pinst.data==0
                    pinstCount(:)=pinstCount+uint16(1);
                    pinst.init(pinstCount);
                    allPinsts=[allPinsts,pinst];
                end
            end



            function g=createPortinstGraph()
                g=graph();
                for component=obj.components'
                    if component.hasConstrainedMemOutput()
                        for pinst=component.outputs'
                            net=pinst.net;
                            g=addNetToGraph(g,net);
                        end
                    end
                    if component.hasConstrainedMemInput()
                        for pinst=component.inputs'
                            net=pinst.net;
                            g=addNetToGraph(g,net);
                        end
                    end
                    if component.hasSharedMem()
                        if numel(component.inputs)==1&&numel(component.outputs)==1
                            initPortinst(component.inputs);
                            initPortinst(component.outputs);
                            g=g.addedge(component.inputs.data,component.outputs.data,0);
                            g=addNetToGraph(g,component.inputs.net);
                            g=addNetToGraph(g,component.outputs.net);
                        end
                    end
                end
            end

            function g=addNetToGraph(g,net)
                prev={};
                for p=[net.driver,net.receivers]
                    if~isempty(prev)
                        initPortinst(prev);
                        initPortinst(p);
                        g=g.addedge(p.data,prev.data,0);

                    end
                    prev=p;
                end
            end

            function g=updatePortinstGraph(g,pinst)
                count=g.numnodes();
                num1=pinst.data;
                for num2=1:count
                    g=g.rmedge(num1,num2);
                end
            end


            for net=obj.nets'
                for pinst=[net.driver,net.receivers]
                    pinst.clear();
                    pinst.init(uint16(0));
                end
            end

            g=createPortinstGraph();
            count=g.numnodes();

            d=distances(g);



            for component=obj.components'
                if component.hasConstrainedMemOutput()
                    for pinst=component.outputs'
                        num1=pinst.data;
                        for num2=1:count
                            if d(num1,num2)==0
                                p=allPinsts(num2);
                                if p~=pinst&&p.isReceiver()
                                    if p.component.hasConstrainedMemInput()||p.component.hasConstrainedMemOutput()
                                        if pinst.isDriver()&&pinst.net==p.net&&...
                                            pinst.component.hasKind(LayerKind.Concat)...
                                            p.component.hasKind(LayerKind.Concat)

                                        else


                                            g=updatePortinstGraph(g,p);

                                            d=distances(g);

                                            obj.insertMemSeparator(p);
                                        end
                                    end
                                end
                            end
                        end
                    end
                end



                if component.hasConstrainedMemInput()
                    for pinst=component.inputs'
                        num1=pinst.data;
                        for num2=1:count
                            if d(num1,num2)==0
                                p=allPinsts(num2);
                                if p~=pinst&&p.isReceiver()
                                    if p.component.hasConstrainedMemInput()||p.component.hasConstrainedMemOutput()
                                        if pinst.isDriver()&&pinst.net==p.net&&...
                                            pinst.component.hasKind(LayerKind.Concat)...
                                            p.component.hasKind(LayerKind.Concat)

                                        else


                                            g=updatePortinstGraph(g,p);

                                            d=distances(g);

                                            obj.insertMemSeparator(p);
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        function validateNetworkLayers(obj,layer,processor,processorConfig)%#ok<INUSL>



            if~dnnfpga.dagCompile.Layers.isSupported(layer,obj.ProcessorConfig)
                msg=message('dnnfpga:dnnfpgacompiler:UnsupportedLayer',class(layer));
                error(msg);
            end


            dnnfpga.dagCompile.Layers.validateNetworkLayers(layer,processor);

        end


        function component=getComponent(obj,name,noError)
            if nargin<3
                noError=false;
            end
            try
                component=obj.componentMap(name);
            catch ME
                if noError
                    component={};
                else
                    throwAsCaller(ME);
                end
            end
        end

        function net=getNet(obj,name)
            try
                net=obj.netMap(name);
            catch ME
                throwAsCaller(ME);
            end
        end

        function obj=addComponent(obj,component)
            if isa(component,'dnnfpga.dagCompile.Component')
                obj.setModified();
                obj.components=cat(1,obj.components,component);
                obj.componentMap(component.name)=component;
                component.ngraph=obj;
            else
                msg=message('dnnfpga:workflow:InvalidDataWrongClass','component','dnnfpga.dagCompile.Component',class(component));
                error(msg);
            end
        end

        function obj=addNet(obj,net)
            if isa(net,'dnnfpga.dagCompile.Net')
                obj.setModified();
                obj.nets=cat(1,obj.nets,net);
                obj.netMap(net.name)=net;
                net.ngraph=obj;
            else
                msg=message('dnnfpga:workflow:InvalidDataWrongClass','net','dnnfpga.dagCompile.Net',class(net));
                error(msg);
            end
        end
    end

    methods(Access=public)

        function components=getInputComponents(obj)


            components=[];
            i=1;
            for idx=1:numel(obj.components)
                currComp=obj.components(idx);
                if currComp.isInput()
                    components{i}=currComp;
                    i=i+1;
                end
            end
        end

        function components=getSortedInputComponents(obj)


            components=[];
            i=1;
            for idx=1:numel(obj.sortedComponents)
                currComp=obj.sortedComponents(idx);
                if currComp.isInput()
                    components{i}=currComp;
                    i=i+1;
                end
            end
        end

        function components=getOutputComponents(obj)


            components=[];
            i=1;
            for idx=1:numel(obj.components)
                currComp=obj.components(idx);
                if currComp.isOutput()
                    components{i}=currComp;
                    i=i+1;
                end
            end
        end

        function components=getSortedOutputComponents(obj)


            components=[];
            i=1;
            for idx=1:numel(obj.sortedComponents)
                currComp=obj.sortedComponents(idx);
                if currComp.isOutput()
                    components{i}=currComp;
                    i=i+1;
                end
            end
        end

    end

    methods

        function simplifyGraphForActivation(obj,activationLayer)

            actParts=strsplit(activationLayer,'/');










            obj.components.initVisit(false);
            activationComponent=obj.getActivationComponent(actParts{1});
            obj.markActivationOutputComponentAsVisited(activationComponent,actParts{2});
            obj.backwardTraverse(activationComponent);
            obj.removeNotVisitedComponents();
            obj.removeDanglingNets();
        end

        function activationComponent=getActivationComponent(obj,activationLayer)

            for component=obj.components'
                if strcmp(component.name,activationLayer)
                    activationComponent=component;
                end
            end
        end

        function markActivationOutputComponentAsVisited(~,activationComponent,actOutputName)

            for i=1:numel(activationComponent.outputs)

                output=activationComponent.outputs(i);
                if strcmpi(output.name,actOutputName)

                    for receiver=output.net.receivers


                        if strcmpi(receiver.component.name,'dnnfpgaActivationOutput')

                            receiver.component.visited=true;
                            break
                        end
                    end
                end
            end
        end

        function backwardTraverse(obj,component)

            component.visited=true;
            if isempty(component.inputs)
                return;
            end
            if numel(component.inputs)==1
                for driver=component.inputs.net.driver
                    obj.backwardTraverse(driver.component);
                end
            else

                for i=1:numel(component.inputs)
                    for driver=component.inputs(i).net.driver
                        obj.backwardTraverse(driver.component);
                    end
                end
            end
        end

        function removeNotVisitedComponents(obj)

            for component=obj.components'
                if~component.visited

                    if~isempty(component.inputs)
                        for i=1:numel(component.inputs)
                            netIn=component.inputs(i).net;
                            netIn.removePortInst(component.inputs);
                        end
                    end

                    if~isempty(component.outputs)
                        for i=1:numel(component.outputs)
                            netOut=component.outputs(i).net;
                            obj.removeNet(netOut);
                        end
                    end

                    obj.removeComponent(component);
                end
            end
        end

        function removeDanglingNets(obj)

            for net=obj.nets'
                if isempty(net.receivers)

                    driver=net.driver;
                    componentDriver=driver.component;
                    componentDriver.removePortInst(driver);

                    obj.removeNet(net);
                end
            end
        end


        function updateConstantValues(obj)
            import dnnfpga.dagCompile.*
            for component=obj.components'
                if component.hasKind(LayerKind.Constant)
                    layer=component.nLayer;

                    if~isempty(layer)
                        sz=component.outputs.size;
                        value=ones(sz);
                        value=layer.Value*value;
                        component.ConstValue=value;
                    end
                end
            end
        end
    end

    methods


        function net=getOrCreateNet(obj,p_source)
            try
                existing=obj.getNet(p_source.nameFull);
            catch
                existing=dnnfpga.dagCompile.Net(p_source);
                obj.addNet(existing);
            end
            net=existing;
        end

        function obj=addConnectivity(obj,connections)
            if nargin>1
                for i=1:length(connections.Destination)
                    source=connections.Source{i};
                    dest=connections.Destination{i};
                    p_source=obj.getOutputPortInst(source);
                    p_dest=obj.getInputPortInst(dest);
                    net=obj.getOrCreateNet(p_source);
                    net.driver=p_source;
                    net.addPortInst(p_dest);
                end
                for c=obj.components'
                    for pinst=c.outputs'
                        if isempty(pinst.net)
                            net=obj.getOrCreateNet(pinst);
                            net.driver=pinst;
                        end
                    end
                end
            else

                p_source={};
                p_dest={};
                n=length(obj.components);
                for i=1:n
                    c=obj.components(i);
                    if i>1
                        p_dest=c.inputs(1);
                        net=obj.getOrCreateNet(p_source);
                        net.addPortInst(p_dest);
                    end
                    if i<n
                        p_source=c.outputs(1);
                    end
                end
            end
        end
        function pInst=getInputPortInst(obj,name)
            both=strsplit(name,'/');
            c_name=both{1};
            try
                p_name=both{2};
            catch
                p_name='in';
            end
            component=obj.componentMap(c_name);
            for i=1:length(component.inputs)
                p=component.inputs(i);
                if strcmp(p_name,p.name)
                    pInst=p;
                end
            end
        end
        function pInst=getOutputPortInst(obj,name)
            both=strsplit(name,'/');
            c_name=both{1};
            try
                p_name=both{2};
            catch
                p_name='out';
            end
            component=obj.componentMap(c_name);
            for i=1:length(component.outputs)
                p=component.outputs(i);
                if strcmp(p_name,p.name)
                    pInst=p;
                end
            end
        end

        function removeComponent(obj,component)
            obj.setModified();

            cc=obj.componentMap(component.name);
            if(cc==component)
                remove(obj.componentMap,component.name);
            end
            components=[];
            for i=1:numel(obj.components)
                c=obj.components(i);
                if c~=component
                    components=cat(1,components,c);
                end
            end
            obj.components=components;
        end

        function removeNet(obj,net)
            obj.setModified();
            if(isKey(obj.netMap,net.name))
                remove(obj.netMap,net.name);
            end
            nets=[];
            for i=1:numel(obj.nets)
                n=obj.nets(i);
                if n~=net
                    nets=cat(1,nets,n);
                end
            end
            obj.nets=nets;
        end



        function removeComponentCleanly(obj,component,allowMismatch)
            if nargin<3
                allowMismatch=false;
            end
            if numel(component.inputs)==1&&numel(component.outputs)==1
                netIn=component.inputs.net;
                netOut=component.outputs.net;
                if all(netIn.size==netOut.size)||allowMismatch
                    netIn.removePortInst(component.inputs);
                    for i=1:numel(netOut.receivers)
                        pinst=netOut.receivers(i);
                        netIn.addPortInst(pinst);

                    end
                    obj.removeNet(netOut);
                    obj.removeComponent(component);
                end
            end
        end




        function insertComponentCleanly(obj,component,pinst)

            component.addPortInsts();
            sz=pinst.size;
            netOrig=pinst.net;
            netOut=dnnfpga.dagCompile.Net(component.outputs);
            netOut.receivers=pinst;
            pinst.net=netOut;
            netOut.size=sz;
            netOut.driver.size=sz;
            component.inputs.size=sz;
            netOrig.replacePortInst(component.inputs,pinst)
            component.inputs.net=netOrig;
            obj.addNet(netOut);
            obj.addComponent(component);

        end

        function numberComponents(obj)
            for i=1:numel(obj.components)
                component=obj.components(i);
                component.id=uint32(i);
            end
        end

        function numberNets(obj)
            for i=1:numel(obj.nets)
                net=obj.nets(i);
                net.id=uint32(i);
            end
        end

        function addDigraph(obj)
            obj.digraphInner=digraph();
            obj.numberComponents();
            obj.digraphInner=addnode(obj.digraphInner,numel(obj.components));
            for i=1:numel(obj.nets)
                net=obj.nets(i);
                source=net.driver.component.id;
                for j=1:numel(net.receivers)
                    dest=net.receivers(j).component.id;

                    obj.digraphInner=addedge(obj.digraphInner,source,dest,single(net.id));
                end
            end
        end

        function toDot(obj,addColor,addLabels,addSizes,fileName)

            render=false;

            if nargin<2
                addColor=true;
            end

            if nargin<3
                addLabels=true;
            end

            if nargin<4
                addSizes=false;
            end

            if nargin<5
                name=tempname;
                fileName=[tempname,'.dot'];
                imageName=[tempname,'.png'];
                fprintf("Generated dot file is located at: %s\n",fileName);
                fprintf("Rendered image is located at: %s\n",imageName);
                render=true;
            else
                fprintf("Generated dot file is located at: %s\n",fileName);
            end


            fid=fopen(fileName,'w');
            fprintf(fid,"digraph structs {\n");
            fprintf(fid,"  overlap = false\n");
            fprintf(fid,"  nodesep = 2.0\n");
            fprintf(fid,"  ranksep = 0.3\n");
            fprintf(fid,"  node [shape=Mrecord, style=filled];\n");
            fprintf(fid,"  rankdir = TB\n");
            fprintf(fid,"  splines = false\n\n");

            for i=1:numel(obj.components)
                component=obj.components(i);
                component.toDot(fid,addColor);
            end

            fprintf(fid,"\n");

            for i=1:numel(obj.nets)
                net=obj.nets(i);
                net.toDot(fid,addLabels,addSizes);
            end

            fprintf(fid,"}\n");
            fclose(fid);


            if render

                status=1;
                dotExecutable=dnnfpga.dagCompile.Utils.findDotExecutable();

                command=[dotExecutable,' ',fileName,' -Tpng -o ',imageName];
                status=system(command);

                if~status
                    h=figure('Visible','Off');
                    img=imread(imageName);
                    im=image(img);
                    das=daspect();
                    d=max(das);
                    daspect([d,d,1]);
                    set(gca,'XTick',[],'YTick',[]);
                    figure(h);
                end
            end
        end
        function plot(obj,useMRs)
            useMRNums=false;
            if nargin>1&&useMRs
                useMRNums=true;
            end
            if useMRNums
                try
                    num=obj.nets(1).data.num;
                catch
                    error("Graph includes no MemoryRegion data.");
                end
            end
            edgelabels=[];
            weights=obj.digraph.Edges.Weight;
            for i=1:numel(weights)
                weight=weights(i);
                net=obj.nets(uint8(weight));
                if useMRNums
                    edgelabels=[edgelabels,net.data.num];
                else
                    edgelabels=[edgelabels,weight];
                end
            end
            cells=arrayfun(@(x)cellstr(x.name),obj.components,'UniformOutput',false);
            names=[cells{:}];
            names=strrep(names,'_','\_');
            h=figure('Visible','Off');
            p=plot(obj.digraph,'Layout','layered');
            p.NodeLabel=names;
            p.EdgeLabel=edgelabels;
            p.YData=p.YData*2;
            figure(h);
        end
        function data=getComponentData(obj)
            data=[];
            for i=1:numel(obj.components)
                component=obj.components(i);
                data=[data,component.data];
            end
        end
        function data=getNetData(obj)
            data=[];
            for i=1:numel(obj.nets)
                net=obj.nets(i);
                data=[data,net.data];
            end
        end
    end
    methods
        function dg=get.digraph(obj)

            if obj.updateVersion>obj.digraphVersion
                obj.addDigraph();
                obj.digraphVersion=obj.updateVersion;
            end
            dg=obj.digraphInner;
        end
    end
    methods(Access=private)
        function setModified(obj)
            obj.updateVersion=obj.updateVersion+1;
        end
        function propogateSizes(obj)


            function[sz,l]=removeBT(sizeVector,labels)
                if labels(end)=='T'||labels(end)=='B'
                    [sz,l]=removeBT(sizeVector(1:end-1),labels(1:end-1));
                else
                    sz=sizeVector;
                    l=labels;
                end
            end

            function[sz,l]=addSSC(sizeVector,labels)
                if labels(end)~='C'
                    sz=[sizeVector,1];
                    l=[labels,'C'];
                else
                    sz=sizeVector;
                    l=labels;
                end
                if numel(sz)<3
                    sz=[1,sz];
                    l=['S',l];
                    [sz,l]=addSSC(sz,l);
                end
            end



            st=obj.report.toStruct();
            for i=1:numel(st.Layers)
                layer=st.Layers(i);
                for j=1:numel(layer.Activations)
                    activation=layer.Activations(j);

                    sz=interpretSize(activation);
                    sz=uint32(sz);
                    sz=reshape(sz,1,numel(sz));

                    [sz,l]=removeBT(sz,activation.DimensionLabels);
                    [sz,l]=addSSC(sz,l);
                    sz=double(sz);
                    pinstName=[layer.Name,'/',activation.Name];
                    try
                        pinst=getOutputPortInst(obj,pinstName);
                        pinst.size=sz;
                        pinst.net.size=sz;
                    catch
                    end
                end
            end


            for i=1:numel(obj.nets)
                net=obj.nets(i);
                sz=net.size;
                net.driver.size=sz;
                for j=1:numel(net.receivers)
                    pinst=net.receivers(j);
                    pinst.size=sz;
                end
            end

            function sz=interpretSize(activation)
                s=activation.DimensionLabels=='S';
                c=activation.DimensionLabels=='C';
                b=activation.DimensionLabels=='B';

                sz=ones(1,4);
                switch nnz(s)
                case 0

                case 1
                    sz(1)=activation.Size(s);
                case 2
                    sz(1:2)=activation.Size(s);
                otherwise
                    sz=activation.Size;
                    return
                end
                sz(3)=activation.Size(c);
                sz(4)=activation.Size(b);
            end
        end




        function removeDanglingPortinsts(obj)
            for component=obj.components'
                if numel(component.inputs)==1
                    pinst=component.inputs;
                    if isempty(pinst.net)
                        component.inputs={};
                    end
                end
                if numel(component.outputs)==1
                    pinst=component.outputs;
                    if isempty(pinst.net)
                        component.outputs={};
                    end
                end
            end
        end
        function removeDataFormatComponents(obj)
            import dnnfpga.dagCompile.*;
            components=obj.components;
            for i=1:numel(components)
                component=components(i);
                if component.hasKind(LayerKind.FCFmt)
                    obj.removeComponentCleanly(component,true);
                end
            end
        end
        function removeResizeComponents(obj)
            import dnnfpga.dagCompile.*;
            components=obj.components;
            for i=1:numel(components)
                component=components(i);
                if component.hasKind(LayerKind.Resize)
                    obj.removeComponentCleanly(component,true);
                end
            end
        end
    end
    methods

        function addDataFormat(obj)
            import dnnfpga.dagCompile.*
            for i=1:numel(obj.nets)
                net=obj.nets(i);
                net.dataFormat=DataFormat.None;
            end
            for i=1:numel(obj.components)
                component=obj.components(i);
                obj.updateDataFormat(component);
            end
        end

        function updateDataFormat(obj,component)
            import dnnfpga.dagCompile.*
            if numel(component.outputs)==1
                net=component.outputs.net;
                if net.dataFormat==DataFormat.None

                    if component.hasKind(LayerKind.Conv)||...
                        component.hasKind(LayerKind.SoftToHard)||...
                        component.isInput()

                        net.dataFormat=DataFormat.Conv;
                    elseif component.hasKind(LayerKind.FC)
                        net.dataFormat=DataFormat.FC;
                    elseif component.hasKind(LayerKind.FCFmt)
                        net.dataFormat=DataFormat.FC;
                    else

                        formats=arrayfun(@(x)x.net.dataFormat(),component.inputs);
                        if~isempty(formats)
                            filtered=[];
                            for i=1:numel(formats)
                                format=formats(i);
                                if format~=DataFormat.None
                                    filtered=[filtered,format];
                                end
                            end
                            if~isempty(filtered)
                                minValue=min(filtered);
                                maxValue=max(filtered);
                                if minValue==maxValue
                                    net.dataFormat=filtered(1);
                                else
                                    mismatch=true;
                                    msg=message('dnnfpga:dnnfpgacompiler:MismatchedLayerInputs',component.name);
                                    error(msg);
                                end
                            end
                        end
                    end
                    if net.dataFormat~=DataFormat.None
                        for i=1:numel(net.receivers)
                            pinst=net.receivers(i);
                            obj.updateDataFormat(pinst.component);
                        end
                    end
                end
            end
        end
        function addDataFormatFCDirect(obj)
            import dnnfpga.dagCompile.*
            for i=1:numel(obj.components)
                component=obj.components(i);
                if numel(component.outputs)==1
                    net=component.outputs.net;
                    if component.hasKind(LayerKind.FC)&&~component.hasKind(LayerKind.CustomLayer)
                        net.dataFormat=DataFormat.FCDirect;
                        for i=1:numel(net.receivers)
                            pinst=net.receivers(i);
                            updateDataFormatFCDirect(obj,pinst.component);
                        end
                    end
                end
            end
        end
        function updateDataFormatFCDirect(obj,component)
            import dnnfpga.dagCompile.*
            if component.hasSharedMem()&&~isempty(component.outputs)
                net=component.outputs.net;
                net.dataFormat=DataFormat.FCDirect;
                for i=1:numel(net.receivers)
                    pinst=net.receivers(i);
                    updateDataFormatFCDirect(obj,pinst.component);
                end
            end
        end
    end
    methods(Access=protected)
        function import(obj,ngraph)
            cp=copy(ngraph);
            for i=1:numel(cp.components)
                component=cp.components(i);
                component.ngraph=obj;
                obj.addComponent(component);
            end
            for i=1:numel(cp.nets)
                net=cp.nets(i);
                net.ngraph=obj;
                obj.addNet(net);
            end
            obj.ProcessorConfig=ngraph.ProcessorConfig;

        end

        function cp=copyElement(obj)


            className=class(obj);
            constructor=str2func(className);

            cp=constructor();

            portInstMap=containers.Map('KeyType','char','ValueType','Any');

            function p=getPortInst(pinst)
                try
                    p=portInstMap(pinst.nameFull);
                catch ME
                    p=copy(pinst);
                    netName=pinst.net.name;
                    componentName=pinst.component.name;
                    net=cp.getNet(netName);
                    component=cp.getComponent(componentName);
                    p.net=net;
                    p.component=component;
                    portInstMap(pinst.nameFull)=p;
                    ins=[];
                    for i=1:numel(component.inputs)
                        pp=component.inputs(i);
                        if strcmp(pp.nameFull,p.nameFull)
                            ins=[ins,p];
                        else
                            ins=[ins,pp];
                        end
                    end
                    component.inputs=ins;
                    outs=[];
                    for i=1:numel(component.outputs)
                        pp=component.outputs(i);
                        if strcmp(pp.nameFull,p.nameFull)
                            outs=[outs,p];
                        else
                            outs=[outs,pp];
                        end
                    end
                    component.outputs=outs;
                    if strcmp(net.driver.nameFull,p.nameFull)
                        net.driver=p;
                    end
                    rs=[];
                    for j=1:numel(net.receivers)
                        pp=net.receivers(j);
                        if strcmp(pp.nameFull,p.nameFull)
                            rs=[rs,p];
                        else
                            rs=[rs,pp];
                        end
                    end
                    net.receivers=rs;
                end
            end

            for i=1:numel(obj.components)
                component=obj.components(i);
                cp.addComponent(copy(component));
            end
            for i=1:numel(obj.nets)
                net=obj.nets(i);
                cp.addNet(copy(net));
            end
            for i=1:numel(cp.components)
                component=cp.components(i);
                ins_0=[];
                for j=1:numel(component.inputs)
                    pinst=component.inputs(j);
                    p=getPortInst(pinst);
                    ins_0=[ins_0,p];
                end
                component.inputs=ins_0;
                component.inputExp=[];
                component.outputExp=[];
                outs_0=[];
                for j=1:numel(component.outputs)
                    pinst=component.outputs(j);
                    p=getPortInst(pinst);
                    outs_0=[outs_0,p];
                end
                component.outputs=outs_0;
            end
        end
    end
end



