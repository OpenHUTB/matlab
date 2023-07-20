classdef(CaseInsensitiveProperties)Application<handle





    properties(SetAccess=private,GetAccess=public,Hidden)
AppObj
    end


    properties(SetAccess=private,GetAccess=public)
ApplicationName
ModelName
    end

    properties(Dependent)
UserData
    end

    properties(SetAccess=private,GetAccess=public)
Options
    end




    properties(Access=private)
Signals
Parameters
RootIOs
    end

    properties(Access=private)
        CANSignalsCached=false
CANSignals
CANFDSignals
    end

    methods
        function obj=Application(mldatxfile)
            mldatxfile=convertStringsToChars(mldatxfile);
            validateattributes(mldatxfile,{'char'},{'scalartext'});
            if isfile(mldatxfile)
                [~,AppName,~]=fileparts(mldatxfile);
            else
                AppName=mldatxfile;
                AppNameWithExt=strcat(AppName,'.mldatx');
                mldatxfile=which(AppNameWithExt);
            end

            obj.AppObj=slrealtime.internal.Application(mldatxfile);
            obj.ApplicationName=AppName;
            obj.Options=slrealtime.internal.ApplicationOptions(obj.AppObj);
            modeldescription=slrealtime.internal.deserializeMetadata(obj.AppObj,'/misc/','modelDescription');
            obj.ModelName=modeldescription.ModelName;
        end

        function delete(obj)
            delete(obj.AppObj);
        end

        function signals=getSignals(obj)

            if isempty(obj.Signals)
                codeDescriptor=obj.getCodeDescriptor();
                [obj.Signals,obj.Parameters]=slrealtime.Application.extractSignalsAndParameters(codeDescriptor);
            end
            signals=obj.Signals;
        end

        function parameters=getParameters(obj)

            if isempty(obj.Parameters)
                codeDescriptor=obj.getCodeDescriptor();
                [obj.Signals,obj.Parameters]=slrealtime.Application.extractSignalsAndParameters(codeDescriptor);
            end
            parameters=obj.Parameters;
        end

        function rootIOs=getRootLevelInports(obj)


            if isempty(obj.RootIOs)
                try
                    obj.AppObj.extract(['/ri/',obj.ModelName,'_RI.mat']);
                catch

                    rootIOs=obj.RootIOs;
                    return;
                end
                fullFilePath=fullfile(obj.AppObj.getWorkingDir,'ri',[obj.ModelName,'_RI.mat']);
                if exist(fullFilePath,'file')==2

                    res=load(fullFilePath);
                    obj.RootIOs=struct('BlockPath',{},...
                    'PortIndex',{},...
                    'SignalLabel',{},...
                    'BlockType',{},...
                    'Dimensions',{},...
                    'DataType',{});
                    for i=1:numel(res.metadata)


                        fullBlockPath=res.metadata(i).FullBlockPath;
                        if contains(fullBlockPath,',')
                            fullBlockPath={strsplit(fullBlockPath,',')};
                        end

                        element=struct('BlockPath',fullBlockPath,...
                        'PortIndex',res.metadata(i).PortIndex+1,...
                        'SignalLabel',res.metadata(i).SigLabel,...
                        'BlockType',res.metadata(i).BlockType,...
                        'Dimensions',res.metadata(i).Dimensions,...
                        'DataType',res.metadata(i).DataType);
                        obj.RootIOs(end+1)=element;
                    end
                end
            end
            rootIOs=obj.RootIOs;
        end







        function updateRootLevelInportData(obj)
            slrealtime.internal.ExternalInputManager.updateRootLevelInportData(obj.AppObj,obj.ModelName);
        end


        function set.UserData(obj,userData)
            narginchk(2,2);
            matFileName=[tempname,'.mat'];
            save(matFileName,'userData');
            cleanupObj=onCleanup(@()delete(matFileName));
            obj.AppObj.add('/user/UserData.mat',matFileName);
        end

        function userData=get.UserData(obj)
            try
                obj.AppObj.extract('/user/UserData.mat');
                s=load(fullfile(obj.AppObj.getWorkingDir,'user','UserData.mat'));
                userData=s.userData;
            catch ME
                if strcmp(ME.identifier,'slrealtime:application:partNotFound')
                    userData=[];
                else
                    throwAsCaller(ME);
                end
            end

        end


















        function extractASAP2(obj,varargin)


            argParser=inputParser;


            argParser.addParameter('TargetIPAddress','',@(x)(ischar(x)||isStringScalar(x)));
            argParser.addParameter('Folder','',@(x)(ischar(x)||isStringScalar(x)));
            argParser.addParameter('FileName','',@(x)(ischar(x)||isStringScalar(x)));
            argParser.parse(varargin{:});

            ipAddress=convertStringsToChars(argParser.Results.TargetIPAddress);
            if~isempty(ipAddress)&&...
                ~slrealtime.internal.validateIpAddress(ipAddress)
                DAStudio.error('slrealtime:target:badipaddr',ipAddress);
            end


            if~isempty(argParser.Results.Folder)
                folderPath=convertStringsToChars(argParser.Results.Folder);
                if exist(folderPath,'dir')~=7
                    mkdir(folderPath);
                end
                exportLocation=folderPath;
            else

                exportLocation=pwd;
            end

            if~isempty(argParser.Results.FileName)
                newA2lFilePath=fullfile(exportLocation,...
                [convertStringsToChars(argParser.Results.FileName),'.a2l']);
            else
                newA2lFilePath=fullfile(exportLocation,[obj.ModelName,'.a2l']);
            end

            try
                a2lFileName=[obj.ModelName,'.a2l'];

                obj.AppObj.extract(['/host/asap2/',a2lFileName]);

                copyfile(fullfile(obj.AppObj.getWorkingDir,'/host/asap2/',a2lFileName),...
                newA2lFilePath,'f');

                if~isempty(ipAddress)




                    fileContent=fileread(newA2lFilePath);

                    [a2lTillBeginXCP_ON_UDP_IP,a2lContentsRest]=splitA2LContents(fileContent,'/begin XCP_ON_UDP_IP');

                    [a2lContentXCP_ON_UDP_IP,a2lContentsRest]=splitA2LContents(a2lContentsRest,'/end XCP_ON_UDP_IP');

                    expToFind='ADDRESS ".*"';
                    if isempty(regexp(a2lContentXCP_ON_UDP_IP,expToFind,'once'))



                        expToFind='HOST_NAME ""';
                    end

                    textToReplace=['ADDRESS "',ipAddress,'"'];

                    newA2lContentXCP_ON_UDP_IP=regexprep(a2lContentXCP_ON_UDP_IP,expToFind,textToReplace,'dotexceptnewline');

                    fid=fopen(newA2lFilePath,'w');

                    newContent=[a2lTillBeginXCP_ON_UDP_IP,newline,newA2lContentXCP_ON_UDP_IP,newline,a2lContentsRest];
                    fwrite(fid,newContent);
                    fclose(fid);
                end
            catch ME
                if~strcmp(ME.identifier,'slrealtime:application:partNotFound')
                    throwAsCaller(ME);
                end
            end
            function varargout=splitA2LContents(a2lContents,splitLine)


                varargout=regexp(a2lContents,...
                ['(?<=(',splitLine,'.*))\n'],...
                'split','once','dotexceptnewline');
            end
        end


        function updateASAP2(obj,inA2lFile)






            if exist(inA2lFile,'file')


                [~,~,fileFullPath]=xcp.validateA2LFile(inA2lFile);

                try

                    a2lobj=xcp.A2LManager.getInstance.find(fileFullPath);
                catch
                    error(message('slrealtime:application:invalidA2LFile',fileFullPath));
                end


                obj.add(['/host/asap2/',obj.ModelName,'.a2l'],inA2lFile);

            else
                error(message('slrealtime:application:fileNotFound',inA2lFile));
            end
        end



        function appInfo=getInformation(obj)

            modeldescription=slrealtime.internal.deserializeMetadata(obj.AppObj,'/misc/','modelDescription');


            appInfo.ApplicationName=obj.ApplicationName;
            appInfo.ApplicationCreationDate=modeldescription.ApplicationCreationDate;
            appInfo.ApplicationLastModifiedDate=obj.getApplicationLastModifiedDate;


            appInfo.ModelName=modeldescription.ModelName;
            appInfo.ModelVersion=modeldescription.ModelVersion;
            appInfo.ModelCreationDate=modeldescription.ModelCreationDate;
            appInfo.ModelLastModifiedDate=modeldescription.ModelLastModifiedDate;
            appInfo.ModelLastModifiedBy=modeldescription.ModelLastModifiedBy;
            appInfo.ModelSolverType=modeldescription.ModelSolverType;
            appInfo.ModelSolverName=modeldescription.ModelSolverName;
            appInfo.MatlabVersion=modeldescription.MatlabVersion;
        end


        function addParamSet(obj,paramSet)









            tmpDir=tempname;
            mkdir(tmpDir);
            currDir=pwd;
            cdCleanup=onCleanup(@()cd(currDir));
            dirCleanup=onCleanup(@()rmdir(tmpDir,'s'));
            cd(tmpDir);


            jsonFileName=[paramSet.filename,'.json'];

            srcFile=paramSet.saveAsJSON(tmpDir,jsonFileName);

            obj.add(['/paramSet/',jsonFileName],srcFile);
        end



        function updateStartupParameterSet(obj,paramSet)












            fileName=paramSet.filename;
            if ischar(fileName)
                fileName=convertCharsToStrings(fileName);
            end
            obj.Options.set('startupParameterSet',fileName);
        end



        function updateAutoSaveParameterSetOnStop(obj,newVal)







            obj.Options.set('autoSaveParameterSetOnStop',newVal);
        end


        function fileLogDecimation=getFileLogDecimation(obj,blkpath)









            codeDescriptor=obj.getCodeDescriptor();


            if isa(blkpath,"Simulink.BlockPath")
                blkpath=blkpath.convertToCell();
            elseif isa(blkpath,"string")||isa(blkpath,"char")
                blkpath=cellstr(blkpath);
            elseif iscell(blkpath)

            else
                error(message('slrealtime:application:incorrectFileLogBlkPathInput'));
            end


            modelBlockPath={};


            [decimation,~]=obj.taqBlockDecimation(modelBlockPath,blkpath,codeDescriptor);
            if~isempty(decimation)
                codeDescriptor=[];%#ok
                fileLogDecimation=decimation;
            else


                decimations=int32(zeros(length(blkpath),1));
                for i=1:length(blkpath)
                    [decimation,~]=obj.taqBlockDecimation(modelBlockPath,blkpath{i},codeDescriptor);
                    if isempty(decimation)
                        codeDescriptor=[];%#ok
                        error(message('slrealtime:application:invalidFileLogBlkPath',strjoin(string(blkpath{i}),'|')));
                    else
                        decimations(i)=decimation;
                    end
                end
                codeDescriptor=[];%#ok


                if numel(unique(decimations))==1
                    fileLogDecimation=decimations(1);
                else
                    fileLogDecimation=decimations;
                end
            end
        end


        function setFileLogDecimation(obj,blkpath,decimationValue)










            codeDescriptor=obj.getCodeDescriptor();


            validateattributes(decimationValue,{'numeric'},{'positive','integer'});


            if isa(blkpath,"Simulink.BlockPath")
                blkpath=blkpath.convertToCell();
            elseif isa(blkpath,"string")||isa(blkpath,"char")
                blkpath=cellstr(blkpath);
            elseif iscell(blkpath)

            else
                error(message('slrealtime:application:incorrectFileLogBlkPathInput'));
            end


            if~(length(decimationValue)==length(blkpath)||length(decimationValue)==1)
                error(message('slrealtime:application:invalidDecimationInput'));
            end


            modelBlockPath={};
            decimationChanged=false;

            if isscalar(decimationValue)

                [~,decimationChanged]=obj.taqBlockDecimation(modelBlockPath,blkpath,codeDescriptor,decimationValue);
            end

            if decimationChanged
                obj.updateMLDATXFiles(codeDescriptor);
                codeDescriptor=[];%#ok           
            else

                codeDescriptor.commitTransaction();



                for i=1:length(blkpath)
                    if isscalar(decimationValue)
                        [~,decimationChanged]=obj.taqBlockDecimation(modelBlockPath,blkpath{i},codeDescriptor,decimationValue);
                    else
                        [~,decimationChanged]=obj.taqBlockDecimation(modelBlockPath,blkpath{i},codeDescriptor,decimationValue(i));
                    end

                    if~decimationChanged
                        codeDescriptor=[];%#ok
                        error(message('slrealtime:application:invalidFileLogBlkPath',strjoin(string(blkpath{i}),'|')));
                    end
                end
                obj.updateMLDATXFiles(codeDescriptor);
                codeDescriptor=[];%#ok
            end
        end


        function fileLogBlockPaths=getAllFileLogBlocks(obj)









            loggingMetadata=slrealtime.internal.deserializeMetadata(obj.AppObj,'/logging/','loggingdb');
            nChannels=loggingMetadata.channels;
            fileLogBlockPaths=cell(loggingMetadata.num_entries,1);
            blockPathIndex=1;

            for i=1:length(nChannels)
                channel=nChannels(i);
                nEntries=channel.entries;
                for j=1:length(nEntries)
                    entry=nEntries(j);
                    fullBlockPath=strsplit(string(entry.blockpath),'|');



                    indices=slrealtime.internal.parseBlockPath(fullBlockPath{end});
                    fullBlockPath{end}=extractBefore(fullBlockPath{end},indices(end));

                    fileLogBlockPaths{blockPathIndex}=fullBlockPath;
                    blockPathIndex=blockPathIndex+1;
                end
            end
        end
    end

    methods(Hidden)



        function list=list(obj)
            list=obj.AppObj.list;
        end

        function add(obj,filePathInMldatx,sourcefile)
            obj.Appobj.add(filePathInMldatx,sourcefile);
        end

        function remove(obj,filePathInMldatx)
            obj.AppObj.remove(filePathInMldatx);
        end

        function res=extract(obj,filename)
            res=obj.AppObj.extract(filename);
        end

        function res=File(obj)
            res=obj.AppObj.File;
        end

        function dir=getWorkingDir(obj)
            dir=obj.AppObj.getWorkingDir;
        end

        function setWorkingDir(obj,directory)
            obj.AppObj.setWorkingDir(directory);
        end








        function updateRootLevelInportDataWithMapping(obj,mapping)
            slrealtime.internal.ExternalInputManager.updateRootLevelInportData(obj.AppObj,obj.ModelName,mapping);
        end




        function str=getRootLevelInportMapping(obj)
            str=slrealtime.internal.ExternalInputManager.getRootLevelInportMapping(obj.AppObj,obj.ModelName);
        end

        function[canSignals,canFDSignals]=getCANSignals(obj)




            try
                if~obj.CANSignalsCached
                    obj.CANSignalsCached=true;
                    obj.extract('/host/dmr/');
                    wd=obj.getWorkingDir();
                    RTWDirStruct=load(fullfile(wd,'host','dmr','RTWDirStruct.mat'));
                    codeDescriptor=coder.internal.getCodeDescriptorInternal(fullfile(wd,'host','dmr',RTWDirStruct.dirStruct.RelativeBuildDir),247362);

                    obj.CANSignals=slrealtime.Application.findSignalsWithType('TMW SLRT Send to CAN Explorer Block',codeDescriptor,{});
                    obj.CANFDSignals=slrealtime.Application.findSignalsWithType('TMW SLRT Send to CAN FD Explorer Block',codeDescriptor,{});
                end
            catch ME
                obj.CANSignals=[];
                obj.CANFDSignals=[];
                obj.CANSignalsCached=false;
                rethrow(ME);
            end

            canSignals=obj.CANSignals;
            canFDSignals=obj.CANFDSignals;
        end
    end
    methods(Access=private)




        function dtStrOut=getApplicationLastModifiedDate(obj)
            dtStr=obj.AppObj.getLastModifiedTime();
            if isempty(dtStr)






                [~,AppName,~]=fileparts(obj.File);
                unzipDir=fullfile(tempdir,AppName);
                unzip(obj.File,unzipDir);
                uuidFile=dir(fullfile(unzipDir,'misc','UUID'));
                rmdir(unzipDir,'s');

                try

                    dt=datetime(uuidFile.datenum,'ConvertFrom','datenum');
                    dt.Format='yyyy-MM-dd HH:mm:ss';
                    dtStrOut=char(dt);
                catch


                    dtStrOut=uuidFile.date;
                end
            else




                try






                    if length(dtStr)>length('yyyy-MMM-dd HH:mm:ss')
                        dt=datetime(dtStr,'InputFormat','yyyy-MMM-dd HH:mm:ss.SSSSSSSSS','Locale','en');
                    elseif length(dtStr)==length('yyyy-MMM-dd HH:mm:ss')
                        dt=datetime(dtStr,'InputFormat','yyyy-MMM-dd HH:mm:ss','Locale','en');
                    else


                        dt=datetime(dtStr);
                    end

                    dt.Format='yyyy-MM-dd HH:mm:ss';
                    dtStrOut=char(dt);
                catch


                    dtStrOut=dtStr;
                end
            end
        end



        function[decimation,decimationChanged]=taqBlockDecimation(obj,modelBlockPath,inputBlockPath,codeDescriptor,varargin)

            if~isempty(varargin)
                updateDecimation=true;
                newDecimationValue=varargin{1};
                codeDescriptor.beginTransaction();
            else
                updateDecimation=false;
            end


            if iscell(inputBlockPath)&&length(inputBlockPath)==1&&isstring(inputBlockPath{1})
                inputBlockPath=inputBlockPath{1};
            end

            decimation=[];
            decimationChanged=false;

            taqBlocks=codeDescriptor.getMF0TAQBlocks.toArray;
            for nTAQBlock=1:numel(taqBlocks)
                taqBlock=taqBlocks(nTAQBlock);


                if taqBlock.IsLiveStreaming
                    continue;
                end


                indices=slrealtime.internal.parseBlockPath(taqBlock.BlockPath);
                newBlkPath=extractBefore(taqBlock.BlockPath,indices(end));
                if~isempty(modelBlockPath)
                    fullTAQBlockPath=[modelBlockPath,newBlkPath];
                else
                    fullTAQBlockPath={newBlkPath};
                end

                if length(fullTAQBlockPath)==length(inputBlockPath)
                    if isempty(setdiff(fullTAQBlockPath,inputBlockPath))
                        if updateDecimation
                            taqBlock.Decimation=newDecimationValue;
                            decimationChanged=true;

                            codeDescriptor.commitTransaction();
                            return;
                        else
                            decimation=taqBlock.Decimation;
                            return;
                        end
                    end
                end
            end


            bhm=codeDescriptor.getMF0BlockHierarchyMapForEdit();
            mdlBlks=bhm.getBlocksByType('ModelReference');
            for nMdlBlk=1:length(mdlBlks)
                mdlBlk=mdlBlks(nMdlBlk);


                if mdlBlk.IsProtectedModelBlock
                    continue;
                end

                mdlBlkPath=[modelBlockPath,cellstr(mdlBlk.Path)];
                subCodeDescriptor=codeDescriptor.getReferencedModelCodeDescriptor(mdlBlk.ReferencedModelName);
                if updateDecimation
                    [~,decimationChanged]=obj.taqBlockDecimation(mdlBlkPath,inputBlockPath,subCodeDescriptor,newDecimationValue);
                else
                    [decimation,~]=obj.taqBlockDecimation(mdlBlkPath,inputBlockPath,subCodeDescriptor);
                end


                if~isempty(decimation)
                    return;
                end


                if decimationChanged

                    if exist(fullfile(subCodeDescriptor.BuildDir,'codedescriptor.dmr'),'file')
                        obj.add(['/host/dmr/slprj/slrealtime/',mdlBlk.ReferencedModelName,'/codedescriptor.dmr'],fullfile(subCodeDescriptor.BuildDir,'codedescriptor.dmr'));
                    end
                    return;
                end
            end
        end


        function codeDescriptor=getCodeDescriptor(obj)
            obj.extract('/host/dmr/');
            wd=obj.getWorkingDir;
            RTWDirStruct=load(fullfile(wd,'host','dmr','RTWDirStruct.mat'));
            codeDescFolder=fullfile(wd,'host','dmr',RTWDirStruct.dirStruct.RelativeBuildDir);
            codeDescriptor=coder.internal.getCodeDescriptorInternal(codeDescFolder,247362);
        end


        function updateMLDATXFiles(obj,codeDescriptor)

            logger=slrealtime.internal.logging.Importer;
            logger.serializeDatabase(codeDescriptor.BuildDir);


            if isfile(fullfile(codeDescriptor.BuildDir,'loggingdb.json'))
                obj.add('/logging/loggingdb.json',fullfile(codeDescriptor.BuildDir,'loggingdb.json'));
            end


            if isfile(fullfile(codeDescriptor.BuildDir,'codedescriptor.dmr'))
                obj.add(['/host/dmr/',obj.ModelName,'_slrealtime_rtw','/codedescriptor.dmr'],fullfile(codeDescriptor.BuildDir,'codedescriptor.dmr'));
            end


            delete(fullfile(codeDescriptor.BuildDir,'loggingdb.json'));
        end
    end

    methods(Static,Hidden)


        function outSignals=findSignalsWithType(type,codeDescriptor,modelRefPrefix)
            outSignals=struct('BlockPath',{},'PortIndex',{});

            bhm=codeDescriptor.getBlockHierarchyMap();

            blks=bhm.getBlocksByType('SubSystem');
            blks=blks(strcmp({blks.Description},type));

            if~isempty(blks)
                signals(1)=blks(1).DataInputPorts(1).DataInterfaces(1);
                signals(2)=blks(1).DataInputPorts(2).DataInterfaces(1);

                if isempty(signals),return;end

                for nSig=1:length(signals)
                    blk=slrealtime.internal.getBlockBySID(bhm,signals(nSig).SID);
                    if isempty(blk),return;end
                    outPorts=blk.DataOutputPorts.toArray();
                    for nOutPort=1:length(outPorts)
                        dataIntrfs=outPorts(nOutPort).DataInterfaces.toArray();
                        for nDataIntrf=1:length(dataIntrfs)
                            if signals(nSig)==dataIntrfs(nDataIntrf)
                                outSignals(end+1)=struct('BlockPath',{[modelRefPrefix,{blk.Path}]},'PortIndex',nOutPort);%#ok
                            end
                        end
                    end
                end



                if~isempty(outSignals),return;end
            end

            mdlBlks=bhm.getBlocksByType('ModelReference');
            for nMdlBlk=1:length(mdlBlks)
                mdlBlk=mdlBlks(nMdlBlk);

                if mdlBlk.IsProtectedModelBlock,continue;end

                skipModelBlock=false;
                try
                    codeDescriptorSub=codeDescriptor.getReferencedModelCodeDescriptor(mdlBlk.ReferencedModelName);
                catch
                    skipModelBlock=true;
                end
                if skipModelBlock,continue;end

                outSignals=slrealtime.Application.findSignalsWithType(type,codeDescriptorSub,[modelRefPrefix,{mdlBlk.Path}]);



                if~isempty(outSignals),return;end
            end
        end








        function[signals,parameters]=extractSignalsAndParameters(codeDescriptor,varargin)
            signals=slrealtime.Application.extractSignals(codeDescriptor,varargin{:});
            parameters=slrealtime.Application.extractParameters(codeDescriptor,varargin{:});
        end

        function signals=extractSignals(codeDescriptor,varargin)
            signals=codeDescriptor.getTunableSignalsForSLRT(varargin{:});
        end

        function parameters=extractParameters(codeDescriptor,varargin)
            parameters=codeDescriptor.getTunableParametersForSLRT(varargin{:});


































            map=containers.Map('KeyType','char','ValueType','any');
            idxs=find([parameters.IsModelArgument]);
            for idx=1:length(idxs)
                blockpath={};
                strs=split(parameters(idxs(idx)).BlockParameterName,'.');
                for j=1:length(strs)
                    if isempty(str2num(strs{j}))%#ok
                        break;
                    end
                    blockpath{j}=strs{j};%#ok
                end

                if~isempty(blockpath)
                    mdlBlkPath=parameters(idxs(idx)).BlockPath;
                    bhm=codeDescriptor.getBlockHierarchyMap;

                    for nLevel=1:j-1


                        mdlBlk=[];
                        mdlBlks=bhm.getBlocksByType('ModelReference');
                        for nMdlBlk=1:length(mdlBlks)
                            mdlBlk=mdlBlks(nMdlBlk);
                            if strcmp(mdlBlkPath,mdlBlk.Path)
                                break;
                            end
                        end



                        if isempty(mdlBlk)||mdlBlk.IsProtectedModelBlock
                            continue;
                        end
                        skipModelBlock=false;
                        if map.isKey(mdlBlk.ReferencedModelName)
                            val=map(mdlBlk.ReferencedModelName);
                            subCodeDescriptor=val{1};
                            subBhm=val{2};
                        else
                            try
                                subCodeDescriptor=codeDescriptor.getReferencedModelCodeDescriptor(mdlBlk.ReferencedModelName);
                                subBhm=subCodeDescriptor.getBlockHierarchyMap;
                                map(mdlBlk.ReferencedModelName)={subCodeDescriptor,subBhm};
                            catch
                                skipModelBlock=true;
                            end
                        end
                        if skipModelBlock
                            continue;
                        end



                        blk=slrealtime.internal.getBlockBySID(subBhm,[subCodeDescriptor.ModelName,':',blockpath{nLevel}]);
                        blockpath{nLevel}=blk.Path;%#ok



                        mdlBlkPath=blk.Path;
                        bhm=subBhm;
                    end



                    parameters(idxs(idx)).BlockPath=[parameters(idxs(idx)).BlockPath,blockpath];
                    parameters(idxs(idx)).BlockParameterName=join(strs{j:end},'.');
                end
            end
        end
    end
end

