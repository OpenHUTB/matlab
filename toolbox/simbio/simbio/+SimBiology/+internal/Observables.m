










classdef Observables
    properties
        Names(1,:)string
        Functions(1,:)cell
        EvaluationOrder(1,:)double
        Scalar(1,:)logical
        UnitConversionMultipliers(1,:)double
        StatesToLogUnitConversionMultipliers(1,:)double
    end

    methods
        function obj=Observables(names,functions,evaluationOrder)
            if nargin==0

                return
            end
            obj.Names=names;
            obj.Functions=functions;
            obj.EvaluationOrder=evaluationOrder;
        end

        function[obj,errorInfo]=validateFunctionsAndSetScalar(obj,time,x)
            [observableCell,errorInfo]=evaluateHelper(obj,true,time,x,false);
            obj.Scalar=cell2mat(observableCell(1,:));
        end

        function[observableCell,warnInfo]=evaluate(obj,time,x,issueWarnings)
            if nargin<4
                issueWarnings=true;
            end
            [observableCell,warnInfo]=evaluateHelper(obj,false,time,x,issueWarnings);
        end
    end

    methods(Access=private)
        function[value,info]=handleError(obj,areErrorsFatal,issueWarnings,index,messageID,varargin)
            obsName=obj.Names(index);
            info={index,messageID,getString(message(messageID,obsName,varargin{:})),char(obsName)};
            if areErrorsFatal
                value=[];
                return
            end
            value=nan;
            if issueWarnings
                warning(message(messageID,obsName,varargin{:}));
            end
        end

        function[observableCell,warnErrorInfo]=evaluateHelper(obj,areErrorsFatal,time,x,issueWarnings)









            unitConversion=~isempty(obj.UnitConversionMultipliers);
            if unitConversion



                n=numel(obj.StatesToLogUnitConversionMultipliers);
                x(:,1:n)=x(:,1:n).*obj.StatesToLogUnitConversionMultipliers;
            end

            xCell=mat2cell(x,size(x,1),ones(1,size(x,2)));

            numTimes=numel(time);
            observableCell=cell(2,numel(obj.EvaluationOrder));
            [observableCell{1,:}]=deal(false);
            warnErrorInfo=cell(0,4);
            for i=1:numel(obj.EvaluationOrder)
                idx=obj.EvaluationOrder(i);
                try
                    value=feval(obj.Functions{idx},time,xCell,observableCell(2,:));
                catch exception
                    [value,warnErrorInfo(end+1,:)]=handleError(obj,areErrorsFatal,issueWarnings,idx,'SimBiology:Simulation:ObservableEvaluationError',exception.message);%#ok<AGROW>
                    if areErrorsFatal
                        return
                    end
                end
                try
                    value=double(value);
                catch exception
                    [value,warnErrorInfo(end+1,:)]=handleError(obj,areErrorsFatal,issueWarnings,idx,'SimBiology:Simulation:ObservableTypeError',exception.message);%#ok<AGROW>
                    if areErrorsFatal
                        return
                    end
                end

                if isempty(obj.Scalar)

                    if~isscalar(value)&&(~isvector(value)||length(value)~=numTimes)

                        [value,warnErrorInfo(end+1,:)]=handleError(obj,areErrorsFatal,issueWarnings,idx,'SimBiology:Simulation:ObservableSizeError');%#ok<AGROW>
                        if areErrorsFatal
                            return
                        end
                    else

                        value=value(:);
                    end
                elseif obj.Scalar(idx)
                    if~isscalar(value)

                        value=handleError(obj,areErrorsFatal,issueWarnings,idx,'SimBiology:Simulation:ObservableSizeErrorScalar');
                    end
                else
                    if~isvector(value)||length(value)~=numTimes

                        value=handleError(obj,areErrorsFatal,issueWarnings,idx,'SimBiology:Simulation:ObservableSizeErrorVector');
                    else

                        value=value(:);
                    end
                end
                if isempty(obj.Scalar)
                    observableCell{1,idx}=isscalar(value);
                else
                    observableCell{1,idx}=obj.Scalar(idx);
                end
                observableCell{2,idx}=value;
            end
            if unitConversion
                for idx=1:numel(obj.UnitConversionMultipliers)
                    observableCell{2,idx}=observableCell{2,idx}/obj.UnitConversionMultipliers(idx);
                end
            end
        end
    end

    methods(Static)
        function[validOrder,evalOrder,circularDependencyGroups]=getObservableEvaluationOrder(dependencyIdx)


















            nObs=dependencyIdx(end,1);
            dependencyMatrix=accumarray(dependencyIdx,1,[nObs,nObs],[],[],true);
            [validOrder,evalOrder,circularDependencyGroups]=SimBiology.internal.determineEvalOrderFromDependencies(dependencyMatrix);
        end
    end
end

