classdef DataDescriptor<handle

    properties
name
net
memoryRegion
bytesPerData
dataTransNum
convThreadNum
fcThreadNum
constValue
    end

    methods
        function obj=DataDescriptor(name,net,memoryRegion,dataTransNum,bytesPerData,convThreadNum,fcThreadNum,constValue)
            obj.name=name;
            obj.net=net;
            obj.memoryRegion=memoryRegion;
            obj.dataTransNum=uint32(dataTransNum);
            obj.bytesPerData=uint32(bytesPerData);
            obj.convThreadNum=uint32(convThreadNum);
            obj.fcThreadNum=uint32(fcThreadNum);
            if(nargin>7)
                obj.constValue=constValue;
            else
                obj.constValue=[];
            end
        end
        function count=getDataCount(obj)
            import dnnfpga.dagCompile.*
            sz=DDRSupport.normalizeSizeStatic(obj.net.size,obj.dataTransNum,obj.convThreadNum,obj.net.dataFormat,obj.fcThreadNum);
            count=uint32(prod(sz));
        end
        function sz=getSizeInBytes(obj)
            import dnnfpga.dagCompile.*
            count=obj.getDataCount();
            sz=uint32(count*obj.bytesPerData);
        end
    end
end