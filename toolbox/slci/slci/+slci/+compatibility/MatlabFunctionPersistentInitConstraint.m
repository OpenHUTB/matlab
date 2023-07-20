



classdef MatlabFunctionPersistentInitConstraint<slci.compatibility.Constraint

    methods


        function out=getDescription(aObj)%#ok
            out=['Only one initialization statement is allowed to '...
            ,'initialize persistent variable in if condition body.'];
        end


        function obj=MatlabFunctionPersistentInitConstraint()
            obj.setEnum('MatlabFunctionPersistentInit');
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

                pids=aObj.getCondIsEmptyPersistentIds(pers,condAst{1});

                ifBodyAst=ifhead{1}.getBodyAST();
                if~isempty(ifBodyAst)
                    isSupportedIfBody=...
                    aObj.isSupportedBody(ifBodyAst,pers,pids);
                    if~isSupportedIfBody
                        out=slci.compatibility.Incompatibility(...
                        aObj,aObj.getEnum());
                        return;
                    end
                end

                elseIfBody=owner.getElseIfAST();
                if~isempty(elseIfBody)
                    out=slci.compatibility.Incompatibility(...
                    aObj,aObj.getEnum());
                    return;
                end


                elseBody=owner.getElseAST();
                if~isempty(elseBody)
                    elseBodyAst=elseBody{1}.getBodyAST();
                    if~isempty(elseBodyAst)
                        isSupportedElseBody=...
                        aObj.isSupportedBody(elseBodyAst,pers,pids);
                        if~isSupportedElseBody
                            out=slci.compatibility.Incompatibility(...
                            aObj,aObj.getEnum());
                            return
                        end
                    end
                end
            end
        end

    end

    methods(Access=private)

        function out=isPersistentVar(~,pers,ast)
            assert(isa(ast,'slci.ast.SFAstIdentifier'));
            id=ast.getIdentifier;
            match=cellfun(@(x)(isa(x,'slci.ast.SFAstIdentifier')...
            &&strcmpi(x.getIdentifier,id)),pers);
            out=any(match);
        end


        function out=isEmptyPersistent(aObj,pers,ast)
            out=false;
            if isa(ast,'slci.ast.SFAstIsTester')
                funcName=ast.getFuncName();
                if strcmpi(funcName,'isempty')
                    child=ast.getChildren();
                    assert(numel(child)==1);
                    if isa(child{1},'slci.ast.SFAstIdentifier')
                        if aObj.isPersistentVar(pers,child{1})
                            out=true;
                            return;
                        end
                    end
                end
            end
        end


        function out=containIsEmptyPersistent(aObj,pers,ast)
            out=false;
            if aObj.isEmptyPersistent(pers,ast)
                out=true;
                return;
            else
                children=ast.getChildren;
                for i=1:numel(children)
                    out=aObj.containIsEmptyPersistent(pers,children{i});
                    if(out)
                        return;
                    end
                end
            end
        end


        function out=getIdFromIsEmptyPer(~,ast)
            assert(isa(ast,'slci.ast.SFAstIsTester'));
            funcName=ast.getFuncName();
            assert(strcmpi(funcName,'isempty'));
            child=ast.getChildren();
            assert(numel(child)==1);
            assert(isa(child{1},'slci.ast.SFAstIdentifier'));
            out=child{1}.getIdentifier;
        end


        function out=getCondIsEmptyPersistentIds(aObj,pers,ast)
            out={};
            if aObj.isEmptyPersistent(pers,ast)
                out{end+1}=aObj.getIdFromIsEmptyPer(ast);
            else
                children=ast.getChildren;
                for i=1:numel(children)
                    ids=getCondIsEmptyPersistentIds(aObj,pers,children{i});
                    out=[out,ids];%#ok
                end
            end
        end


        function out=isSupportedBody(aObj,ast,pers,pids)
            out=true;

            if numel(ast)>1
                out=false;
                return;
            end

            if(numel(ast)==1)
                if isa(ast{1},'slci.ast.SFAstEqualAssignment')
                    children=ast{1}.getChildren();
                    assert(numel(children)==2);
                    lhs=children{1};
                    if isa(lhs,'slci.ast.SFAstIdentifier')
                        if aObj.isPersistentVar(pers,lhs)

                            id=lhs.getIdentifier;
                            if~ismember(pids,id)
                                out=false;
                                return;
                            end
                        else
                            out=false;
                            return;
                        end
                    end
                end
            end
        end

    end
end