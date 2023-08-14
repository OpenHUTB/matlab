

classdef IfBlock<slci.simulink.Block

    properties
        fCondAsts={};
        fVarList={};
    end

    methods




        function obj=IfBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);
            obj.initializeVarList();
            obj.populateIfAst();
            obj.populateElseIfAsts();
            obj.addConstraint(...
            slci.compatibility.ConstantPortConstraint('Inport',1));
        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

        function condAsts=getCondAsts(aObj)
            condAsts=aObj.fCondAsts;
        end

        function[val,resolved]=readIdentifier(aObj,id)


            if aObj.isInportVariable(id)
                val=[];
                resolved=false;
                return;
            end

            try
                val=slResolve(id,aObj.getSID());
            catch %#ok<CTCH>
                val=[];
                resolved=false;
                return;
            end


            if~isa(val,'numeric')||(numel(val)>1)
                resolved=false;
                return;
            end

            resolved=true;
        end

        function[val,resolved]=readSubscriptStr(aObj,arrayId,subscriptStr)


            if aObj.isInportVariable(arrayId)
                val=[];
                resolved=false;
                return;
            end


            try
                val=slResolve(subscriptStr,aObj.getSID());
            catch %#ok<CTCH>
                val=[];
                resolved=false;
                return;
            end


            if~isa(val,'numeric')||(numel(val)>1)
                resolved=false;
                return;
            end
            resolved=true;
        end

    end

    methods(Access=private)

        function initializeVarList(aObj)



            ports=get_param(aObj.getSID,'PortHandles');
            numInports=numel(ports.Inport);
            aObj.fVarList=cell(numInports,1);
            for k=1:numInports
                inportId=['u',num2str(k)];
                aObj.fVarList{k}=inportId;
            end
        end

        function isInport=isInportVariable(aObj,id)
            isInport=any(strcmp(aObj.fVarList,id));
        end

        function populateIfAst(aObj)
            ifExpr=get_param(aObj.getSID(),'IfExpression');
            ast=aObj.getAst(ifExpr);
            aObj.fCondAsts{1}=ast;
        end

        function populateElseIfAsts(aObj)
            elseIfExprs=get_param(aObj.getSID(),'ElseIfExpressions');
            if~isempty(elseIfExprs)
                elseIfs=regexp(elseIfExprs,',','split');
                for k=1:numel(elseIfs)
                    elseIfExpr=elseIfs{k};
                    aObj.fCondAsts{k+1}=aObj.getAst(elseIfExpr);
                end
            end
        end

        function ast=getAst(aObj,mexpr)
            ast=slci.matlab.astTranslator.translateMATLABExpr(mexpr,aObj);
        end

    end

end
