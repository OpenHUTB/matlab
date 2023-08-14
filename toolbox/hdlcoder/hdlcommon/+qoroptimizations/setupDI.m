function[hD,toolID]=setupDI(model,projFolder)



    hD=downstream.integration('Model',model,'keepCodegenDir',true);


    prjFilePath=fullfile(hD.hToolDriver.hTool.ProjectDir,hD.hToolDriver.hTool.ProjectFileName);
    if(exist(prjFilePath,'file')==2)
        delete(prjFilePath);
    end
    hD.setProjectFolder(projFolder);
    hD.createProjectFolder(projFolder);
    toolID=hdlget_param(model,'SynthesisTool');

    if(~strcmp(toolID,'Xilinx ISE')&&~strcmp(toolID,'Xilinx Vivado'))
        error(message('hdlcoder:optimization:UnsupportedTool',toolID));
    end
    try
        hD.set('Tool',toolID);
    catch me
        if(startsWith(me.identifier,'hdlcommon:workflow:ToolNotAvailable','IgnoreCase',true))
            error(message('hdlcoder:optimization:ToolNotAvailable',toolID));
        end
    end

    fdps={hdlget_param(model,'SynthesisToolChipFamily'),...
    hdlget_param(model,'SynthesisToolDeviceName'),...
    hdlget_param(model,'SynthesisToolPackageName'),...
    hdlget_param(model,'SynthesisToolSpeedValue'),...
    };
    if(~isempty(fdps{1})&&~isempty(fdps{2}))
        try
            hD.set('Family',fdps{1});
            hD.set('Device',fdps{2});
            hD.set('Package',fdps{3});
            hD.set('Speed',fdps{4});
            hD.setCustomHDLFile(hdlget_param(model,'SynthesisProjectAdditionalFiles'));
        catch me
            if(strcmpi(me.identifier,'hdlcommon:workflow:DownstreamInvalidValue'))
                error(message('hdlcoder:optimization:UnsupportedDevice',evalc('disp(fdps)'),toolID));
            end
            rethrow(me);
        end
    elseif(~(isempty(fdps{1})&&isempty(fdps{2})))
        error(message('hdlcoder:optimization:InvalidDevice',evalc('disp(fdps)')));
    end
end

