classdef FPTools




    methods(Static)

        function C=bitGet(data,lidx,ridx)

            dataclass=class(data);
            switch(dataclass)
            case 'int8'
                data=typecast(data,'uint8');
            case 'int16'
                data=typecast(data,'uint16');
            case 'int32'
                data=typecast(data,'uint32');
            case 'int64'
                data=typecast(data,'uint64');
            otherwise
                validateattributes(data,{'uint8','uint16','uint32','uint64','int8','int16','int32','int64'},{});
            end
            ONE=cast(ones(size(data)),class(data(1)));
            validBitNum=lidx-ridx+1;
            bitMask=bitshift(ONE,validBitNum)-1;
            C=bitand(...
            bitshift(data,-(ridx-1)),bitMask);
        end

        function C=bitConcat(data0,data1)

            if(isa(class(data0),class(data1)))
                error("The input must have the same data type.");
            end
            dataclass=class(data0);
            switch(dataclass)
            case{'uint8'}
                C=bitor(...
                bitshift(uint16(data0),8),uint16(data1)...
                );
            case{'int8'}
                C=bitor(...
                bitshift(int16(data0),8),int16(data1)...
                );
                C=typecast(C,'int16');
            case{'uint16'}
                C=bitor(...
                bitshift(uint32(data0),16),uint32(data1)...
                );
            case{'int16'}
                C=bitor(...
                bitshift(uint32(data0),16),uint32(data1)...
                );
                C=typecast(C,'int32');
            case{'uint32'}
                C=bitor(...
                bitshift(uint64(data0),32),uint64(data1)...
                );
            case{'int32'}
                C=bitor(...
                bitshift(uint64(data0),32),uint64(data1)...
                );
                C=typecast(C,'int64');
            otherwise
                validateattributes(data,{'uint8','uint16','uint32','int8','int16','int32'},{});
            end
        end

        function a=FPConvert(v,s,w,f)






            validateattributes(v,{'double','single'},{},'FPConvert','v');
            validateattributes(w,{'numeric'},{'scalar','>',1,'<=',64},'FPConvert','w');
            validateattributes(f,{'numeric'},{'scalar','>=',0,'<',max(w-1,50)},'FPConvert','f');
            if(s~=0)
                index0=v>(2^(w-1-f)-2^(-f));
                a(index0)=int64(2^(w-1)-1);
                index1=v<(-(2^(w-1-f)));
                a(index1)=-int64(2^(w-1));

                index=~(index0|index1);
                coeff_scale=v(index)*2^f;
                a(index)=int64(round(coeff_scale));
            else
                index0=v>(2^(w-f)-2^(-f));
                a(index0)=int64(2^w-1);
                index1=v<(-(2^(w-f)));
                a(index1)=-int64(2^w);

                index=~(index0|index1);
                coeff_scale=v(index)*2^f;
                a(index)=int64(round(coeff_scale));
            end
        end
    end

end
