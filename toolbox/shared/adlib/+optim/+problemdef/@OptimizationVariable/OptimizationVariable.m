classdef(Sealed)OptimizationVariable<optim.problemdef.OptimizationExpression&handle

























    properties(Dependent,SetAccess=private)
        Name char
    end

    properties(Dependent)
        Type char{mustBeMember(Type,{'continuous','integer'})}
    end




    properties(Dependent)
        LowerBound{mustBeNumeric,mustBeReal};
        UpperBound{mustBeNumeric,mustBeReal};
    end

    methods

        showbounds(obj);
        writebounds(obj,varargin);


        show(obj);
        write(obj,filename);


        varargout=findindex(obj,varargin)
    end



    properties(GetAccess=private,SetAccess=private)
        IsSubsref=false
    end

    properties(Hidden,Dependent=true)



        Offset;







        TotalVar;

    end
    properties(SetAccess=private,GetAccess=private)

VariableImpl
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        OptimizationVariableVersion=1;
    end


    methods(Hidden)
        showvar(obj);
        writevar(obj,filename);
        obj=setIndexNames(obj,val)
        varStr=getDisplayStr(obj)
        boundStr=getBoundStr(obj,printUnboundedMsg,paddingAmount)
        varargout=subsref(y,S)
        y=subsasgn(y,S,b)
    end


    methods(Hidden,Access=protected)
        displayScalarObject(obj)
        displayNonScalarObject(obj)
        groups=getPropertyGroups(obj)
        footer=getFooter(obj)
    end
    methods(Hidden,Access=protected)
        obj=reloadv1tov2(obj,vin);
    end


    methods(Hidden,Access=private)
        obj=createNew(obj,name,dims,idxnames)
        obj=createSubset(obj,oldobj,sub)



        function idxSubscript=getSubscriptValues(obj)
            idxSubscript=getVarIdx(obj.OptimExprImpl);
        end
    end


    methods(Hidden,Static)
        varInfo=getVariableInfo(varStruct);
        TotalVar=setVariableOffset(varStruct);
        vout=loadobj(vin);



        function list=getPublicPropertiesAndSupportedHiddenMethods()
            list=[optim.problemdef.OptimizationVariable.getPublicProperties,...
            {'showvar','writevar'}];
        end



        function list=getPublicProperties()
            list={'Name','Type','IndexNames','LowerBound',...
            'UpperBound'};
        end

    end


    methods(Hidden)

        function obj=OptimizationVariable(name,dims,idxnames)







            obj=obj@optim.problemdef.OptimizationExpression([]);

            if nargin>0
                obj=createNew(obj,name,dims,idxnames);
            end

        end

    end


    methods




        function p=properties(obj)
            props=obj.getPublicProperties;
            if nargout==1
                p=props;
            else
                m=string(getString(message("MATLAB:ClassUstring:PROPERTIES_FUNCTION_LABEL",class(obj))));
                optim.internal.problemdef.display.blankLine;
                disp(m);
                optim.internal.problemdef.display.blankLine;
                disp(strjoin(blanks(4)+string(props),newline))
                optim.internal.problemdef.display.blankLine;
            end
        end

        function out=get.Name(obj)
            out=char(obj.VariableImpl.Name);
        end

        function set.Name(obj,~)%#ok




            error(message('shared_adlib:OptimizationVariable:NameIsReadOnly'));

        end

        function out=get.Type(obj)
            out=obj.VariableImpl.VariableType;
        end

        function set.Type(obj,thisType)

            if obj.IsSubsref



                error(message('shared_adlib:OptimizationVariable:CannotOverwritePartsOfTypeArray'));
            else
                obj.VariableImpl.VariableType=thisType;
            end

        end

        function val=get.LowerBound(obj)


            varIdx=getVarIdx(obj.OptimExprImpl);


            varLowerBound=obj.VariableImpl.LowerBound;


            val=varLowerBound(varIdx);
            val=reshape(val,obj.Size);

        end

        function set.LowerBound(obj,val)

            if any((isinf(val(:))&val(:)>0)|isnan(val(:)))
                error(message('shared_adlib:OptimizationVariable:CannotSetLowerBoundInf'));
            elseif isempty(val)
                val=-Inf;
            else







                if~isscalar(val)&&numel(obj)~=numel(val)
                    throw(MException(message('shared_adlib:OptimizationVariable:DimensionMismatchBound',...
                    'LowerBound')));
                end
            end


            varIdx=getVarIdx(obj.OptimExprImpl);


            obj.VariableImpl.LowerBound(varIdx)=val(:);

        end

        function val=get.UpperBound(obj)


            varIdx=getVarIdx(obj.OptimExprImpl);


            varUpperBound=obj.VariableImpl.UpperBound;


            val=varUpperBound(varIdx);
            val=reshape(val,obj.Size);

        end

        function set.UpperBound(obj,val)

            if any((isinf(val(:))&val(:)<0)|isnan(val(:)))
                error(message('shared_adlib:OptimizationVariable:CannotSetUpperBoundNegInf'));
            elseif isempty(val)
                val=Inf;
            else







                if~isscalar(val)&&numel(obj)~=numel(val)
                    throw(MException(message('shared_adlib:OptimizationVariable:DimensionMismatchBound',...
                    'UpperBound')));
                end
            end


            varIdx=getVarIdx(obj.OptimExprImpl);


            obj.VariableImpl.UpperBound(varIdx)=val(:);

        end

        function set.Offset(obj,val)

            obj.VariableImpl.Offset=val;

        end

        function val=get.Offset(obj)

            val=obj.VariableImpl.Offset;

        end
    end



    methods


        function constr=lt(a,b)





            constr=lt@optim.problemdef.OptimizationExpression(a,b);
        end


        function constr=gt(a,b)





            constr=gt@optim.problemdef.OptimizationExpression(a,b);
        end


        function constr=le(a,b)










            constr=le@optim.problemdef.OptimizationExpression(a,b);
        end


        function constr=ge(a,b)










            constr=ge@optim.problemdef.OptimizationExpression(a,b);
        end


        function constr=eq(a,b)










            constr=eq@optim.problemdef.OptimizationExpression(a,b);
        end

    end


    methods(Hidden)


        function o=getOffset(obj)
            o=obj.Offset;
        end

        function setOffset(obj,offset)
            obj.Offset=offset;
        end

        function var=getVariableImpl(obj)
            var=obj.VariableImpl;
        end



        function initializeJacobianMemory(obj,JacVarName)


            initializeJacobianMemory(obj.VariableImpl,JacVarName,0);
        end









        function[jach,jacNumParens]=getJacobianMemory(var)
            [jach,jacNumParens]=getJacobianMemory(var.VariableImpl);
        end







    end

    methods(Hidden,Static)
        function empty(varargin)
            error(message('shared_adlib:OptimizationVariable:CannotCreateEmptyOptimVar'));
        end
    end

end
