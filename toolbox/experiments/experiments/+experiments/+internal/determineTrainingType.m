function trainingType=determineTrainingType(mockTraining,varargin)




    trainingType='classification';
    if~isempty(mockTraining)
        return;
    end
    try

        factory=nnet.internal.cnn.trainNetwork.DLTComponentFactory();
        inputParser=factory.createInputParser();
        [layersOrGraph,~,~,~]=inputParser.parseInputArguments(varargin{:});


        isaDAG=isa(layersOrGraph,'nnet.cnn.LayerGraph');
        [internalLayers,~]=nnet.internal.cnn.layer.util.inferParameters(layersOrGraph,"internal");
        networkInfo=nnet.internal.cnn.util.ComputeNetworkInfo(isaDAG,internalLayers);
        if~networkInfo.DoesClassification
            trainingType='regression';
        end
    catch ME
        mex=experiments.internal.ExperimentException(...
        message('experiments:manager:ErrorDeterminingTrainingProblemType'));
        ME=nnet.internal.cnn.util.CNNException.hBuildCustomError(ME);
        mex=mex.addCause(experiments.internal.ExperimentException(ME));
        mex.throw();
    end
end
