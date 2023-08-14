




classdef InterfaceInternalIOXilinx<hdlturnkey.interface.InterfaceInternalIOBase

    properties

    end

    methods

        function obj=InterfaceInternalIOXilinx(varargin)


            obj=obj@hdlturnkey.interface.InterfaceInternalIOBase(varargin{:});


            obj.SupportedTool={'Xilinx Vivado','Xilinx ISE'};

        end

    end


    methods

    end


    methods

    end


    methods

    end


    methods

    end


    methods

    end


    methods

    end



    methods


        function generatePCoreMPD(obj,fid,~)



            fprintf(fid,'## External Port\n');


            hdlturnkey.tool.generateEDKMPDPort(fid,obj.PortName,obj.PortWidth,obj.InterfaceType);
        end


        function generateRDInsertIPVivadoTcl(obj,fid,~)

            hdlturnkey.tool.generateVivadoTclInternalConnection(...
            fid,obj.InterfaceConnection,obj.PortName)
        end
        function ipMHSStr=generateRDInsertIPEDKMHS(obj,ipMHSStr)

            ipMHSStr=sprintf('%sPORT %s = %s\n',ipMHSStr,obj.PortName,obj.InterfaceConnection);
        end

    end

end



