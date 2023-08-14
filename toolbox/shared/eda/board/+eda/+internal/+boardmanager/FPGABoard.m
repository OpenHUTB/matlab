



classdef FPGABoard<matlab.mixin.Copyable

    properties
        BoardName;
        BoardFile;
        FPGA;



        FILBoardClass;
        TurnkeyBoardClass;
    end

    properties
        WorkflowOptions=[];
        ConnectionOptions=[];
        ProgramFPGAOptions=[];
        IsBoardCopyDisabled=false;
        IsBoardValidateDisabled=false;
    end

    methods
        function obj=FPGABoard
            obj.BoardName='My Board';
            obj.BoardFile='tmpfile';
            obj.FILBoardClass='';
            obj.TurnkeyBoardClass='';
            obj.FPGA=eda.internal.boardmanager.FPGA;
        end

        function set.BoardName(obj,name)
            if~ischar(name)
                error(message('EDALink:boardmanager:InvalidBoardName'));
            end
            newName=strtrim(name);
            if isempty(newName)
                error(message('EDALink:boardmanager:EmptyBoardName'));
            end
            obj.BoardName=newName;
        end
        function set.BoardFile(obj,name)
            assert(ischar(name));
            obj.BoardFile=name;
        end
        function validate(obj)
            obj.FPGA.validate;
        end

        function r=isFILCompatible(obj)
            r=obj.FPGA.hasFILInterface;
        end
        function r=isTurnkeyCompatible(obj)
            r=obj.FPGA.hasUserIO;
        end
        function r=getFILConnectionOptions(obj)
            tmp=obj.FPGA.getFILInterface;
            r=cell(1,numel(tmp));
            for m=1:numel(tmp)
                r{m}.Name=tmp{m}.ConnectionDispName;
                r{m}.Communication_Channel=tmp{m}.Communication_Channel;
                r{m}.RTIOStreamLibName=tmp{m}.RTIOStreamLibName;
                r{m}.RTIOStreamParams=tmp{m}.RTIOStreamParams;
                r{m}.ProtocolParams=tmp{m}.ProtocolParams;
                r{m}.GenerateOnlyChIf=tmp{m}.GenerateOnlyChIf;
                r{m}.PostCodeGenerationFcn=tmp{m}.PostCodeGenerationFcn;
                if strcmpi(tmp{m}.Name,'PSEthernet')
                    r{m}.TclScript=tmp{m}.TclScript;
                    r{m}.ConstraintFile=tmp{m}.ConstraintFile;
                    r{m}.DeviceTree=tmp{m}.DeviceTree;
                    r{m}.FILCoreInterface=tmp{m}.FILCoreInterface;
                    r{m}.HasMWDMA=tmp{m}.HasMWDMA;
                end
            end
        end
        function r=getFILFPGAToolName(obj)
            if strcmpi(obj.FPGA.Vendor,'microsemi')
                r='Microchip Libero SoC';
            elseif strcmpi(obj.FPGA.Vendor,'altera')
                switch obj.FPGA.Family







                case 'Cyclone 10 GX'
                    r='Intel Quartus Pro';
                otherwise
                    r='Altera Quartus II';
                end
            else
                vivadoFamilies=eda.internal.fpgadevice.getXilinxVivadoFPGAFamilies;
                switch obj.FPGA.Family
                case vivadoFamilies
                    r='Xilinx Vivado';
                otherwise
                    r='Xilinx ISE';
                end
            end
        end
    end
    methods(Access=protected)

        function cpObj=copyElement(obj)

            cpObj=copyElement@matlab.mixin.Copyable(obj);

            cpObj.FPGA=copy(obj.FPGA);
        end
    end
end
