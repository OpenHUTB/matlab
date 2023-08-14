classdef Queue<handle



































%#codegen

    properties(Access=protected)

        buffer;
        popAddress;
        entryCount;

    end

    methods



        function obj=Queue(bufferLength,dataType)



            coder.allowpcode('plain');

            obj.buffer=cell(bufferLength,1);
            for k=1:bufferLength
                obj.buffer{k}=dataType;
            end
            obj.popAddress=uint32(1);
            obj.entryCount=uint32(0);

        end



        function result=isEmpty(obj)
            result=(obj.entryCount==0);
        end



        function result=isFull(obj)
            result=(obj.entryCount==length(obj.buffer));
        end



        function value=pop(obj)

            value=obj.buffer{obj.popAddress};

            if obj.entryCount>0


                if obj.popAddress==length(obj.buffer)
                    obj.popAddress(:)=1;
                else
                    obj.popAddress(:)=obj.popAddress+1;
                end

                obj.entryCount(:)=obj.entryCount-1;

            end

        end



        function push(obj,value)

            if obj.entryCount<length(obj.buffer)


                writeAddress=obj.popAddress+obj.entryCount;

                if writeAddress>length(obj.buffer)
                    writeAddress=writeAddress-length(obj.buffer);
                end

                obj.buffer{writeAddress}(:)=value;

                obj.entryCount=obj.entryCount+1;

            end

        end




        function clear(obj)

            obj.popAddress=uint32(1);
            obj.entryCount=uint32(0);

        end



        function disp(obj)

            L=length(obj.buffer);

            if obj.entryCount==0
                queueUnrwapped={};
            else
                backAddress=obj.popAddress+obj.entryCount-1;

                if backAddress<=L
                    queueUnrwapped=obj.buffer(obj.popAddress:backAddress);
                else
                    backAddress=backAddress-length(obj.buffer);
                    queueUnrwapped=cell(obj.entryCount,1);
                    p=length(obj.buffer)-obj.popAddress+1;
                    queueUnrwapped(1:p)=obj.buffer(obj.popAddress:L);
                    queueUnrwapped(p+1:end)=obj.buffer(1:backAddress);
                end
            end

            disp(queueUnrwapped);

        end

    end

end
