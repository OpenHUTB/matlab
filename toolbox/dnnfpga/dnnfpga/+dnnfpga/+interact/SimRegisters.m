




classdef SimRegisters<handle&dnnfpga.interact.AbstractSimMem&matlab.mixin.Copyable

    properties
Model
Path
Id
ZeroData
DataSize
Banks
Size
Offset
SystemObject
    end

    methods
        function[obj,ss]=SimRegisters(path,id,bdEnabled,sampleData,num,sz,delta)
            import dnnfpga.interact.*
            parts=split(path,'/');
            obj.Model=parts(1);
            obj.Model=obj.Model{1};
            obj.Path=path;
            obj.Id=uint32(id);
            zeroData=cast(0,'like',sampleData);
            obj.ZeroData=repmat(zeroData,num,1);
            obj.DataSize=uint32(dnnfpga.codegen.Packed.getBitSize(zeroData));
            obj.Banks=uint32(num);
            obj.Size=uint32(sz);
            obj.SystemObject=SystemState(repmat(zeroData,num,sz));
            ss=obj.SystemObject;

            obj.Offset=uint32(delta);
            obj.validateBDAddr(obj.Offset);

            obj.Size=uint32(sz);

            if bdEnabled
                SimMemStore.registerMem(obj);
            end
        end
        function[data,nextAddr]=bdRead(obj,addr,num)
            obj.validateSelf();
            if nargin<3
                num=1;
            end
            bytesPerOne=uint32(double(obj.DataSize)/double(8));
            num=uint32(num);
            adr=uint32(addr)-obj.Offset*bytesPerOne;
            limit=uint32(obj.SystemObject.ReadLimit);

            nextAddr=adr+num*bytesPerOne;


            if uint32(addr)<obj.Offset*bytesPerOne||...
                ((nextAddr-bytesPerOne)>(obj.Size-1)*obj.Banks*bytesPerOne)
                error("bdRead request exceeds the address space of SimInputRegisters (%u).\n",obj.Id);
            end

            remain=num;
            nextAddr=adr;
            data=[];
            while remain>0
                if remain>limit
                    remain=remain-limit;
                    obj.SystemObject(false,nextAddr,limit);
                    r=obj.SystemObject.Results(1:limit);
                    nextAddr=nextAddr+limit*bytesPerOne;
                    data=[data,r];
                else
                    obj.SystemObject(false,nextAddr,remain);
                    r=obj.SystemObject.Results(1:remain);
                    nextAddr=nextAddr+remain*bytesPerOne;
                    remain=0;
                    data=[data,r];
                end
            end
            nextAddr=nextAddr+obj.Offset*bytesPerOne;
        end

        function nextAddr=bdWrite(obj,addr,data)
            obj.validateSelf();
            bytesPerOne=uint32(double(obj.DataSize)/double(8));
            adr=uint32(addr)-obj.Offset*bytesPerOne;



            num=uint32(numel(data));
            nextAddr=adr+num*bytesPerOne;

            if uint32(addr)<obj.Offset*bytesPerOne||...
                ((nextAddr-bytesPerOne)>(obj.Size-1)*obj.Banks*bytesPerOne)
                error("bdWrite request exceeds the address space of SimInputRegisters (%u).\n",obj.Id);
            end


            obj.SystemObject(true,adr,data);

            nextAddr=nextAddr+obj.Offset*bytesPerOne;

        end

        function[r,nextAddr]=read(obj,addr,num)
            [r,nextAddr]=obj.bdRead(addr,num);
        end

        function awaitNonZero(obj,addr)
            while true
                [v,next]=obj.bdRead(addr);
                if v~=0
                    break;
                end
                pause(0.1);
            end
        end
    end
end


