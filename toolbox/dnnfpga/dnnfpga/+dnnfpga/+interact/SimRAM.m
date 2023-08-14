




classdef SimRAM<dnnfpga.interact.AbstractSimMem&matlab.mixin.Copyable

    properties
Model
Path
Id
SystemObject
ZeroAddr
ZeroData
Banks
AddrSize
DataSize
Exchange
Stamp
    end

    methods


        function[obj,hdlRam]=SimRAM(path,id,bdEnabled,sampleAddr,sampleData,varargin)
            import dnnfpga.interact.*
            parts=split(path,'/');

            hdlRam=hdl.RAM(varargin{:});
            obj.Stamp=typecast(now(),'uint64');
            obj.Model=parts(1);
            obj.Model=obj.Model{1};
            obj.Path=path;
            obj.Id=uint32(id);
            obj.SystemObject=hdlRam;
            obj.ZeroAddr=cast(0,'like',sampleAddr);
            zeroData=cast(0,'like',sampleData);
            obj.ZeroData=repmat(zeroData,size(sampleData));
            sz=uint32(dnnfpga.codegen.Packed.getBitSize(obj.ZeroAddr));
            obj.AddrSize=sz;
            obj.DataSize=uint32(dnnfpga.codegen.Packed.getBitSize(zeroData));
            obj.Banks=numel(obj.ZeroData);
            obj.Exchange=repmat(zeroData,1,1024+obj.Banks);
            if bdEnabled
                SimMemStore.registerMem(obj);
            end
        end
    end
    methods









        function[r,nextAddr]=bdRead(obj,addr,num)
            limit=obj.getReadWriteLimit();
            if num>limit
                error(sprintf("A maximum of %u elements can be read using 'bdRead'.\n",limit));
            end
            obj.validateBDAddr(addr);

            bytesPerOne=uint32(double(obj.DataSize)/double(8));

            bytes=uint32(double(obj.DataSize)*double(numel(obj.ZeroData))/double(8));

            shift=uint32(log2(double(bytes)));

            addrStart=bitsrl(uint32(addr),shift);

            addrTrunc=bitsll(addrStart,shift);

            delta=uint32(addr)-addrTrunc;

            skip=uint32(double(delta)/double(bytesPerOne));
            adr=addrStart;
            n=uint32(0);
            nm=num+obj.Banks;
            while true

                readAddr=cast(adr,'like',obj.ZeroAddr);
                [~,dout]=step(obj.SystemObject,obj.ZeroData,readAddr,false,readAddr);

                for i=1:numel(obj.ZeroData)
                    if skip==0
                        n=n+uint32(1);

                        obj.Exchange(n)=dout(i);
                        if n==nm
                            break;
                        end
                    else

                        skip(:)=skip-uint32(1);
                    end
                end
                if n==nm
                    break;
                end
                adr(:)=adr+uint32(1);
            end
            r=obj.Exchange(obj.Banks+1:obj.Banks+num);
            nextAddr=addr+num*bytesPerOne;
        end




        function nextAddr=bdWrite(obj,addr,data)
            num=numel(data);
            limit=obj.getReadWriteLimit();
            if num>limit
                error(sprintf("A maximum of %u elements can be written using 'bdWrite'.\n",limit));
            end
            obj.Exchange(1:num)=reshape(data,1,num);
            obj.validateBDAddr(addr);

            bytesPerOne=uint32(double(obj.DataSize)/double(8));

            bytes=uint32(double(obj.DataSize)*double(numel(obj.ZeroData))/double(8));

            shift=uint32(log2(double(bytes)));

            addrStart=bitsrl(uint32(addr),shift);

            addrTrunc=bitsll(addrStart,shift);

            delta=uint32(addr)-addrTrunc;

            skip=uint32(double(delta)/double(bytesPerOne));
            adr=addrStart;
            n=uint32(0);
            first=true;
            while true
                writeAddr=cast(adr,'like',obj.ZeroAddr);
                last=(num-n)<=obj.Banks;
                if first||last
                    [~,dd]=step(obj.SystemObject,obj.ZeroData,writeAddr,false,writeAddr);
                    [~,dd]=step(obj.SystemObject,obj.ZeroData,writeAddr,false,writeAddr);
                    first=false;
                else
                    dd=obj.ZeroData;
                end

                for i=1:obj.Banks
                    if skip==0
                        n=n+uint32(1);

                        dd(i)=obj.Exchange(n);
                        if n==num
                            break;
                        end
                    else


                        skip(:)=skip-uint32(1);
                    end
                end
                step(obj.SystemObject,dd,writeAddr,true,writeAddr);
                if n==num
                    break;
                end
                adr(:)=adr+uint32(1);
            end
            nextAddr=addr+num*bytesPerOne;
        end





        function[r,nextAddr]=read(obj,addr,num)
            limit=obj.getReadWriteLimit();
            r=[];
            remain=num;
            nextAddr=addr;
            while remain>0
                n=min(remain,limit);
                [r0,nextAddr]=obj.bdRead(nextAddr,n);
                remain=remain-n;
                r=[r,r0];
            end
        end



        function nextAddr=write(obj,addr,data)
            limit=obj.getReadWriteLimit();
            remain=numel(data);
            nextAddr=addr;
            current=1;
            while remain>0
                n=min(remain,limit);
                nextAddr=obj.bdWrite(nextAddr,data(current:current+n-1));
                current=current+n;
                remain=remain-n;
            end
        end


        function limit=getReadWriteLimit(obj)
            limit=uint32(numel(obj.Exchange)-obj.Banks);
        end

    end
end


