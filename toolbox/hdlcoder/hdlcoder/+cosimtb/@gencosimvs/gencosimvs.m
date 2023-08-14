classdef gencosimvs<cosimtb.gencosim







    methods





        function this=gencosimvs(varargin)
            this=this@cosimtb.gencosim(varargin{:});
        end
    end



    methods

        function hl=checkEDALinkLicense(this)



            cosimOpt=this.getCurrentLinkOpt;
            hl=this.hasLicense;
            if~(strcmpi(cosimOpt,'vs')||strcmpi(cosimOpt,'Vivado Simulator'))
                error(message('hdlcoder:cosim:invalidcosimmodeloption'));
            end


            load_system(this.getLibraryName);
        end

        function linkSuffix=getCurrentLinkOpt(~)
            linkSuffix='vs';
        end

        function libName=getLibraryName(~)
            libName='vivadosimlib';
        end

        function cmd=getTclPreSimCommand(~)
            cmd='';
        end

        function cmd=getTclPostSimCommand(~)
            cmd='';
        end


        function cmdstr=getTclCmds(this,~)






            switch(this.getTargetLanguage)
            case 'vhdl'
                timePrecArg='--timeprecision_vhdl 1ps --override_timeprecision';
                compExe='xvhdl';
            case 'verilog'
                timePrecArg='--timescale 1ps/1ps --override_timeunit --override_timeprecision';
                compExe='xvlog';
            otherwise
                timePrecArg='';compExe='';
            end
            hdlDir=this.getCodeGenDir;


            if ispc
                topRelativeDir=regexprep(hdlDir,'\w+\\|\w+$','../');
            else
                topRelativeDir=regexprep(hdlDir,'\w+\/|\w+$','../');
            end
            hdlFileList=this.getEntityFileNames;
            dutName=this.getDutName;
            tclCmds={
''
            ['exec ',compExe,' ',sprintf('%s ',hdlFileList{:})]
            ['exec xelab ',dutName,' ',timePrecArg,' -dll --snapshot design -debug wave ']
''
            ['cd ',topRelativeDir]
''
'# The xsim.dir must be in PWD'
'# - save off existing xsim.dir'
'if {[file exists xsim.dir] == 1} {'
'    set mtime [file mtime xsim.dir]'
'    set mtimestamp [clock format $mtime -format %Y%m%d_%H%M%S]'
'    set xsim_savefile "xsim.dir.$mtimestamp"'
'    file rename xsim.dir $xsim_savefile'
'}'
'# - copy up newly elaborated xsim.dir area from project to the current working directory.'
            ['set proj_xsim_dir {',hdlDir,'/xsim.dir}']
'set proj_mtime [file mtime "$proj_xsim_dir/design"]'
'file copy -force $proj_xsim_dir .'
'file mtime xsim.dir $proj_mtime'
            };
            cmdstr=sprintf('%s\n',tclCmds{:});


        end

        function str=getLaunchBoxDisplayStr(this)
            msg=['Double-click to\nregenerate Vivado HDL DLL\nfor design ',this.getDutName];
            str=sprintf('disp(''%s'')',msg);
        end

        function cmd=getCosimLaunchCmd(~)
            cmd='CUSTOM_LAUNCHER';
        end
        function cmdStr=getCustomCosimLaunchCmd(this)
            tclfilename=[this.getTclCmdFcnName2,'.tcl'];
            openFcnCmds={
'cosimDirName = pwd;'
            ['cd ''',this.getCodeGenDir,''';']
            ['[s,r] = system(''vivado -mode batch -source ',tclfilename,''',''-echo'');']
'cd (cosimDirName);'
'clear cosimDirName;'
'if s'
            ['   error(''Failed to create Vivado HDL design DLL using script ',tclfilename,'.'');']
'end'
            };
            cmdStr=sprintf('%s\n',openFcnCmds{:});
        end







        function crPaths=getClockResetPaths(this)
            crPaths='';
            if this.dutHasClock
                crPaths=[crPaths,this.getClockName,';'];
            end
            if this.dutHasClockEnable
                crPaths=[crPaths,this.getClockEnableName,';'];
            end
            if this.dutHasReset
                crPaths=[crPaths,sprintf('%s;',this.getResetNames{:})];
            end
        end
        function crModes=getClockResetModes(this)
            modes=[];
            availModes=hdllinkddg.ClockResetRowSource.getStrValues('edge');
            if this.dutHasClock
                if this.isClockEdgeRising
                    entry=availModes(contains(availModes,'Rising'));
                else
                    entry=availModes(contains(availModes,'Falling'));
                end
                modes=[modes,hdllinkddg.ClockResetRowSource.convertPropValue('edge',entry{1})];
            end
            if this.dutHasClockEnable
                entry=availModes(contains(availModes,'Step 0 to 1'));
                modes=[modes,hdllinkddg.ClockResetRowSource.convertPropValue('edge',entry{1})];
            end
            if this.dutHasReset
                if this.getResetAssertLevel==1
                    entry=availModes(contains(availModes,'Step 1 to 0'));
                else
                    entry=availModes(contains(availModes,'Step 0 to 1'));
                end
                val=hdllinkddg.ClockResetRowSource.convertPropValue('edge',entry{1});
                rstmodes=repmat(val,size(this.getResetNames));
                modes=[modes,rstmodes];
            end
            crModes=mat2str(modes);
        end
        function crTimes=getClockResetTimes(this)


            tu2time=containers.Map({'fs','ps','ns','us','ms','s'},...
            {1e-15,1e-12,1e-9,1e-6,1e-3,1});
            tutime=tu2time(this.getTimingUnit);
            times=[];
            if this.dutHasClock
                times=[times,this.getClockPeriod];
            end
            if this.dutHasClockEnable
                times=[times,this.getClockEnableHigh];
            end
            if this.dutHasReset


                rsttimes=repmat(this.computeResetLength,size(this.getResetNames));
                times=[times,rsttimes];
            end

            crTimes=mat2str(times.*tutime);
        end
        function xsiData=getXSIData(this,portInfo)










            thePortDims=cellfun(@(x)({double(x)}),portInfo.PortDims');
            thePortTypes=portInfo.PortTypes';

            switch(this.getTargetLanguage)
            case 'vhdl',lang='vhdl';
            case 'verilog',lang='vlog';
            end




            prec="1ps";

            xsiData=createXsiData(...
            'lang',lang,...
            'prec',prec,...
            'types',thePortTypes,...
            'dims',thePortDims);
        end
    end



    methods

        function hl=hasLicense(~)
            tooldir=fullfile(matlabroot,'toolbox','edalink','extensions','vivadosim','vivadosim');
            if~(license('test','EDA_Simulator_Link')&&exist(tooldir,'dir'))
                error(message('hdlcoder:cosim:vivadosimnotinstalled'));
            end
            hl=true;
        end
    end
end




