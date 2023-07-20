function[sigIDs,runIDs]=addToRunFromNamesAndValues(runID,varNames,varValues,varargin)









    repo=sdi.Repository(1);
    wksParser=Simulink.sdi.internal.import.WorkspaceParser.getDefault();
    priorSigIDs=repo.getAllSignalIDs(runID,'leaf');



    wksParser.resetParser();


    overwrittenRunID=0;
    mdlName='';
    numArgs=length(varargin);
    if numArgs>1
        mdlName=varargin{1};
        try
            wksParser.GlobalTimeVectorName=varargin{2};
            wksParser.GlobalTimeVectorValue=evalin('base',varargin{2});
        catch me %#ok<NASGU>
            wksParser.GlobalTimeVectorName='';
            wksParser.GlobalTimeVectorValue=[];
        end
        fileNames=varargin{3};
        scopeData=varargin{4};
        if numArgs>4
            overwrittenRunID=varargin{5};
        end
    else
        if numArgs&&ischar(varargin{1})
            mdlName=varargin{1};
        elseif numArgs
            overwrittenRunID=varargin{1};
        end
        wksParser.GlobalTimeVectorName='';
        wksParser.GlobalTimeVectorValue=[];
        fileNames={};
        scopeData={};
    end


    idxWithMetaData=[];
    numVars=length(varNames);
    numScopes=length(scopeData);
    vars=repmat(struct(...
    'VarName','',...
    'VarValue',[],...
    'VarBlockPath','',...
    'VarSignalName','',...
    'TimeSourceRule','block based'),...
    [1,numVars+numScopes]);
    for idx=1:numVars
        if isstruct(varNames{idx})&&isfield(varNames{idx},'MetaData')
            idxWithMetaData(end+1)=idx;%#ok<AGROW>
        elseif isstruct(varNames{idx})
            vars(idx).VarName=varNames{idx}.VarName;
            vars(idx).VarSignalName='';
            vars(idx).VarBlockPath=varNames{idx}.BlockPath;
        else
            vars(idx).VarName=varNames{idx};
        end
        vars(idx).VarValue=varValues{idx};
    end


    for idx=1:numScopes
        vars(numVars+idx).VarName=scopeData{idx}.VarName;
        vars(numVars+idx).VarSignalName='';
        vars(numVars+idx).VarBlockPath=scopeData{idx}.BlockPath;
        vars(numVars+idx).TimeSourceRule='scope';
        try
            vars(numVars+idx).VarValue=evalin('base',scopeData{idx}.VarName);
        catch me %#ok<NASGU>
            vars(numVars+idx).VarValue=[];
        end
    end


    vars=locAddOutputAndStates(varNames,vars,idxWithMetaData);


    varParser=parseVariables(wksParser,vars);
    runIDs=addToRun(wksParser,repo,runID,varParser,mdlName,overwrittenRunID);


    for idx=1:length(fileNames)
        varParser=parseMATFile(wksParser,fileNames{idx}.VarName,fileNames{idx}.BlockPath);
        addToRun(wksParser,repo,runID,varParser);
    end


    wksParser.GlobalTimeVectorName='';
    wksParser.GlobalTimeVectorValue=[];


    sigIDs=repo.getAllSignalIDs(runID,'leaf');
    numPrior=length(priorSigIDs);
    sigIDs=sigIDs(numPrior+1:end);
end


function vars=locAddOutputAndStates(allVarNames,vars,idxWithMetaData)


    vars(idxWithMetaData)=[];
    numMetaDataVars=length(idxWithMetaData);
    for allVarsIdx=1:numMetaDataVars
        varIndex=idxWithMetaData(allVarsIdx);
        curVarNames=allVarNames{varIndex}.VarName;
        numMetaData=length(allVarNames{varIndex}.MetaData);
        newVars=repmat(struct(...
        'VarName','',...
        'VarValue',[],...
        'VarBlockPath','',...
        'VarSignalName','',...
        'TimeSourceRule','model based'),...
        [1,numMetaData]);
        colOffset=1;
        for metaDataIdx=1:numMetaData



            if length(curVarNames)>=metaDataIdx
                metaDataVarName=curVarNames{metaDataIdx};
                colOffset=1;
            else
                metaDataVarName=curVarNames{1};
            end


            newVars(metaDataIdx).VarName=metaDataVarName;
            newVars(metaDataIdx).VarSignalName=allVarNames{varIndex}.MetaData(metaDataIdx).SignalName;
            newVars(metaDataIdx).VarBlockPath=allVarNames{varIndex}.MetaData(metaDataIdx).BlockPath;
            try
                curVal=evalin('base',metaDataVarName);
            catch me %#ok<NASGU>
                curVal=[];
            end


            if~isempty(curVal)
                curWidth=allVarNames{varIndex}.MetaData(metaDataIdx).Width;
                newVars(metaDataIdx).VarValue=eval(...
                sprintf('curVal(:,%d:%d)',colOffset,colOffset+curWidth-1));
                colOffset=colOffset+curWidth;
            else
                newVars(metaDataIdx).VarValue=[];
            end
        end


        vars=[vars,newVars];%#ok<AGROW>
    end
end

