function[variableExist,data]=...
    exportToBaseWorkspace(this,runIDs,signalIDs,activeApp,baseWorkspace_VarName,checkIfVarsExist)



    if nargin<6
        checkIfVarsExist=true;
    end

    if strcmp(activeApp,'siganalyzer')
        data=[];
        varInfo=baseWorkspace_VarName;



        variableExist=false;
        if checkIfVarsExist
            variableExist=false;
            for idx=1:length(varInfo)
                variableExist=isVariableExistInWorkspace(varInfo(idx).varName);
                if variableExist
                    break;
                end
            end
        end
        if~variableExist
            for idx=1:length(varInfo)
                if varInfo(idx).isLSS
                    data=this.exportToLabeledSignalSet(varInfo(idx));
                elseif varInfo(idx).isExportToTimetable
                    data=this.exportToTimetable(varInfo(idx));
                else
                    data=this.exportToMatrix(varInfo(idx));
                end
                if~isempty(data)
                    assignin('base',varInfo(idx).varName,data);
                    data=[];
                end
            end
        end
    elseif strcmp(activeApp,'labeler')
        data=[];



        variableExist=isVariableExistInWorkspace(baseWorkspace_VarName);
    else
        [baseWorkspace_VarName,data]=this.exportToDataset(...
        runIDs,signalIDs,activeApp,baseWorkspace_VarName);

        variableExist=isVariableExistInWorkspace(baseWorkspace_VarName);
        if~variableExist
            assignin('base',baseWorkspace_VarName,data);
        end
    end
end

function flag=isVariableExistInWorkspace(varName)
    cmd=sprintf('exist(''%s'')',varName);
    flag=(evalin('base',cmd)==1);
end
