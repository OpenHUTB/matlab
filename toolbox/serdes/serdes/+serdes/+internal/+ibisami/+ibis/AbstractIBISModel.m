classdef(Abstract)AbstractIBISModel<handle&matlab.mixin.Heterogeneous



























    properties
        Hidden(1,1)logical=false;
    end
    properties(SetAccess=protected)
        ModelName(1,1)string{serdes.utilities.mustBeShorterThan(ModelName,40)}=""
        ModelType(1,1)string{serdes.utilities.mustBeShorterThan(ModelType,40)}=""
        Ccomp(1,3){mustBeReal,mustBeFinite}=[0.0,0.0,0.0]
        CcompCorner(1,3){mustBeReal,mustBeFinite}=[0.0,0.0,0.0]
        TemperatureRange(1,3){mustBeReal,mustBeFinite}=[0.0,0.0,0.0]
        VoltageRange(1,3){mustBeReal,mustBeFinite}=[1.0,1.0,1.0]
        Pulldown(:,4){mustBeReal,mustBeFinite}=[]
        Pullup(:,4){mustBeReal,mustBeFinite}=[]
        GNDClamp(:,4){mustBeReal,mustBeFinite}=[]
        POWERClamp(:,4){mustBeReal,mustBeFinite}=[]
        DtRising(1,3){mustBeReal,mustBeFinite}=[-1,-1.,-1]
        DtFalling(1,3){mustBeReal,mustBeFinite}=[-1,-1,-1]
        dV(1,3){mustBeReal,mustBeFinite}=[-1,-1,-1]
        ModelResistance(1,3){mustBeReal,mustBeFinite}=[50,50,50]
Executables
ExecutablesTx
ExecutablesRx
    end
    properties(Constant)
        InputType="Input"
        OutputType="Output"
        IOType="I/O"
    end
    properties(Dependent)
Vinl
Vinh
Vmeas
Executable
ExecutableTx
ExecutableRx
    end
    methods
        function vinl=get.Vinl(model)
            if~isempty(model.VoltageRange)
                vinl=model.VoltageRange(1)*.45;
            else
                vinl=0.45;
            end
        end
        function vinh=get.Vinh(model)
            if~isempty(model.VoltageRange)
                vinh=model.VoltageRange(1)*.55;
            else
                vinh=0.55;
            end
        end
        function vmeas=get.Vmeas(model)
            if~isempty(model.VoltageRange)
                vmeas=model.VoltageRange(1)*.5;
            else
                vmeas=0.5;
            end
        end
        function executable=get.Executable(model)
            executable=model.executableForPlatform;
        end
        function executable=get.ExecutableTx(model)
            executable=model.executableForPlatform('Tx');
        end
        function executable=get.ExecutableRx(model)
            executable=model.executableForPlatform('Rx');
        end
    end
    methods
        function ibisString=getIBISString(model,prettyPrint)
            if model.Hidden
                ibisString="";
            else
                if prettyPrint
                    indent="    ";
                else
                    indent="";
                end
                ibisString="|***************************************************************************"+newline+...
                "| MODEL: "+model.ModelName+newline+...
                "|***************************************************************************"+newline;
                ibisString=ibisString+string(sprintf('[Model]       %s\n',model.ModelName));
                ibisString=ibisString+indent+string(sprintf('Model_type    %s\n',model.ModelType));
                ibisString=ibisString+indent+"|"+newline;
                if strcmp(model.ModelType,model.InputType)
                    ibisString=ibisString+indent+string(sprintf('Vinl = %f\n',model.Vinl));
                    ibisString=ibisString+indent+string(sprintf('Vinh = %f\n',model.Vinh));
                elseif strcmp(model.ModelType,model.IOType)
                    ibisString=ibisString+indent+string(sprintf('Vinl = %f\n',model.Vinl));
                    ibisString=ibisString+indent+string(sprintf('Vinh = %f\n',model.Vinh));
                    ibisString=ibisString+indent+string(sprintf('Vmeas = %f\n',model.Vmeas));
                else
                    ibisString=ibisString+indent+string(sprintf('Vmeas = %f\n',model.Vmeas));
                end
                ibisString=ibisString+indent+"|          typ          min          max"+newline;
                ibisString=ibisString+indent+string(sprintf('C_comp     %1.3e    %1.3e    %1.3e\n',model.Ccomp));
                ibisString=ibisString+indent+string(sprintf('[C Comp Corner]\n'));
                ibisString=ibisString+indent+indent+"|          typ          min          max"+newline;
                ibisString=ibisString+indent+indent+string(sprintf('C_comp     %1.3e    %1.3e    %1.3e\n',model.CcompCorner));
                if~isempty(model.Executables)||~isempty(model.ExecutablesTx)||~isempty(model.ExecutablesRx)
                    ibisString=ibisString+indent+"|"+newline;
                    ibisString=ibisString+indent+string(sprintf('[Algorithmic Model]\n'));
                    if~isempty(model.Executables)
                        for idx=1:numel(model.Executables)
                            executable=model.Executables{idx};
                            ibisString=ibisString+indent+string(sprintf('Executable %s    %s    %s\n',executable));
                        end
                    end
                    if~isempty(model.ExecutablesRx)
                        for idx=1:numel(model.ExecutablesRx)
                            executable=model.ExecutablesRx{idx};
                            ibisString=ibisString+indent+string(sprintf('Executable_Rx %s    %s    %s\n',executable));
                        end
                    end
                    if~isempty(model.ExecutablesTx)
                        for idx=1:numel(model.ExecutablesTx)
                            executable=model.ExecutablesTx{idx};
                            ibisString=ibisString+indent+string(sprintf('Executable_Tx %s    %s    %s\n',executable));
                        end
                    end
                    ibisString=ibisString+indent+string(sprintf('[End Algorithmic Model]\n'));
                end
                ibisString=ibisString+indent+"|"+newline;
                ibisString=ibisString+indent+"|                       typ     min      max"+newline;
                ibisString=ibisString+indent+string(sprintf('[Temperature Range]     %1.1f    %1.1f    %1.1f\n',model.TemperatureRange));
                ibisString=ibisString+indent+string(sprintf('[Voltage Range]         %1.3f   %1.3f    %1.3f\n',model.VoltageRange));
                ibisString=ibisString+indent+"|"+newline;
                if~isempty(model.Pulldown)
                    ibisString=ibisString+indent+string(sprintf('[Pulldown]\n'));
                    ibisString=ibisString+indent+indent+"|Voltage         I(typ)           I(min)           I(max)"+newline;
                    rows=size(model.Pulldown);
                    for row=1:rows
                        ibisString=ibisString+indent+indent+string(sprintf('%+e    %+e    %+e    %+e\n',model.Pulldown(row,:)));
                    end
                    ibisString=ibisString+indent+"|"+newline;
                end
                if~isempty(model.Pullup)
                    ibisString=ibisString+indent+string(sprintf('[Pullup]\n'));
                    ibisString=ibisString+indent+indent+"|Voltage         I(typ)           I(min)           I(max)"+newline;
                    rows=size(model.Pullup);
                    for row=1:rows
                        ibisString=ibisString+indent+indent+string(sprintf('%+e    %+e    %+e    %+e\n',model.Pullup(row,:)));
                    end
                    ibisString=ibisString+indent+"|"+newline;
                end
                if~isempty(model.GNDClamp)
                    ibisString=ibisString+indent+string(sprintf('[GND Clamp]\n'));
                    ibisString=ibisString+indent+indent+"|Voltage         I(typ)           I(min)           I(max)"+newline;
                    rows=size(model.GNDClamp);
                    for row=1:rows
                        ibisString=ibisString+indent+indent+string(sprintf('%+e    %+e    %+e    %+e\n',model.GNDClamp(row,:)));
                    end
                    ibisString=ibisString+indent+"|"+newline;
                end
                if~isempty(model.POWERClamp)
                    ibisString=ibisString+indent+string(sprintf('[POWER Clamp]\n'));
                    ibisString=ibisString+indent+indent+"|Voltage         I(typ)           I(min)           I(max)"+newline;
                    rows=size(model.POWERClamp);
                    for row=1:rows
                        ibisString=ibisString+indent+indent+string(sprintf('%+e    %+e    %+e    %+e\n',model.POWERClamp(row,:)));
                    end
                    ibisString=ibisString+indent+"|"+newline;
                end
                if model.DtRising(1)>0||model.DtFalling(1)>0
                    ibisString=ibisString+indent+string(sprintf('[Ramp]\n'));
                    if model.DtRising(1)>0
                        ibisString=ibisString+indent+string(sprintf('dV/dt_r     %1.3f/%1.3e    %1.3f/%1.3e    %1.3f/%1.3e\n',...
                        model.dV(1),model.DtRising(1),...
                        model.dV(2),model.DtRising(3),...
                        model.dV(3),model.DtRising(2)...
                        ));
                    end
                    if model.DtFalling(1)>0
                        ibisString=ibisString+indent+string(sprintf('dV/dt_f     %1.3f/%1.3e    %1.3f/%1.3e    %1.3f/%1.3e\n',...
                        model.dV(1),model.DtFalling(1),...
                        model.dV(2),model.DtFalling(3),...
                        model.dV(3),model.DtFalling(2)...
                        ));
                    end
                    ibisString=ibisString+indent+"|"+newline;
                end
            end
        end
        function executable=executableForPlatform(model,direction)
            if nargin<2
                direction='both';
            end
            platform=model.platformArchDllCompiler;
            switch direction
            case 'Tx'
                executables=model.ExecutablesTx;
            case 'Rx'
                executables=model.ExecutablesRx;
            otherwise
                executables=model.Executables;
            end
            for idx=1:numel(executables)
                executable=executables{idx};
                if startsWith(executable(1),platform)
                    return
                end
            end
            executable=model.CurrentExecutable;
        end
        function currentExecutable=CurrentExecutable(model)
            if ismac
                currentExecutable=[];
            else
                [platform,arch,dllExt,compiler]=model.platformArchDllCompiler;
                platformCompilerBits=platform+compiler+"_64";
                currentExecutable=[platformCompilerBits,model.ModelName+"_"+arch+dllExt,model.ModelName+".ami"];
            end
        end
    end
    methods(Static)
        function[platform,arch,dllExt,compiler]=platformArchDllCompiler
            arch=computer('arch');
            if ispc
                platform="Windows_";
                dllExt=".dll";
            elseif ismac
                platform="MacOS_";
                dllExt=".so";
            else
                platform="Linux_";
                dllExt=".so";
            end
            mexCompilerInfo=mex.getCompilerConfigurations('C++');
            if isempty(mexCompilerInfo)
                compiler='NoCompiler';
            else
                compiler=mexCompilerInfo(1).ShortName;
            end
        end
    end
end

