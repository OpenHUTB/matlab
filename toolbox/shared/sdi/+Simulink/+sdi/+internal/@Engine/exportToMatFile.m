function exportToMatFile(this,runIDs,signalIDs,activeApp,matFile_VarName,matFile_FileName)





    appName='sdi';
    message.publish('/sdi2/progressUpdate',struct('dataIO','begin','appName',appName));
    tmp=onCleanup(@()message.publish('/sdi2/progressUpdate',struct('dataIO','end','appName',appName)));

    try
        if strcmp(activeApp,'siganalyzer')
            locSignalAnalyzerExport(this,matFile_VarName,matFile_FileName);
        elseif isempty(signalIDs)&&isscalar(runIDs)&&strcmpi(activeApp,'SDI')
            locStreamRunToFile(this,runIDs,matFile_VarName,matFile_FileName);
        else
            locExportViaSave(this,runIDs,signalIDs,activeApp,matFile_VarName,matFile_FileName);
        end
    catch me
        throwAsCaller(me);
    end
end


function locStreamRunToFile(~,runID,matFile_VarName,matFile_FileName)
    Simulink.sdi.internal.export.createMATFileForRun(runID,[],matFile_FileName,matFile_VarName);
end


function locExportViaSave(this,runIDs,signalIDs,activeApp,matFile_VarName,matFile_FileName)

    if strcmpi(activeApp,'SDI')&&isscalar(signalIDs)&&isempty(runIDs)

        currSig=this.getSignalObject(signalIDs(1));
        data=currSig.Values;
        data.Name=currSig.SignalLabel;
    else

        [matFile_VarName,data]=this.exportToDataset(...
        runIDs,signalIDs,activeApp,matFile_VarName);%#ok<ASGLU>
    end

    save(matFile_FileName,matFile_VarName,'-v7.3');
    eval(['clear(''',matFile_VarName,''');']);
end


function locSignalAnalyzerExport(this,matFile_VarName,matFile_FileName)

    varInfo=matFile_VarName;
    initFlag=true;
    for idx=1:length(varInfo)
        varName=varInfo(idx).varName;
        if varInfo(idx).isLSS
            data=this.exportToLabeledSignalSet(varInfo(idx));
        elseif varInfo(idx).isExportToTimetable
            data=this.exportToTimetable(varInfo(idx));
        else
            data=this.exportToMatrix(varInfo(idx));
        end

        if~isempty(data)
            if(initFlag)
                m=locCreateMATFile(matFile_FileName);
                initFlag=false;
            end
            if(m.Properties.isvalid)
                m.(varName)=data;
            end
        end
    end
end


function m=locCreateMATFile(fileName)

    s=struct;
    save(fileName,'-struct','s')
    m=matfile(fileName,'Writable',true);
end