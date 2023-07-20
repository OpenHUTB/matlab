



classdef MatlabFunctionColonDatatypeConstraint<...
    slci.compatibility.StateflowDatatypeConstraint

    methods


        function out=getDescription(aObj)%#ok
            out=['Operands of Math operation in Matlab Function '...
            ,' must be of type ''int8'', ''int16'',''int32'','...
            ,'''uint8'',''uint16'',''uint32'' or '...
            ,'''double'' '];
        end

        function obj=MatlabFunctionColonDatatypeConstraint
            obj.setEnum('MatlabFunctionColonDatatype');
            obj.setFatal(false);
            obj.fSupportedTypes={'int8','int16','int32','uint8',...
            'uint16','uint32','double'};
        end


        function out=check(aObj)

            out=[];
            owner=aObj.getOwner();

            assert(isa(owner,'slci.ast.SFAstColon'));

            dataType=owner.getDataType();
            dataWidth=owner.getDataWidth();
            isMissingType=isempty(dataType)||isempty(dataWidth);
            if~isMissingType
                isSupported=aObj.supportedType(dataType,dataWidth);
                if~isSupported
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    aObj.getEnum());
                end
            end
        end
    end

end

