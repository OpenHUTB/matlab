






classdef MatlabFunctionAssumedTypeConstraint<slci.compatibility.Constraint
    properties(Access=protected)
        fSupportedTypes={};
    end

    methods

        function out=getDescription(aObj)%#ok
            out=['ASSUMEDTYPE in Matlab bit operators '...
            ,' must be of type ''int8'', ''int16'',''int32'','...
            ,'''uint8'',''uint16'',''uint32'''];
        end


        function obj=MatlabFunctionAssumedTypeConstraint
            obj.setEnum('MatlabFunctionAssumedType');
            obj.setFatal(false);
            obj.fSupportedTypes={'int8','int16','int32',...
            'uint8','uint16','uint32'};
        end


        function out=check(aObj)

            out=[];
            owner=aObj.getOwner();

            assert(aObj.isBitOpAst(owner));
            assumpedType=owner.getTypeName();
            if~isempty(assumpedType)
                isSupported=any(ismember(aObj.fSupportedTypes,assumpedType));
                if~isSupported
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    aObj.getEnum());
                end
            end

        end


        function[SubTitle,Information,StatusText,RecAction]=...
            getSpecificMAStrings(aObj,status,varargin)
            if status
                status='Pass';
            else
                status='Warn';
            end
            enum=aObj.getEnum();
            StatusText=DAStudio.message(...
            ['Slci:compatibility:',enum,'Constraint',status]);
            Information=DAStudio.message(...
            ['Slci:compatibility:',enum,'ConstraintInfo']);
            SubTitle=DAStudio.message(...
            ['Slci:compatibility:',enum,'ConstraintSubTitle']);
            RecAction=DAStudio.message(...
            ['Slci:compatibility:',aObj.getEnum(),'ConstraintRecAction'],...
            aObj.getListOfStrings(aObj.fSupportedTypes,false));
        end

    end

    methods(Access=private)

        function out=isBitOpAst(~,ast)
            out=isa(ast,'slci.ast.SFAstBitAnd')...
            ||isa(ast,'slci.ast.SFAstBitOr')...
            ||isa(ast,'slci.ast.SFAstBitXor')...
            ||isa(ast,'slci.ast.SFAstBitCmp')...
            ||isa(ast,'slci.ast.SFAstBitShift')...
            ||isa(ast,'slci.ast.SFAstBitGet')...
            ||isa(ast,'slci.ast.SFAstBitSet');
        end
    end

end