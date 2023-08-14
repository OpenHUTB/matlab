



classdef MatlabFunctionMathDatatypeConstraint<...
    slci.compatibility.StateflowDatatypeConstraint

    methods


        function out=getDescription(aObj)%#ok
            out=['Operands of Math operation in Matlab Function '...
            ,' must be of type ''int8'', ''int16'',''int32'','...
            ,'''uint8'',''uint16'',''uint32'',''single'' or '...
            ,'''double'' '];
        end

        function obj=MatlabFunctionMathDatatypeConstraint
            obj.setEnum('MatlabFunctionMathDatatype');
            obj.setFatal(false);
            obj.fSupportedTypes={'int8','int16','int32','uint8',...
            'uint16','uint32','single','double'};
        end


        function out=check(aObj)

            out=[];
            owner=aObj.getOwner();

            assert(isa(owner,'slci.ast.SFAst'));

            children=owner.getChildren();
            for i=1:numel(children)
                child=children{1};
                if~aObj.isMathExpression(child)
                    dataType=child.getDataType();
                    dataWidth=child.getDataWidth();
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
    end

    methods(Access=private)

        function out=isMathExpression(~,ast)
            out=isa(ast,'slci.ast.SFAstPlus')...
            ||isa(ast,'slci.ast.SFAstMinus')...
            ||isa(ast,'slci.ast.SFAstMul')...
            ||isa(ast,'slci.ast.SFAstTimes')...
            ||isa(ast,'slci.ast.SFAstDivide')...
            ||isa(ast,'slci.ast.SFAstLDiv')...
            ||isa(ast,'slci.ast.SFAstDotLDiv')...
            ||isa(ast,'slci.ast.SFAstDotDiv')...
            ||isa(ast,'slci.ast.SFAstUplus')...
            ||isa(ast,'slci.ast.SFAstUminus')...
            ||isa(ast,'slci.ast.SFAstDotPow')...
            ||isa(ast,'slci.ast.SFAstPow')...
            ||isa(ast,'slci.ast.SFAstMathBuiltin')...
            ;
        end

    end

end

