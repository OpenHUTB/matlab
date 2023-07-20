classdef(Abstract)ILauncher<handle





    methods(Abstract)
        setExe(this,exe);

        exe=getExe(this);

        startApplication(this);

        status=getApplicationStatus(this);

        stopApplication(this);

        extModeEnable(this,enableConnection);

        componentCodePath=getComponentCodePath(this);
    end
end
