function sigStruct=getSFSignals()




    gssf=sf('GetCurrentObject');
    rt=sfroot;
    sfObjs=rt.idToHandle(gssf);
    sigStruct=utils.initializeSigStruct();
    if isempty(sfObjs)
        return
    end
    for sfObjsInd=1:length(sfObjs)
        sfObj=sfObjs(sfObjsInd);
        chartID=sfObj.Id;
        if~isa(sfObj,'Stateflow.Chart')
            chartID=sfObj.chart.Id;
        end
        blkH=sf('Private','chart2block',chartID);
        spn=get_param(blkH,'AvailSigsInstanceProps');
        sfSignals=i_getSignalsForSelectedSFObj(sfObj,spn);
        for sfSignalsInd=1:length(sfSignals)
            sfSignal=sfSignals{sfSignalsInd};


            [bStatus,ctrls,UUIDs]=utils.getBoundControlsAndStatus('','','','');


            signames=sigStruct.srcBlockorSFSigNames;
            if any(strcmp(signames,sfSignal.SigName))
                continue
            end
            sigType='SFSTATE';
            if i_isaSFData(chartID,sfSignal.SigName)
                sigType='SFDATA';
            end



            sigStruct.srcBlockorSFSigNames{end+1}=sfSignal.SigName;
            sigStruct.srcBlockHs{end+1}=blkH;
            sigStruct.srcPortNums{end+1}=1;
            sigStruct.signalLabels{end+1}=i_getSFLabel(sfSignal.SigName);
            sigStruct.sigCtrlBndSrcs{end+1}=ctrls;
            sigStruct.sigCtrlBndUUIDs{end+1}=UUIDs;
            sigStruct.sigBndStatus{end+1}=bStatus;
            sigStruct.sigTypes{end+1}=sigType;
        end
    end
end



function sfSignals=i_getSignalsForSelectedSFObj(sfObj,spn)



    sfSignals={};
    searchLevel=1;
    if isa(sfObj,'Stateflow.Chart')
        searchPath={};
    elseif isa(sfObj,'Stateflow.AtomicSubchart')
        searchPath=textscan(sfObj.LoggingInfo.LoggingName,'%s',...
        'Delimiter','.');
        searchPath=searchPath{1};
        searchLevel=0;
    elseif isa(sfObj,'Stateflow.State')
        searchPath=textscan(sfObj.LoggingInfo.LoggingName,'%s',...
        'Delimiter','.');
        searchPath=searchPath{1};
        if(sfObj.IsSubchart)
            searchLevel=0;
        end
    else
        return;
    end


    while~isempty(spn)


        curChild=spn;
        while~isempty(curChild)


            for idx=1:length(curChild.Signals)


                curPath=textscan(curChild.Signals(idx).SigName,...
                '%s','Delimiter','.');
                curPath=curPath{1};


                if(length(curPath)<length(searchPath)||...
                    length(curPath)>length(searchPath)+searchLevel)
                    continue;
                end


                bInPath=isequal(curPath,searchPath)||...
                isequal(curPath(1:end-searchLevel),searchPath);

                if~isempty(searchPath)&&~bInPath
                    continue;
                end


                sfSignals{end+1}=curChild.Signals(idx);%#ok
            end


            curChild=curChild.right;
        end


        spn=spn.down;
    end
end


function sfLabel=i_getSFLabel(sigName)
    sfLabel=textscan(sigName,'%s','Delimiter','.');
    sfLabel=sfLabel{1}{end};
end


function bisaSFData=i_isaSFData(chartID,sigName)
    bisaSFData=false;
    rt=sfroot;
    chart=rt.idToHandle(chartID);
    sfObjs=chart.find('-isa','Stateflow.Data');
    for i=1:length(sfObjs)
        if strcmp(sfObjs(i).LoggingInfo.LoggingName,sigName)
            bisaSFData=true;
            break;
        end
    end
end

