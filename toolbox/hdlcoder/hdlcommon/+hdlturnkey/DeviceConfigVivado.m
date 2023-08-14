


classdef DeviceConfigVivado<handle


    properties

        DevicePositionInChain=0;


        TclFileName='';
        BitstreamFileName='';


        hTurnkey=[];

    end

    methods

        function obj=DeviceConfigVivado(devicePositionInChain)


            obj.DevicePositionInChain=devicePositionInChain;
        end

        function[status,result]=configureFPGA(obj,hTurnkey)


            obj.hTurnkey=hTurnkey;
            status=true;
            result='';


            obj.generateVivadoTclFile;


            [status,result]=hdlturnkey.DeviceConfigVivado.runVivadoTclFile(...
            obj.hTurnkey,obj.VivadoTclFileName);
        end

    end

    methods(Access=protected,Hidden=true)

        function generateVivadoFile(obj)



            [fid,obj.TclFileName]=...
            hdlturnkey.DeviceConfigVivado.createVivadoTclFile(obj.hTurnkey);


            obj.printVivadoTclCmd(fid);


            fclose(fid);

        end

        function printVivadoTclCmd(obj,fid)


        end

    end

    methods(Static)

        function[fid,tclFilePath]=createVivadoTclFile(hTurnkey)



            [dirName,fileName,~]=fileparts(hTurnkey.hD.getMCSFilePath);
            tclFilePath=fullfile(dirName,[fileName,'.tcl']);


            fid=downstream.tool.createTclFile(tclFilePath);
        end

        function[status,result]=runVivadoTclFile(hTurnkey,tclFilePath)


            toolCmdStr=hTurnkey.hD.hToolDriver.hTool.getToolTclCmdStrfull;
            [status,result]=downstream.tool.runTclFile(tclFilePath,toolCmdStr);
        end
    end

end
