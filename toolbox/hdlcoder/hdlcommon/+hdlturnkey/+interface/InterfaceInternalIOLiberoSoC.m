




classdef InterfaceInternalIOLiberoSoC<hdlturnkey.interface.InterfaceInternalIOBase

    properties

    end

    methods

        function obj=InterfaceInternalIOLiberoSoC(varargin)


            obj=obj@hdlturnkey.interface.InterfaceInternalIOBase(varargin{:});


            obj.SupportedTool={'Microchip Libero SoC'};

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


        function generatePCoreLiberoTCL(obj,fid,hElab,topModuleFile)



            fprintf(fid,'## External Port\n');


            hdlturnkey.tool.generateLiberoTclConduitPort(fid,obj.PortName,obj.PortWidth,obj.InterfaceType,topModuleFile)

        end
    end

end
