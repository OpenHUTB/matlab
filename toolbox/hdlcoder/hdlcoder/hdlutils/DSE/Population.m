classdef Population<handle

    properties
        Individuals(1,:)
        PopulationSize(1,1){mustBeInteger}
        Fitnesses(1,:){mustBeNumeric}
    end

    methods
        function obj=Population(individuals)
            obj.Individuals=individuals;
            obj.PopulationSize=numel(individuals);
            obj.Fitnesses=zeros(1,obj.PopulationSize);
        end

        function calculateFitnesses(obj,targets)

            for i=1:obj.PopulationSize
                obj.Fitnesses(i)=obj.Individuals{i}.calculateFitness(targets);
            end
        end

        function newPopulation=getNextGeneration(obj)

            numElites=ceil(obj.PopulationSize*0.1);
            numParents=ceil(obj.PopulationSize*0.5);
            numChildren=obj.PopulationSize-numElites;
            mutationRate=0.2;

            elites=selectFittests(obj,numElites);
            parents=selectFittests(obj,numParents);
            children=mate(parents,numChildren);
            children=mutation(children,mutationRate);

            newPopulation=Population([elites,children]);
        end

        function fittests=selectFittests(obj,numFittests)

            fitnesses=obj.Fitnesses;
            fittests=cell(1,numFittests);
            for i=1:numFittests
                [~,fittestIdx]=max(fitnesses);
                fittests{i}=obj.Individuals{fittestIdx};
                fitnesses(fittestIdx)=-inf;
            end
        end


    end
end

function children=mate(parents,numChildren)

    numParents=numel(parents);

    children=cell(1,numChildren);
    for i=1:numChildren
        parent1=parents{randi(numParents)};
        parent2=parents{randi(numParents)};
        child=Individual(parent1);

        for j=1:child.GeneLength
            probability=rand;
            if probability<0.5

                child.Genes.(child.GeneNames{j})=parent2.Genes.(child.GeneNames{j});
            end
        end

        children{i}=child;
    end
end

function children=mutation(children,mutationRate)

    numChildren=numel(children);

    for i=1:numChildren
        child=children{i};

        for j=1:child.GeneLength
            probability=rand;
            if probability<mutationRate
                if isequal(child.GeneTypes.(child.GeneNames{j}),'logical')

                    child.Genes.(child.GeneNames{j})=~child.Genes.(child.GeneNames{j});
                elseif isequal(child.GeneTypes.(child.GeneNames{j}),'numeric')

                    if child.Genes.(child.GeneNames{j})==0
                        shift=1;
                    else
                        shift=randi([-1,1]);
                    end
                    child.Genes.(child.GeneNames{j})=child.Genes.(child.GeneNames{j})+shift;
                else

                    possibleValues=child.GeneTypes.(child.GeneNames{j});
                    possibleValues(cellfun(@(x)isequal(x,child.Genes.(child.GeneNames{j})),possibleValues))=[];
                    idx=randi(numel(possibleValues));
                    child.Genes.(child.GeneNames{j})=possibleValues{idx};
                end
            end
        end

        children{i}=child;
    end
end