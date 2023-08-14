classdef actionType<uint8
















    enumeration

        Skip(0)


        Append(1)


        Recreate(2)
    end

    methods

        function TF=isSkip(this)

            TF=(this==actionType.Skip);
        end


        function TF=isAppend(this)

            TF=(this==actionType.Append);
        end

        function TF=isRecreate(this)

            TF=(this==actionType.Recreate);
        end

    end

end