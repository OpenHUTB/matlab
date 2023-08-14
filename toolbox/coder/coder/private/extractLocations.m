



function[locations]=extractLocations(locationInfos,msgID,report)

    fcns=report.inference.Functions;
    scripts=report.inference.Scripts;
    altScripts=report.scripts;

    scriptPaths={scripts.ScriptPath};
    altScriptPaths=cellfun(@(x)x.ScriptPath,altScripts,'UniformOutput',false);

    locations=createLocation({},{},{},{},{});

    for i=1:length(locationInfos)
        [scriptPath,scriptName,textStart,textEnd,fcnID]=coder.report.RegisterCGIRInspectorResults.parseRecordSID(locationInfos{i});


        scriptFilePath=[fullfile(scriptPath,scriptName),'.m'];

        scriptID=find(strcmp(scriptPaths,scriptFilePath));

        if isempty(scriptID)
            continue;
        end

        altScript=altScripts{strcmp(altScriptPaths,scriptFilePath)};

        textLength=textEnd-textStart;
        [textStart,textLength]=uniposition(altScript.unicodemap,textStart,textLength);





        if fcnID~=-1&&fcnID<=numel(fcns)

            locations(end+1)=createLocation(msgID,fcnID,scriptID,textStart,textLength);%#ok<AGROW>
        else

            fcnIDs=findFunctions(scriptID,textStart,fcns);
            for j=1:length(fcnIDs)
                locations(end+1)=createLocation(msgID,fcnIDs(j),scriptID,textStart,textLength);%#ok<AGROW>
            end
        end
    end
end

function[selectedFcnIDs]=findFunctions(scriptID,textStart,fcns)
    fcnIDs=find([fcns.ScriptID]==scriptID);
    selectedFcnIDs=[];

    for i=1:length(fcnIDs)
        fcn=fcns(fcnIDs(i));
        if fcn.TextStart<textStart&&textStart<(fcn.TextStart+fcn.TextLength)
            selectedFcnIDs(end+1)=fcnIDs(i);%#ok<AGROW>
        end
    end
end

function[location]=createLocation(msgID,fcnID,scriptID,textStart,textLength)
    location=struct(...
    'MsgID',msgID,...
    'FunctionID',fcnID,...
    'ScriptID',scriptID,...
    'TextStart',textStart,...
    'TextLength',textLength);
end
