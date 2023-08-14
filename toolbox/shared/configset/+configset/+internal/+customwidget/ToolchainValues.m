function out=ToolchainValues(cs,~,direction,widgetVals)










    cs=cs.getConfigSet;
    toolchain=cs.get_param('Toolchain');
    adp=configset.internal.getConfigSetAdapter(cs);
    defTc=coder.make.internal.getInfo('default-toolchain');
    isDefaultTc=strcmp(defTc,toolchain);

    if direction==0
        if isempty(adp.toolchainInfo)||isDefaultTc||...
            ~strcmp(adp.toolchainInfo.TcName,toolchain)
            update=true;
            [compInfo,tcList,tcGroups,dispTcName,tcFound]=loc_computeToolchainInfo(cs,toolchain);
        else
            update=false;
            dispTcName=adp.toolchainInfo.TcDispName;
        end

        out={toolchain,dispTcName,'',''};

    elseif direction==1
        tcName=widgetVals{1};

        if strcmp(toolchain,tcName)&&~isDefaultTc
            update=false;
        else
            toolchain=tcName;
            update=true;
            [compInfo,tcList,tcGroups,dispTcName,tcFound]=loc_computeToolchainInfo(cs,toolchain);
        end
        out=tcName;
    end

    if update
        tcNameList={tcList.Name};



        if tcFound
            idx=find(strncmp(dispTcName,tcNameList,length(dispTcName)),1);
        else
            idx=find(strncmp(toolchain,tcNameList,length(toolchain)),1);
            tcFound=~isempty(idx);
        end
        if tcFound&&~isempty(idx)
            tc=tcList(idx).getToolchainInfo();
            tcGroup=tcGroups(idx);
        else
            tc=[];
            tcGroup=coder.make.enum.ToolchainGroup.UNKNOWN;
        end

        if(tcFound&&~isempty(tc))
            buildConfigList=coder.make.internal.getBuildConfigurationList(tc);
        else
            buildConfigList={};
        end

        if~isempty(adp)
            adp.toolchainInfo=[];
            adp.toolchainInfo.MexCompInfo=compInfo;
            adp.toolchainInfo.TcName=toolchain;
            adp.toolchainInfo.TcFound=tcFound;
            adp.toolchainInfo.TcDispName=dispTcName;
            adp.toolchainInfo.TcNameList=tcNameList;
            adp.toolchainInfo.TcGroupList=tcGroups;
            adp.toolchainInfo.Tc=tc;
            adp.toolchainInfo.TcGroup=tcGroup;
            adp.toolchainInfo.BcList=buildConfigList;
        end
    end
end

function[compInfo,tcList,tcGroups,dispTcName,tcFound]=loc_computeToolchainInfo(cs,toolchain)
    filter=configset.internal.util.ToolchainListFilter(cs);
    [tcList,tcGroups]=coder.make.internal.getToolchainList(filter);

    defTc=coder.make.internal.getInfo('default-toolchain');
    gpuEnabled=~strcmpi(cs.get_param('GenerateGPUCode'),'None');
    isGPUHardware=strcmp(cs.get_param('HardwareBoard'),'NVIDIA Jetson')...
    ||strcmp(cs.get_param('HardwareBoard'),'NVIDIA Drive');


    lDefaultCompInfo=coder.internal.DefaultCompInfo.createDefaultCompInfo;
    compInfo=lDefaultCompInfo.DefaultMexCompInfo;

    if isempty(toolchain)||isequal(toolchain,defTc)
        if gpuEnabled
            if isGPUHardware
                dispTcName=coder.make.internal.getNvidiaSpkgToolchain(gpuEnabled);
            else
                dispTcName=coder.internal.getGPUToolchainName(compInfo,tcList);
            end
        elseif isGPUHardware
            dispTcName=coder.make.internal.getNvidiaSpkgToolchain(gpuEnabled);
        else
            dispTcName=coder.make.internal.getDefaultToolchain(compInfo,tcList);
        end
        tcFound=true;
    else
        dispTcName='';
        tcFound=false;
    end
end

