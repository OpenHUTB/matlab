function xsgComp=elaborate(~,hN,hC)





    xsgDrv=targetcodegen.xilinxvivadosysgendriver();
    if~xsgDrv.isXSGIsland(hC.SimulinkHandle)
        error('Not XSG island.');
    end

    [entityName,inportNames,outportNames,clkNames,ceNames,ceclrNames,...
    rates,baseRate,hasDownSample,blackBoxAttributes,vhdlComponentLibrary]=getBlockInfo(hN,hC,xsgDrv);

    xsgComp=pirelab.getXsgVivadoComp(hN,hC.Name,hC.PirInputSignals,hC.PirOutputSignals,...
    entityName,inportNames,outportNames,clkNames,ceNames,ceclrNames,...
    rates,baseRate,hasDownSample,blackBoxAttributes,vhdlComponentLibrary);

    for i=1:length(inportNames)
        xsgComp.setInputPortName(i-1,inportNames{i});
    end
    for i=1:length(outportNames)
        xsgComp.setOutputPortName(i-1,outportNames{i});
    end


    targetcodegen.xilinxsysgendriver.addXSGCodeGenPath(vhdlComponentLibrary);
end




function[entityName,inportNames,outportNames,clkNames,ceNames,ceclrNames,...
    rates,baseRate,hasDownSample,blackBoxAttributes,vhdlComponentLibrary]...
    =getBlockInfo(hN,hC,xsgDrv)

    hasDownSample=false;


    blocks=find_system(hC.SimulinkHandle,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks','on','LookUnderMasks','all');
    for i=1:length(blocks)
        if(isequal(blocks(i),hC.SimulinkHandle))
            continue;
        end

        if(doesDownSampleOnPorts(blocks(i)))
            hasDownSample=true;
            break;
        end
    end
    island=hC.SimulinkHandle;
    settings=xsgDrv.getSettings;














    tlang=hdlgetparameter('target_language');
    if(~strcmpi(settings.SynthesisLanguage,tlang))
        settings.SynthesisLanguage=tlang;
    end

    if(~strcmpi(settings.CompilationTarget,'HDL Netlist'))
        settings.CompilationTarget='HDL netlist';
    end

    if(~strcmpi(settings.Testbench,'off'))
        settings.Testbench='off';
    end

    if(~strcmpi(settings.SynthesisStrategy,'Vivado Synthesis Defaults'))
        settings.SynthesisStrategy='Vivado Synthesis Defaults';
    end
    if(~strcmpi(settings.ImplementationStrategy,'Vivado Implementation Defaults'))
        settings.ImplementationStrategy='Vivado Implementation Defaults';
    end
    if(~strcmpi(settings.ProvideCEClear,'on'))
        settings.ProvideCEClear='on';
    end

    vhdlComponentLibrary=[hN.RefNum,'_',hC.RefNum];
    settings.VHDLLibrary=vhdlComponentLibrary;

    [entityName,inportNames,outportNames,clkNames,ceNames,ceclrNames,rates,baseRate]=processXSG(xsgDrv,island,settings);

    if~strcmpi(settings.CompilationTarget,'HDL Netlist')
        blackBoxAttributes=true;
    else
        blackBoxAttributes=false;
    end

end




function[entityName,inportNames,outportNames,clkNames,ceNames,ceclrNames,rates,baseRate]=processXSG(xsgDrv,island,settings)


    xsgFullDir=tempname;
    settings.TargetDirectory=xsgFullDir;
    targetDir=setupHDLCTargeDir();


    xsgDrv.updateXSGSettings(settings);

    designInfoStruct=xsgCodeGen(xsgDrv,island);




    copyXSGFiles(xsgDrv,targetDir);
    rmdir(xsgFullDir,'s');

    baseRate=designInfoStruct.sim_period;
    entityName=designInfoStruct.top_level;

    [inportNames,outportNames,clkNames,ceNames,ceclrNames,rates]=renderFromDesignInfo(designInfoStruct);
end

function copyXSGFiles(xsgDrv,targetDir)
    [xsgDir,libName]=xsgDrv.get({'TargetDirectory','VHDLLibrary'});
    xsgFullDir=fullfile(xsgDir,'sysgen');
    xsgTargetDir=setupXSGTargetDir(targetDir,libName);

    fileList=xsgDrv.getXSGFiles(targetcodegen.xilinxsysgenfileenum.ALL,libName);
    copyFiles(xsgFullDir,xsgTargetDir,fileList);
end

function ds=doesDownSampleOnPorts(blk)
    ds=false;
    ports=get_param(blk,'PortHandles');
    minInPortRate=inf;
    for i=1:length(ports.Inport)
        portRate=get_param(ports.Inport(i),'CompiledSampletime');
        if(portRate(1)<minInPortRate)
            minInPortRate=portRate(1);
        end
    end
    for i=1:length(ports.Outport)
        portRate=get_param(ports.Outport(i),'CompiledSampletime');
        if(portRate(1)>minInPortRate)
            ds=true;
            return;
        end
    end
end

function copyFiles(srcDir,destDir,fileList)
    for i=1:length(fileList)
        status=copyfile(fullfile(srcDir,fileList{i}),fullfile(destDir,fileList{i}));
        if(status==0)
            error(message('hdlcoder:validate:xsgcopyfailure',fullfile(xsgTargetDir,fileList{i})));
        end
    end
end

function targetDir=setupHDLCTargeDir()
    hDrv=hdlcurrentdriver;
    targetDir=hDrv.hdlGetCodegendir;
    if~exist(targetDir,'dir')
        mkdir(targetDir);
    end
end

function xsgTargetDir=setupXSGTargetDir(targetDir,libName)

    xsgTargetDir=fullfile(targetDir,libName);
    if~exist(xsgTargetDir,'dir')
        mkdir(xsgTargetDir);
    end
end

function designInfoStruct=xsgCodeGen(xsgDrv,subsystem)



    isMdlCompiled=~isempty(get_param(subsystem,'CompiledSampleTime'));
    mdlObj=get_param(bdroot(subsystem),'Object');
    if(isMdlCompiled)
        mdlObj.term;
    end
    try
        designInfoStruct=xsgDrv.generate(subsystem);
    catch ME
        error(message('hdlcoder:validate:xsgcodegenfailure',subsystem,ME.message));
    end

    if(isMdlCompiled)
        mdlObj.init;
    end

end

function[inportNames,outportNames,clkNames,ceNames,ceclrNames,rates]=renderFromDesignInfo(designInfoStruct)
    inportNames={};
    inportIdx=[];
    outportNames={};
    outportIdx=[];
    clkNames={};
    ceNames={};
    ceclrNames={};
    rates={};
    ceRates=[];
    clkRates=[];

    portNames=fields(designInfoStruct.ports);

    for i=1:length(portNames)
        port=getfield(designInfoStruct.ports,portNames{i});
        if isCe(port)
            ceNames{end+1}=port.Name;
            ceRates(end+1)=port.Period;
        elseif isCeclr(port)
            ceclrNames{end+1}=port.Name;
        elseif isClk(port)
            clkNames{end+1}=port.Name;
            clkRates(end+1)=port.Period;
        elseif isDataIn(port)
            inportNames{end+1}=portNames{i};
            srcBlock=eval(['designInfoStruct.ports.',portNames{i},'.SimulinkBlock']);
            inportIdx(end+1)=getInportIdx(srcBlock);
        elseif(isDataOut(port))
            outportNames{end+1}=portNames{i};
            srcBlock=eval(['designInfoStruct.ports.',portNames{i},'.SimulinkBlock']);
            outportIdx(end+1)=getOutportIdx(srcBlock);
        else
            assert(false,['Unknown Xilinx System Generator Port: ',portNames{i}]);
        end
    end


    [ceRates,idx]=sort(ceRates);
    ceNames=ceNames(idx);
    [clkRates,idx]=sort(clkRates);
    clkNames=clkNames(idx);
    assert(ceRates==clkRates,'ceRates do not match clkRates');

    for i=1:length(ceRates)
        rates{end+1}=num2str(ceRates(i));
    end


    [~,inportIdx]=sort(inportIdx);
    inportNames=inportNames(inportIdx);
    [~,outportIdx]=sort(outportIdx);
    outportNames=outportNames(outportIdx);
end

function idx=getInportIdx(srcBlock)
    assert(strcmpi(get_param(srcBlock,'block_type'),'gatewayin'),['The source_block, ',srcBlock,', is not a gatewayin block']);
    nextBlock=walk(srcBlock,'backward');
    assert(strcmpi(get_param(nextBlock,'blocktype'),'Inport'),['The block before gatewayin block, ',nextBlock,', is not an Inport block']);
    idx=str2double(get_param(nextBlock,'Port'));
end

function idx=getOutportIdx(srcBlock)
    assert(strcmpi(get_param(srcBlock,'block_type'),'gatewayout'),['The source_block, ',srcBlock,', is not a gatewayout block']);
    nextBlock=walk(srcBlock,'forward');
    nextBlockType=get_param(nextBlock,'blocktype');
    if(strcmpi(nextBlockType,'DataTypeConversion'))
        nextBlock=walk(nextBlock,'forward');
        nextBlockType=get_param(nextBlock,'blocktype');
    end
    assert(strcmpi(nextBlockType,'Outport'),['The block after gatewayout block, ',nextBlock,', is not an Outport block']);
    idx=str2double(get_param(nextBlock,'Port'));
end

function bool=isCe(port)

    bool=isfield(port,'InterfaceString');
    if(bool)
        bool=strcmpi(port.InterfaceString,'CLOCKENABLE');
    end
end

function bool=isClk(port)
    bool=isfield(port,'InterfaceString');
    if(bool)
        bool=strcmpi(port.InterfaceString,'CLOCK');
    end
end

function bool=isCeclr(port)
    bool=isfield(port,'InterfaceString');
    if(bool)
        bool=strcmpi(port.InterfaceString,'CLOCKENABLE_CLEAR');
    end
end

function bool=isDataIn(port)
    bool=isfield(port,'InterfaceString')&&isfield(port,'Direction');
    if(bool)
        bool=strcmpi(port.InterfaceString,'DATA')...
        &&strcmpi(port.Direction,'in')...
        &&~isempty(port.Name);
    end
end

function bool=isDataOut(port)
    bool=isfield(port,'InterfaceString')&&isfield(port,'Direction');
    if(bool)
        bool=strcmpi(port.InterfaceString,'DATA')...
        &&strcmpi(port.Direction,'out')...
        &&~isempty(port.Name);
    end
end

function nextBlock=walk(startingBlk,direction)

    nextBlock=[];
    isForward=strcmpi(direction,'forward');

    startingH=get_param(startingBlk,'Handle');
    pc=get_param(startingH,'PortConnectivity');
    for i=1:length(pc)
        if(isForward)
            h=pc(i).DstBlock;
        else
            h=pc(i).SrcBlock;
        end
        nextBlock=[nextBlock,setdiff(h,nextBlock)];%#ok<*AGROW>
    end
    assert(length(nextBlock)==1,'This block has more than one adjacent up/down stream blocks.');
end




