classdef J1850_CRC<handle





    properties(Access=private)
        J1850_Table=zeros(1,256);
    end

    methods
        function obj=J1850_CRC()
            obj.generateCRC8Table();
        end
    end

    methods
        function valid=validateCRC(obj,crc,buffer)


            valid=isequal(crc,obj.calculateCRC(buffer));
        end

        function crc=calculateCRC(obj,buffer)



            crc=uint8(255);
            for i=1:length(buffer)
                idx=bitxor(crc,buffer(i),'uint8');
                idx=uint32(idx)+1;
                crc=obj.J1850_Table(idx);
            end
        end
    end

    methods(Access=private)

        function generateCRC8Table(obj)


            poly=0x1D;

            for index=0:255
                currByte=uint8(index);

                for bit=0:7
                    if~isequal(bitand(currByte,0x80),0)
                        currByte=bitshift(currByte,1);
                        currByte=bitxor(currByte,poly);
                    else
                        currByte=bitshift(currByte,1);
                    end
                end
                obj.J1850_Table(index+1)=currByte;
            end
        end
    end
end

