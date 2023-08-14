function[VarNameList,TimeSaveName,FileList,scopeVarList]=getLogVarNamesFromModel(mdl,varargin)





    if isempty(varargin)||isempty(varargin{1})
        metaData=[];
        [VarNameList,TimeSaveName,FileList,scopeVarList]=...
        Simulink.sdi.internal.SLUtil.getLogVarNamesWithoutMetaData(mdl,metaData);
        return
    else
        metaData=varargin{1};
    end


    if isfield(metaData,'isTopModelXIL')&&metaData.isTopModelXIL
        [VarNameList,TimeSaveName,FileList,scopeVarList]=...
        Simulink.sdi.internal.SLUtil.getLogVarNamesWithoutMetaData(mdl,metaData);
        return
    else

        TimeSaveName=metaData.TimeVarName;
        FileList=cell(size(metaData.ToFileBlks));
        VarNameList={};
        scopeVarList={};
    end


    numFiles=length(metaData.ToFileBlks);
    for idx=1:numFiles
        fileInfo.VarName=metaData.ToFileBlks(idx).FileName;
        fileInfo.BlockPath=metaData.ToFileBlks(idx).BlockPath;
        FileList{idx}=fileInfo;
    end


    if metaData.MATFileLogging&&~metaData.IsRapidAccel
        fileInfo.VarName=[mdl,'.mat'];
        if exist(fileInfo.VarName,'file')
            fileInfo.BlockPath='';
            FileList{end+1}=fileInfo;
            return
        end
    end


    cs=getActiveConfigSet(mdl);
    if strcmpi(get_param(cs,'ReturnWorkspaceOutputs'),'on')
        [VarNameList,TimeSaveName,scopeVarList]=...
        getLogVarNamesForSingleOutput(metaData,cs,VarNameList,TimeSaveName);
        return
    end


    if metaData.IsRapidAccel
        [VarNameList,TimeSaveName,~,scopeVarList]=...
        Simulink.sdi.internal.SLUtil.getLogVarNamesWithoutMetaData(mdl,metaData);
    end


    numVars=length(metaData.WksVars);
    for idx=1:numVars
        switch metaData.WksVars(idx).Type
        case 'scope'
            scopeVarList{end+1}=metaData.WksVars(idx);%#ok<AGROW>

        case{'towks','unknownblock'}
            VarNameList{end+1}=metaData.WksVars(idx);%#ok<AGROW>

        case{'state','finalstate','output'}


        otherwise
            VarNameList{end+1}=metaData.WksVars(idx).VarName;%#ok<AGROW>
        end
    end


    VarNameList=addStateMetaData(metaData,VarNameList,'');
    VarNameList=addOutputMetaData(metaData,VarNameList,'');
end


function[VarNameList,TimeSaveName,scopeVarList]=getLogVarNamesForSingleOutput(metaData,cs,VarNameList,TimeSaveName)

    outName=get_param(cs,'ReturnWorkspaceOutputsName');
    VarNameList{end+1}=outName;


    if~isempty(TimeSaveName)
        TimeSaveName=sprintf('%s.find(''%s'')',outName,TimeSaveName);
        if~isempty(metaData.States)
            VarNameList=addStateMetaData(metaData,VarNameList,outName);
        end
        if~isempty(metaData.Outputs)
            VarNameList=addOutputMetaData(metaData,VarNameList,outName);
        end
    end


    scopeVarList={};
    numVars=length(metaData.WksVars);
    for idx=1:numVars
        if strcmp(metaData.WksVars(idx).Type,'scope')
            scopeVarList{end+1}=metaData.WksVars(idx);%#ok<AGROW>
            scopeVarList{end}.VarName=sprintf('%s.find(''%s'')',outName,scopeVarList{end}.VarName);
        end
    end
end


function VarNameList=addStateMetaData(metaData,VarNameList,outName)
    numVars=length(metaData.WksVars);
    for idx=1:numVars
        if strcmp(metaData.WksVars(idx).Type,'state')||strcmp(metaData.WksVars(idx).Type,'finalstate')
            VarNameList{end+1}=metaData.WksVars(idx);%#ok<AGROW>
            if~isempty(metaData.States)
                if~isempty(outName)
                    VarNameList{end}.VarName=...
                    Simulink.sdi.internal.Util.helperFixVarNameOneObject({VarNameList{end}.VarName},outName);
                else
                    VarNameList{end}.VarName={VarNameList{end}.VarName};
                end
                VarNameList{end}.MetaData=metaData.States;
                VarNameList{end}.Final=strcmp(metaData.WksVars(idx).Type,'finalstate');
            end
        end
    end
end


function VarNameList=addOutputMetaData(metaData,VarNameList,outName)
    outportVarIdices=[];
    numVars=length(metaData.WksVars);
    for idx=1:numVars
        if strcmp(metaData.WksVars(idx).Type,'output')
            VarNameList{end+1}=metaData.WksVars(idx);%#ok<AGROW>
            if~isempty(metaData.Outputs)
                if~isempty(outName)
                    VarNameList{end}.VarName=...
                    Simulink.sdi.internal.Util.helperFixVarNameOneObject({VarNameList{end}.VarName},outName);
                else
                    VarNameList{end}.VarName={VarNameList{end}.VarName};
                end
                VarNameList{end}.MetaData=metaData.Outputs;
                VarNameList{end}.Final=false;
                outportVarIdices(end+1)=length(VarNameList);%#ok<AGROW>
            end
        end
    end


    if length(outportVarIdices)>1
        outputIdx=outportVarIdices(1);
        dupVarIdx=outportVarIdices(2:end);
        for idx=1:length(dupVarIdx)
            VarNameList{outputIdx}.VarName{end+1}=VarNameList{dupVarIdx(idx)}.VarName{1};
        end
        VarNameList(dupVarIdx)=[];
    end
end


