
function covTotal=genResultsForSigbuilder(modelH,sigbuilderH,covdata)


    try

        coveng=cvi.TopModelCov.getInstance(modelH);
        coveng.isMenuSimulation=true;

        [~,~,~,tags.labels]=signalbuilder(sigbuilderH);
        tags.totalLabel=get_param(sigbuilderH,'Name');
        covTotal=cvi.TopModelCov.genResultsForMultiSim(modelH,covdata,tags);

    catch MEx
        rethrow(MEx);
    end

