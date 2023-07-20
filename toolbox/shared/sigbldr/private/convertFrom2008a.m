function sbobj=convertFrom2008a(tempUD)



    sbobj=tempUD.sbobj;
    grpCnt=sbobj.NumGroups;
    sigCnt=sbobj.Groups{1}.NumSignals;
    time=cell(sigCnt,grpCnt);
    data=cell(sigCnt,grpCnt);
    for m=1:grpCnt
        for n=1:sigCnt
            time{n,m}=sbobj.Groups{m}.Signals{n}.XData;
            data{n,m}=sbobj.Groups{m}.Signals{n}.YData;
        end
    end
    grpNames={tempUD.dataSet.name};
    sigNames={tempUD.channels.label};
    tempobj=SigSuite(time,data,sigNames,grpNames);

    sbobj=tempobj;


    if isfield(tempUD,'dataSetIdx')
        sbobj.ActiveGroup=tempUD.dataSetIdx;
    elseif isfield(tempUD,'current')
        sbobj.ActiveGroup=tempUD.current.dataSetIdx;
    end

end
