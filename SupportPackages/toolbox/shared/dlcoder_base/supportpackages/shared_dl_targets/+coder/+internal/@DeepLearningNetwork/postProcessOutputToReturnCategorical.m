%#codegen















function processedOutput=postProcessOutputToReturnCategorical(obj,scores)

    coder.allowpcode('plain');

    coder.inline('never');
    coder.extrinsic('coder.internal.DeepLearningNetwork.getClassNames');

    numOutputs=coder.const(numel(scores));
    processedOutput=cell(1,numOutputs);

    for outputIdx=1:coder.const(numOutputs)

        layerScores=scores{outputIdx};

        if obj.ClassificationOutputLayersBool(outputIdx)


            [classNames,isOrdinal]=coder.const(@coder.internal.DeepLearningNetwork.getClassNames,...
            obj.DLTNetwork,...
            outputIdx);

            if obj.IsRNN

                processedOutput{outputIdx}=processRNNOutput(obj.HasSequenceOutput,layerScores,classNames,isOrdinal);
            else

                processedOutput{outputIdx}=getLabelsFromScores(layerScores,classNames,isOrdinal);
            end

        else

            processedOutput{outputIdx}=layerScores;

        end

    end

end


function labels=getLabelsFromScores(scores,classNames,isOrdinal)
    coder.inline('always');

    [~,maxidxs]=max(scores,[],2);






    labelsCells={};
    coder.varsize('labelsCells',[1,size(classNames,1)],[0,1]);
    for i=1:size(classNames,1)
        labelsCells{end+1}=nonzeros(classNames(i,:))';
    end


    numObs=numel(maxidxs);
    predictedClassNames=cell(numObs,1);
    for i=1:numObs
        predictedClassNames{i}=labelsCells{maxidxs(i)};
    end


    labels=categorical(predictedClassNames,labelsCells,'Ordinal',isOrdinal);


end


function labels=processRNNOutput(hasSequenceOutput,scores,classes,isOrdinal)

    coder.inline('always');

    if coder.const(hasSequenceOutput)
        isMatrixScores=~iscell(scores);
        if isMatrixScores

            labels=getLabelsFromScores(scores',classes,isOrdinal)';
        else



            numscores=numel(scores);
            labels=coder.nullcopy(cell(numscores,1));
            for sample=1:numscores


                labels{sample}=getLabelsFromScores(scores{sample}',classes,isOrdinal)';
            end
        end
    else



        labels=getLabelsFromScores(scores,classes,isOrdinal);
    end
end
