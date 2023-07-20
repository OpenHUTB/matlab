





classdef MESupport<handle

    properties
meMatrix


distances
sets
setIds
pairs
ConvInputPathArray
FCInputPathArray
AddInputPathArray
ConvOutputPathArray
FCOutputPathArray
AddOutputPathArray
    end

    methods

        function obj=MESupport(sgraph,uniqueActivations)
            if nargin<2
                uniqueActivations=false;
            end
            netCount=numel(sgraph.nets);
            obj.meMatrix=uint8(zeros([netCount,netCount]));
            obj.addGraph(sgraph,uniqueActivations);
            obj.addSortedPairs();
            obj.sets=cell([netCount,1]);
            for i=1:netCount
                obj.sets{i}=[i];
                obj.setIds(i)=i;
            end
        end

        function addEdge(obj,num0,num1)
            obj.meMatrix(num0,num1)=1;
            obj.meMatrix(num1,num0)=1;
        end
        function v=hasEdge(obj,num0,num1)
            v=obj.meMatrix(num0,num1);
        end
        function v=canMerge(obj,node0,node1)
            v=obj.hasEdge(node0,node1);
        end













        function d=createDistances(obj,sgraph)
            d=obj.createDistancesWithPred(sgraph,@(x)true);
        end





        function d=createDistancesWithPred(obj,sgraph,pred,invertWeights)
            if nargin<4
                invertWeights=false;
            end
            g=digraph(numel(sgraph.nets));
            for i=1:numel(sgraph.components)
                component=sgraph.components(i);
                if component.hasKind(dnnfpga.dagCompile.LayerKind.State)
                    continue;
                end
                weight=int32(1);
                if component.isJoin()&&isa(component.nLayer,'nnet.cnn.layer.DepthConcatenationLayer')
                    weight=int32(0);
                end
                if~pred(component)
                    weight=int32(0);
                end
                for j=1:numel(component.outputs)
                    pOut=component.outputs(j);
                    nOut=pOut.net;
                    for k=1:numel(component.inputs)
                        pIn=component.inputs(k);
                        nIn=pIn.net;
                        if invertWeights
                            weight=-weight;
                        end
                        g=addedge(g,nIn.id,nOut.id,weight);
                    end
                end
            end
            d=distances(g);
        end



        function isolateNode(obj,node)
            sz=size(obj.meMatrix);
            netCount=sz(1);
            id=obj.setIds(node);
            set=obj.sets(id);
            for i=1:netCount
                if i~=id
                    obj.meMatrix(id,i)=0;
                    obj.meMatrix(i,id)=0;
                end
            end

        end




        function mergeNodes(obj,node0,node1)
            sz=size(obj.meMatrix);
            netCount=sz(1);
            id0=obj.setIds(node0);
            id1=obj.setIds(node1);
            set0=obj.sets(id0);
            set1=obj.sets(id1);

            if id0~=id1
                for i=1:netCount
                    me0=obj.meMatrix(id0,i);
                    me1=obj.meMatrix(id1,i);
                    me=me0&&me1;
                    if i~=id0
                        obj.meMatrix(id0,i)=0;
                        obj.meMatrix(i,id0)=0;
                        if me
                            obj.addEdge(id0,i);
                        end
                    end
                end
                for i=1:netCount
                    obj.meMatrix(id1,i)=0;
                    obj.meMatrix(i,id1)=0;
                end

                x=union(obj.sets{id0},obj.sets{id1});
                obj.sets{id0}=x;
                obj.sets{id1}=[];
                for i=1:numel(set1);
                    n=set1{i};
                    obj.setIds(n)=id0;
                end
            end
        end
    end
    methods(Access=private)

        function addGraph(obj,sgraph,uinqueActivations)

            obj.distances=obj.createDistances(sgraph);



            obj.ConvInputPathArray=obj.createInputPathArray(sgraph,@(x)x.hasKind(dnnfpga.dagCompile.LayerKind.Conv));
            obj.FCInputPathArray=obj.createInputPathArray(sgraph,@(x)x.hasKind(dnnfpga.dagCompile.LayerKind.FC));
            obj.AddInputPathArray=obj.createInputPathArray(sgraph,@(x)x.hasKind(dnnfpga.dagCompile.LayerKind.Add));



            obj.ConvOutputPathArray=obj.createOutputPathArray(sgraph,@(x)x.hasKind(dnnfpga.dagCompile.LayerKind.Conv));
            obj.FCOutputPathArray=obj.createOutputPathArray(sgraph,@(x)x.hasKind(dnnfpga.dagCompile.LayerKind.FC));
            obj.AddOutputPathArray=obj.createOutputPathArray(sgraph,@(x)x.hasKind(dnnfpga.dagCompile.LayerKind.Add));

            netCount=size(obj.distances,1);




            for i=1:netCount
                for j=1:netCount
                    if i==j
                        obj.meMatrix(i,j)=1;
                    else
                        v=obj.distances(i,j);
                        if~uinqueActivations&&v~=Inf&&v>1
                            if~obj.hasStrayPath(i,j,sgraph)
                                if obj.multiFrameSafe(i,j)
                                    obj.addEdge(i,j);
                                end
                            end
                        end
                    end
                end
            end
        end



        function pathArray=createInputPathArray(obj,sgraph,pred)

            distances=obj.createDistancesWithPred(sgraph,pred,true);
            netCount=size(distances,1);
            pathArray=zeros(1,netCount,'uint32');
            pathArray=pathArray+intmax('uint32');
            for i=1:numel(sgraph.components)
                component=sgraph.components(i);
                if component.isInput()
                    for j=1:numel(component.outputs)
                        pinst=component.outputs(j);
                        net=pinst.net;
                        for k=1:netCount
                            weight=uint32(-distances(net.id,k));
                            pathArray(k)=min(pathArray(k),weight);
                        end
                    end
                end
            end
        end



        function pathArray=createOutputPathArray(obj,sgraph,pred)

            distances=obj.createDistancesWithPred(sgraph,pred,true);
            netCount=size(distances,1);
            pathArray=zeros(1,netCount,'uint32');
            pathArray=pathArray+intmax('uint32');
            for i=1:numel(sgraph.components)
                component=sgraph.components(i);
                if component.isOutput()
                    for j=1:numel(component.inputs)
                        pinst=component.inputs(j);
                        net=pinst.net;
                        for k=1:netCount
                            weight=uint32(-distances(k,net.id));
                            pathArray(k)=min(pathArray(k),weight);
                        end
                    end
                end
            end
        end

        function r=multiFrameSafe(obj,i,j)
            r=false;
            if obj.ConvInputPathArray(i)>0&&obj.ConvOutputPathArray(j)>0
                r=true;
            end
            if obj.FCInputPathArray(i)>0&&obj.FCOutputPathArray(j)>0
                r=true;
            end
            if obj.AddInputPathArray(i)>0&&obj.AddOutputPathArray(j)>0
                r=true;
            end
        end


        function addSortedPairs(obj)
            obj.pairs=obj.createSortedPairs();
        end
        function r=hasStrayPath(obj,i,j,sgraph)
            netSrc=sgraph.nets(i);
            netDst=sgraph.nets(j);
            r=false;
            for k=1:numel(netSrc.receivers)
                pinst=netSrc.receivers(k);
                component=pinst.component;
                if isempty(component.outputs)
                    continue;
                end
                net=component.outputs.net;
                v=obj.distances(net.id,netDst.id);
                if v==Inf
                    r=true;
                    break;
                end
            end
        end






















        function pairs=createSortedPairs(obj)
            netCount=size(obj.distances,1);
            limit=inf;




            count=1;
            for i=1:netCount
                for j=1:netCount
                    value=obj.distances(i,j);
                    if value~=inf&&value>1&&value<uint32(limit)
                        count=count+1;
                    end
                end
            end
            pairs(count)=dnnfpga.dagCompile.Pair();
            k=1;
            for i=1:netCount
                for j=1:netCount
                    value=obj.distances(i,j);
                    if value~=inf&&value>1&&value<uint32(limit)
                        pair=dnnfpga.dagCompile.Pair(i,j,value);
                        pairs(k)=pair;
                        k=k+1;
                    end
                end
            end
            values=[pairs.value];
            [~,I]=sort(values);
            pairs=pairs(I);
        end
    end
end

