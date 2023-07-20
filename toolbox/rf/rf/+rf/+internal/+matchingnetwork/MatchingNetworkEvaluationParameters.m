classdef MatchingNetworkEvaluationParameters




    properties(Access=public)
ParamList
ComparisonList
TargetList
FrequencyList
WeightList
SourceList
    end

    methods(Access=public)


        function[result,pass,testsFailed]=evaluatePerformance(obj,gammaindB,GtdB,frequencies)
            pass=1;
            result=0;
            testsFailed=[];


            for k=1:length(obj.ParamList)
                index1=find(frequencies>=obj.FrequencyList{k}(1),1);
                index2=find(frequencies>=obj.FrequencyList{k}(end),1);
                if isempty(index2)
                    index2=numel(frequencies);
                end


                if(strcmp(obj.ParamList{k},'gammain'))
                    performance=gammaindB(index1:index2);
                else
                    performance=GtdB(index1:index2);
                end

                if(strcmp(obj.ComparisonList{k},'>'))
                    normalizedPerformance=obj.WeightList{k}*min(performance-obj.TargetList{k});
                else
                    normalizedPerformance=obj.WeightList{k}*min(obj.TargetList{k}-performance);
                end

                if(normalizedPerformance<0)
                    pass=0;
                    testsFailed=[testsFailed,k];%#ok<AGROW> %Can't tell in advance how many tests will fail
                end
                result=result+normalizedPerformance;


            end
        end


        function t=getEvaluationParameters(obj)
            t=table(obj.ParamList',obj.ComparisonList',obj.TargetList',obj.FrequencyList',obj.WeightList',obj.SourceList');
            t.Properties.VariableNames={'Parameter','Comparison','Goal','Band','Weight','Source'};
        end

        function obj=addEvaluationParameter(obj,requirements,desiredIndex)

            if(nargin<3)
                desiredIndex=length(obj.ParamList)+1;
            end



            if(desiredIndex>length(obj.ParamList)+1)
                desiredIndex=length(obj.ParamList)+1;
            end


            if(desiredIndex<=length(obj.ParamList))
                obj.ParamList(desiredIndex+1:end+1)=obj.ParamList(desiredIndex:end);
                obj.ComparisonList(desiredIndex+1:end+1)=obj.ComparisonList(desiredIndex:end);
                obj.TargetList(desiredIndex+1:end+1)=obj.TargetList(desiredIndex:end);
                obj.FrequencyList(desiredIndex+1:end+1)=obj.FrequencyList(desiredIndex:end);
                obj.WeightList(desiredIndex+1:end+1)=obj.WeightList(desiredIndex:end);
                obj.SourceList(desiredIndex+1:end+1)=obj.SourceList(desiredIndex:end);
            end


            p=desiredIndex;
            obj.ParamList{p}=requirements{1};
            obj.ComparisonList{p}=requirements{2};
            obj.TargetList{p}=requirements{3};
            obj.FrequencyList{p}=requirements{4};
            obj.WeightList{p}=requirements{5};
            obj.SourceList{p}=requirements{6};
        end

        function obj=clearEvaluationParameter(obj,indices)
            validateattributes(indices,{'numeric'},{'vector','real','finite','nonnan','positive','<=',length(obj.ParamList)});
            obj.ParamList(indices)=[];
            obj.ComparisonList(indices)=[];
            obj.TargetList(indices)=[];
            obj.FrequencyList(indices)=[];
            obj.WeightList(indices)=[];
            obj.SourceList(indices)=[];
        end


        function keyFrequencies=getEvaluationBand(obj)
            freqs=[];

            for k=1:length(obj.FrequencyList)
                freqs=union(freqs,obj.FrequencyList{k});
            end
            keyFrequencies=freqs;
        end
    end
end
