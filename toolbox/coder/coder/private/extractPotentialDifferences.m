




function[potentialDifferences]=extractPotentialDifferences(report)

    if~isfield(report.summary,'runtimeMessages')||isempty(report.summary.runtimeMessages)
        potentialDifferences=[];
        return;
    end

    potentialDifferences=repmat(report.summary.runtimeMessages{1},1,numel(report.summary.runtimeMessages));

    persistent potentialDiffMap;
    persistent shouldReportInLibraries;

    if isempty(potentialDiffMap)
        [potentialDiffMap,shouldReportInLibraries]=createPotentialDifferencesMap();
    end

    potentialDiffCount=0;
    fcns=report.inference.Functions;
    scripts=report.inference.Scripts;
    extScripts=report.scripts;

    for i=1:numel(report.summary.runtimeMessages)
        msgID=report.summary.runtimeMessages{i}.MsgID;
        potentialDiff=report.summary.runtimeMessages{i};


        if potentialDiffMap.isKey(msgID)&&...
            (isUserVisibleFunction(potentialDiff.FunctionID,fcns,scripts)||shouldReportInLibraries(msgID))&&...
            hasConsistentScripts(potentialDiff,fcns,scripts,extScripts)
            potentialDiffID=potentialDiffMap(msgID);
            potentialDiff.MsgID=potentialDiffID;
            potentialDiffText=message(potentialDiffID).getString();
            potentialDiff.MsgText=potentialDiffText;
            potentialDiff.MsgTypeName='PotentialDiff';
            potentialDiffCount=potentialDiffCount+1;
            potentialDifferences(potentialDiffCount)=potentialDiff;
        end
    end


    potentialDifferences(potentialDiffCount+1:end)=[];

end

function[bool]=isUserVisibleFunction(fcnID,fcns,scripts)
    scriptID=fcns(fcnID).ScriptID;
    bool=scriptID>0&&scripts(scriptID).IsUserVisible;
end

function has=hasConsistentScripts(potDiff,fcns,scripts,extScripts)



    infScriptId=fcns(potDiff.FunctionID).ScriptID;
    has=infScriptId>0&&strcmp(extScripts{potDiff.ScriptID}.ScriptPath,scripts(infScriptId).ScriptPath);
end

function[map,shouldReportInLibraries]=createPotentialDifferencesMap()
    text=fileread(fullfile(matlabroot,'toolbox','coder','coder','private','differencesFromMATLAB.txt'));
    columns=textscan(text,'%s %s %d','Delimiter',',');
    runtimeErrorIDs=columns{1};
    potentialDifferenceIDs=columns{2};
    map=containers.Map(runtimeErrorIDs,potentialDifferenceIDs);
    shouldReportInLibraries=containers.Map(runtimeErrorIDs,logical(columns{3}));
end
