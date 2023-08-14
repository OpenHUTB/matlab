classdef(Hidden)mw_subsystem<handle




    properties


        mwcfg;



        ucfg;



        mwpath='';



        mwblkname='';



        mwblkUVMVCodeInfo;



        pkginfo;

        IsDUTBuild;

        UVMComponent;

        UVMBuildDir;

        common_dpi_pkg='';
    end

    properties(Access=private)


        input_connections=containers.Map;



        output_connections=containers.Map;
    end

    methods
        function this=mw_subsystem(varargin)


            this.pkginfo=what('+uvmcodegen');
            p=inputParser;
            p.KeepUnmatched=true;
            addParameter(p,'mwpath','');
            addParameter(p,'mwcfg',0);
            addParameter(p,'ucfg','');
            addParameter(p,'IsDUTBuild',false);
            addParameter(p,'UVMComponent','uvm_testbench');

            parse(p,varargin{:});

            this.mwcfg=p.Results.mwcfg;
            this.ucfg=p.Results.ucfg;
            this.mwpath=p.Results.mwpath;
            this.IsDUTBuild=p.Results.IsDUTBuild;
            this.UVMComponent=p.Results.UVMComponent;
            this.UVMBuildDir=p.Results.ucfg.component_paths(this.UVMComponent);

            if(isempty(this.mwpath))
                this.mwblkname='generic';
            else
                this.mwblkname=get_param(this.mwpath,'Name');
                this.build();
            end


            if isempty(this.common_dpi_pkg)&&~isempty(this.mwcfg.sl2uvmtopo.DG.Nodes.UVMCodeInfo_Obj{1})
                this.common_dpi_pkg=this.mwcfg.sl2uvmtopo.DG.Nodes.UVMCodeInfo_Obj{1}.CompPortInfo.CommonDpiPkgName;
            end
        end

        function status=build(this)



            hdlverifierfeature('IS_CODEGEN_FOR_UVM',true);
            c=onCleanup(@()hdlverifierfeature('IS_CODEGEN_FOR_UVM',false));
            c1=onCleanup(@()hdlverifierfeature('UVM_DPIBUILD_DIR',''));
            if this.IsDUTBuild
                hdlverifierfeature('IS_CODEGEN_FOR_UVMDUT',true);
                c2=onCleanup(@()hdlverifierfeature('IS_CODEGEN_FOR_UVMDUT',false));
            end
            if strcmpi(this.UVMComponent,'sequence')
                hdlverifierfeature('IS_CODEGEN_FOR_UVMSEQ',true);
                c4=onCleanup(@()hdlverifierfeature('IS_CODEGEN_FOR_UVMSEQ',false));
            end
            hdlverifierfeature('SL_BLOCK_NAME',this.mwblkname);
            c3=onCleanup(@()hdlverifierfeature('SL_BLOCK_NAME',''));

            if strcmp('ModelReference',get_param(this.mwpath,'BlockType'))






                rtwbuild(get_param(this.mwpath,'ModelName'));
            else
                rtwbuild(this.mwpath);
            end

            this.mwblkUVMVCodeInfo=load(fullfile(hdlverifierfeature('UVM_DPIBUILD_DIR'),'UVMCodeInfo.mat'));

            l_checkST_constraints(cell2mat(this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.OutputFunction.ArgumentST(2:end)),...
            this.mwblkUVMVCodeInfo.UVMCodeInfo.TimingInfo.BaseRate,...
            this.UVMComponent);
            this.mwcfg.sl2uvmtopo.SetNodeUVMCodeInfo(Simulink.ID.getSID(this.mwpath),this.mwblkUVMVCodeInfo);


            copyfile(this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMBuildInfo.DPIPkg,...
            this.UVMBuildDir,'f');


            this.ucfg.setDirFromDPIArtifact(n_getFile(this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMBuildInfo.DPIPkg),this.UVMBuildDir);

            switch computer
            case 'PCWIN64'
                dllExt='_win64.dll';
            otherwise
                dllExt='.so';
            end
            if exist([this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMBuildInfo.SharedLib,dllExt],'file')==2


                copyfile([this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMBuildInfo.SharedLib,dllExt],...
                this.UVMBuildDir,'f');
            end
            this.ucfg.setDirFromDPIArtifact(n_getFile(this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMBuildInfo.SharedLib),this.UVMBuildDir);

            if this.IsDUTBuild

                copyfile(this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMBuildInfo.DPIModule,...
                this.UVMBuildDir,'f');
                this.ucfg.setDirFromDPIArtifact(n_getFile(this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMBuildInfo.DPIModule),this.UVMBuildDir);
            end

            function str=n_getFile(filefullpath)
                [~,f,e]=fileparts(filefullpath);
                str=[f,e];
            end

        end

        function cellarry=inports(this)


            iports=find_system(this.mwpath,'SearchDepth',1,'BlockType','Inport');
            cellarry=get_param(iports,'Name');
        end

        function cellarry=outports(this)



            oports=find_system(this.mwpath,'SearchDepth',1,'BlockType','Outport');
            cellarry=get_param(oports,'Name');
        end

        function ports=getSrcPort(this,port)


            ports=this.input_connections(char(port));

        end

        function ports=getDstPort(this,port)


            ports=this.output_connections(char(port));
        end


        function handles=getAllSrcs(this)


            pc=get_param(this.mwpath,'PortConnectivity');
            handles=unique([pc(1:end).SrcBlock]);
        end

        function handles=getAllDsts(this)


            pc=get_param(this.mwpath,'PortConnectivity');
            handles=unique([pc(1:end).DstBlock]);
        end

        function status=addInSrc(this,myport,srchdl,srcport)


            this.input_connections(char(myport))=[struct('srchandle',srchdl,'srcport',srcport)];
        end
    end
end


function l_checkST_constraints(SamplePeriodArray,SystemBaseRate,UVMComponent)

    if any(strcmp(UVMComponent,{'sequence','scoreboard'}))




        assert(numel(unique(SamplePeriodArray/SystemBaseRate))==1&&any(SamplePeriodArray<=SystemBaseRate),message('HDLLink:uvmgenerator:UnsupportedMultirate'));
    else


        assert(any(SamplePeriodArray<=SystemBaseRate),message('HDLLink:uvmgenerator:UnsupportedMultirate'));
    end
end
