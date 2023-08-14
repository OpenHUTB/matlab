function output=reportExists(SystemName)




    if nargin<1
        DAStudio.error('Simulink:tools:MASpecifySystemName');
    end
    this=Simulink.ModelAdvisor;
    if ischar(SystemName)

        SystemName=fliplr(SystemName);
        if strncmpi(SystemName,'ldm.',4)
            SystemName=SystemName(5:end);
        end;
        SystemName=fliplr(SystemName);
    end
    try
        origSystem=this.System;
        this.System=SystemName;
        report=[this.getWorkDir('CheckOnly'),filesep,'report.html'];
        this.System=origSystem;
        output=exist(report,'file')==2;
    catch
        this.System=origSystem;
        output=false;
    end

