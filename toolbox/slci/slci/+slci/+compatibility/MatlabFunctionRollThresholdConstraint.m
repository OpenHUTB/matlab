




classdef MatlabFunctionRollThresholdConstraint<slci.compatibility.Constraint

    methods


        function out=getDescription(aObj)%#ok
            out=['SLCI does not support partially rolled loop '...
            ,'if the Loop unrolling threshold is set to a value '...
            ,'that triggers partial loop unrolling. '...
            ,'1) matrix multiplication u1[mxn] * u2[n*p] = y[m*p],'...
            ,' Roll threshold should be either less than or equal '...
            ,'to m OR greater than (m*n*p); '...
            ,'2) transpose functions, TRANSPOSE(u[mxn]), ',...
'roll threshold should be either less or equal to '...
            ,'n OR greater than (m*n).'];
        end


        function obj=MatlabFunctionRollThresholdConstraint
            obj.setEnum('MatlabFunctionRollThreshold');
            obj.setFatal(false);
        end


        function out=check(aObj)
            out=[];
            owner=aObj.getOwner();

            assert(isa(owner,'slci.ast.SFAstMul')...
            ||isa(owner,'slci.ast.SFAstDotTranspose'));

            rollThreshold=...
            get_param(aObj.ParentModel.getName(),'RollThreshold');


            isPartiallyUnrolledLoop=...
            aObj.isPartiallyUnrolledAst(owner,rollThreshold);

            if isPartiallyUnrolledLoop
                out=slci.compatibility.Incompatibility(...
                aObj,...
                aObj.getEnum()...
                );
            end
        end

    end

    methods(Access=private)

        function result=isPartiallyUnrolledAst(aObj,ast,rollThreshold)
            result=false;
            if isequal(ast.getDataDim(),-1)

                return;
            end
            children=ast.getChildren();
            for i=1:numel(children)
                if isequal(children{i}.getDataDim(),-1)
                    return;
                end
            end
            if isa(ast,'slci.ast.SFAstMul')
                [min,max]=aObj.checkMatrixMult(ast);
            elseif isa(ast,'slci.ast.SFAstDotTranspose')
                [min,max]=aObj.checkTranspose(ast);
            else
                return;
            end
            result=aObj.isIncompatible(min,max,rollThreshold);
        end


        function out=isIncompatible(~,min,max,rollThreshold)
            out=(~isempty(min)&&~isempty(max)...
            &&((rollThreshold>min)&&(min~=1))...
            &&((rollThreshold<=max)&&(max~=1))...
            &&(rollThreshold~=1));
        end



        function[min,max]=checkMatrixMult(aObj,ast)
            assert(isa(ast,'slci.ast.SFAstMul'));
            children=ast.getChildren();
            assert(numel(children)==2);

            lhs_dim=children{1}.getDataDim();
            rhs_dim=children{2}.getDataDim();

            if((numel(lhs_dim)==2)&&(numel(rhs_dim)==2)...
                &&(lhs_dim(2)==rhs_dim(1)))

                min=aObj.getMin(lhs_dim(2),rhs_dim(2),lhs_dim(1));
                max=lhs_dim(1)*lhs_dim(2)*rhs_dim(2);
            else
                min=[];
                max=[];
            end

        end


        function[min,max]=checkTranspose(aObj,ast)
            assert(isa(ast,'slci.ast.SFAstDotTranspose'));
            children=ast.getChildren();
            assert(numel(children)==1);

            opnd_dim=children{1}.getDataDim();
            assert(numel(opnd_dim)==2);


            min=aObj.getMin(opnd_dim(2),opnd_dim(1),1);

            max=opnd_dim(1)*opnd_dim(2);
        end





        function min=getMin(~,n,p,m)

            min=n;

            if(min==1)
                min=p;

                if(min==1)
                    min=m;
                end
            end
        end

    end

end