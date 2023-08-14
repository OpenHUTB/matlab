classdef(Hidden)mwconfig<handle
    properties


        build_path;

        abs_build_path;



        sldut_path;



        sldut_name;


        sl2uvmtopo;
    end

    methods
        function this=mwconfig(sldut_path,varargin)


            p=inputParser;
            p.KeepUnmatched=true;
            addRequired(p,'sldut_path');
            addParameter(p,'build_path','');
            addParameter(p,'abs_build_path','');

            parse(p,sldut_path,varargin{:});

            this.sldut_path=p.Results.sldut_path;
            this.sldut_name=get_param(p.Results.sldut_path,'Name');
            this.sl2uvmtopo=uvmcodegen.SL2UVMTopo(bdroot(p.Results.sldut_path));

            if(isempty(p.Results.build_path))
                this.build_path=[bdroot,'_uvmbuild'];
            else
                this.build_path=p.Results.build_path;
            end
            this.abs_build_path=p.Results.abs_build_path;
        end

        function CheckSTCntr4DrvAndMon(obj)



















            assert(abs(obj.sl2uvmtopo.getSeqBR-obj.sl2uvmtopo.getScrBR)<eps(obj.sl2uvmtopo.getScrBR),...
            message('HDLLink:uvmgenerator:FundSTMustBeEqual','sequence',obj.sl2uvmtopo.seq,num2str(obj.sl2uvmtopo.getSeqBR),...
            'scoreboard',obj.sl2uvmtopo.scr,num2str(obj.sl2uvmtopo.getScrBR)));















            assert(isempty(obj.sl2uvmtopo.drv)||abs(obj.sl2uvmtopo.getDrvBR-obj.sl2uvmtopo.getDutBR)<eps(obj.sl2uvmtopo.getDutBR),...
            message('HDLLink:uvmgenerator:FundSTMustBeEqual','Driver',obj.sl2uvmtopo.drv,num2str(obj.sl2uvmtopo.getDrvBR),...
            'DUT',obj.sl2uvmtopo.dut,num2str(obj.sl2uvmtopo.getDutBR)));

            assert(isempty(obj.sl2uvmtopo.mon)||abs(obj.sl2uvmtopo.getMonBR-obj.sl2uvmtopo.getDutBR)<eps(obj.sl2uvmtopo.getDutBR),...
            message('HDLLink:uvmgenerator:FundSTMustBeEqual','Monitor',obj.sl2uvmtopo.mon,num2str(obj.sl2uvmtopo.getMonBR),...
            'DUT',obj.sl2uvmtopo.dut,num2str(obj.sl2uvmtopo.getDutBR)));

            assert(isempty(obj.sl2uvmtopo.drv)||isempty(obj.sl2uvmtopo.mon)||abs(obj.sl2uvmtopo.getMonBR-obj.sl2uvmtopo.getDrvBR)<eps(obj.sl2uvmtopo.getDrvBR),...
            message('HDLLink:uvmgenerator:FundSTMustBeEqual','Driver',obj.sl2uvmtopo.drv,num2str(obj.sl2uvmtopo.getDrvBR),...
            'Monitor',obj.sl2uvmtopo.mon,num2str(obj.sl2uvmtopo.getMonBR)));
        end
    end

end
