




classdef InterfaceInternalIOAlteraSoC<hdlturnkey.interface.InterfaceInternalIOBase

    properties

    end

    methods

        function obj=InterfaceInternalIOAlteraSoC(varargin)


            obj=obj@hdlturnkey.interface.InterfaceInternalIOBase(varargin{:});


            obj.SupportedTool={'Altera QUARTUS II'};

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


        function generatePCoreQsysTCL(obj,fid,hElab)



            fprintf(fid,'## External Port\n');


            hdlturnkey.tool.generateQsysTclConduitPort(fid,obj.PortName,obj.PortWidth,obj.InterfaceType)

        end


        function generateRDInsertIPQsysTcl(obj,fid,~)


            hdlturnkey.tool.generateQsysTclInternalConnection(...
            fid,obj.InterfaceConnection,obj.PortName)

        end

    end

end



