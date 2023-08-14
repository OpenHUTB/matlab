




classdef SystemState<matlab.System

    properties
Value
Size
ZeroData
Banks
DataSize

    end

    properties(Hidden=true)
ReadLimit
Results
    end

    methods
        function obj=SystemState(value,readLimit)
            if nargin<2
                readLimit=16;
            end
            obj.ReadLimit=uint32(min(readLimit,numel(value)));
            obj.Value=value;
            obj.Size=uint32(size(value));
            zeroData=cast(0,'like',value(1,1));
            obj.ZeroData=repmat(zeroData,obj.Size(1),1);
            obj.DataSize=uint32(dnnfpga.codegen.Packed.getBitSize(zeroData));
            obj.Banks=numel(obj.ZeroData);
            obj.Results=repmat(zeroData,1,obj.ReadLimit);
        end
    end

    methods(Access=protected)



        function y=stepImpl(obj,isWrite,arg0,arg1)

            y=obj.Value;
            if nargin==4&&isWrite&&arg0>=0
                addr=arg0;
                data=arg1;
                obj.bdWrite(addr,data);
            end
            if nargin==4&&~isWrite&&arg0>=0
                addr=arg0;
                num=arg1;
                [r,~]=obj.bdRead(addr,num);
                obj.Results(1:num)=r;
            end
            if nargin==3&&isWrite
                if size(arg0)~=obj.Size
                    error("Value to be written does not match size of SystemState value.\n")
                end
                obj.Value=arg0;
            end
        end
    end
    methods





        function[r,nextAddr]=bdRead(obj,addr,nm)
            num=uint32(nm);
            adr=uint32(addr);
            obj.validateBDAddr(adr);

            bytesPerOne=uint32(double(obj.DataSize)/double(8));

            if(adr+num*bytesPerOne)>prod(obj.Size)*bytesPerOne
                error("bdRead request exceeds the address space of SystemState.\n");
            end


            shift=uint32(log2(double(bytesPerOne)));

            addrStart=bitsrl(uint32(addr),shift);
            r=obj.Value(addrStart+1:addrStart+num);

            nextAddr=addr+num*bytesPerOne;
        end





        function nextAddr=bdWrite(obj,addr,data)
            num=uint32(numel(data));
            adr=uint32(addr);
            obj.validateBDAddr(adr);

            bytesPerOne=uint32(double(obj.DataSize)/double(8));

            if(adr+num*bytesPerOne)>prod(obj.Size)*bytesPerOne
                error("bdWrite request exceeds the address space of SystemState.\n");
            end


            shift=uint32(log2(double(bytesPerOne)));

            addrStart=bitsrl(uint32(addr),shift);

            obj.Value(addrStart+1:addrStart+num)=reshape(data,1,[]);
            nextAddr=addr+num*bytesPerOne;
        end
        function validateBDAddr(obj,address)
            bytesPerOne=uint32(double(obj.DataSize)/double(8));
            r=mod(address,bytesPerOne);
            if r~=0
                error("Address/Offset values must be an even multiple of %u bytes.\n",bytesPerOne);
            end
        end
    end
end
