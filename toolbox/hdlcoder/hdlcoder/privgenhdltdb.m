function privgenhdltdb(varargin)





    inputArgs=parseArguments(varargin{:});


    if~isempty(inputArgs.Model)
        load_system(inputArgs.Model)
    end


    inputArgs=validateAndSetTimingDatabaseDirectory(inputArgs);


    inputArgs=validateAndSetToolConfig(inputArgs);


    inputArgs=validateAndSetOverride(inputArgs);


    inputArgs=validateAndSetDeviceConfig(inputArgs);

    if~isempty(inputArgs.Model)
        close_system(inputArgs.Model)
        return;
    end


    characterization.STA.genhdltdb(inputArgs);
end



function inputArgs=parseArguments(varargin)

    argsParser=inputParser;



    argsParser.addParameter('SynthesisDeviceConfiguration','');


    argsParser.addParameter('SynthesisDeviceFamily','');
    argsParser.addParameter('SynthesisDeviceName','');
    argsParser.addParameter('SynthesisDevicePackage','');
    argsParser.addParameter('SynthesisDeviceSpeedGrade','');


    argsParser.addParameter('SynthesisDevicePart','');

    argsParser.addParameter('TimingDatabaseDirectory','');
    argsParser.addParameter('SynthesisToolName','');
    argsParser.addParameter('SynthesisToolPath','');
    argsParser.addParameter('Override','');
    argsParser.addParameter('TestMode','');
    argsParser.addParameter('Model','');

    if mod(nargin,2)==0
        argsParser.parse(varargin{:});
        inputArgs=argsParser.Results;
    else
        argsParser.parse(varargin{2:end});
        inputArgs=argsParser.Results;
        inputArgs.Model=varargin{1};
        inputArgs.Override='on';
    end

end

function inputArgs=validateAndSetTimingDatabaseDirectory(inputArgs)


    if isempty(inputArgs.TimingDatabaseDirectory)&&~isempty(inputArgs.Model)
        inputArgs.TimingDatabaseDirectory=hdlget_param(inputArgs.Model,'TimingDatabaseDirectory');
    end


    if isempty(inputArgs.TimingDatabaseDirectory)
        msg=message('HDLShared:hdlshared:tdbinputargnotset','TimingDatabaseDirectory');
        if~isempty(inputArgs.Model)
            close_system(inputArgs.Model);
            error(message('HDLShared:hdlshared:tdbinputargmodel',msg.getString(),inputArgs.Model));
        end
        error(message('HDLShared:hdlshared:tdbinputargnotset','TimingDatabaseDirectory'));
    end


    if(exist(inputArgs.TimingDatabaseDirectory,'dir')~=7)
        error(message('HDLShared:hdlshared:tdbinputarginvalid',inputArgs.TimingDatabaseDirectory,'TimingDatabaseDirectory'));
    end
end

function inputArgs=validateAndSetToolConfig(inputArgs)


    if isempty(inputArgs.SynthesisToolName)

        if~isempty(inputArgs.Model)
            if isempty(hdlget_param(inputArgs.Model,'SynthesisTool'))
                msg=message('HDLShared:hdlshared:tdbinputargnotset','SynthesisToolName');
                close_system(inputArgs.Model);
                error(message('HDLShared:hdlshared:tdbinputargmodel',msg.getString(),inputArgs.Model));
            else
                inputArgs.SynthesisToolName=hdlget_param(inputArgs.Model,'SynthesisTool');
            end
        else
            error(message('HDLShared:hdlshared:tdbinputargnotset','SynthesisToolName'));
        end
    end


    if~strcmpi(inputArgs.SynthesisToolName,'xilinx vivado')
        error(message('HDLShared:hdlshared:tdbinputarginvalid',inputArgs.SynthesisToolName,'SynthesisToolName'));
    end


    if isempty(inputArgs.SynthesisToolPath)
        if isempty(getenv('XILINX_VIVADO'))

            msg=message('HDLShared:hdlshared:tdbinputargnotset','SynthesisToolPath');
            if~isempty(inputArgs.Model)
                close_system(inputArgs.Model);
            end
            error(message('HDLShared:hdlshared:tdbinputargtoolpath',msg.getString()));
        else
            inputArgs.SynthesisToolPath=getenv('XILINX_VIVADO');
        end
    end


    hdlsetuptoolpath('ToolName',inputArgs.SynthesisToolName,'ToolPath',inputArgs.SynthesisToolPath);
end

function inputArgs=validateAndSetOverride(inputArgs)
    if~isempty(inputArgs.Override)
        if~strcmp(inputArgs.Override,'on')&&~strcmp(inputArgs.Override,'off')
            error(message('HDLShared:hdlshared:tdbinputarginvalid',inputArgs.Override,'Override'));
        end
    end
end

function inputArgs=validateAndSetDeviceConfig(inputArgs)

    if~isempty(inputArgs.SynthesisDevicePart)
        deviceConfig=inputArgs.SynthesisDevicePart;
    elseif~isempty(inputArgs.SynthesisDeviceConfiguration)

        deviceConfig=inputArgs.SynthesisDeviceConfiguration;
        if numel(deviceConfig)>0
            inputArgs.SynthesisDeviceFamily=deviceConfig{1};
        end
        if numel(deviceConfig)>1
            inputArgs.SynthesisDeviceName=deviceConfig{2};
        end
        if numel(deviceConfig)>2
            inputArgs.SynthesisDevicePackage=deviceConfig{3};
        end
        if numel(deviceConfig)>3
            inputArgs.SynthesisDeviceSpeedGrade=deviceConfig{4};
        end
    elseif~isempty(inputArgs.Model)

        inputArgs.SynthesisDeviceFamily=hdlget_param(inputArgs.Model,'SynthesisToolChipFamily');
        inputArgs.SynthesisDeviceName=hdlget_param(inputArgs.Model,'SynthesisToolDeviceName');
        inputArgs.SynthesisDevicePackage=hdlget_param(inputArgs.Model,'SynthesisToolPackageName');
        inputArgs.SynthesisDeviceSpeedGrade=hdlget_param(inputArgs.Model,'SynthesisToolSpeedValue');
    end


    if(~isempty(inputArgs.TestMode)&&inputArgs.TestMode{3})
        return;
    end
    switch lower(inputArgs.SynthesisToolName)
    case 'xilinx vivado'
        characterization.STA.XilinxVivado.validateTargetSettings(inputArgs);

    case 'altera quartus ii'
        characterization.STA.XilinxVivado.validateTargetSettings(inputArgs);

    case 'microchip libero soc'
        characterization.STA.XilinxVivado.validateTargetSettings(inputArgs);

    end
end
