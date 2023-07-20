classdef LayerKind<uint8
    enumeration
        CustomLayer(0)
        Add(1)
        Concat(2)
        Conv(3)
        FC(4)
        State(5)
        Input(6)
        Output(7)
        MaxpoolData(8)
        MaxpoolIndex(9)
        Unpool(10)
        Relu(11)
        Dropout(12)
        TransposedConv(13)
        Hard(14)
        Soft(15)
        HardToSoft(16)
        SoftToHard(17)
        QuantIn(18)
        QuantOut(19)
        Constant(20)
        Identity(21)
        FCFmt(22)
        Label(23)
        None(24)
        Resize(25)
    end
    methods
        function v=canMerge(obj,other)
            import dnnfpga.dagCompile.*
            if obj==LayerKind.Add&&other==LayerKind.Add
                v=false;
            elseif obj==LayerKind.Concat&&other==LayerKind.Concat
                v=false;
            elseif obj==other
                v=true;
            elseif obj.isPrimary()&&other.isPrimary()
                v=false;
            elseif other<obj
                v=other.canMerge(obj);
            elseif other==LayerKind.Relu
                v=obj.canMerge(LayerKind.Hard);
            else
                switch(obj)
                case LayerKind.Conv
                    v=other==LayerKind.Hard;
                case LayerKind.FC
                    v=other==LayerKind.Hard;
                case LayerKind.Add
                    v=other==LayerKind.Hard;
                case LayerKind.Relu
                    v=other==LayerKind.Hard;
                case LayerKind.Input
                    v=other==LayerKind.Soft;
                case LayerKind.Output
                    v=other==LayerKind.Soft;
                otherwise
                    v=false;
                end
            end
        end
        function v=isPrimary(obj)
            import dnnfpga.dagCompile.*
            v=obj==LayerKind.Add||...
            obj==LayerKind.Concat||...
            obj==LayerKind.Conv||...
            obj==LayerKind.FC||...
            obj==LayerKind.Input||...
            obj==LayerKind.Output;
        end
        function v=isNoOp(obj)
            import dnnfpga.dagCompile.*
            v=obj==LayerKind.FCFmt||obj==LayerKind.State;
        end
        function v=hasSharedMem(obj)
            import dnnfpga.dagCompile.*
            v=(obj==LayerKind.State||...
            obj==LayerKind.Concat||...
            obj==LayerKind.FCFmt||...
            obj==LayerKind.Soft||...
            obj==LayerKind.SoftToHard);
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
            str=sprintf('<LayerKind %s>',obj);
        end
    end
    methods(Static)
        function ks=toKind(layer)

            ks=dnnfpga.dagCompile.LayerKind.empty;
            if dnnfpga.dagCompile.Layers.isSoft(layer)
                ks=cat(1,ks,dnnfpga.dagCompile.LayerKind.Soft);
            else
                ks=cat(1,ks,dnnfpga.dagCompile.LayerKind.Hard);
            end
            if dnnfpga.dagCompile.Layers.isConv(layer)
                ks=cat(1,ks,dnnfpga.dagCompile.LayerKind.Conv);
            end
            if dnnfpga.dagCompile.Layers.isFC(layer)
                ks=cat(1,ks,dnnfpga.dagCompile.LayerKind.FC);
            end
            if dnnfpga.dagCompile.Layers.isAdd(layer)
                ks=cat(1,ks,dnnfpga.dagCompile.LayerKind.Add);
            end
            if dnnfpga.dagCompile.Layers.isReLU(layer)
                ks=cat(1,ks,dnnfpga.dagCompile.LayerKind.Relu);
            end
            if dnnfpga.dagCompile.Layers.isDropout(layer)
                ks=cat(1,ks,dnnfpga.dagCompile.LayerKind.Dropout);
            end
            if dnnfpga.dagCompile.Layers.isDepthConcat(layer)
                ks=cat(1,ks,dnnfpga.dagCompile.LayerKind.Concat);
            end
            if dnnfpga.dagCompile.Layers.isUnpool(layer)
                ks=cat(1,ks,dnnfpga.dagCompile.LayerKind.Unpool);
            end
            if dnnfpga.dagCompile.Layers.isCustomLayer(layer)
                ks=cat(1,ks,dnnfpga.dagCompile.LayerKind.CustomLayer);
            end
            if dnnfpga.dagCompile.Layers.isStateRead(layer)
                ks=cat(1,ks,dnnfpga.dagCompile.LayerKind.State);
            end
            if dnnfpga.dagCompile.Layers.isStateWrite(layer)
                ks=cat(1,ks,dnnfpga.dagCompile.LayerKind.State);
            end
            if dnnfpga.dagCompile.Layers.isIdentity(layer)
                ks=cat(1,ks,dnnfpga.dagCompile.LayerKind.Identity);
            end
            if dnnfpga.dagCompile.Layers.isConstant(layer)
                ks=cat(1,ks,dnnfpga.dagCompile.LayerKind.Constant);
            end
            if dnnfpga.dagCompile.Layers.isFCFmt(layer)
                ks=cat(1,ks,dnnfpga.dagCompile.LayerKind.FCFmt);
            end
            if dnnfpga.dagCompile.Layers.isLabel(layer)
                ks=cat(1,ks,dnnfpga.dagCompile.LayerKind.Label);
            end
            if dnnfpga.dagCompile.Layers.isResize(layer)
                ks=cat(1,ks,dnnfpga.dagCompile.LayerKind.Resize);
            end
        end
    end
end
