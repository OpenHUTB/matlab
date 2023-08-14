


classdef SFUtil<handle

    properties(Constant,Access=private)
        fIsReal=containers.Map({'single','double'},{1,1});
        fIsInteger=containers.Map({'int32','int16','int8','uint32','uint16','uint8'},{1,1,1,1,1,1});
        fIsIntegerOrBoolean=containers.Map({'int32','int16','int8','uint32','uint16','uint8','boolean'},{1,1,1,1,1,1,1});
        fIsSigned=containers.Map({'int32','int16','int8'},{1,1,1});
        fIsUnsigned=containers.Map({'uint32','uint16','uint8'},{1,1,1});
        fIsUnsignedOrBoolean=containers.Map({'uint32','uint16','uint8','boolean'},{1,1,1,1});
        fIsBuiltin=containers.Map({'boolean','single','double','int32','int16','int8','uint32','uint16','uint8'},{1,1,1,1,1,1,1,1,1});
    end

    methods(Static=true)

        function out=IsReal(dtype)
            out=isKey(slci.stateflow.SFUtil.fIsReal,dtype);
        end

        function out=IsInteger(dtype)
            out=isKey(slci.stateflow.SFUtil.fIsInteger,dtype);
        end

        function out=IsIntegerOrBoolean(dtype)
            out=isKey(slci.stateflow.SFUtil.fIsIntegerOrBoolean,dtype);
        end

        function out=IsSigned(dtype)
            out=isKey(slci.stateflow.SFUtil.fIsSigned,dtype);
        end

        function out=IsUnsigned(dtype)
            out=isKey(slci.stateflow.SFUtil.fIsUnsigned,dtype);
        end

        function out=IsUnsignedOrBoolean(dtype)
            out=isKey(slci.stateflow.SFUtil.fIsUnsignedOrBoolean,dtype);
        end

        function out=IsBuiltin(dtype)
            out=isKey(slci.stateflow.SFUtil.fIsBuiltin,dtype);
        end


        function LinkTransitionsAndJunctions(transitions,junctions)
            junctionMap=...
            containers.Map('KeyType','double','ValueType','any');

            for i=1:numel(junctions)
                junction=junctions(i);
                junctionMap(junction.getSfId)=junction;
            end

            for i=1:numel(transitions)
                transition=transitions(i);
                srcId=transition.getSrcId();
                junction=junctionMap(srcId);
                junction.AddOutgoingTransition(transition);
                dstId=transition.getDstId();
                if isKey(junctionMap,dstId)
                    junction=junctionMap(dstId);
                    junction.AddIncomingTransition(transition);
                end
            end

            for i=1:numel(junctions)
                junction=junctions(i);
                junction.SortOutgoingTransitions();
            end

        end

    end

end
