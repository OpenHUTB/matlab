


classdef UUID

    properties
Data
    end

    methods
        function uuid=UUID(value)


            if isa(value,'uint8')
                uuid.Data=value;
            else

                validateattributes(value,{'char'},{'size',[1,32]});
                uuid.Data=Simulink.dd.private.getBinaryUUIDFromString(value);
            end
        end

        function result=lt(a,b)

            adata=a.Data;
            bdata=b.Data;
            for i=1:16
                if adata(i)~=bdata(i)
                    result=(adata(i)<bdata(i));
                    return;
                end
            end
            result=false;
        end

        function result=gt(a,b)
            adata=a.Data;
            bdata=b.Data;
            for i=1:16
                if adata(i)~=bdata(i)
                    result=(adata(i)>bdata(i));
                    return;
                end
            end
            result=false;
        end

        function result=le(a,b)
            result=~gt(a,b);
        end

        function result=ge(a,b)
            result=~lt(a,b);
        end

        function result=eq(a,b)
            result=all(a.Data==b.Data);
        end

        function result=ne(a,b)
            result=any(a.Data~=b.Data);
        end

        function obj=set.Data(obj,data)

            validateattributes(data,{'uint8'},{'size',[1,16]});
            obj.Data=data;
        end

        function str=char(obj)



            str=Simulink.dd.private.getStringUUIDFromBinary(obj.Data);
        end
    end

    methods(Static)
        function uuid=nil()

            uuid=Simulink.dd.UUID(zeros(1,16,'uint8'));
        end
    end
end
