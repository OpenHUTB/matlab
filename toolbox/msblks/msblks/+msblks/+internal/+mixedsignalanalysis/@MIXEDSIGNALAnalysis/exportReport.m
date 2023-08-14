function hDoc=exportReport(obj,plotDocs,plotFigs)

    title='My MSA Report';
    descriptions{length(plotDocs)}=[];
    for i=1:length(plotDocs)
        descriptions{i}=plotDocs{i}.Title;
    end

    ds=msblks.internal.mixedsignalanalysis.BaseAnalysis.DataStorage();
    ds.dataArea.location=-1;
    msblks.internal.mixedsignalanalysis.BaseAnalysis.reportDlgBox(title,plotFigs,descriptions,ds);

end