function text=utilGenerateSdiHTML(newBaseLine,oldBaseLine)

    oldRunID=oldBaseLine.time.runID;
    newRunID=newBaseLine.time.runID;

    text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SeeResultDifference'));

    if isempty(oldRunID)


        oldRunID=1;
    end

    text.setHyperlink(['matlab: utilCallSdi(',num2str(oldRunID),',',num2str(newRunID),');']);


