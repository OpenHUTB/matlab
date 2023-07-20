function createTargetOnTheFly(tgtName,folder,varargin)


















    disp(['Running  ',mfilename('fullpath'),'.m'])

    p=inputParser;
    addRequired(p,'tgtName',@ischar);
    addRequired(p,'folder',@ischar);
    addOptional(p,'isSimTgt',false,@islogical);
    addParameter(p,'hwboards',{},@iscellstr);
    p.KeepUnmatched=true;
    p.parse(tgtName,folder,varargin{:});
    isSimTgt=p.Results.isSimTgt;
    hwboards=p.Results.hwboards;


    tgtObj=i_createTargetObject(tgtName,folder);



    for i=1:numel(hwboards)

        hwObj=i_createHardwareObject(hwboards{i});
        map(tgtObj,hwObj,hwboards{i});

    end

    saveTarget(tgtObj);
    i_applyCoderTargetAPIs(tgtObj,isSimTgt);
    i_updateRTWTargetInfo(tgtObj,isSimTgt);
    rehash toolbox;
    sl_refresh_customizations;
end



function tgtObj=i_createTargetObject(name,folder)

    tgtObj=createTarget(name,folder);
end





function hwObj=i_createHardwareObject(hwName)
    hwObj=createHardware(hwName);
    hwObj.DeviceID='Custom Processor->Custom Processor';
    hwObj.MathWorksDeviceType='ASIC/FPGA->ASIC/FPGA';
end


function i_applyCoderTargetAPIs(tgtObj,isSimTgt)
    tgtHwDir=dir(fullfile(tgtObj.Folder,'registry','targethardware'));



    for ii=1:length(tgtHwDir(3:end))
        tgtHwFileName=tgtHwDir(2+ii).name;
        tgtHWInfo=codertarget.targethardware.TargetHardwareInfo(...
        fullfile(tgtObj.Folder,'registry','targethardware',tgtHwFileName),...
        tgtObj.Name);

        tgtHWInfo.ESBCompatible=2;
        tgtHWInfo.BaseProductID=codertarget.targethardware.BaseProductID.SOC;
        if isSimTgt
            tgtHWInfo.SupportsOnlySimulation=true;
        else
            tgtHWInfo.TaskMap.isSupported=true;
            tgtHWInfo.TaskMap.useAutoMap=true;
        end



        fwdInfoFileName='forwarding.xml';
        fwdObj=codertarget.forwarding.ForwardingInfo();
        fwdObj.setTargetName(tgtObj.Name);
        fwdObj.setDefinitionFileName(fwdInfoFileName);
        fwdObj.addParameter(struct('Name','FPGADesign','ForwardingFcn','soc.internal.forwardFPGAParameters'));
        fwdObj.register;


        tgtHWInfo.setForwardingInfoFile(fwdInfoFileName);

        tgtHWInfo.register;







        [~,fname,fext]=fileparts(tgtHWInfo.getParameterInfoFile);
        parametersObj=i_createParameterInfoObject(tgtHWInfo);
        parametersObj.setTargetName(tgtObj.Name);
        parametersObj.setName(tgtObj.Name);
        parametersObj.DefinitionFileName=[fname,fext];
        parametersObj.register;

    end
end



function p=i_createParameterInfoObject(tgtHWInfo)
    p=codertarget.parameter.ParameterInfo;

    out.parameters.ParameterGroups={};

    out.parameters=loc_addFPGADesignWidgets(tgtHWInfo,out.parameters,'Bogus');

    p.ParameterGroups=[p.ParameterGroups,out.parameters.ParameterGroups];
    p.Parameters=[p.Parameters,out.parameters.Parameters];

end

function in=loc_addFPGADesignWidgets(hObj,in,groupName)
    [info,e]=codertarget.utils.getFPGADesignWidgets(hObj,groupName);

    if~isempty(e)
        disp(e.message);
    end
    if isempty(info.Parameters)
        if isempty(hObj)
            disp('Target Hardware Info is empty');
        else
            disp(['Empty param info for ',hObj.Name,':',groupName])
        end
    end

    grpname=DAStudio.message(['codertarget:ui:FPGADesignGroup',groupName]);
    in.ParameterGroups{end+1}=grpname;
    in.Parameters{numel(in.ParameterGroups)}=info.Parameters{1};

end


function i_updateRTWTargetInfo(tgtObj,isSimTgt)
    if isSimTgt
        fcnWriter=codertarget.internal.FunctionWriter;
        fcnWriter.FileName=fullfile(tgtObj.Folder,'rtwTargetInfo.m');
        fcnWriter.deserialize;
        fcnWriter.addLineToFcnAt('rtwTargetInfo',2,...
        'if (codertarget.internal.isSpPkgInstalled(''xilinxfpga'')), return; end');
        fcnWriter.serialize;
    end
end









