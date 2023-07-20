classdef Evaluator

    properties
    end

    methods(Static=true)
        function perf=Evaluate(AlgSettings,x)









            AlgSettings=Evaluator.RunObjectiveFunctions(AlgSettings,x);
            AlgSettings=Evaluator.RunConstraints(AlgSettings,x);



            if isempty(AlgSettings.ListOfConstraints)
                perf=AlgSettings.ListOfObjectiveFunctions{1}.Value;
                return;
            end

            if isempty(AlgSettings.ListOfObjectiveFunctions)
                perf=zeros(1,length(AlgSettings.ListOfConstraints)+1);
                perf(1)=max(AlgSettings.ListOfConstraints{1}.Value,0)*...
                AlgSettings.ListOfConstraints{1}.Penalty;
                perf(2)=AlgSettings.ListOfConstraints{1}.Value;
                for i=2:length(AlgSettings.ListOfConstraints)
                    perf(1)=perf(1)+...
                    (max(AlgSettings.ListOfConstraints{i}.Value,0)*...
                    AlgSettings.ListOfConstraints{i}.Penalty);
                    perf(i+1)=AlgSettings.ListOfConstraints{i}.Value;
                end
                return;
            end

            perf=zeros(1,length(AlgSettings.ListOfConstraints)+2);
            perf(1)=AlgSettings.ListOfObjectiveFunctions{1}.Value;
            perf(2)=AlgSettings.ListOfObjectiveFunctions{1}.Value;
            for i=1:length(AlgSettings.ListOfConstraints)
                perf(1)=perf(1)+...
                (max(AlgSettings.ListOfConstraints{i}.Value,0)*...
                AlgSettings.ListOfConstraints{i}.Penalty);
                perf(i+2)=AlgSettings.ListOfConstraints{i}.Value;
            end
        end
    end

    methods(Static,Access=private)
        function ThrowForBadResult(result)
            if isempty(result)
                error(message("antenna:antennaerrors:NoOptimResult"));
            end
            if any(isnan(result))
                error(message("antenna:antennaerrors:InvalidOptimResult"));
            end
        end

        function y=ReadAndRunPerfFunction(func,x)
            if ischar(func.Name)
                funcHandle=str2func(func.Name);
            else
                funcHandle=func.Name;
            end
            y=funcHandle(x);
        end

        function AlgSettings=RunConstraints(AlgSettings,x)
            for i=1:length(AlgSettings.ListOfConstraints)
                AlgSettings.ListOfConstraints{i}.Value=...
                Evaluator.ReadAndRunPerfFunction(...
                AlgSettings.ListOfConstraints{i},...
                x);
                Evaluator.ThrowForBadResult...
                (AlgSettings.ListOfConstraints{i}.Value);
            end
        end

        function AlgSettings=RunObjectiveFunctions(AlgSettings,x)
            for i=1:length(AlgSettings.ListOfObjectiveFunctions)
                AlgSettings.ListOfObjectiveFunctions{i}.Value=...
                Evaluator.ReadAndRunPerfFunction(...
                AlgSettings.ListOfObjectiveFunctions{i},...
                x);
                Evaluator.ThrowForBadResult...
                (AlgSettings.ListOfObjectiveFunctions{i}.Value);
            end
        end
    end

end