function validateTargetSettings(inputArgs)





    validateTimingDatabaseDirectory(inputArgs);


    validateDeviceConfiguration(inputArgs);


    [toolStatus,logTxt]=validateDeviceConfigurationVivado(inputArgs);

    if toolStatus
        processSynthesisErrors(inputArgs,logTxt);
    end
end

function validateTimingDatabaseDirectory(inputArgs)



    if contains(inputArgs.TimingDatabaseDirectory,' ')
        error(message('HDLShared:hdlshared:tdbOutputPathContainsWhiteSpaces','TimingDatabaseDirectory',...
        inputArgs.TimingDatabaseDirectory,inputArgs.SynthesisToolName));
    end
end

function validateDeviceConfiguration(inputArgs)



    if~isempty(inputArgs.SynthesisDevicePart)
        return;
    end


    if isempty(inputArgs.SynthesisDeviceFamily)
        if~isempty(inputArgs.SynthesisDeviceConfiguration)
            msg=message('HDLShared:hdlshared:tdbinputsynthesisdeviceconfig','family');
        elseif~isempty(inputArgs.Model)
            msg=message('HDLShared:hdlshared:tdbinputargnotset','SynthesisDeviceFamily');
            close_system(inputArgs.Model);
            msg=message('HDLShared:hdlshared:tdbinputargmodel',msg.getString(),inputArgs.Model);
        else
            msg=message('HDLShared:hdlshared:tdbinputargnotset','SynthesisDeviceFamily');
        end
        error(msg);
    end


    if isempty(inputArgs.SynthesisDeviceName)
        if~isempty(inputArgs.SynthesisDeviceConfiguration)
            msg=message('HDLShared:hdlshared:tdbinputsynthesisdeviceconfig','name');
        elseif~isempty(inputArgs.Model)
            msg=message('HDLShared:hdlshared:tdbinputargnotset','SynthesisDeviceName');
            close_system(inputArgs.Model);
            msg=message('HDLShared:hdlshared:tdbinputargmodel',msg.getString(),inputArgs.Model);
        else
            msg=message('HDLShared:hdlshared:tdbinputargnotset','SynthesisDeviceName');
        end
        error(msg);
    end


    if strcmpi(inputArgs.SynthesisDeviceFamily,'Artix7')||strcmpi(inputArgs.SynthesisDeviceFamily,'Kintex7')...
        ||strcmpi(inputArgs.SynthesisDeviceFamily,'Zynq')||strcmpi(inputArgs.SynthesisDeviceFamily,'Virtex7')

        if isempty(inputArgs.SynthesisDevicePackage)

            if~isempty(inputArgs.SynthesisDeviceConfiguration)
                msg=message('HDLShared:hdlshared:tdbinputsynthesisdeviceconfig','package');
            elseif~isempty(inputArgs.Model)
                msg=message('HDLShared:hdlshared:tdbinputargnotset','SynthesisDevicePackage');
                close_system(inputArgs.Model);
                msg=message('HDLShared:hdlshared:tdbinputargmodel',msg.getString(),inputArgs.Model);
            else
                msg=message('HDLShared:hdlshared:tdbinputargnotset','SynthesisDevicePackage');
            end
            error(msg);
        end



        if isempty(inputArgs.SynthesisDeviceSpeedGrade)

            if~isempty(inputArgs.SynthesisDeviceConfiguration)
                msg=message('HDLShared:hdlshared:tdbinputsynthesisdeviceconfig','speed-grade');
            elseif~isempty(inputArgs.Model)
                msg=message('HDLShared:hdlshared:tdbinputargnotset','SynthesisDeviceSpeedGrade');
                close_system(inputArgs.Model);
                msg=message('HDLShared:hdlshared:tdbinputargmodel',msg.getString(),inputArgs.Model);
            else
                msg=message('HDLShared:hdlshared:tdbinputargnotset','SynthesisDeviceSpeedGrade');
            end
            error(msg);
        end
    end
end

function[toolStatus,logTxt]=validateDeviceConfigurationVivado(inputArgs)

    try

        if~exist(fullfile(inputArgs.TimingDatabaseDirectory,'targetCheck'),'dir')
            mkdir(fullfile(inputArgs.TimingDatabaseDirectory,'targetCheck'));
        end
        cd(fullfile(inputArgs.TimingDatabaseDirectory,'targetCheck'));


        if~isempty(inputArgs.SynthesisDevicePart)
            mypart=inputArgs.SynthesisDevicePart;
        else
            mypart=[inputArgs.SynthesisDeviceName,inputArgs.SynthesisDevicePackage,inputArgs.SynthesisDeviceSpeedGrade];
        end

        projLocation=fullfile(inputArgs.TimingDatabaseDirectory,'targetCheck');
        cfile=fopen('SetTarget.tcl','w');
        projLocation=replace(projLocation,'\','/');
        fprintf(cfile,sprintf("%s {%s} %s %s",'create_project proj',projLocation,'-part',mypart));
        fclose(cfile);


        cd(fullfile(inputArgs.TimingDatabaseDirectory,'targetCheck'));
        scriptName=fullfile('SetTarget.tcl');
        cmdString=['vivado -mode batch -source ',scriptName];
        [toolStatus,logTxt]=system(cmdString);


        cd(fullfile(inputArgs.TimingDatabaseDirectory));
        rmdir(fullfile(inputArgs.TimingDatabaseDirectory,'targetCheck'),'s');
    catch
        toolStatus=1;
    end
end

function processSynthesisErrors(inputArgs,logTxt)
    if contains(logTxt,"Specified part could not be found")

        if~isempty(inputArgs.SynthesisDevicePart)
            errStr=sprintf("\n%s: %s",'SynthesisDevicePart',inputArgs.SynthesisDevicePart);
        end

        if~isempty(inputArgs.SynthesisDeviceName)
            errStr=sprintf("\n%s: %s",'SynthesisDeviceName',inputArgs.SynthesisDeviceName);
        end

        if~isempty(inputArgs.SynthesisDevicePackage)
            errStr=sprintf("%s\n%s: %s",errStr,'SynthesisDevicePackage',...
            inputArgs.SynthesisDevicePackage);
        end

        if~isempty(inputArgs.SynthesisDeviceSpeedGrade)
            errStr=sprintf("%s\n%s: %s",errStr,'SynthesisDeviceSpeedGrade',...
            inputArgs.SynthesisDeviceSpeedGrade);
        end

        if~isempty(inputArgs.SynthesisDeviceConfiguration)
            errmsg=message('HDLShared:hdlshared:tdbinvaliddevicesettings1',errStr);
        else
            errmsg=message('HDLShared:hdlshared:tdbinvaliddevicesettings',errStr);
        end

        if~isempty(inputArgs.Model)
            close_system(inputArgs.Model);
            error(message('HDLShared:hdlshared:tdbinputargmodel',errmsg.getString(),inputArgs.Model));
        else
            error(errmsg);
        end
    else
        error(message("HDLShared:hdlshared:tdbfpgatoolerror",logTxt));
    end
end