














classdef SGraph<handle&dnnfpga.dagCompile.NGraph

    properties
sortedComponents
processorConfig
hardwarenormalization
verbose
    end

    methods
        function obj=SGraph(ngraph,maxInputs,processorConfig,hardwarenormalization,verbose)
            import dnnfpga.dagCompile.*;
            if nargin~=0

                if nargin<2
                    maxInputs=2;
                end

                if nargin<3
                    obj.processorConfig=[];
                else
                    obj.processorConfig=processorConfig;
                end

                if~isempty(processorConfig)&&strcmp(processorConfig.ProcessorDataType,'single')
                    if nargin<4
                        obj.hardwarenormalization='auto';
                    else
                        obj.hardwarenormalization=hardwarenormalization;
                    end
                else
                    obj.hardwarenormalization='off';
                end

                if nargin<5
                    obj.verbose=1;
                else
                    obj.verbose=verbose;
                end


                obj.import(ngraph);




                cc=obj.components;
                for i=1:numel(cc)
                    component=cc(i);
                    if component.isJoin()
                        obj.createJoinTree(component,maxInputs);
                    end
                end
                obj.updateSGraph();


                obj.removeDropouts();
                obj.updateSGraph();


                obj.splitMaxpool();
                obj.updateSGraph();



                obj.transformTransposedConv();
                obj.updateSGraph();

                if(~strcmpi(obj.hardwarenormalization,'off'))
                    obj.transformInputNormalization();
                    obj.updateSGraph();
                end


                obj.transformUnpool();
                obj.updateSGraph();


                obj.mergeComponents();
                obj.updateSGraph();

                if numel(obj.nets)==1
                    msg=message('dnnfpga:dnnfpgacompiler:UnsupportedNetworkOnlyIO');
                    error(msg);
                end
            end
        end
    end
    methods
        function obj=updateSGraph(obj)

            obj.numberComponents();

            obj.numberNets();

            obj.addSortedComponents();
        end
    end

    methods(Access=private)


        function mergeComponents(obj)
            cc=obj.components;
            for i=1:numel(cc)
                component=cc(i);
                if isempty(component.ngraph)
                    continue;
                end
                if component.isPrimary()
                    obj.tryMerge(component);
                end
            end
        end




        function tryMerge(obj,component)
            import dnnfpga.dagCompile.*;
            driver=component.outputs;
            if numel(driver)==1
                net=driver.net;
                if numel(net.receivers)==1
                    next=net.receivers.component;
                    if~next.isJoin()&&component.canMerge(next)






                        if~(component.hasKind(LayerKind.Conv)&&next.isPrimary())...
                            ||~next.followingPrimaryIsFC()
                            component.merge(next);
                            obj.tryMerge(component);
                        end
                    end
                end
            end
        end



        function createJoinTree(obj,cn,maxInputs)
            isDepthConcat=dnnfpga.dagCompile.Layers.isDepthConcat(cn.nLayer);
            isAdd=dnnfpga.dagCompile.Layers.isAdd(cn.nLayer);

            function propogateSizes(component)
                size=[];
                if isempty(component.outputs.net.size)
                    if isAdd
                        for i=1:numel(component.inputs)
                            input=component.inputs(i);
                            if~isempty(input.net.size)
                                size=input.net.size;
                                break;
                            end
                        end
                    elseif isDepthConcat
                        sz=[];
                        found=true;
                        for i=1:numel(component.inputs)
                            input=component.inputs(i);
                            if~isempty(input.net.size)
                                if i==1
                                    sz=input.net.size;
                                else
                                    sz(3)=sz(3)+input.net.size(3);
                                end
                            else
                                found=false;
                                break;
                            end
                        end
                        if found
                            size=sz;
                        end
                    end
                    if~isempty(size)
                        component.outputs.net.size=size;
                        for i=1:numel(component.outputs.net.receivers)
                            pinst=component.outputs.net.receivers(i);
                            c=pinst.component;
                            propogateSizes(c);
                        end
                    end
                end
            end

            if numel(cn.inputs)>maxInputs&&(isAdd||isDepthConcat)
                size=numel(cn.inputs);
                inputs=[];
                cs=[];
                for i=1:size-1
                    parentComponent=[];
                    if(i==1)
                        name=cn.name;
                    else
                        name=strcat(cn.name,'_',num2str(i));
                        parentComponent=cn.name;
                    end
                    if isDepthConcat
                        nLayer=depthConcatenationLayer(2,'Name',name);
                    end
                    if isAdd
                        nLayer=additionLayer(2,'Name',name);
                    end
                    c=dnnfpga.dagCompile.Component(nLayer,'',obj.ProcessorConfig);
                    c.parentComponent=parentComponent;
                    c.addPortInsts();
                    obj.addComponent(c);
                    cs=[cs,c];
                    pinst=c.outputs;
                    net=obj.getOrCreateNet(pinst);
                    net.driver=pinst;
                    pinst.net=net;
                    if i==1
                        inputs=[c.inputs(1)];
                    else
                        net.addPortInst(prev.inputs(2));
                        inputs=[inputs,c.inputs(1)];
                    end
                    if i==size-1
                        inputs=[inputs,c.inputs(2)];
                    end
                    prev=c;
                end
                for i=1:size
                    pinst=cn.inputs(i);
                    net=pinst.net;
                    net.removePortInst(pinst);
                    net.addPortInst(inputs(i));
                end
                for i=1:numel(cs)
                    c=cs(i);
                    propogateSizes(c);
                end
                obj.removeComponent(cn);
            end
        end



        function connectInputs(sgraph,obj,netSize,varargin)
            if(isempty(obj.inputs))
                obj.addPortInsts();
            end
            for i=1:numel(varargin)
                input=varargin{i};
                net=sgraph.getOrCreateNet(input.outputs);
                net.size=netSize;
                net.addPortInst(obj.inputs(i));
            end
        end


        function comp=constructConstOp(obj,layer,name,outSize,input,consts)
            import dnnfpga.dagCompile.*;
            constComp=Component(LayerKind.Constant,[name,'_const'],obj.processorConfig);
            if(numel(consts)==1)
                constComp.ConstValue=repmat(consts,outSize);
            elseif(numel(consts)==prod(outSize))
                constComp.ConstValue=reshape(consts,outSize);
            else
                constComp.ConstValue=repmat(consts,outSize./size(consts));
            end
            constComp.addPortInsts();
            constComp.inputs=[];
            comp=Component(layer,name,obj.processorConfig);
            obj.connectInputs(comp,outSize,input,constComp);
            obj.addComponent(constComp);
            obj.addComponent(comp);
        end



        function constructNormalizationComps(obj,inputComp,addConsts,multConsts)
            import dnnfpga.dagCompile.*;
            usemult=nargin>3;

            multLayer=[];
            outSize=inputComp.outputs.size;
            if(~isempty(obj.processorConfig))
                hCustom=obj.processorConfig.getModule('custom');
                hasAdd=hCustom.ModuleGeneration&&hCustom.Addition;
            else
                hasAdd=false;
            end
            if(~hasAdd)
                if(strcmpi(obj.hardwarenormalization,'auto'))
                    return;
                else
                    error(message('dnnfpga:workflow:HardwareNormLayerMissing','addition'));
                end
            end


            if(usemult)
                addName=[inputComp.name,'_norm_add'];
                multName=[inputComp.name,'_norm'];

                if(~isempty(obj.processorConfig))
                    hCustom=obj.processorConfig.getModule('custom');
                    hasMultiply=hCustom.ModuleGeneration&&hCustom.Multiplication;
                else
                    hasMultiply=false;
                end
                if(~hasMultiply)


                    if(strcmpi(obj.hardwarenormalization,'auto'))
                        return;
                    else
                        error(message('dnnfpga:workflow:HardwareNormLayerMissing','multiplication'));
                    end
                end


                msg=message('dnnfpga:dnnfpgadisp:SplitLayerNotice3',...
                inputComp.name,'ImageInputLayer',inputComp.name,addName,multName);
                dnnfpga.disp(msg,1,obj.verbose);
                multLayer=multiplicationLayer(2,'Name',multName);
                multLayer=dltargets.internal.utils.NetworkUtils.replaceLayersWithRedirectedLayers(multLayer);

            else
                addName=[inputComp.name,'_norm'];
                msg=message('dnnfpga:dnnfpgadisp:SplitInputLayerNotice',...
                inputComp.name,'ImageInputLayer',inputComp.name,addName);
                dnnfpga.disp(msg,1,obj.verbose);
            end



            outNet=inputComp.outputs.net;
            newOutputNet=dnnfpga.dagCompile.Net(inputComp.outputs);
            inputComp.outputs.net=newOutputNet;
            newOutputNet.size=outSize;
            obj.addNet(newOutputNet);


            addLayer=additionLayer(2,'Name',addName);
            addComp=obj.constructConstOp(addLayer,addName,outSize,inputComp,addConsts);

            outComp=addComp;



            if(usemult)
                multComp=obj.constructConstOp(multLayer,[inputComp.name,'_norm'],outSize,addComp,multConsts);
                outComp=multComp;
            end



            outComp.outputs.net=outNet;
            outNet.replacePortInst(outComp.outputs,inputComp.outputs);
            outNet.name=[outComp.name,'/out'];



            inputComp.nLayer=imageInputLayer(outSize,'Name',inputComp.nLayer.Name,'Normalization','none',...
            'DataAugmentation',inputComp.nLayer.DataAugmentation);
            obj.hardwarenormalization='done';
        end



        function transformZeroCenter(obj,component)
            obj.constructNormalizationComps(component,-component.nLayer.Mean);
        end



        function transformZScore(obj,component)
            constructNormalizationComps(obj,component,-component.nLayer.Mean,1.0./component.nLayer.StandardDeviation);
        end



        function transformRescale(obj,component,targetMin,targetMax)
            currLayer=component.nLayer;
            diff=currLayer.Max-currLayer.Min;
            tdiff=targetMax-targetMin;
            addConsts=targetMin.*diff./tdiff-currLayer.Min;
            multConsts=tdiff./diff;
            constructNormalizationComps(obj,component,addConsts,multConsts);
        end



        function transformInputNormalization(obj)
            components=obj.components;
            for i=1:numel(components)
                component=components(i);
                if(strcmpi(class(component.nLayer),'nnet.cnn.layer.ImageInputLayer'))
                    currLayer=component.nLayer;
                    if(strcmpi(currLayer.Normalization,'zerocenter'))
                        transformZeroCenter(obj,component);
                    elseif(strcmpi(currLayer.Normalization,'zscore'))
                        transformZScore(obj,component);
                    elseif(~strcmpi(currLayer.Normalization,'none')&&strcmpi(obj.hardwarenormalization,'on'))
                        error(message('dnnfpga:workflow:HardwareNormUnsupported'));
                    end
                end
            end
        end


        function transformTransposedConv(obj)

            import dnnfpga.dagCompile.*;

            components=obj.components;

            for i=1:numel(components)
                component=components(i);
                if(strcmpi(class(component.nLayer),'nnet.cnn.layer.TransposedConvolution2DLayer'))

                    currLayer=component.nLayer;
                    origname=component.name;
                    origclass=class(component.nLayer);
                    weightSize=size(currLayer.Weights);
                    if weightSize(1)~=weightSize(2)
                        msg=message('dnnfpga:dnnfpgacompiler:OnlySymmetricFilterSizeSupported',origname);
                        error(msg);
                    end

                    if currLayer.Stride(1)~=currLayer.Stride(2)
                        msg=message('dnnfpga:dnnfpgacompiler:OnlySymmetricStrideSupported',origname);
                        error(msg);
                    end


                    inputSize=component.inputs.size;

                    weightSize=[currLayer.Stride(1),currLayer.Stride(2),inputSize(3),inputSize(3)];
                    outputSize=[inputSize(1)+(inputSize(1)-1)*(currLayer.Stride(1)-1)...
                    ,inputSize(2)+(inputSize(2)-1)*(currLayer.Stride(2)-1)...
                    ,inputSize(3)];

                    biasSize=[1,1,inputSize(3)];

                    zeroInsertName=[component.name,'_insertZeros'];
                    stride=[1,1];
                    insertZeroLayer=convolution2dLayer(...
                    weightSize(1),...
                    inputSize(3),...
                    'Stride',stride,...
                    'Name',zeroInsertName,...
                    'Padding','same');

                    insertZeroLayer.Weights=ones(weightSize)*3;
                    insertZeroLayer.Bias=zeros(biasSize);


                    zeroComp=Component(insertZeroLayer,zeroInsertName);
                    zeroComp.layerKinds(end+1)=LayerKind.TransposedConv;
                    zeroComp.addPortInsts();



                    convName=component.name;

                    sizeCropSize=size(currLayer.CroppingSize);
                    if(sizeCropSize(2)==2)
                        sizeCropSize=[currLayer.CroppingSize(1),currLayer.CroppingSize(1),currLayer.CroppingSize(2),currLayer.CroppingSize(2)];
                    elseif(sizeCropSize(2)==1)
                        sizeCropSize=[currLayer.CroppingSize(1),currLayer.CroppingSize(1),currLayer.CroppingSize(1),currLayer.CroppingSize(1)];
                    else
                        sizeCropSize=currLayer.CroppingSize;
                    end
                    weightSize=size(currLayer.Weights);
                    if(sizeCropSize(1)>(weightSize(1)-1)||sizeCropSize(2)>(weightSize(2)-1))
                        error(message('dnnfpga:dnnfpgacompiler:UnsupportedCroppingSize',convName));
                    else
                        newPadding=[(weightSize(1)-sizeCropSize(1)-1)...
                        ,(weightSize(1)-sizeCropSize(2)-1)...
                        ,(weightSize(2)-sizeCropSize(3)-1)...
                        ,(weightSize(2)-sizeCropSize(4)-1)];

                    end
                    layerInsert=convolution2dLayer(...
                    weightSize(1),...
                    weightSize(3),...
                    'Name',convName,...
                    'Stride',1,...
                    'Padding',newPadding);

                    origWeights=currLayer.Weights;






                    permutedWeights=permute(origWeights,[1,2,4,3]);

                    layerInsert.Weights=flip(flip(permutedWeights,1),2);
                    layerInsert.Bias=currLayer.Bias;

                    convComp=Component(layerInsert,component.name);
                    convComp.addPortInsts();



                    netBetween=obj.getOrCreateNet(zeroComp.outputs);
                    netBetween.size=outputSize;
                    netBetween.addPortInst(convComp.inputs);




                    netIn=component.inputs.net;
                    netIn.replacePortInst(zeroComp.inputs,component.inputs);
                    zeroComp.inputs.net=netIn;

                    netOut=component.outputs.net;
                    netOut.replacePortInst(convComp.outputs,component.outputs);
                    convComp.outputs.net=netOut;




                    obj.removeComponent(component);


                    obj.addComponent(zeroComp);
                    obj.addComponent(convComp);


                    msg=message('dnnfpga:dnnfpgadisp:SplitLayerNotice',...
                    origname,origclass,zeroInsertName,convName);
                    dnnfpga.disp(msg,1,obj.verbose);
                end
            end
        end


        function splitMaxpool(obj)
            import dnnfpga.dagCompile.*;
            components=obj.components;
            for i=1:numel(components)
                component=components(i);

                if isa(component.nLayer,'nnet.cnn.layer.MaxPooling2DLayer')&&component.nLayer.HasUnpoolingOutputs

                    origname=component.nLayer.Name;
                    origclass=class(component.nLayer);
                    driver=component.inputs;
                    netDriver=driver.net;


                    port1_m=[];
                    port2_m=[];
                    port3_m=[];
                    name_data=[];
                    name_index=[];

                    for j=1:numel(component.outputs)
                        switch component.outputs(j).name
                        case 'out'

                            name_data=[component.name,'_data'];
                            net=component.outputs(j).net;

                            currLayer=component.nLayer;
                            layerInsert=maxPooling2dLayer(...
                            currLayer.PoolSize,...
                            'Name',name_data,...
                            'Stride',currLayer.Stride,...
                            'Padding',currLayer.PaddingSize,...
                            'HasUnpoolingOutputs',false);

                            c=Component(layerInsert,name_data);
                            c.addPortInsts();
                            c.layerKinds=[c.layerKinds;LayerKind.MaxpoolData];


                            net.insert(c);

                            netDriver.addPortInst(c.inputs);

                            port1_m=component.outputs(j);
                            toRemove=port1_m.net;
                            component.ngraph.removeNet(toRemove);
                            toRemove.ngraph=[];
                        case 'indices'

                            name_index=[component.name,'_index'];
                            net=component.outputs(j).net;



                            net.size=component.outputs(1).net.size;
                            for k=1:numel(net.receivers)
                                net.receivers(k).size=net.size;
                            end

                            currLayer=component.nLayer;
                            layerInsert=maxPooling2dLayer(...
                            currLayer.PoolSize,...
                            'Name',name_index,...
                            'Stride',currLayer.Stride,...
                            'Padding',currLayer.PaddingSize,...
                            'HasUnpoolingOutputs',false);

                            c=Component(layerInsert,name_index);
                            c.addPortInsts();
                            c.layerKinds=[c.layerKinds;LayerKind.MaxpoolIndex];


                            net.insert(c);

                            netDriver.addPortInst(c.inputs);

                            port2_m=component.outputs(j);
                            toRemove=port2_m.net;
                            component.ngraph.removeNet(toRemove);
                            toRemove.ngraph=[];
                        case 'size'

                            port3_m=component.outputs(j);
                            port3_r=port3_m.net.receivers;
                            receivers=[];

                            for k=1:numel(port3_r)
                                if(port3_r(k).component.hasKind(LayerKind.Unpool))
                                    port3_u=port3_r(k);
                                    component_u=port3_u.component;
                                    component_u.removePortInst(port3_u);
                                else

                                    receivers=[receivers,port3_r(k)];
                                end
                            end
                            port3_m.net.receivers=receivers;



                            if isempty(port3_m.net.receivers)
                                component.ngraph.removeNet(port3_m.net);
                                port3_m.net.ngraph=[];
                            end
                        end
                    end





                    netDriver.removePortInst(driver);

                    component.removePortInst(port1_m);
                    if~isempty(port2_m)



                        component.removePortInst(port2_m);
                    end
                    if~isempty(port3_m)



                        component.removePortInst(port3_m);
                    end

                    component.ngraph.removeComponent(component);
                    component.ngraph=[];


                    if~isempty(name_data)&&~isempty(name_index)
                        msg=message('dnnfpga:dnnfpgadisp:SplitLayerNotice',...
                        origname,origclass,name_data,name_index);
                        dnnfpga.disp(msg,1,obj.verbose);
                    end
                end
            end

        end

        function transformUnpool(obj)
            import dnnfpga.dagCompile.*;
            for i=1:numel(obj.components)
                component=obj.components(i);
                if component.hasKind(LayerKind.Unpool)
                    mpoolComp=component.inputs(2).net.driver.component;


                    stride=[1,1];
                    kSize=mpoolComp.nLayer.PoolSize;
                    inputSize=mpoolComp.outputs.net.size;
                    weightSize=[kSize,inputSize(3),inputSize(3)];
                    biasSize=[1,1,inputSize(3)];
                    component.nLayer=convolution2dLayer(...
                    kSize,inputSize(3),...
                    'Stride',stride,...
                    'Name',component.nLayer.Name,...
                    'Padding','same');
                    component.nLayer.Weights=zeros(weightSize);
                    component.nLayer.Bias=zeros(biasSize);
                end
            end
        end

        function addSortedComponents(obj)

            obj.addDepthAsData();
            depths=obj.getComponentData();
            [~,I]=sort(depths);
            obj.sortedComponents=obj.components(I);
            obj.components.clear();
        end

        function addDepthAsData(obj)
            import dnnfpga.dagCompile.*
            obj.components.init(uint32(0));

            for component=obj.components'
                if component.hasKind(LayerKind.Hard)
                    component.data=uint32(10);
                end
            end
            for i=1:numel(obj.components)
                component=obj.components(i);
                obj.updateDepth(component);
            end
        end

        function updateDepth(obj,component)
            import dnnfpga.dagCompile.*
            if component.hasKind(LayerKind.State)
                return;
            end
            depth=component.data;
            for i=1:numel(component.outputs)
                pinst=component.outputs(i);
                net=pinst.net;
                for j=1:numel(net.receivers)
                    npinst=net.receivers(j);
                    neighbor=npinst.component;
                    if neighbor.data<depth+1
                        neighbor.data=depth+1;
                        obj.updateDepth(neighbor);
                    end
                end
            end
        end
    end

    methods

        function outputComponents=getOutputComponentList(obj)
            import dnnfpga.dagCompile.*;
            outputComponents=[];
            sortedComponents=obj.sortedComponents;
            for i=1:numel(sortedComponents)
                component=sortedComponents(i);
                if component.hasKind(LayerKind.HardToSoft)
                    next_component=dnnfpga.dagCompile.getNextComponent(component);
                    if(~isempty(next_component))
                        outputComponents{end+1}=next_component;
                    end
                end
            end
        end


        function constComponents=getConstComponentList(obj)
            import dnnfpga.dagCompile.*;
            constComponents=[];
            sortedComponents=obj.sortedComponents;
            for i=1:numel(sortedComponents)
                component=sortedComponents(i);
                if component.hasKind(LayerKind.Constant)
                    constComponents{end+1}=component;
                end
            end
        end


        function inputComponents=getInputComponentList(obj)
            import dnnfpga.dagCompile.*;
            inputComponents=[];
            for i=1:numel(obj.sortedComponents)
                if obj.sortedComponents(i).isInput
                    inputComponents{end+1}=obj.sortedComponents(i);
                end
            end
        end
    end
    methods

        function[v,c]=insertForNet(obj,net,layerKind0,layerKind1,layerKindInsert,name)
            import dnnfpga.dagCompile.*;
            v=false;
            c=[];
            componentDriver=net.driver.component;
            count=0;
            if componentDriver.hasKind(layerKind0)
                pinsts_0=[];
                pinsts_1=[];
                for j=1:numel(net.receivers)
                    pinst=net.receivers(j);
                    component=pinst.component;
                    if component.hasKind(layerKind1)
                        count=count+1;
                        pinsts_0=[pinst,pinsts_0];
                    else
                        pinsts_1=[pinst,pinsts_1];
                    end
                end
            end
            if count>0
                if count==j
                    component=Component(layerKindInsert,name);
                    component.addPortInsts();
                    net.insert(component);
                    v=true;
                    c=component;
                else
                    for k=1:numel(pinsts_1)
                        pinst=pinsts_1(k);
                        net.removePortInst(pinst);
                    end
                    [v,c]=obj.insertForNet(net,layerKind0,layerKind1,layerKindInsert,name);
                    net=c.inputs.net;
                    for k=1:numel(pinsts_1)
                        pinst=pinsts_1(k);
                        net.addPortInst(pinst);
                    end
                end
            end
        end
        function removeDropouts(obj)
            import dnnfpga.dagCompile.*;
            components=obj.components;
            for i=1:numel(components)
                component=components(i);
                if component.hasKind(LayerKind.Dropout)
                    obj.removeComponentCleanly(component);
                end
            end
        end
    end
end



