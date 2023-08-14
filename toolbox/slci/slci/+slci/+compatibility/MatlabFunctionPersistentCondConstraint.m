

classdef MatlabFunctionPersistentCondConstraint<slci.compatibility.Constraint

    methods


        function out=getDescription(aObj)%#ok
            out=['Initialization of persistent variable in MATLAB code '...
            ,'uses isempty(persistent) or ~isempty(persistent) as '...
            ,'if condition'];
        end


        function obj=MatlabFunctionPersistentCondConstraint()
            obj.setEnum('MatlabFunctionPersistentCond');
            obj.setFatal(false);
        end


        function out=check(aObj)
            out=[];
            owner=aObj.getOwner();
            assert(isa(owner,'slci.ast.SFAstIf'));

            root=owner.getRootAst();


            if~isa(root,'slci.ast.SFAstMatlabFunctionDef')
                return;
            end

            pers=root.getPersistentArgs();
            if isempty(pers)
                return;
            end

            ifhead=owner.getIfHeadAST();
            condAst=ifhead{1}.getCondAST();
            containIsEmptyPer=aObj.containIsEmptyPersistent(pers,condAst{1});

            if containIsEmptyPer
                isSupportedConditon=aObj.isSupportedCondition(condAst{1});

                if~isSupportedConditon
                    out=slci.compatibility.Incompatibility(aObj,...
                    aObj.getEnum());
                end
            end
        end


    end

    methods(Access=private)

        function out=containIsEmptyPersistent(aObj,pers,ast)
            if isa(ast,'slci.ast.SFAstIsTester')
                funcName=ast.getFuncName();
                if strcmpi(funcName,'isempty')
                    child=ast.getChildren();
                    assert(numel(child)==1);
                    if isa(child{1},'slci.ast.SFAstIdentifier')
                        id=child{1}.getIdentifier;
                        for i=1:numel(pers)
                            assert(isa(pers{i},...
                            'slci.ast.SFAstIdentifier'));
                            pid=pers{i}.getIdentifier();
                            out=strcmpi(pid,id);
                            if out
                                return;
                            end
                        end
                    else
                        out=aObj.containIsEmptyPersistent(pers,child{1});
                        return;
                    end
                end
            else
                children=ast.getChildren;
                for i=1:numel(children)
                    out=aObj.containIsEmptyPersistent(pers,children{i});
                    if(out)
                        return;
                    end
                end
            end
            out=false;
        end


        function out=isSupportedCondition(~,ast)
            out=isa(ast,'slci.ast.SFAstIsTester')...
            ||isa(ast,'slci.ast.SFAstNot');
        end
    end

end
