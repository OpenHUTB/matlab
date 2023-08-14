classdef ParamTransformer













    properties(Dependent)
Transforms
Domains

Ranges

    end

    properties(SetAccess=private)
TransformFcn
UntransformFcn
UntransformDerivFcn
    end

    properties(Access=private)
InternalTransforms
    end

    methods(Static)
        function transforms=convertIntToTransformNames(intCodes)
            transforms=cell(size(intCodes));
            for i=1:numel(intCodes)
                switch intCodes(i)
                case 0
                    transforms{i}='';
                case 1
                    transforms{i}='log';
                case 2
                    transforms{i}='probit';
                case 3
                    transforms{i}='logit';
                otherwise
                    assert(false);
                end
            end
        end

        function intCodes=convertTransformNamesToInt(transforms)
            if ischar(transforms)
                transforms={transforms};
            end
            intCodes=zeros(size(transforms));
            for i=1:numel(transforms)
                switch transforms{i}
                case ''
                    intCodes(i)=0;
                case 'log'
                    intCodes(i)=1;
                case 'probit'
                    intCodes(i)=2;
                case 'logit'
                    intCodes(i)=3;
                otherwise
                    assert(false);
                end
            end
        end
    end

    methods
        function values=transform(obj,values)
            values=obj.TransformFcn(values);
        end
        function values=untransform(obj,values)
            values=obj.UntransformFcn(values);
        end
        function values=untransformDeriv(obj,values)
            values=obj.UntransformDerivFcn(values);
        end

        function obj=ParamTransformer(paramsByNameOrInt)




            if isnumeric(paramsByNameOrInt)
                obj.Transforms=SimBiology.internal.ParamTransformer.convertIntToTransformNames(paramsByNameOrInt);
            else
                obj.Transforms=paramsByNameOrInt;
            end
        end
        function value=get.Transforms(obj)
            value=obj.InternalTransforms;
        end
        function domains=get.Domains(obj)

            domains=nan(length(obj.InternalTransforms),2);
            for i=1:length(obj.InternalTransforms)
                switch obj.InternalTransforms{i}
                case ''
                    domains(i,:)=[-inf,inf];
                case 'log'
                    domains(i,:)=[0,inf];
                case 'logit'
                    domains(i,:)=[0,1];
                case 'probit'
                    domains(i,:)=[0,1];
                otherwise
                    assert(false);
                end
            end
        end
        function ranges=get.Ranges(obj)


            ranges=inf(length(obj.InternalTransforms),2).*[-1,1];
        end
        function obj=set.Transforms(obj,transformNames)
            if ischar(transformNames)
                transformNames={transformNames};
            end
            obj.InternalTransforms=transformNames(:);
            firstTransform=transformNames{1};
            if isscalar(transformNames)||all(strcmp(firstTransform,transformNames))
                [obj.TransformFcn,obj.UntransformFcn,obj.UntransformDerivFcn]=getSingleTypeTransforms(firstTransform);
            else
                [obj.TransformFcn,obj.UntransformFcn,obj.UntransformDerivFcn]=getMultiTypeTransforms(transformNames);
            end
        end
    end
end

function x=noTransform(x)
end
function x=allOnes(x)
    x=ones(size(x));
end
function x=logit(x)
    x=log(x./(1-x));
end
function x=logitInv(x)
    x=1./(1+exp(-x));
end
function x=logitInvDeriv(x)
    x=1./(2+exp(-x)+exp(x));
end

function[transformFcn,untransformFcn,untransformDerivFcn]=getSingleTypeTransforms(transformName)
    switch transformName
    case ''
        [transformFcn,untransformFcn,untransformDerivFcn]=deal(@noTransform,@noTransform,@allOnes);
    case 'log'
        [transformFcn,untransformFcn,untransformDerivFcn]=deal(@log,@exp,@exp);
    case 'probit'
        [transformFcn,untransformFcn,untransformDerivFcn]=deal(@norminv,@normcdf,@normpdf);
    case 'logit'
        [transformFcn,untransformFcn,untransformDerivFcn]=deal(@logit,@logitInv,@logitInvDeriv);
    otherwise
        assert(false);
    end
end

function[transformFcn,untransformFcn,untransformDerivFcn]=getMultiTypeTransforms(transformNames)
    tfNone=strcmp('',transformNames);
    tfLog=strcmp('log',transformNames);
    tfProbit=strcmp('probit',transformNames);
    tfLogit=strcmp('logit',transformNames);
    transformFcn=@transform;
    untransformFcn=@untransform;
    untransformDerivFcn=@untransformDeriv;
    function x=transform(x)
        if any(tfLog)
            x(:,tfLog)=log(x(:,tfLog));
        end
        if any(tfProbit)
            x(:,tfProbit)=norminv(x(:,tfProbit));
        end
        if any(tfLogit)
            x(:,tfLogit)=logit(x(:,tfLogit));
        end
    end
    function x=untransform(x)
        if any(tfLog)
            x(:,tfLog)=exp(x(:,tfLog));
        end
        if any(tfProbit)
            x(:,tfProbit)=normcdf(x(:,tfProbit,:));
        end
        if any(tfLogit)
            x(:,tfLogit)=logitInv(x(:,tfLogit));
        end
    end
    function x=untransformDeriv(x)
        if any(tfNone)
            x(:,tfNone)=allOnes(x(:,tfNone));
        end
        if any(tfLog)
            x(:,tfLog)=exp(x(:,tfLog));
        end
        if any(tfProbit)
            x(:,tfProbit)=normpdf(x(:,tfProbit));
        end
        if any(tfLogit)
            x(:,tfLogit)=logitInvDeriv(x(:,tfLogit));
        end
    end
end
