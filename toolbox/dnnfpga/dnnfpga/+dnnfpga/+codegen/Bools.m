%#codegen


classdef Bools
    methods(Static)
        function bs=or(bs0,bs1)
            coder.allowpcode('plain');
            bs=bs0|bs1;
        end
        function bs=shiftll(bs0,n)
            coder.allowpcode('plain');
            bs=dnnfpga.codegen.Bools.allZeros();
            bs1=dnnfpga.codegen.Bools.extend(bs0);
            for i=1:numel(bs)
                if i<=(numel(bs1)-n)
                    bs(i)=bs1(i+n);
                end
            end
        end
        function bs=shiftlr(bs0,n)
            coder.allowpcode('plain');
            bs=dnnfpga.codegen.Bools.allZeros();
            bs1=dnnfpga.codegen.Bools.extend(bs0);
            for i=n:numel(bs)
                if i>=n+1
                    bs(i)=bs1(i-n);
                end
            end
        end
        function bs=extend(bs0,sz)
            coder.allowpcode('plain');
            if nargin<2
                sz=dnnfpga.codegen.Bools.bitSizeMax();
            end
            n=uint32(numel(bs0));
            bs=dnnfpga.codegen.Bools.allZeros(max(uint32(sz),n));
            bs(end-n+1:end)=bs0;
        end



        function[r,sz]=fromBools(bs,evalue)
            coder.allowpcode('plain');
            if islogical(evalue)
                r=bs(end);
                sz=uint32(1);
            elseif isa(evalue,'single')
                [ur,sz]=dnnfpga.codegen.Bools.fromBools(bs,uint32(0));
                r=typecast(ur,'single');
            else
                sz=dnnfpga.codegen.Bools.getBitSize(evalue);
                r=evalue;
                for z=1:sz
                    r=bitset(r,z,bs(end-z+1));
                end
            end
        end


        function[bs,sz]=toBools(value)
            coder.allowpcode('plain');
            if islogical(value)
                sz=uint32(1);
                bs=dnnfpga.codegen.Bools.extend(value);
            elseif isa(value,'single')
                [bs,sz]=dnnfpga.codegen.Bools.toBools(typecast(value,'uint32'));
            else
                if isfi(value)
                    sz=uint32(value.WordLength);
                else
                    sz=uint32(dnnfpga.codegen.Bools.getBuiltinSize(value));
                end
                bs=dnnfpga.codegen.Bools.allZeros();
                for i=uint32(1):sz
                    bs(end-i+1)=logical(bitget(value,i));
                end
            end
        end


        function sz=getBitSize(value)
            coder.allowpcode('plain');
            if isfi(value)
                sz=uint32(value.WordLength);
            else
                sz=uint32(dnnfpga.codegen.Bools.getBuiltinSize(value));
            end
        end


        function sz=getBuiltinSize(value)
            coder.allowpcode('plain');
            switch(class(value))
            case 'logical'
                sz=1;
            case{'int8','uint8'}
                sz=8;
            case{'int16','uint16','half'}
                sz=16;
            case{'int32','uint32','single'}
                sz=32;
            case{'int64','uint64','double'}
                sz=64;
            otherwise
                sz=0;
            end
        end
        function chars=toBin(bs)
            chars=dec2bin(bs)';
        end
        function bs=allZeros(sz)
            coder.allowpcode('plain');
            if nargin<1
                sz=dnnfpga.codegen.Bools.bitSizeMax();
            end
            bs=zeros(1,sz,'logical');
        end
        function sz=bitSizeMax()
            coder.allowpcode('plain');
            sz=uint32(512);
        end
    end
end
