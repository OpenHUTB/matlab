


classdef GenMatlabVivadoSimTb<emlhdlcoder.hdlverifier.GenMatlabCosimTb
    properties(Constant)
        SimulatorName=message('hdlcoder:hdlverifier:VivadoSimulator').getString;
    end

    methods
        function this=GenMatlabVivadoSimTb(varargin)
            this=this@emlhdlcoder.hdlverifier.GenMatlabCosimTb(varargin{:});
        end

...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...


        function cmd=getTclPreSimCommand(~)
            cmd='';
        end

        function cmd=getLaunchCmd(~)
            cmd='CUSTOM_LAUNCHER';
        end

        function launchCmdsStr=getCustomCosimLaunchCmd(this,tclcmds)

            tclCmdFullFileName=regexprep(this.getTclFileWithPath,'\.m$','.tcl');
            fid=fopen(tclCmdFullFileName,'w');
            fwrite(fid,sprintf('%s\n',tclcmds));
            fclose(fid);


            launchCmdsCell={
            ['[s,r] = system(''vivado -mode batch -source ',tclCmdFullFileName,''',''-echo'');']
'if s'
            ['   error(''Failed to create Vivado HDL design DLL using script ',tclCmdFullFileName,'.'');']
'end'
            };
            launchCmdsStr=sprintf('%s\n',launchCmdsCell{:});
        end


        function cmdstr=getTclCmds(this)
            switch(lower(this.getTargetLanguage))
            case 'vhdl'
                timePrecArg='--timeprecision_vhdl 1ps --override_timeprecision';
                compExe='xvhdl';
            case 'verilog'
                timePrecArg='--timescale 1ps/1ps --override_timeunit --override_timeprecision';
                compExe='xvlog';
            otherwise
                timePrecArg='';compExe='';
            end
            dutName=this.getDutName;
            tclCmds={
''
'# Save off existing xsim.dir'
'if {[file exists xsim.dir] == 1} {'
'    set mtime [file mtime xsim.dir]'
'    set mtimestamp [clock format $mtime -format %Y%m%d_%H%M%S]'
'    set xsim_savefile "xsim.dir.$mtimestamp"'
'    file rename xsim.dir $xsim_savefile'
'}'
''
            [' set hdlsrc {',this.getCodeGenDir,'}']
            [sprintf(['exec ',compExe,' $hdlsrc/%s\n'],this.getEntityFileNames{:})]
            ['exec xelab ',dutName,' ',timePrecArg,' -dll --snapshot design -debug wave ']
''
            };
            cmdstr=sprintf('%s\n',tclCmds{:});
        end

        function str=getHDLSimulator(~)
            str='Vivado Simulator';
        end








        function crNames=getClockResetSignals(this)
            if this.dutHasClock,clkn={this.getClockName};
            else,clkn={};
            end
            if this.dutHasClockEnable,clkenn={this.getClockEnableName};
            else,clkenn={};
            end
            if this.dutHasReset,rstn={this.getResetName};
            else,rstn={};
            end
            crNames=[clkn,clkenn,rstn];
            crNames=crNames(~cellfun('isempty',crNames));
            crNames=l_asString(crNames,'cellOfStrings');
        end

        function crModes=getClockResetTypes(this)


            if this.dutHasClock
                clkm={'Active Rising Edge Clock'};
            else
                clkm={};
            end

            if this.dutHasClockEnable








                if this.isClkEnableAtInputDataRate
                    error('We cannot cosimulate a design using Vivado Simulator that requires a periodic clock enable.');
                end
                clkenm={'Step 0 to 1'};
            else
                clkenm={};
            end

            if this.dutHasReset
                switch this.getResetAssertLevel
                case 'ActiveHigh'
                    rstm={'Step 1 to 0'};
                otherwise
                    rstm={'Step 0 to 1'};
                end
            else
                rstm={};
            end
            crModes=[clkm,clkenm,rstm];
            crModes=crModes(~cellfun('isempty',crModes));
            crModes=l_asString(crModes,'cellOfStrings');
        end

        function crTimes=getClockResetTimes(this)
            if this.dutHasClock,clkt={this.getClockPeriod,this.getTimingUnit};
            else,clkt={};
            end
            if this.dutHasClockEnable,clkent={this.getClockEnableHigh,this.getTimingUnit};
            else,clkent={};
            end
            if this.dutHasReset,rstt={this.computeResetLength,this.getTimingUnit};
            else,rstt={};
            end
            crTimes={clkt,clkent,rstt};
            crTimes=crTimes(~cellfun('isempty',crTimes));
            crTimes=l_asString(crTimes,'cellOfCellOfTimes');
        end

        function xsiData=getXSIData(this)








            switch(lower(this.getTargetLanguage))
            case 'vhdl',lang='vhdl';
            case 'verilog',lang='vlog';
            end


            types={};dims={};didx=0;
            for m=1:length(this.codeInfo.hdlDutPortInfo)
                portInfo=this.codeInfo.hdlDutPortInfo(m);
                if strcmpi(portInfo.Kind,'data')
                    didx=didx+1;
                    [types{didx},dims{didx}]=l_getCosimTypeAndDims(portInfo.TypeInfo);%#ok<AGROW> 
                end
            end




            prec='1ps';

            xsiPV={'lang',lang,'prec',prec,'types',types,'dims',dims};



            xsiAsStringMap=containers.Map(...
            {'design','lang','prec','types','dims','rstnames','rstvals','rstdurs'},...
            {'string','string','string','cellOfStrings','cellOfMat','cellOfStrings','cellOfNums','cellOfNums'});
            xsiData='';
            xsiData=[xsiData,'createXsiData( ...',newline];
            for idx=1:2:length(xsiPV)
                p=xsiPV{idx};
                v=xsiPV{idx+1};
                xsiData=[xsiData,sprintf('\t''%s'', %s, ...\n',p,l_asString(v,xsiAsStringMap(p)))];%#ok<AGROW> 
            end
            xsiData(end-5)=' ';
            xsiData=[xsiData,');',newline];
        end
    end
end




function str=l_asString(orig,kind)
    if isempty(orig)
        switch(kind)




        case 'string',str='';
        case 'cellOfStrings',str='';
        case 'cellOfNums',str='';
        case 'cellOfMat',str='';
        case 'arrayOfNums',str='';
        case 'cellOfCellOfTimes',str='';
        otherwise,error('(internal) asString: bad kind.');
        end
    else
        switch(kind)
        case 'string'
            str=['''',orig,''''];
        case 'cellOfStrings'
            str=['{',sprintf('''%s'' ',orig{:}),'}'];
        case 'cellOfNums'
            str=['{',sprintf('[%d] ',orig{:}),'}'];
        case 'cellOfMat'
            matStr=cellfun(@(x)(mat2str(x)),orig,'UniformOutput',false);
            str=['{',sprintf('%s ',matStr{:}),'}'];
        case 'arrayOfNums'
            str=mat2str(orig);
        case 'cellOfCellOfTimes'
            tmp=cellfun(@(x)(['{',sprintf('%d,''%s''',x{:}),'}']),orig,'UniformOutput',false);
            str=['{',sprintf('%s ',tmp{:}),'}'];
        otherwise
            error('(internal) asString: bad kind.');
        end
    end
end

function[t,d]=l_getCosimTypeAndDims(tInfo)
    if tInfo.isfloat
        t='Real';
    else
        t='Logic';
    end
    switch t
    case 'Logic'
        if tInfo.isscalar
            d=tInfo.wordsize;
        else
            d=[tInfo.dims,tInfo.wordsize];
        end
    otherwise
        d=tInfo.dims;
    end
end

