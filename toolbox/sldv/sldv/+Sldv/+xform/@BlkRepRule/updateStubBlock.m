function updateStubBlock(obj,blockInfo)







    obj.ReplacementBlockUpdatedOnInstance=true;

    BlockH=blockInfo.ReplacementInfo.BlockToReplaceH;
    blkReplacer=Sldv.xform.BlkReplacer.getInstance();

    obj.ReplacementLib=blockInfo.ReplacementInfo.LibForStubBlocks;

    origBlkPos=get_param(BlockH,'Position');
    widthBlk=origBlkPos(3)-origBlkPos(1);
    heightBlk=origBlkPos(4)-origBlkPos(2);

    targetBlock=['sldvBlockReplacementSubsysCopy_',get_param(blockInfo.BlockH,'Name')];




    spacing=50;
    [xPos,yPos]=Sldv.xform.BlkRepRule.findLocation(obj.ReplacementLib,spacing,widthBlk);
    subsystemPathOnLib=[obj.ReplacementLib,'/',targetBlock];
    position=[xPos,yPos,xPos+widthBlk,yPos+heightBlk];
    orientations=get_param(BlockH,'Orientation');
    namePlacement=get_param(BlockH,'NamePlacement');
    blkReplacer.addBlock('simulink/User-Defined Functions/MATLAB Function',...
    subsystemPathOnLib,...
    'Position',position,...
    'Orientation',orientations,...
    'NamePlacement',namePlacement);


    sfObj=getSFObj(obj.ReplacementLib,targetBlock);
    [sfObj.Script,stubPortNameMap]=create_stub_script(blockInfo);



    configurePortDataTypes(sfObj,blockInfo,stubPortNameMap);


    obj.ReplacementBlk=['./',targetBlock];
end

function configurePortDataTypes(sfObj,blockInfo,stubPortNameMap)
    portBlocks=blockInfo.SsPortBlks;
    portBlockMap=getSFPortBlockMap(sfObj);

    for i=1:length(portBlocks)
        portIOInfo=blockInfo.CompIOInfo(i);
        portName=stubPortNameMap(get_param(portIOInfo.block,'Name'));
        portObj=portBlockMap(portName);
        if isempty(portIOInfo.bus)
            portObj.DataType=portIOInfo.portAttributes.DataType;
        else
            portObj.DataType=['Bus: ',portIOInfo.busName];
        end
    end
end

function sfObj=getSFObj(lib,block)
    rt=sfroot;
    m=rt.find('-isa','Stateflow.Machine','name',lib);
    sfObj=m.find('-isa','Stateflow.EMChart','name',block);
end

function portBlockMap=getSFPortBlockMap(sfObj)

    portBlockMap=containers.Map;

    for i=1:length(sfObj.Inputs)
        input=sfObj.Inputs(i);
        portBlockMap(input.Name)=input;
    end
    for i=1:length(sfObj.Outputs)
        output=sfObj.Outputs(i);
        portBlockMap(output.Name)=output;
    end
end

function[str,stubPortNameMap]=create_stub_script(blockInfo)

    scriptName='stub_script';
    [ssInBlkHs,ssOutBlkHs,stubPortNameMap]=portBlockHdls(blockInfo);

    inBlkName=cellstr(get_param(ssInBlkHs,'Name'))';
    inNames=cellfun(@(x)stubPortNameMap(x),inBlkName,'UniformOutput',false);

    outBlkName=cellstr(get_param(ssOutBlkHs,'Name'))';
    outNames=cellfun(@(x)stubPortNameMap(x),outBlkName,'UniformOutput',false);

    inparams=['(',strjoin(inNames',', '),')'];
    outparams=['[',strjoin(outNames',', '),']'];

    scriptHeader=['function ',outparams,' = ',scriptName,inparams];
    scriptHeader=[scriptHeader,newline,'%#codegen'];

    scriptFooter='end';

    scriptBody=getStubBody(blockInfo,stubPortNameMap);
    str=strjoin({scriptHeader,scriptBody,scriptFooter},newline);
end

function stubBody=getStubBody(blockInfo,stubPortNameMap)
    stubStr={};

    [~,ssOutBlkIOBuses]=portBlockSignalInfo(blockInfo);


    for i=1:length(ssOutBlkIOBuses)
        stubStr{end+1}=getStubInstr(ssOutBlkIOBuses{i},stubPortNameMap);%#ok<AGROW>
    end
    stubBody=strjoin(stubStr,newline);
end

function[ssInBlkHs,ssOutBlkHs,portNamesMap]=portBlockHdls(blockInfo)
    ssInBlkHs=[];
    ssOutBlkHs=[];
    portNamesMap=containers.Map;

    portBlocks=blockInfo.SsPortBlks;
    in_idx=0;
    out_idx=0;

    for i=1:length(portBlocks)
        if(strcmpi(get_param(portBlocks(i),'BlockType'),'Inport'))
            ssInBlkHs(end+1)=portBlocks(i);%#ok<AGROW>
            portNamesMap(get_param(portBlocks(i),'Name'))=['i',num2str(in_idx)];
            in_idx=in_idx+1;
        else
            ssOutBlkHs(end+1)=portBlocks(i);%#ok<AGROW>
            portNamesMap(get_param(portBlocks(i),'Name'))=['o',num2str(out_idx)];
            out_idx=out_idx+1;
        end
    end
end

function[ssInBlkAttrs,ssOutBlkAttrs]=portBlockSignalInfo(blockInfo)
    ssInBlkAttrs={};
    ssOutBlkAttrs={};

    portBlocks=blockInfo.SsPortBlks;

    for i=1:length(portBlocks)
        portIOInfo=blockInfo.CompIOInfo(i);
        if(strcmpi(get_param(portBlocks(i),'BlockType'),'Inport'))
            ssInBlkAttrs{end+1}=portIOInfo.flatSignalInfo;%#ok<AGROW>
        else
            ssOutBlkAttrs{end+1}=portIOInfo.flatSignalInfo;%#ok<AGROW>
        end
    end
end

function stubInstr=getStubInstr(portCompiledInfo,stubPortNameMap)

    stubInstrArr={};

    for i=1:length(portCompiledInfo)
        elem=portCompiledInfo(i);

        if strcmp(elem.DataType,'boolean')
            stubInstrArr{end+1}=[stubPortNameMap(elem.SignalPath),' = '...
            ,'sldv.stub('...
            ,'logical','(zeros('...
            ,getDimensionStr(elem.Dimensions),')));'];%#ok<AGROW>
        else
            stubInstrArr{end+1}=[stubPortNameMap(elem.SignalPath),' = '...
            ,'sldv.stub('...
            ,elem.DataType,'(zeros('...
            ,getDimensionStr(elem.Dimensions),')));'];%#ok<AGROW>
        end
    end

    stubInstr=strjoin(stubInstrArr,newline);
end

function dimStr=getDimensionStr(dimensions)

    if length(dimensions)==1
        dimStr=[num2str(dimensions),', 1'];
    else
        dimensionsStr=cell(1,length(dimensions));
        for i=1:length(dimensions)
            dimensionsStr{i}=num2str(dimensions(i));
        end
        dimStr=strjoin(dimensionsStr,',');
    end
end