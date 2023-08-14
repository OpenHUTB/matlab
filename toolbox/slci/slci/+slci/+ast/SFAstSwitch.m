








classdef SFAstSwitch<slci.ast.SFAst
    properties
        fCaseIdx={};
        fOtherwiseIdx={};
    end

    methods

        function aObj=SFAstSwitch(aAstObj,aParent)

            assert(isa(aAstObj,'mtree'),...
            message('Slci:slci:NotMtreeNode',...
            'SFAstSwitch').getString);
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);


            aObj.setProperty();
        end


        function out=getCondAST(aObj)
            objChildren=aObj.getChildren();
            assert(numel(objChildren)>0);

            out=objChildren{1};
        end


        function out=getCaseAST(aObj)
            out=cell(1,numel(aObj.fCaseIdx));
            if(~isempty(aObj.fCaseIdx))
                objChildren=aObj.getChildren();

                for k=1:numel(aObj.fCaseIdx)
                    assert(aObj.fCaseIdx{k}<=numel(objChildren));
                    out{1,k}=objChildren{1,aObj.fCaseIdx{k}};
                end
            end
        end


        function out=getOtherwiseAST(aObj)
            out={};
            if(~isempty(aObj.fOtherwiseIdx))
                objChildren=aObj.getChildren();
                assert(numel(aObj.fOtherwiseIdx)==1);
                assert(aObj.fOtherwiseIdx<=numel(objChildren));
                out=objChildren(aObj.fOtherwiseIdx);
            end
        end
    end

    methods(Access=private)


        function setProperty(aObj)
            objChildren=aObj.getChildren();
            assert(numel(objChildren)>0);


            for k=2:numel(objChildren)
                objChild=objChildren{k};
                if(isa(objChild,'slci.ast.SFAstCase'))
                    aObj.fCaseIdx{end+1}=k;
                elseif(isa(objChild,'slci.ast.SFAstOtherwise'))
                    aObj.fOtherwiseIdx=k;
                else

                    assert(false,['Error SFAstSwitch children:',class(objChild)]);
                end
            end

        end

    end

    methods(Access=protected)

        function addMatlabFunctionConstraints(aObj)
            newConstraints={...
            slci.compatibility.MatlabFunctionSwitchCaseConstraint,...
            slci.compatibility.MatlabFunctionSwitchCondTypeConstraint,...
            };
            aObj.setConstraints(newConstraints);

            addMatlabFunctionConstraints@slci.ast.SFAst(aObj);
        end
    end

end