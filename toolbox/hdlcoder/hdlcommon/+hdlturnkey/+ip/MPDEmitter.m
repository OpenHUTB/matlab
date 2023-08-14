


classdef MPDEmitter<handle


    properties

        MPDFileName='';
        MPDFilePath='';


        hIPEmitter=[];

    end

    methods

        function obj=MPDEmitter(hIPEmitter)


            obj.hIPEmitter=hIPEmitter;

        end

        function generateMPDFile(obj)

            fid=initialMPDFile(obj);


            generateMPDInit(obj,fid);


            generateInterfaceMPD(obj,fid);

            fclose(fid);
        end

    end

    methods(Access=protected,Hidden=true)

        function fid=initialMPDFile(obj)

            obj.MPDFileName=sprintf('%s_%s.mpd',obj.hIPEmitter.hIP.getIPCoreName,...
            obj.hIPEmitter.PCorePostfix);


            obj.MPDFilePath=fullfile(obj.hIPEmitter.IPCoreDataPath,obj.MPDFileName);


            fid=createFile(obj,obj.MPDFilePath);
            printTitle(obj,fid);

        end

        function generateMPDInit(obj,fid)



            hCodeGen=obj.hIPEmitter.hIP.hD.hCodeGen;
            if hCodeGen.isVHDL
                targetL='VHDL';
            else
                targetL='VERILOG';
            end


            fprintf(fid,'BEGIN %s\n\n',obj.hIPEmitter.hIP.getIPCoreName);

            fprintf(fid,'## Peripheral Options\n');
            fprintf(fid,'OPTION IPTYPE = PERIPHERAL\n');
            fprintf(fid,'OPTION IMP_NETLIST = TRUE\n');
            fprintf(fid,'OPTION HDL = %s\n',targetL);
            fprintf(fid,'OPTION ARCH_SUPPORT_MAP = (OTHERS = DEVELOPMENT)\n');
            fprintf(fid,'OPTION IP_GROUP = MICROBLAZE:PPC:USER\n');
            fprintf(fid,'OPTION DESC = %s\n',obj.hIPEmitter.hIP.getIPCoreName);
            fprintf(fid,'OPTION LONG_DESC = %s\n',obj.hIPEmitter.hIP.getIPCoreName);
            fprintf(fid,'\n');


            fprintf(fid,'PORT IPCORE_CLK = "", DIR = I, SIGIS = CLK, ASSIGNMENT = REQUIRE\n');
            fprintf(fid,'PORT IPCORE_RESETN = "", DIR = I, SIGIS = RST, ASSIGNMENT = REQUIRE\n');
            fprintf(fid,'\n');

        end

        function generateInterfaceMPD(obj,fid)


            hTurnkey=obj.hIPEmitter.hIP.hD.hTurnkey;
            interfaceIDList=hTurnkey.getSupportedInterfaceIDList;

            for ii=1:length(interfaceIDList)
                interfaceID=interfaceIDList{ii};
                hInterface=hTurnkey.getInterface(interfaceID);


                if~hInterface.isIPInterface
                    continue;
                end


                if~hInterface.isInterfaceInUse(hTurnkey)
                    continue;
                end


                hElab=obj.hIPEmitter.hIP.hD.hTurnkey.hElab;
                hInterface.generatePCoreMPD(fid,hElab);

            end
        end

        function fid=createFile(~,filePath)

            fid=fopen(filePath,'w');
            if fid==-1
                error(message('hdlcommon:workflow:UnableCreateConstrainFile',filePath));
            end
        end

        function printTitle(obj,fid)
            fprintf(fid,'##############################################################################\n');
            fprintf(fid,'## File Name:         %s\n',obj.MPDFilePath);
            fprintf(fid,'## Description:       Microprocessor Peripheral Description\n');
            fprintf(fid,'## Created:           %s\n',datestr(now,'yyyy-mm-dd HH:MM:SS'));
            fprintf(fid,'##############################################################################\n\n');
        end

    end


end






