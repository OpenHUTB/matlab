classdef(Hidden)SimulinkUVM<handle



    properties(GetAccess=public,SetAccess=private)


        mcfg;



        ucfg;



        mwblkcodeinfo;



        seqblk_path;



        scrblk_path;

        drvblk_path;
        monblk_path;

        gldblk_path;


        seqname;



        scrname;
    end

    methods
        function this=SimulinkUVM(varargin)


            p=inputParser;
            p.KeepUnmatched=true;
            addParameter(p,'mwcfg','');
            addParameter(p,'ucfg','');
            addParameter(p,'seqname','');
            addParameter(p,'scrname','');
            addParameter(p,'seqblk_path','');
            addParameter(p,'scrblk_path','');
            addParameter(p,'drvblk_path','');
            addParameter(p,'monblk_path','');
            addParameter(p,'gldblk_path','');

            parse(p,varargin{:});

            this.mcfg=p.Results.mwcfg;
            this.ucfg=p.Results.ucfg;
            this.seqname=p.Results.seqname;
            this.scrname=p.Results.scrname;

            this.seqblk_path=p.Results.seqblk_path;
            this.scrblk_path=p.Results.scrblk_path;

            this.drvblk_path=p.Results.drvblk_path;
            this.monblk_path=p.Results.monblk_path;

            this.gldblk_path=p.Results.gldblk_path;


            this.mcfg.sl2uvmtopo.InitializeDG(this.mcfg.sldut_path,this.seqblk_path,this.scrblk_path,...
            'drv',this.drvblk_path,...
            'mon',this.monblk_path,...
            'gld',this.gldblk_path);
        end
    end
end
