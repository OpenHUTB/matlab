classdef ByteOrder<handle




%#codegen

    methods(Access=private)
        function obj=ByteOrder()
            coder.allowpcode('plain');
        end
    end

    methods(Static)
        function out=getSwappedBytes(in)
            coder.inline('always');

            if~(isequal(class(in),'uint8')||isequal(in,'int8'))
                out=typecast(swapbytes(in),'uint8');
            else
                out=in;
            end
        end

        function out=concatenateBytes(in,dtype)
            coder.inline('always');

            out=typecast(in,dtype);
        end

        function changeData=changeByteOrder(data,datatype)
            coder.inline('always');
            if~(isequal(datatype,'int8')||isequal(datatype,'uint8'))

                changeData=ioplayback.base.ByteOrder.concatenateBytes(data,datatype);


                changeData=swapbytes(changeData);
            else

                changeData=ioplayback.base.ByteOrder.concatenateBytes(data,datatype);
            end
        end

        function allowedDataType(DataType)
            validatestring(DataType,{'int8','uint8','int16','uint16','int32','uint32','int64','uint64','single','double'},'','Data type');
        end

        function NumberOfBytes=getNumberOfBytes(DataType)
            ioplayback.base.ByteOrder.allowedDataType(DataType);
            switch(DataType)
            case{'int8','uint8'}
                NumberOfBytes=1;
            case{'int16','uint16'}
                NumberOfBytes=2;
            case{'int32','uint32','single'}
                NumberOfBytes=4;
            case{'int64','uint64','double'}
                NumberOfBytes=8;
            otherwise
                error('Invalid datatype');
            end
        end

        function outvalue=reverseBits(value,precision)
            coder.inline('always');

            validateattributes(value,{'numeric'},{'vector'},'','value');
            NumberOfBytes=ioplayback.base.ByteOrder.getNumberOfBytes(precision);

            outvalue=coder.nullcopy(cast(zeros(size(value)),precision));


            for j=1:numel(value)
                if isequal(class(value),precision)
                    outvalue1=value(j);
                else
                    outvalue1=cast(value(j),precision);
                end

                for i=int32(1):int32(NumberOfBytes*8/2)

                    outvalue(j)=bitor(bitset(outvalue(j),NumberOfBytes*8-i+1,bitget(outvalue1,i)),bitset(outvalue(j),i,bitget(outvalue1,NumberOfBytes*8-i+1)));
                end
            end
        end
    end
end
