function xsgComp=elaborate(~,hN,hC)




    [entityName,inportNames,outportNames,clkNames,ceNames,ceclrNames,...
    rates,baseRate,hasDownSample,blackBoxAttributes,vhdlComponentLibrary]=getBlockInfo(hN,hC);

    xsgComp=pirelab.getXsgComp(hN,hC.Name,hC.PirInputSignals,hC.PirOutputSignals,...
    entityName,inportNames,outportNames,clkNames,ceNames,ceclrNames,...
    rates,baseRate,hasDownSample,blackBoxAttributes,vhdlComponentLibrary);

    for i=1:length(inportNames)
        xsgComp.setInputPortName(i-1,inportNames{i});
    end
    for i=1:length(outportNames)
        xsgComp.setOutputPortName(i-1,outportNames{i});
    end


    targetcodegen.xilinxisesysgendriver.addXSGCodeGenPath(vhdlComponentLibrary);
end


function[entityName,inportNames,outportNames,clkNames,ceNames,ceclrNames,...
    rates,baseRate,hasDownSample,blackBoxAttributes,vhdlComponentLibrary]...
    =getBlockInfo(hN,hC)

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

    xsgBlk=targetcodegen.xilinxisesysgendriver.findXSGBlks(hC.simulinkHandle);
    assert(length(xsgBlk)==1,...
    sprintf('Exactly one System Generator block is expected, while %s has %d.',...
    [get_param(hC.SimulinkHandle,'parent'),'/',get_param(hC.SimulinkHandle,'name')],...
    length(xsgBlk)));

    if(~isempty(xsgBlk))
        xsgParams=xlgetparams(xsgBlk);
    else

        xsgParams.compilation='HDL netlist';
        xsgParams.directory='./netlist';
    end


    tlang=hdlgetparameter('target_language');
    if(~strcmpi(xsgParams.synthesis_language,tlang))

        xlsetparam(xsgBlk,'synthesis_language',tlang);
    end
    if(~strcmpi(xsgParams.compilation,'HDL netlist'))
        xlsetparam(xsgBlk,'compilation','HDL netlist');


        xlsetparam(xsgBlk,'xilinxfamily',xsgParams.xilinxfamily);
        xlsetparam(xsgBlk,'part',xsgParams.part);
        xlsetparam(xsgBlk,'package',xsgParams.package);
        xlsetparam(xsgBlk,'speed',xsgParams.speed);
    end
    if(~strcmpi(xsgParams.testbench,'off'))
        xlsetparam(xsgBlk,'testbench','off');
    end
    if(~strcmpi(xsgParams.clock_wrapper,'Clock Enables'))
        xlsetparam(xsgBlk,'clock_wrapper','Clock Enables');
    end
    if(isfield(xsgParams,'proj_type')&&~strcmpi(xsgParams.proj_type,'Project Navigator'))
        xlsetparam(xsgBlk,'proj_type','Project Navigator');
    end
    if(isfield(xsgParams,'synth_file')&&~strcmpi(xsgParams.synth_file,'XST Defaults*'))
        xlsetparam(xsgBlk,'synth_file','XST Defaults*');
    end
    if(isfield(xsgParams,'impl_file')&&~strcmpi(xsgParams.impl_file,'ISE Defaults*'))
        xlsetparam(xsgBlk,'impl_file','ISE Defaults*');
    end
    if(~isequal(xsgParams.ce_clr,1))
        xlsetparam(xsgBlk,'ce_clr',1);
    end

    vhdlComponentLibrary=[hN.RefNum,'_',hC.RefNum];

    [entityName,inportNames,outportNames,clkNames,ceNames,ceclrNames,rates,baseRate]=processXSG(xsgBlk,xsgParams,vhdlComponentLibrary);

    if~strcmpi(xsgParams.compilation,'HDL netlist')
        blackBoxAttributes=true;
    else
        blackBoxAttributes=false;
    end


    xlsetparam(xsgBlk,'synthesis_language',xsgParams.synthesis_language);
    xlsetparam(xsgBlk,'compilation',xsgParams.compilation);
    xlsetparam(xsgBlk,'testbench',xsgParams.testbench);
    xlsetparam(xsgBlk,'clock_wrapper',xsgParams.clock_wrapper);
    if(isfield(xsgParams,'proj_type'))
        xlsetparam(xsgBlk,'proj_type',xsgParams.proj_type);
    end
    if(isfield(xsgParams,'synth_file'))
        xlsetparam(xsgBlk,'synth_file',xsgParams.synth_file);
    end
    if(isfield(xsgParams,'impl_file'))
        xlsetparam(xsgBlk,'impl_file',xsgParams.impl_file);
    end
    xlsetparam(xsgBlk,'ce_clr',xsgParams.ce_clr);

end


function[entityName,inportNames,outportNames,clkNames,ceNames,ceclrNames,rates,baseRate]=processXSG(xsgBlk,xsgParams,libName)



    targetDir=setupHDLCTargeDir();
    xsgFullDir=tempname;
    xlsetparam(xsgBlk,'directory',xsgFullDir);

    xlsetparam(xsgBlk,'testbench','off');

    pref=xlGetPrefs;
    pref.has_ce=1;
    xlSetPrefs(pref);

    xsgCodeGen(xsgBlk,xsgFullDir,libName);


    xlsetparam(xsgBlk,'testbench',xsgParams.testbench)
    xlsetparam(xsgBlk,'directory',xsgParams.directory);

    designInfoStruct=xilinx.design.getdesigninfo(xsgFullDir);



    copyXSGFiles(xsgFullDir,libName,targetDir);
    rmdir(xsgFullDir,'s');

    baseRate=slResolve(xsgParams.simulink_period,xsgBlk);
    entityName=designInfoStruct.top;



    [inportNames,outportNames,clkNames,ceNames,ceclrNames,rates]=renderFromDesignInfo(designInfoStruct);
end

function copyXSGFiles(xsgFullDir,libName,targetDir)

    xsgTargetDir=setupXSGTargetDir(targetDir,libName);
    hdlFileList=targetcodegen.xilinxisesysgendriver.getXSGHDLFiles(xsgFullDir);
    hdlFileList{end+1}='hdlFiles';
    copyFiles(xsgFullDir,xsgTargetDir,hdlFileList);

    [netlistFileList,otherFileList]=targetcodegen.xilinxisesysgendriver.extractXSGTargetFiles(xsgFullDir);
    copyFiles(xsgFullDir,targetDir,[netlistFileList,otherFileList]);
    targetcodegen.xilinxutildriver.addXilinxOtherTargetFiles(otherFileList);
    targetcodegen.xilinxutildriver.addXilinxNetlistFiles(netlistFileList);
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

function xsgCodeGen(xsgBlk,xsgFullDir,libName)



    isMdlCompiled=~isempty(get_param(get_param(xsgBlk,'Parent'),'CompiledSampleTime'));
    mdlObj=get_param(bdroot(xsgBlk),'Object');
    if(isMdlCompiled)
        mdlObj.term;
    end
    status=xlGenerateButton(xsgBlk);
    if(status~=0)
        error(message('hdlcoder:validate:xsgcodegenfailure',[get_param(xsgBlk,'parent'),'/',get_param(xsgBlk,'name')],status));
    end
    if(isMdlCompiled)
        mdlObj.init;
    end
    xlSwitchLibrary(xsgFullDir,'work',libName);
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
        if(isCe(port))
            ceNames{end+1}=portNames{i};%#ok<*AGROW>
            ceRates(end+1)=eval(['designInfoStruct.ports.',portNames{i},'.attributes.period']);
        elseif(isClk(port))
            clkNames{end+1}=portNames{i};
            clkRates(end+1)=eval(['designInfoStruct.ports.',portNames{i},'.attributes.period']);
        elseif(isCeclr(port))



            ceclrNames{end+1}=portNames{i};
        elseif(isDataIn(port))
            inportNames{end+1}=portNames{i};
            srcBlock=eval(['designInfoStruct.ports.',portNames{i},'.attributes.source_block']);
            inportIdx(end+1)=getInportIdx(srcBlock);
        elseif(isDataOut(port))
            outportNames{end+1}=portNames{i};
            srcBlock=eval(['designInfoStruct.ports.',portNames{i},'.attributes.source_block']);
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
    bool=isfield(port.attributes,'isCe');
    if(bool)
        bool=port.attributes.isCe;
    end
end

function bool=isClk(port)
    bool=isfield(port.attributes,'isClk');
    if(bool)
        bool=port.attributes.isClk;
    end
end

function bool=isCeclr(port)
    bool=isfield(port.attributes,'isClr');
    if(bool)
        bool=port.attributes.isClr;
    end
end

function bool=isDataIn(port)
    bool=strcmpi(port.direction,'in')...
    &&isfield(port.attributes,'simulinkName')...
    &&(~isempty(port.attributes.simulinkName));
end

function bool=isDataOut(port)
    bool=strcmpi(port.direction,'out')...
    &&isfield(port.attributes,'simulinkName')...
    &&(~isempty(port.attributes.simulinkName));
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




