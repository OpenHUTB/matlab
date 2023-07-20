





classdef Component<handle&dnnfpga.dagCompile.AddData&matlab.mixin.Copyable
    properties
name
nLayer
        inputs=[];
        outputs=[];
        inputExp=[];
        outputExp=[];
        reLUMode=[];
        reLUExp=[];
        reLUValue=[];
        parentComponent=[];
        ngraph=dnnfpga.dagCompile.NGraph.empty;
        id=uint32(0);
layerKinds
LegLevelIR
        visited=false;
        deployableLayerCreated=false;
        CustomLayerInfo=[];
        ConstValue=[];
    end
    methods

        function obj=Component(object,name,hPC)
            if nargin<3
                hPC=[];
            end


            if isa(object,'nnet.cnn.layer.Layer')
                obj.name=object.Name;
                obj.nLayer=object;
                obj.layerKinds=dnnfpga.dagCompile.LayerKind.toKind(object);
                if obj.hasKind(dnnfpga.dagCompile.LayerKind.Add)||...
                    obj.hasKind(dnnfpga.dagCompile.LayerKind.CustomLayer)














                    if(~isempty(hPC)&&~isempty(hPC.CustomLayerManager.getLayerList))
                        [currentLayerID,currentLayerBlockName]=hPC.CustomLayerManager.getLayerInfo(object);
                        totalLayersPVList=[hPC.CustomLayerManager.getLayerList.PropertyValueList];
                    else
                        currentLayerID=0;
                        currentLayerBlockName=[];
                        totalLayersPVList=[];
                    end




                    currentLayerPVList=dnnfpga.customLayer.getProperties(object);


                    obj.CustomLayerInfo=struct('CurrentLayerID',currentLayerID,...
                    'ConfigBlockname',currentLayerBlockName,...
                    'CurrentLayerPVList',currentLayerPVList,...
                    'TotalLayersPVList',totalLayersPVList);
                end
            elseif isa(object,'dnnfpga.dagCompile.LayerKind')
                obj.name=name;
                obj.layerKinds=object;
                obj.inputs=dnnfpga.dagCompile.PortInst('in',[],obj);
                obj.outputs=dnnfpga.dagCompile.PortInst('out',[],obj);
            else
                msg=message('dnnfpga:workflow:InvalidDataWrongClass','nLayer','nnet.cnn.layer.Layer',class(nLayer));
                error(msg);
            end
        end





        function fc=followingPrimaryIsFC(obj)
            import dnnfpga.dagCompile.*;
            driver=obj.outputs;



            if numel(driver)==1
                net=driver.net;
                if(numel(net.receivers)==1)
                    next=net.receivers.component;


                    if(next.hasKind(LayerKind.FC))
                        fc=true;
                        return;



                    elseif(next.isPrimary())
                        fc=false;
                        return;



                    else
                        fc=next.followingPrimaryIsFC();
                        return;
                    end
                end
            end



            fc=false;
        end

        function set.LegLevelIR(obj,LegLevelIR)

            obj.LegLevelIR=LegLevelIR;
        end

        function initVisit(obj,value)

            if numel(obj)==1
                obj.visited=value;
            else
                for i=1:numel(obj)
                    one=obj(i);
                    one.init(value);
                end
            end
        end

        function obj=addPortInsts(obj)
            nLayer=obj.nLayer;
            if~isempty(nLayer)
                if isprop(nLayer,'InputNames')
                    for i=1:length(nLayer.InputNames)
                        name=nLayer.InputNames(i);
                        name=name{1};
                        p=dnnfpga.dagCompile.PortInst(name,[],obj);
                        obj.inputs=cat(1,obj.inputs,p);
                    end
                else

                    obj.inputs=dnnfpga.dagCompile.PortInst('in',[],obj);
                end
                if isprop(nLayer,'OutputNames')

                    for i=1:length(nLayer.OutputNames)
                        name=nLayer.OutputNames(i);
                        name=name{1};
                        p=dnnfpga.dagCompile.PortInst(name,[],obj);
                        obj.outputs=cat(1,obj.outputs,p);
                    end
                else

                    obj.outputs=dnnfpga.dagCompile.PortInst('out',[],obj);
                end
            end
        end

        function removePortInst(obj,pinst)
            inputs=[];
            for i=1:numel(obj.inputs)
                input=obj.inputs(i);
                if pinst~=obj.inputs(i)
                    inputs=[inputs,input];
                end
            end
            obj.inputs=inputs;

            outputs=[];
            for i=1:numel(obj.outputs)
                receiver=obj.outputs(i);
                if receiver~=pinst
                    outputs=[outputs,receiver];
                end
            end
            obj.outputs=outputs;
        end


        function v=numOutputs(obj)
            if numel(obj.outputs)==1
                pinst=obj.outputs(1);
                net=pinst.net;
                v=numel(net.receivers);
            else
                v=0;
            end
        end


        function v=numInputs(obj)
            v=numel(obj.inputs);
        end

        function v=isInput(obj)
            import dnnfpga.dagCompile.*
            v=numel(obj.inputs)==0&&~obj.hasKind(LayerKind.Constant);
        end


        function v=isOutput(obj)
            import dnnfpga.dagCompile.*
            v=numel(obj.outputs)==0&&~obj.hasKind(LayerKind.Label);
        end

        function v=hasConstrainedMemInput(obj)
            import dnnfpga.dagCompile.*
            v=obj.isOutput||obj.hasKind(LayerKind.Concat);
        end

        function v=hasConstrainedMemOutput(obj)
            import dnnfpga.dagCompile.*
            v=obj.isInput;
        end

        function v=hasSharedMem(obj)

            v=obj.isInput||any(arrayfun(@(x)x.hasSharedMem,obj.layerKinds));
        end

        function v=isSplit(obj)
            v=false;
            if numel(obj.outputs)==1
                pinst=obj.outputs(1);
                net=pinst.net;
                v=numel(net.receivers)>1;
            elseif numel(obj.outputs)>1
                v=true;
            end
        end

        function v=isJoin(obj)
            v=numel(obj.inputs)>1;
        end

        function v=hasKind(obj,layerKind)
            v=ismember(layerKind,obj.layerKinds);
        end

        function v=isPrimary(obj)
            import dnnfpga.dagCompile.*
            v=any(arrayfun(@(x)x.isPrimary(),obj.layerKinds));
        end

        function v=canMerge(obj,other)
            v=true;
            for i=1:numel(obj.layerKinds)
                lk_0=obj.layerKinds(i);
                for j=1:numel(other.layerKinds)
                    lk_1=other.layerKinds(j);
                    if~lk_0.canMerge(lk_1)
                        v=false;
                        break;
                    end
                end
            end
        end

        function merge(obj,other)
            if obj.canMerge(other)
                ngraph=obj.ngraph;

                name0=strsplit(obj.name,'>>');
                name0=name0{1};
                name1=strsplit(other.name,'>>');
                name1=name1{end};

                name=strcat(name0,'>>',name1);

                ngraph.removeComponent(obj);

                obj.name=name;
                obj.nLayer=[obj.nLayer,other.nLayer];
                obj.layerKinds=union(obj.layerKinds,other.layerKinds);

                ngraph.addComponent(obj);

                driver0=obj.outputs;
                net0=driver0.net;
                if~isempty(other.outputs)
                    driver1=other.outputs;
                    net1=driver1.net;
                    driver0.size=net1.size;
                    net1.driver=driver0;
                    driver0.net=net1;
                else
                    obj.outputs=[];
                end

                ngraph.removeComponent(other);
                other.ngraph=[];
                ngraph.removeNet(net0);
                net0.ngraph=[];
            end
        end

        function toDot(obj,fid,addColor)

            function color=getColor()
                import dnnfpga.dagCompile.*
                if obj.hasKind(LayerKind.Conv)
                    color='tomato';
                elseif obj.hasKind(LayerKind.Concat)
                    color='tomato';
                elseif obj.hasKind(LayerKind.FC)
                    color='yellow';
                elseif obj.hasKind(LayerKind.Add)
                    color='green';
                elseif obj.hasKind(LayerKind.State)
                    color='orange';
                elseif obj.hasKind(LayerKind.Soft)
                    color='cyan';
                elseif obj.hasKind(LayerKind.CustomLayer)
                    if isa(obj.nLayer,'nnet.cnn.layer.SigmoidLayer')
                        color='violet';
                    elseif isa(obj.nLayer,'nnet.cnn.layer.TanhLayer')
                        color='violet';
                    elseif isa(obj.nLayer,'nnet.internal.cnn.coder.MultiplicationLayer')
                        color='cornflowerblue';
                    elseif isa(obj.nLayer,'dnnfpga.layer.identityLayer')
                        color='tan';
                    else
                        color='violet';
                    end
                elseif obj.hasKind(LayerKind.HardToSoft)||obj.hasKind(LayerKind.SoftToHard)
                    color='gray';
                else
                    color='tan';
                end
            end

            if nargin<3
                addColor=false;
            end

            if addColor
                color=getColor();
            end

            name=obj.getDotName();

            if numel(obj.nLayer)==0
                nameMod=strrep(name,'_','.');
                fprintf(fid,'%s [fillcolor=%s, label=\"{ %s }\"];\n',name,color,nameMod);
            end

            if numel(obj.nLayer)==1
                fprintf(fid,'%s [fillcolor=%s, label=\"{ %s }\"];\n',name,color,obj.nLayer.Name);
            end


            if numel(obj.nLayer)>1
                fprintf(fid,'%s [fillcolor=%s, label=\"{<top>',name,color);
                for i=1:numel(obj.nLayer)-1
                    layer=obj.nLayer(i);
                    fprintf(fid,' %s |',layer.Name);
                end
                layer=obj.nLayer(end);
                fprintf(fid,' <bottom> %s }\"];\n',layer.Name);
            end
        end


        function name=getDotName(obj)
            if numel(obj.nLayer)<=1
                name=obj.name;
                name=strrep(name,'-','_');
                name=strrep(name,'.','_');
            end
            if numel(obj.nLayer)>1
                name=sprintf("Component_%u",obj.id);
            end
        end

        function name=getDotSrc(obj)
            name=obj.getDotName;
            name=strrep(name,'-','_');
            name=strrep(name,'.','_');
            if numel(obj.nLayer)>1
                name=sprintf("%s:bottom",name);
            end
        end
        function name=getDotDst(obj)
            name=obj.getDotName;
            name=strrep(name,'-','_');
            name=strrep(name,'.','_');
            if numel(obj.nLayer)>1
                name=sprintf("%s:top",name);
            end
        end

        function disp(obj)
            obj.display();
        end
        function display(obj)
            if numel(obj)==1
                one=obj(1);
                fprintf('%s\n',one.toString());
            else
                fprintf('[');
                for i=1:numel(obj)
                    one=obj(i);
                    fprintf('%s ',one.toString());
                end
                fprintf(']\n');
            end
        end
        function str=toString(obj)
            str=sprintf('<Component %s>',obj.name);
        end
    end
    methods(Access=protected)

        function cp=copyElement(obj)
            cp=copyElement@matlab.mixin.Copyable(obj);
            if~isempty(obj.inputs)
                cp.inputs=copy(obj.inputs);
            end
            if~isempty(obj.outputs)
                cp.outputs=copy(obj.outputs);
            end
        end
    end
end


