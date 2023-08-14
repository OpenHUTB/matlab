function ret=hardware(name,targettype)



































































    if nargin==2&&coder.internal.isScalarText(name)&&name=="TargetType"

        targettype=validatestring(targettype,{'tf','mlc'},2);
    else
        narginchk(0,1);
        targettype='all';
    end
    if nargin==1

        name=convertStringsToChars(name);

        if name=="MATLAB Host Computer"
            ret=[];
            return;
        end


        [~,hwList,tfList]=coder.internal.getHardwareAndTargetFrameworkNames();
        if isempty(hwList)&&isempty(tfList)
            error('coder:hardware:NoHardware',i_getSpkgInstallMsg);
        end
        name=validatestring(name,[hwList,tfList]);
        if ismember(name,hwList)
            ret=coder.Hardware(name);
        elseif ismember(name,tfList)
            ret=coder.TargetPackageHardware(name);
        else
            ret=coder.Hardware(name);
        end
    elseif nargin==0||nargin==2

        [combinedList,hwList,tfList]=coder.internal.getHardwareAndTargetFrameworkNames();
        switch targettype
        case 'mlc'
            ret=hwList;
        case 'tf'
            ret=tfList;
        otherwise
            ret=combinedList;
        end
        ret{end+1}='MATLAB Host Computer';
    end
end


function str=i_getSpkgInstallMsg()
    str='\nThere are no hardware support packages installed that support Processor-in-the-Loop (PIL) simulation.\n';
    str=[str,'The following support packages provide support for PIL simulation with MATLAB coder:\n\n'];
    str=[str,i_insertHyperlink('Embedded Coder Support Package for BeagleBone Black Hardware',...
    'matlab.addons.supportpackage.internal.explorer.showSupportPackages(''EC_BEAGLEBONE'', ''tripwire'')')];
    str=[str,'\n'];
    str=[str,i_insertHyperlink('Embedded Coder Support Package for Xilinx Zynq-7000 Platform',...
    'matlab.addons.supportpackage.internal.explorer.showSupportPackages(''ECZYNQ7000'', ''tripwire'')')];
    str=[str,'\n'];
    str=[str,i_insertHyperlink('Embedded Coder Support Package for Altera SoC Platform',...
    'matlab.addons.supportpackage.internal.explorer.showSupportPackages(''EC_ALTERA_SOC'', ''tripwire'')')];
    str=[str,'\n'];
    str=[str,i_insertHyperlink('Embedded Coder Support Package for ARM Cortex-A Processors',...
    'matlab.addons.supportpackage.internal.explorer.showSupportPackages(''ECCORTEXA'', ''tripwire'')')];
    str=sprintf([str,'\n']);
    str=[str,i_insertHyperlink('Embedded Coder Support Package for ARM Cortex-M Processors',...
    'matlab.addons.supportpackage.internal.explorer.showSupportPackages(''ECCORTEXM'', ''tripwire'')')];
    str=sprintf([str,'\n']);
    str=[str,i_insertHyperlink('Embedded Coder Support Package for STMicroelectronics Discovery Boards',...
    'matlab.addons.supportpackage.internal.explorer.showSupportPackages(''STMICRODIS'', ''tripwire'')')];
    str=sprintf([str,'\n']);
    str=[str,i_insertHyperlink('MATLAB Support Package for Raspberry Pi Hardware',...
    'matlab.addons.supportpackage.internal.explorer.showSupportPackages(''RASPPIIO'', ''tripwire'')')];
    str=sprintf([str,'\n']);
    str=[str,i_insertHyperlink('Simulink Support Package for Raspberry Pi Hardware',...
    'matlab.addons.supportpackage.internal.explorer.showSupportPackages(''RASPPI'', ''tripwire'')')];
    str=sprintf([str,'\n']);
end

function h=i_insertHyperlink(prompt,fcnCall)
    prompt=strtrim(prompt);
    fcnCall=strtrim(fcnCall);
    h=sprintf('<a href="matlab:%s">%s</a>',fcnCall,prompt);
end

