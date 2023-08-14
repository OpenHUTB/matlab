






classdef SFAstIf<slci.ast.SFAst
    properties
        fIfHeadIdx=-1;
        fElseIfIdx={};
        fElseIdx=-1;
    end

    methods
        function aObj=SFAstIf(aAstObj,aParent)

            assert(isa(aAstObj,'mtree'),...
            message('Slci:slci:NotMtreeNode',...
            'SFAstIf').getString);
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);


            aObj.setProperty();
        end


        function out=getIfHeadAST(aObj)
            objChildren=aObj.getChildren();

            assert(aObj.fIfHeadIdx~=-1);
            assert(aObj.fIfHeadIdx<=numel(objChildren));
            out=objChildren(aObj.fIfHeadIdx);
        end


        function out=getElseIfAST(aObj)
            out=cell(1,numel(aObj.fElseIfIdx));
            if(~isempty(aObj.fElseIfIdx))
                objChildren=aObj.getChildren();

                for k=1:numel(aObj.fElseIfIdx)
                    assert(aObj.fElseIfIdx{k}<=numel(objChildren));
                    out{1,k}=objChildren{1,aObj.fElseIfIdx{k}};
                end
            end
        end


        function out=getElseAST(aObj)
            out={};
            if(aObj.fElseIdx~=-1)

                objChildren=aObj.getChildren();
                assert(aObj.fElseIdx<=numel(objChildren));
                out=objChildren(aObj.fElseIdx);
            end
        end
    end

    methods(Access=private)

        function setProperty(aObj)
            objChildren=aObj.getChildren();

            for k=1:numel(objChildren)
                objChild=objChildren{k};

                if(isa(objChild,'slci.ast.SFAstIfHead'))
                    aObj.fIfHeadIdx=k;
                elseif(isa(objChild,'slci.ast.SFAstElseIf'))
                    aObj.fElseIfIdx{end+1}=k;
                elseif(isa(objChild,'slci.ast.SFAstElse'))
                    aObj.fElseIdx=k;
                else
                    assert(false,['Error SFAstIf children: ',class(objChild)]);
                end
            end
        end

    end

    methods(Access=protected)

        function addMatlabFunctionConstraints(aObj)
            newConstraints={...
            slci.compatibility.MatlabFunctionIfCondDimConstraint,...
            slci.compatibility.MatlabFunctionPersistentCondConstraint,...
            slci.compatibility.MatlabFunctionPersistentInitConstraint...
            };
            aObj.setConstraints(newConstraints);
        end
    end
end
