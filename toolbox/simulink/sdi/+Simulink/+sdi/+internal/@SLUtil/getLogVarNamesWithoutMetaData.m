function[VarNameList,TimeSaveName,FileList,scopeVarList]=getLogVarNamesWithoutMetaData(mdl,metaData)






    VarNameList={};
    TimeSaveName='';
    FileList={};
    scopeVarList={};


    cs=getActiveConfigSet(mdl);
    if strcmpi(get_param(cs,'ReturnWorkspaceOutputs'),'on')
        VarNameList{end+1}=get_param(cs,'ReturnWorkspaceOutputsName');
        return
    end


    if strcmpi(get_param(cs,'SaveTime'),'on')
        TimeSaveName=get_param(cs,'TimeSaveName');
    end


    saveFormat=get_param(cs,'SaveFormat');


    VarNameList=safeAddCSParam(VarNameList,cs,'SaveState','StateSaveName');
    VarNameList=addOutputVars(VarNameList,cs,saveFormat,metaData);
    VarNameList=safeAddCSParam(VarNameList,cs,'SaveFinalState','FinalStateName');
    VarNameList=safeAddCSParam(VarNameList,cs,'SignalLogging','SignalLoggingName');
    VarNameList=safeAddSimscapeParam(VarNameList,cs,'SimscapeLogType','SimscapeLogName');
    VarNameList=safeAddCSParam(VarNameList,cs,'DSMLogging','DSMLoggingName');
end


function VarNameList=addOutputVars(VarNameList,cs,saveFormat,metaData)
    if~strcmp(saveFormat,'Array')
        VarNameList=safeAddCSParam(VarNameList,cs,'SaveOutput','OutputSaveName');
    elseif isfield(metaData,'Outputs')&&~isempty(metaData.Outputs)
        list={};
        list=safeAddCSParam(list,cs,'SaveOutput','OutputSaveName');
        if~isempty(list)
            temp.VarName=list;
            temp.MetaData=metaData.Outputs;
            temp.Final=false;
            VarNameList{end+1}=temp;
        end
    end
end


function VarNameList=safeAddCSParam(VarNameList,cs,EnableParam,NameParam)



    if strcmpi(get_param(cs,EnableParam),'on')
        varName=get_param(cs,NameParam);
        variablesArray=textscan(varName,'%s','Delimiter',',');
        assert(length(variablesArray)==1,'array length should be 1');
        vars=variablesArray{1};
        numVariables=length(vars);
        for idx=1:numVariables
            VarNameList{end+1}=vars{idx};%#ok<AGROW>
        end
    end
end


function VarNameList=safeAddSimscapeParam(VarNameList,cs,EnableParam,NameParam)
    try
        if~isequal(get_param(cs,EnableParam),'none')
            varName=get_param(cs,NameParam);
            VarNameList{end+1}=varName;
        end
    catch me %#ok<NASGU>

    end
end

