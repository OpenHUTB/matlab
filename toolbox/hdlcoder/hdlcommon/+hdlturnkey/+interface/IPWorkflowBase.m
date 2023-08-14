




classdef(Abstract)IPWorkflowBase<handle


    properties
        InterfaceIPFolder=''
    end

    methods

        function obj=IPWorkflowBase()

        end

    end

    methods(Sealed=true)



        function isa=isIPInterface(~)
            isa=true;
        end

    end

    methods


        function isa=isAXI4StreamBasedInterface(~)
            isa=false;
        end
        function isa=isAXI4StreamInterface(~)
            isa=false;
        end
        function isa=isAXI4StreamVideoInterface(~)
            isa=false;
        end
        function isa=isAXI4MasterInterface(~)
            isa=false;
        end


        function isa=isIPCoreClockNeeded(~)
            isa=true;





        end


        function generateIPInterfaceVivadoTcl(obj,fid,~)

        end

        function interfaceStr=generateIPClockVivadoTcl(obj,interfaceStr)%#ok<*INUSL>

        end
        function generatePCoreMPD(obj,fid,~)

        end
        function generatePCoreQsysTCL(obj,fid,hElab)

        end
        function generatePCoreLiberoTCL(obj,fid,~,topModuleFile,~)

        end


        function generateRDInsertIPVivadoTcl(obj,fid,~)

        end
        function generateRDCleanUpIPVivadoTcl(obj,fid,~)

        end
        function ipMHSStr=generateRDInsertIPEDKMHS(obj,ipMHSStr)

        end
        function generateRDInsertIPQsysTcl(obj,fid,~)

        end

        function copyInterfaceIPToProjFolder(obj,targetFolder)



            if isempty(obj.InterfaceIPFolder)
                return;
            end


            downstream.tool.createDir(targetFolder);


            classPackage=class(obj);
            interfaceFileFullPath=which(classPackage);
            sourceDir=fileparts(interfaceFileFullPath,obj.InterfaceIPFolder);


            ip=dir([sourceDir,'*.zip']);

            for ii=1:length(ip)
                sourcePath=fullfile(sourceDir,ip(ii).name);
                targetPath=fullfile(targetFolder,ip(ii).name);
                copyfile(sourcePath,targetPath,'f');
            end

        end

    end

    methods(Access=protected)


    end

end


