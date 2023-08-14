



function status=hiliteCode(actionOrSid,moduleName,fileId,line)

    doClearOnly=(nargin==1&&actionOrSid=="clearCache");


    persistent moduleName2Info;
    if isempty(moduleName2Info)||doClearOnly
        moduleName2Info=containers.Map('KeyType','char','ValueType','any');
    end

    status=0;

    if doClearOnly
        return
    end

    try

        [trDataFile,~,buildDir,isSharedUtils]=SlCov.coder.EmbeddedCoder.getCodeCovDataFiles(moduleName);
        fileInfo=dir(trDataFile);
        if isempty(fileInfo)
            return
        end


        moduleInfo=[];
        needExtract=~moduleName2Info.isKey(moduleName);
        if~needExtract
            moduleInfo=moduleName2Info(moduleName);
            needExtract=moduleInfo.datenum~=fileInfo.datenum;
        end





        if needExtract
            moduleInfo.datenum=fileInfo.datenum;
            moduleInfo.fileId2Path=containers.Map('KeyType','char','ValueType','any');
            trData=sldv.code.xil.internal.TraceabilityDb(trDataFile);
            trData.close();
            trData.computeShortestUniquePaths();
            moduleInfo.trData=trData;

            symbolicName=trData.getSymbolicName('MATLAB_ROOT');
            if~isempty(symbolicName)
                moduleInfo.matlabRoot=symbolicName.value;
            end
            symbolicName=trData.getSymbolicName('BUILD_DIR');
            if~isempty(symbolicName)
                moduleInfo.buildDir=symbolicName.value;
            end
            symbolicName=trData.getSymbolicName('ANCHOR_DIR');
            if~isempty(symbolicName)
                moduleInfo.anchorDir=symbolicName.value;
            end
            symbolicName=trData.getSymbolicName('SHAREDUTILS_DIR');
            if~isempty(symbolicName)
                moduleInfo.sharedUtilsDir=symbolicName.value;
            end

            if~isfield(moduleInfo,'matlabRoot')
                moduleInfo.matlabRoot=matlabroot;
            end
            if~isfield(moduleInfo,'buildDir')
                moduleInfo.buildDir=buildDir;
            end
            if~isfield(moduleInfo,'anchorDir')
                moduleInfo.anchorDir=pwd;
            end
            if~isfield(moduleInfo,'sharedUtilsDir')
                if isSharedUtils
                    moduleInfo.sharedUtilsDir=buildDir;
                else
                    moduleInfo.sharedUtilsDir=fullfile(moduleInfo.anchorDir,'slprj','ert','_sharedutils');
                end
            end
        end


        if isempty(moduleInfo)
            moduleInfo=moduleName2Info(moduleName);
        end


        fullPath='';
        needUpdate=~moduleInfo.fileId2Path.isKey(fileId)||isempty(moduleInfo.fileId2Path(fileId));
        if needUpdate
            file=[];
            allFiles=moduleInfo.trData.Root.files.toArray();
            for ii=1:numel(allFiles)
                currFileId=sldv.code.internal.computeFileKey(allFiles(ii));
                if strcmp(fileId,currFileId)
                    file=allFiles(ii);
                    break
                end
            end
            if isempty(file)

                try
                    file=moduleInfo.trData.Model.findElement(fileId);
                catch
                    file=[];
                end
            end
            if~isempty(file)
                filePath=file.pathRelativeToSymbolicName;
                if contains(filePath,'$(MATLAB_ROOT)')
                    filePath=strrep(filePath,'$(MATLAB_ROOT)',moduleInfo.matlabRoot);
                elseif contains(filePath,'$(BUILD_DIR)')
                    filePath=strrep(filePath,'$(BUILD_DIR)',moduleInfo.buildDir);
                elseif contains(filePath,'$(ANCHOR_DIR)')
                    filePath=strrep(filePath,'$(ANCHOR_DIR)',moduleInfo.anchorDir);
                elseif contains(filePath,'$(SHAREDUTILS_DIR)')
                    filePath=strrep(filePath,'$(SHAREDUTILS_DIR)',moduleInfo.sharedUtilsDir);
                end
                filePath=polyspace.internal.getAbsolutePath(filePath);
                if isfile(filePath)
                    fullPath=filePath;
                end
            end
            moduleInfo.fileId2Path(fileId)=fullPath;
        else
            fullPath=moduleInfo.fileId2Path(fileId);
        end


        if needExtract||needUpdate
            moduleName2Info(moduleName)=moduleInfo;
        end


        if isempty(fullPath)
            return
        end


        matlab.desktop.editor.openAndGoToLine(fullPath,line);

        status=1;

    catch Me
        if sldv.code.internal.feature('disableErrorRecovery')
            rethrow(Me);
        end
        disp(Me);
    end


