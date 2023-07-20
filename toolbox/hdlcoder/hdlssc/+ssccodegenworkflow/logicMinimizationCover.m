classdef logicMinimizationCover<handle





    properties
        terms={}
    end

    methods
        function obj=logicMinimizationCover(labels)

            if nargin<1
                labels={};
            end

            if iscell(labels)
                obj.terms=labels;
            else
                obj.terms=arrayfun(@(label){label},labels);
            end
        end

        function newCoverTerm=multiply(obj,cTermIn)

            terms1=obj.terms;
            terms2=cTermIn.terms;

            numLabels1=numel(terms1);
            numLabels2=numel(terms2);


            newLabels=cell(1,numLabels1*numLabels2);
            for i=1:numLabels1
                for j=1:numLabels2
                    newLabels{i+(j-1)*numLabels1}=unique([terms1{i},terms2{j}]);
                end
            end


            for i=1:numel(newLabels)
                for j=i+1:numel(newLabels)
                    if~isempty(newLabels{i})&&~isempty(newLabels{j})
                        X=intersect(newLabels{i},newLabels{j});

                        if all(ismember(newLabels{i},X))

                            newLabels{j}={};
                        elseif all(ismember(newLabels{j},X))

                            newLabels{i}={};
                        end
                    end
                end
            end
            emptyIndices=cellfun(@(term)isempty(term),newLabels);

            newLabels=newLabels(~emptyIndices);

            newCoverTerm=logicMinimizationCover(newLabels);


        end

        function smallTerm=minCover(obj)

            [~,i]=min(cellfun(@(term)numel(term),obj.terms));
            smallTerm=obj.terms{i(1)};
        end
    end
end

