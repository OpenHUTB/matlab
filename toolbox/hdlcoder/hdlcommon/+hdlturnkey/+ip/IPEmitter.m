




classdef(Abstract)IPEmitter<handle


    properties


        hCHEmitter=[];





        IPCoreSrcFileList={};


        CodegenIPCoreSrcFileList={};
        CustomIPCoreSrcFileList={};


        DefaultLibName='';


        hIP=[];


        IPCoreHDLPath='';
        IPCoreReportPath='';
        IPCoreCHeaderPath='';


        hIPNameService=[];

    end

    properties(Access=protected)


        IPCoreNameLength=45;
        DefaultIPCoreNameLength=12;

    end


    properties(Abstract)

hReport
    end

    properties(Constant)


        HDLFolder='hdl';
        CHeaderFolder='include';
        DocFolder='doc';

    end


    methods

        function obj=IPEmitter(hIP)


            obj.hIP=hIP;

            obj.hCHEmitter=hdlturnkey.ip.CHeaderEmitter(obj);

        end

        function IPEmitterStruct=getIPEmitterStruct(obj)

            IPEmitterStruct.IPCoreSrcFileList=obj.IPCoreSrcFileList;
            IPEmitterStruct.CodegenIPCoreSrcFileList=obj.CodegenIPCoreSrcFileList;
            IPEmitterStruct.CustomIPCoreSrcFileList=obj.CustomIPCoreSrcFileList;


            if obj.hIP.getIPCoreReportStatus
                IPEmitterStruct.IPReportDocFolder=obj.hReport.getPCoreDocFolder;
                IPEmitterStruct.IPReportHTMLFolder=obj.hReport.getPCoreReportFolder;
            end
        end

        function loadIPEmitterStruct(obj,IPEmitterStruct)

            obj.IPCoreSrcFileList=IPEmitterStruct.IPCoreSrcFileList;
            obj.CodegenIPCoreSrcFileList=IPEmitterStruct.CodegenIPCoreSrcFileList;
            obj.CustomIPCoreSrcFileList=IPEmitterStruct.CustomIPCoreSrcFileList;


            if obj.hIP.getIPCoreReportStatus
                src=fullfile(IPEmitterStruct.IPReportDocFolder,'*');
                dst=IPEmitterStruct.IPReportHTMLFolder;
                copyfile(src,dst,'f')
            end
        end

        function hPlatform=getPlatformObject(obj)
            hPlatform=obj.hIP.hD.hTurnkey.hBoard;
        end
        function hTurnkey=getTurnkeyObject(obj)
            hTurnkey=obj.hIP.hD.hTurnkey;
        end
        function hDI=getDIObject(obj)
            hDI=obj.hIP.hD;
        end


        function ipCoreName=getDefaultIPCoreName(obj)

            dutNameStr=obj.getDUTNameStr;

            dutNameStr=obj.getShorterNameStr(dutNameStr,obj.DefaultIPCoreNameLength-3);

            dutNameStr=obj.removeUnderscoreInIPCoreName(dutNameStr);
            ipCoreName=sprintf('%s_ip',dutNameStr);
        end

        function ipCoreVer=getDefaultIPCoreVer(obj)
            ipCoreVer=obj.defaultIpCoreVer;
        end

        function[customFile,outFileStr]=parseCustomFileStr(obj,customFileStr)


            strCell=regexp(customFileStr,'\s*;\s*','split');


            if~isempty(strCell)
                strCell=unique(strCell);
            end


            customFile={};
            for ii=1:length(strCell)
                strFile=strCell{ii};
                if~isempty(strFile)
                    if exist(strFile,'file')
                        customFile{end+1}=strFile;%#ok<*AGROW>
                    else
                        error(message('hdlcommon:workflow:InvalidCustomHDLFile',strFile));
                    end
                end
            end


            outFileStr='';
            if~isempty(customFile)
                outFileStr=sprintf('%s;',customFile{:});
            end
        end

        function hdlFolder=getHDLSrcFolder(obj)

            isISETool=strcmpi(obj.hIP.hD.getToolName,'Xilinx ISE');
            if(isISETool)
                hCodeGen=obj.hIP.hD.hCodeGen;
                if hCodeGen.isVHDL
                    targetL='vhdl';
                else
                    targetL='verilog';
                end
                hdlFolder=fullfile(obj.HDLFolder,targetL);
            else
                hdlFolder=fullfile(obj.HDLFolder);
            end
        end


        function validateIPCoreName(obj,name)

            if isempty(name)
                error(message('hdlcommon:workflow:IPNameEmpty'));
            end

            obj.checkIPCoreNameLength(name,obj.IPCoreNameLength);


            obj.checkSpaceInIPCoreName(name);


            ipcoreNameMsg=message('HDLShared:hdldialog:HDLWAIPCoreNameStr');
            downstream.tool.checkNonASCII(name,ipcoreNameMsg.getString);


            obj.checkUnderscoreInIPCoreName(name);


            obj.checkDashInIPCoreName(name);
        end

        function validateIPCoreVerShared(~,ver)


            ipcoreVerMsg=message('HDLShared:hdldialog:HDLWAIPCoreVersionStr');
            downstream.tool.checkNonASCII(ver,ipcoreVerMsg.getString);
        end

    end

    methods(Abstract)

        folderName=getIPCoreFolderName(obj)

        validateIPCoreVer(obj,ver)


    end

    methods(Abstract,Access=protected)


        copyToIPRepository(obj)

    end

    methods(Access=protected)

        function dutNameStr=getDUTNameStr(obj)
            dutName=obj.hIP.hD.hCodeGen.getDutName();
            dutNameStr=downstream.tool.createFileNameFromDUTName(dutName);
        end

        function outNameStr=getShorterNameStr(~,inNameStr,numLimit)

            if length(inNameStr)>numLimit
                outNameStr=inNameStr(1:numLimit);
            else
                outNameStr=inNameStr;
            end
        end

        function outNameStr=removeUnderscoreInIPCoreName(~,inNameStr)


            inNameStr=regexprep(inNameStr,'^(_*)','');
            inNameStr=regexprep(inNameStr,'(_*)$','');

            outNameStr=regexprep(inNameStr,'(_)+','_');
        end

        function collectIPFileList(obj)

            obj.IPCoreSrcFileList={};
            obj.CodegenIPCoreSrcFileList={};
            obj.CustomIPCoreSrcFileList={};

            hCodeGen=obj.hIP.hD.hCodeGen;
            hCodeGen.getCodeGenInfo;
            hToolDriver=obj.hIP.hD.hToolDriver;
            codeGenDir=hCodeGen.CodegenDir;


            codegenSrcFileList=hToolDriver.getFinalSrcFileList;




            obj.CodegenIPCoreSrcFileList=cell(length(codegenSrcFileList),1);
            subModelData=obj.hIP.hD.hCodeGen.SubModelData;
            numSubModels=numel(subModelData);
            startIdx=1;
            for ii=1:numSubModels

                stopIdx=startIdx+numel(subModelData(ii).FileNames)-1;
                for jj=startIdx:stopIdx
                    srcFilePath=codegenSrcFileList{jj};

                    shortFilePath=strrep(srcFilePath,codeGenDir,'');
                    srcFileStruct=obj.createSrcFileStruct(...
                    srcFilePath,shortFilePath,subModelData(ii).LibName);
                    obj.CodegenIPCoreSrcFileList{jj}=srcFileStruct;
                end
                startIdx=stopIdx+1;
            end
            for ii=startIdx:length(codegenSrcFileList)
                srcFilePath=codegenSrcFileList{ii};

                shortFilePath=strrep(srcFilePath,codeGenDir,'');

                libName=obj.hIP.hD.hCodeGen.hCHandle.getParameter('vhdl_library_name');
                if strcmpi(libName,'work')
                    vhdlLibName=obj.DefaultLibName;
                else
                    vhdlLibName=libName;
                end
                srcFileStruct=obj.createSrcFileStruct(...
                srcFilePath,shortFilePath,vhdlLibName);
                obj.CodegenIPCoreSrcFileList{ii}=srcFileStruct;
            end


            toolSpecificSrcFileList=obj.colllectToolSpecificSrcFileList(hCodeGen);


            allCodegenSrcFileList=[toolSpecificSrcFileList;obj.CodegenIPCoreSrcFileList];


            customHDLFileList=obj.hIP.getIPCustomFileList;
            obj.CustomIPCoreSrcFileList=cell(length(customHDLFileList),1);
            for ii=1:length(customHDLFileList)
                srcFilePath=customHDLFileList{ii};
                [~,fileName,extName]=fileparts(srcFilePath);
                fileFullName=sprintf('%s%s',fileName,extName);
                srcFileStruct=obj.createSrcFileStruct(...
                srcFilePath,fileFullName,obj.DefaultLibName);
                obj.CustomIPCoreSrcFileList{ii}=srcFileStruct;
            end


            if obj.hIP.hasCustomIPTopHDLFile
                customIPTopHDLFileList=obj.hIP.getIPTopCustomFileList;
                for ii=1:length(customIPTopHDLFileList)
                    customTopHDLFilePath=customIPTopHDLFileList{ii};
                    [~,fileName,extName]=fileparts(customTopHDLFilePath);
                    fileFullName=sprintf('%s%s',fileName,extName);
                    srcFileStruct=obj.createSrcFileStruct(...
                    customTopHDLFilePath,fileFullName,obj.DefaultLibName);
                    allCodegenSrcFileList{end+1}=srcFileStruct;
                end
            end


            obj.verifyIPNameUniquification(obj.CustomIPCoreSrcFileList,allCodegenSrcFileList);


            obj.IPCoreSrcFileList=[obj.CustomIPCoreSrcFileList;allCodegenSrcFileList];
        end

        function toolSpecificSrcFileList=colllectToolSpecificSrcFileList(obj,hCodeGen)


            toolSpecificSrcFileList={};
        end

        function verifyIPNameUniquification(obj,customSrcFileList,codegenSrcFileList)



            hCodeGen=obj.hIP.hD.hCodeGen;


            obj.hIPNameService=coder.internal.lib.DistinctNameService();


            for ii=1:length(codegenSrcFileList)
                codegenFile=codegenSrcFileList{ii};
                codegenFilePath=codegenFile.FilePath;
                [~,nameStr,~]=fileparts(codegenFilePath);
                obj.hIPNameService.distinguishName(lower(nameStr));
            end




            for ii=1:length(customSrcFileList)
                customFile=customSrcFileList{ii};
                customFilePath=customFile.FilePath;
                [~,nameStr,extStr]=fileparts(customFilePath);
                if strcmpi(extStr,hCodeGen.getVHDLExt)||strcmpi(extStr,hCodeGen.getVerilogExt)
                    if~obj.hIPNameService.isDistinguishName(lower(nameStr))
                        error(message('hdlcommon:workflow:IPCustomNameConflict',customFilePath));
                    end
                end
            end
        end

        function srcFileStruct=createSrcFileStruct(~,filePath,shortFilePath,libName)



            srcFileStruct.FilePath=filePath;



            srcFileStruct.ShortFilePath=shortFilePath;


            srcFileStruct.LibName=libName;
        end

        function copyIPCoreHDLCode(obj)

            hCodeGen=obj.hIP.hD.hCodeGen;
            for ii=1:length(obj.IPCoreSrcFileList)
                srcFileStruct=obj.IPCoreSrcFileList{ii};
                srcFile=srcFileStruct.FilePath;
                [~,fileName,extName]=fileparts(srcFile);

                if~strcmpi(extName,hCodeGen.getVHDLExt)&&~strcmpi(extName,hCodeGen.getVerilogExt)
                    continue;
                end

                fileFullName=sprintf('%s%s',fileName,extName);
                sourcePath=srcFile;
                targetPath=fullfile(obj.IPCoreHDLPath,fileFullName);

                copyfile(sourcePath,targetPath,'f');
            end
        end

        function copyFPGADataCaptureCode(obj)
            srcPath=fullfile(obj.hIP.hD.hCodeGen.CodegenDir,'fpga_data_capture');
            dstPath=fullfile(obj.hIP.getIPCoreFolder,'fpga_data_capture');
            if exist(srcPath,'dir')
                mkdir(dstPath);
                copyfile(fullfile(srcPath,'*.m'),dstPath,'f');
                copyfile(fullfile(srcPath,'*.slx'),dstPath,'f');
                copyfile(fullfile(srcPath,'*.html'),dstPath,'f');
                copyfile(fullfile(srcPath,'*.png'),dstPath,'f');
            end
        end

        function createIPCoreFolder(obj)

            createIPCoreFolderBase(obj);
        end

        function ipFolder=createIPCoreFolderBase(obj)

            ipFolder=obj.hIP.getIPCoreFolder;
            isLiberoTool=obj.hIP.hD.isLiberoSoc;

            obj.IPCoreHDLPath=fullfile(ipFolder,obj.getHDLSrcFolder);
            downstream.tool.createDir(obj.IPCoreHDLPath);


            hT=obj.getTurnkeyObject;
            hBus=hT.hElab.getDefaultBusInterface;
            if~hBus.isEmptyAXI4SlaveInterface
                obj.IPCoreCHeaderPath=fullfile(ipFolder,obj.CHeaderFolder);
                downstream.tool.createDir(obj.IPCoreCHeaderPath);
            end


            if obj.hIP.getIPCoreReportStatus
                obj.IPCoreReportPath=fullfile(ipFolder,obj.DocFolder);
                downstream.tool.createDir(obj.IPCoreReportPath);
            end
        end


        function createCHeaderFile(obj)
            hT=obj.getTurnkeyObject;
            hBus=hT.hElab.getDefaultBusInterface;
            if~hBus.isEmptyAXI4SlaveInterface

                obj.hCHEmitter.generateCHeaderFile;
            end
        end


        function checkSpaceInIPCoreName(~,name)

            checkSpace=regexp(name,' ','once');
            if~isempty(checkSpace)
                ipcoreNameMsg=message('HDLShared:hdldialog:HDLWAIPCoreNameStr');
                error(message('hdlcommon:workflow:SpaceInName',name,ipcoreNameMsg.getString));
            end
        end

        function checkDashInIPCoreName(~,name)



            checkDash=regexp(name,'-','once');
            if~isempty(checkDash)
                ipcoreNameMsg=message('HDLShared:hdldialog:HDLWAIPCoreNameStr');
                error(message('hdlcommon:workflow:DashInName',ipcoreNameMsg.getString,name));
            end
        end

        function checkIPCoreNameLength(~,name,numLimit)

            if length(name)>numLimit
                ipcoreNameMsg=message('HDLShared:hdldialog:HDLWAIPCoreNameStr');
                error(message('hdlcommon:workflow:LongNameString',...
                ipcoreNameMsg.getString,numLimit,ipcoreNameMsg.getString,name));
            end
        end

        function checkUnderscoreInIPCoreName(~,name)



            checkUnderscore=regexp(name,'((__))|(^(_))|((_)$)','once');
            if~isempty(checkUnderscore)
                ipcoreNameMsg=message('HDLShared:hdldialog:HDLWAIPCoreNameStr');
                error(message('hdlcommon:workflow:UnderscoreInName',name,ipcoreNameMsg.getString));
            end
        end

    end

end



