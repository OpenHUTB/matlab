classdef Individual<handle

    properties
Genes
        GeneNames(1,:)
        GeneLength(1,1){mustBeInteger}
GeneTypes
        Fitness(1,1){mustBeNumeric}
CodegenResults
    end

    methods
        function obj=Individual(varargin)
            if nargin==1
                individual=varargin{1};
                obj.GeneNames=individual.GeneNames;
                obj.GeneLength=individual.GeneLength;
                obj.Fitness=individual.Fitness;
                obj.Genes=individual.Genes;
                obj.GeneTypes=individual.GeneTypes;
            else
                names=varargin{1};
                values=varargin{2};
                types=varargin{3};
                obj.GeneNames=names;
                obj.GeneLength=numel(names);
                obj.Fitness=0;

                for i=1:obj.GeneLength
                    obj.Genes.(names{i})=values{i};
                    obj.GeneTypes.(names{i})=types{i};
                end
            end
        end

        function fitness=calculateFitness(obj,targets)

            fieldNames=fieldnames(targets);
            accumulatedDifference=0;


            for i=1:numel(fieldNames)
                if targets.(fieldNames{i})==0
                    ratioDifference=1;
                else
                    ratioDifference=max(1,(obj.CodegenResults.(fieldNames{i})/targets.(fieldNames{i})));
                end
                accumulatedDifference=accumulatedDifference+ratioDifference;
            end


            fitness=-accumulatedDifference;
            obj.Fitness=fitness;
        end

        function saveCodegenResults(obj,resourceSummary,criticalPathDelay,latency)

            obj.CodegenResults=resourceSummary;
            obj.CodegenResults.CPDelay=criticalPathDelay;
            obj.CodegenResults.latency=latency;
        end
    end
end