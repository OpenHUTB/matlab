classdef OptimizationConstraint<matlab.mixin.CustomDisplay























    properties(Dependent)
IndexNames
    end

    properties(SetAccess=private,GetAccess=public)
        Variables struct=struct
    end

    methods
        show(con)
        write(con,varargin)
        val=infeasibility(con,x)
        con=vertcat(varargin)
        con=horzcat(varargin)
        con=cat(dim,con,varargin)
        con=reshape(con,varargin)
        con=transpose(con)
        con=ctranspose(con)
        varargout=size(varargin)
        len=length(con)
        nel=numel(con)
    end


    properties(Hidden,SetAccess=protected,GetAccess=public)
        Relation char=''
    end

    properties(Access=protected)




        Expr1 optim.problemdef.OptimizationExpression=optim.problemdef.OptimizationExpression([0,0],{{},{}})
        Expr2 optim.problemdef.OptimizationExpression=optim.problemdef.OptimizationExpression([0,0],{{},{}})
        Size double=[0,0]


        IndexNamesStore cell={{},{}}
    end

    properties(Hidden,Dependent=true)


SupportsAD
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        OptimizationConstraintVersion=1;
    end



    methods(Hidden)
        showconstr(con)
        writeconstr(con,varargin)
        [conStr,nzIdx,hasHTML]=expand2str(con,varargin)
        [outStr,extraParamsStr,displayEntrywise,nzIdx]=expandNonlinearStr(expr,showExtraParamsLink);
        [A,b,idxNumericLhs]=extractDisplayCoefficients(con,numVars)
        [A,b]=extractLinearCoefficients(con,numVars)
        [H,A,b]=extractQuadraticCoefficients(con,numVars)
        nlfunStruct=compileNonlinearFunction(constr,varargin)
        [nlfunStruct,jacStruct]=compileForwardAD(constr,varargin)
        [nlfunStruct,jacStruct]=compileReverseAD(constr,varargin)
        sz=numArgumentsFromSubscript(con,s,context)
        varargout=subsref(conIn,S)
        [code,msg]=variableEditorSetDataCode(con,varname,row,column,newValue)
        con=subsasgn(con,S,b)
        con=permute(con,order)
        varargout=evaluate(varargin)

        function ind=end(con,k,n)








            szd=size(con);
            if k<n
                ind=szd(k);
            else
                ind=prod(szd(k:end));
            end
        end

    end


    methods(Hidden,Access=protected)
        displayScalarObject(con)
        displayNonScalarObject(con)
        displayEmptyObject(con)
        footer=getFooter(con)
        groups=getPropertyGroups(con)
    end

    methods(Hidden,Access=private,Static)
        con=concat(dim,varargin)
    end

    methods(Hidden)

        isinit=isInitialized(con);
    end

    methods(Hidden)


        function con=OptimizationConstraint(expr1,relation,expr2,idxNames)

































            if nargin<=2




                if nargin==0
                    sz=[1,1];
                else

                    sz=expr1;
                end
                if nargin==2

                    idxNames=relation;
                else
                    idxNames=repmat({{}},1,numel(sz));
                end





                con.Expr1=optim.problemdef.OptimizationExpression(sz,idxNames);
                con.Expr2=optim.problemdef.OptimizationExpression(sz,idxNames);






                con.Size=sz;
                con.IndexNamesStore=con.Expr1.IndexNames;

            else


                if isa(expr1,'optim.problemdef.OptimizationVariable')
                    expr1=optim.problemdef.OptimizationExpression(expr1);
                end
                if isa(expr2,'optim.problemdef.OptimizationVariable')
                    expr2=optim.problemdef.OptimizationExpression(expr2);
                end


                if isnumeric(expr1)
                    con.Variables=getVariables(expr2);
                elseif isnumeric(expr2)
                    con.Variables=getVariables(expr1);
                else
                    con.Variables=...
                    optim.internal.problemdef.HashMapFunctions.union(...
                    getVariables(expr1),getVariables(expr2),con.className);
                end





                if isscalar(expr1)
                    if~isscalar(expr2)

                        expr1=repmat(expr1,size(expr2));
                    end
                else
                    if isscalar(expr2)

                        expr2=repmat(expr2,size(expr1));
                    end
                end



                sz=size(expr1);
                con.Size=sz;


                con.Expr1=expr1;
                con.Expr2=expr2;


                con.Relation=relation;


                if nargin==3
                    con.IndexNamesStore=repmat({{}},1,numel(sz));
                else

                    con.IndexNamesStore=optim.internal.problemdef.makeValidIndexNames(idxNames,sz);
                end

            end

        end

    end


    methods

        function con=set.IndexNames(con,indexNames)

            con=setIndexNames(con,indexNames);

        end

        function IndexNames=get.IndexNames(con)

            IndexNames=con.IndexNamesStore;

        end

        function val=get.SupportsAD(obj)
            val=getSupportsAD(obj.Expr1)&&getSupportsAD(obj.Expr2);
        end

        function con=set.Size(con,val)

            nout=numel(val);
            for i=nout:-1:2
                if(val(i)~=1)
                    break;
                end
            end

            val(i+1:end)=[];

            con.Size=val;
        end

    end

    methods(Hidden)


        function s=getSize(con)
            s=con.Size;
        end

        function IndexNames=getIndexNames(con)
            IndexNames=con.IndexNamesStore;
        end

        function vars=getVariables(con)
            vars=con.Variables;
        end

        function r=getRelation(con)
            r=con.Relation;
        end


        function e=getExpr1(con)
            e=con.Expr1;
        end

        function e=getExpr2(con)
            e=con.Expr2;
        end

        function con=setIndexNames(con,indexNames)
            con.IndexNamesStore=optim.internal.problemdef.validateIndexNames(indexNames,size(con));
        end

        function islin=isLinear(con)
            islin=(getExprType(con.Expr1)<optim.internal.problemdef.ImplType.Quadratic)&&...
            (getExprType(con.Expr2)<optim.internal.problemdef.ImplType.Quadratic);
        end

        function isquad=isQuadratic(con)
            exprTypes=[getExprType(con.Expr1),getExprType(con.Expr2)];
            isquad=optim.internal.problemdef.ImplType(max(exprTypes))==...
            optim.internal.problemdef.ImplType.Quadratic;
        end

        function isnonlin=isNonlinear(con)
            isnonlin=(getExprType(con.Expr1)>optim.internal.problemdef.ImplType.Quadratic)||...
            (getExprType(con.Expr2)>optim.internal.problemdef.ImplType.Quadratic);
        end

        isconic=isConic(con);

        function type=getType(con)

            expr1Type=getExprType(con.Expr1);
            expr2Type=getExprType(con.Expr2);


            if expr2Type>expr1Type
                type=expr2Type;
            else
                type=expr1Type;
            end

        end

        function val=getSupportsAD(obj)
            val=obj.SupportsAD;
        end

        val=getValue(con,varVal);
    end



    methods(Hidden)

        function con=upcast(con)






        end

        function out=downcast(con)






            rel=getRelation(con);
            switch rel
            case '=='
                out=optim.problemdef.OptimizationEquality(con.Expr1,'==',...
                con.Expr2,con.IndexNames);
            otherwise
                out=optim.problemdef.OptimizationInequality(con.Expr1,rel,...
                con.Expr2,con.IndexNames);
            end
        end

    end


    methods(Hidden,Access=protected)

        function newcon=createConstraint(~,varargin)






            newcon=optim.problemdef.OptimizationConstraint(varargin{:});

        end

        function con=setRelation(con,relation)





            con.Relation=relation;
        end

        function checkConcat(~,relation,con2cat)






            canCon=isempty(con2cat.Relation)||strcmp(con2cat.Relation,relation);
            if~canCon
                throwAsCaller(MException(message(...
                'optim_problemdef:OptimizationConstraint:OnlyOneRelationPerArray')));
            end

        end

    end

    methods(Hidden,Static)


        function cName=className()
            cName="OptimizationConstraint";
        end



        function type=objectType()
            type="constraint";
        end

        cout=empty(varargin)



        function list=getPublicPropertiesAndSupportedHiddenMethods()
            list={'IndexNames','Variables','showconstr','writeconstr'};
        end


        function szVec=sizeVec4Empty(varargin)







            if nargin==0
                szVec=[0,0];
            else
                szVec=zeros(varargin{:});
                if numel(szVec)~=0
                    error(message('MATLAB:class:emptyMustBeZero'));
                end
                szVec=size(szVec);
            end
        end

    end

    methods(Hidden,Access=private)


        writeDisplay2File(con,defaultFilename,varargin)

    end
end
