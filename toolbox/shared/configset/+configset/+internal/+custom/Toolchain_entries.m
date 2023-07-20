function[out,dscr]=Toolchain_entries(cs,~)


    dscr='Toolchain''s enum option is dynamically generated';

    cs=cs.getConfigSet;
    adp=configset.internal.getConfigSetAdapter(cs);

    if isempty(adp.toolchainInfo)
        configset.internal.customwidget.ToolchainValues(cs,'Toolchain',0);
    end
    tcNameList=adp.toolchainInfo.TcNameList;
    tcFound=adp.toolchainInfo.TcFound;

    defTCName=coder.make.internal.getInfo('default-toolchain');
    val=cs.getProp('Toolchain');
    if~tcFound
        toolchainNames=[defTCName,tcNameList,val];
    else
        toolchainNames=[defTCName,tcNameList];
    end

    out=struct('str',toolchainNames,'disp',toolchainNames);

