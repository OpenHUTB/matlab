



classdef IPEmitterEDK<hdlturnkey.ip.IPEmitter


    properties


        hPAOEmitter=[];
        hMPDEmitter=[];


        IPCoreDataPath='';

    end

    properties

        hReport=[];
    end


    properties(Access=protected)

    end

    properties(Constant)


        defaultIpCoreVer='v1.00.a';


        DataFolder='data';



        PCorePostfix='v2_1_0';


        EDKRepositFolder={'edk_repository','pcores'};
    end


    methods

        function obj=IPEmitterEDK(hIP)


            obj=obj@hdlturnkey.ip.IPEmitter(hIP);

            obj.hReport=hdlturnkey.ip.IPReportEDK(obj);

            obj.hPAOEmitter=hdlturnkey.ip.PAOEmitter(obj);
            obj.hMPDEmitter=hdlturnkey.ip.MPDEmitter(obj);

        end

        function IPEmitterStruct=getIPEmitterStruct(obj)

            IPEmitterStruct=getIPEmitterStruct@hdlturnkey.ip.IPEmitter(obj);
            IPEmitterStruct.IPCoreDataPath=obj.IPCoreDataPath;
        end

        function loadIPEmitterStruct(obj,IPEmitterStruct)

            loadIPEmitterStruct@hdlturnkey.ip.IPEmitter(obj,IPEmitterStruct);
            obj.IPCoreDataPath=IPEmitterStruct.IPCoreDataPath;
        end

        function generateIPCore(obj)


            collectIPFileList(obj);


            createIPCoreFolder(obj);


            obj.hPAOEmitter.generatePAOFile;
            obj.hMPDEmitter.generateMPDFile;


            createCHeaderFile(obj);


            copyIPCoreHDLCode(obj);


            if obj.hIP.getIPCoreReportStatus
                obj.hReport.generateReport;
            end


            copyToIPRepository(obj);

        end


        function ipCoreName=getDefaultIPCoreName(obj)


            ipCoreNameStr=getDefaultIPCoreName@hdlturnkey.ip.IPEmitter(obj);

            ipCoreName=lower(ipCoreNameStr);
        end

        function folderName=getIPCoreFolderName(obj)


            ipVerStr=strrep(obj.hIP.getIPCoreVersion,'.','_');
            folderName=sprintf('%s_%s',obj.hIP.getIPCoreName,ipVerStr);
        end


        function validateIPCoreName(obj,name)


            validateIPCoreName@hdlturnkey.ip.IPEmitter(obj,name);

            detectUpperCase=regexp(name,'[A-Z]+','once');
            if~isempty(detectUpperCase)
                error(message('hdlcommon:workflow:XilinxIPNameUpperCase'));
            end

        end

        function validateIPCoreVer(~,ver)



            verCell=regexp(ver,'\.','split');
            if length(verCell)~=3
                error(message('hdlcommon:workflow:XilinxIPVer'));
            end
            majorRev=verCell{1};
            if isempty(regexp(majorRev,'\<v\d\>','once'))
                error(message('hdlcommon:workflow:XilinxIPVer'));
            end
            minorRev=verCell{2};
            if isempty(regexp(minorRev,'\<\d{2}\>','once'))
                error(message('hdlcommon:workflow:XilinxIPVer'));
            end
            moreRev=verCell{3};
            if isempty(regexp(moreRev,'\<[a-z]{1}\>','once'))
                error(message('hdlcommon:workflow:XilinxIPVer'));
            end
        end
    end

    methods(Access=protected)

        function createIPCoreFolder(obj)

            ipFolder=createIPCoreFolderBase(obj);

            obj.IPCoreDataPath=fullfile(ipFolder,obj.DataFolder);
            downstream.tool.createDir(obj.IPCoreDataPath);
        end

        function copyToIPRepository(obj)



            ipRepositoryPath=obj.hIP.getIPRepository;
            if isempty(ipRepositoryPath)
                return;
            end


            sourcePath=obj.hIP.getIPCoreFolder;


            pcoreFolderName=obj.getIPCoreFolderName;
            targetPath=fullfile(ipRepositoryPath,obj.EDKRepositFolder{:},...
            pcoreFolderName);


            downstream.tool.createDir(fileparts(targetPath));
            copyfile(sourcePath,targetPath,'f');
        end

    end

end


