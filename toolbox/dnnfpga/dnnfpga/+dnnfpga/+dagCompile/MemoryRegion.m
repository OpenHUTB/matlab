





classdef MemoryRegion<dnnfpga.dagCompile.AddData&matlab.mixin.Copyable;

    properties
num
kind
size
baseAddr
        offsetX=uint32(0);
        offsetY=uint32(0);
        offsetZ=uint32(0);
nets
bytesPerData
defaultAddrOffset
    end
    properties(Dependent)
label
    end
    methods
        function obj=MemoryRegion(regionKind,bytesPerData)
            import dnnfpga.dagCompile.*
            if nargin>=1
                obj.kind=regionKind;
            else
                obj.kind=RegionKind.None;
            end
            if nargin>=2
                obj.bytesPerData=uint32(bytesPerData);
            else
                obj.bytesPerData=uint32(4);
            end
            obj.defaultAddrOffset=uint32(0);
        end

        function value=getAddr(obj)
            value=obj.baseAddr+obj.offsetZ;
        end

        function value=get.label(obj)
            if obj.num==0
                value='EMPTY';
            else
                value=sprintf('%c',obj.num+64);
            end
        end
        function updateSize(obj,ddrSupport)
            import dnnfpga.dagCompile.*
            value=0;
            for i=1:numel(obj.nets)
                net=obj.nets(i);


                sz=ddrSupport.normalizeSize(net.size,net.dataFormat);
                value=max(value,prod(sz));
            end
            obj.size=obj.bytesPerData*value;
        end

        function obj=addNet(obj,net)
            if isa(net,'dnnfpga.dagCompile.Net')
                obj.nets=cat(1,obj.nets,net);
            else
                msg=message('dnnfpga:workflow:InvalidDataWrongClass','net','dnnfpga.dagCompile.Net',class(net));
                error(msg);
            end
        end


        function names=getInputNames(obj)
            names={};
            for i=1:numel(obj.nets)
                net=obj.nets(i);
                pinst=net.driver;
                if pinst.component.isInput()
                    names{end+1}=pinst.component.name;
                end
            end
        end


        function names=getOutputNames(obj)
            names={};
            for i=1:numel(obj.nets)
                net=obj.nets(i);
                for j=1:numel(net.receivers)
                    pinst=net.receivers(j);
                    if pinst.component.isOutput()
                        names{end+1}=pinst.component.name;
                    end
                end
            end
        end
    end
end
