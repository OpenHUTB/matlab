function addBusSubsystemBlocks(rManager)











    portStructsVec=rManager.PortsToAddBusSubsystemBlock;

    for busIter=1:numel(portStructsVec)

        portStruct=portStructsVec(busIter);
        try
            gndBlk=get_param(portStruct.SrcPort,'Parent');

            if isempty(portStruct.OrigBlkCell)

                modelName=i_getRootBDNameFromPath(getfullname(gndBlk));
            else

                modelName=cellfun(@(x)i_getRootBDNameFromPath(x),portStruct.OrigBlkCell,'UniformOutput',false);
            end


            busObjName=convertSigHierToBusObj(rManager,modelName,...
            portStruct.CompiledSignalHierarchy,portStruct.CompiledBusStruct);


            if~isempty(busObjName)



                constantBlkH=replaceGroundBlockWithBusSubsystemBlock(rManager,portStruct);


                set_param(constantBlkH,'Value','0');

                set_param(constantBlkH,'OutDataTypeStr',['Bus: ',busObjName]);

            end

        catch me %#ok<NASGU>
        end

    end

end



function constantBlkH=replaceGroundBlockWithBusSubsystemBlock(rManager,portStruct)

    gndBlk=get_param(portStruct.SrcPort,'Parent');
    gndBlkSignalName=get_param(portStruct.SrcPort,'Name');

    blk=get_param(portStruct.DstPort,'Parent');

    currGraph=get_param(gndBlk,'Parent');

    blkType=Simulink.variant.reducer.InsertedBlockType.BUS_SUBSYSTEM;
    [blkAddPath,blkAddTag]=blkType.getBlockPath();

    ssBlkH=add_block(blkAddPath,...
    [blk,'_BUS_SUBSYSTEM'],...
    'MakeNameUnique','on',...
    'Position',get_param(gndBlk,'Position'),...
    'ShowName','off',...
    'Tag',blkAddTag);

    rManager.BlocksInserted(end+1)=ssBlkH;


    ssBlkMask=Simulink.Mask.create(ssBlkH);
    ssBlkMask.Display='disp([''b''])';

    gndBlkPortH=get_param(gndBlk,'PortHandles');

    try
        delete_line(get(gndBlkPortH.Outport(1),'Line'));
    catch ex %#ok<NASGU>
    end

    try
        delete_block(gndBlk);
    catch ex %#ok<NASGU>
    end

    ssPortH=get(ssBlkH,'PortHandles');


    set(ssPortH.Outport,'Name',gndBlkSignalName);

    add_line(currGraph,ssPortH.Outport,portStruct.DstPort,'AutoRouting','on');


    ssBlkPath=getfullname(ssBlkH);


    inPortBlkPath=[ssBlkPath,'/In1'];
    inPortBlkPos=get_param(inPortBlkPath,'Position');

    blkType=Simulink.variant.reducer.InsertedBlockType.BUS_SUBSYSTEM_CONSTANT;
    [blkAddPath,blkAddTag]=blkType.getBlockPath();

    constantBlkH=add_block(blkAddPath,...
    [ssBlkPath,'/Constant'],...
    'MakeNameUnique','on',...
    'Position',inPortBlkPos,...
    'ShowName','off',...
    'Tag',blkAddTag);

    rManager.BlocksInserted(end+1)=constantBlkH;

    inPortBlkPortH=get_param(inPortBlkPath,'PortHandles');
    lineH=get(inPortBlkPortH.Outport(1),'Line');
    Simulink.variant.reducer.utils.assert(lineH~=-1,'line is missing in a newly added subsystem');
    constantBlkDstPortH=get(lineH,'DstPortHandle');

    try
        delete_line(lineH);
    catch ex %#ok<NASGU>
    end

    try
        delete_block(inPortBlkPath);
    catch ex %#ok<NASGU>
    end

    constantBlkPortH=get(constantBlkH,'PortHandles');



    if strcmp('VIRTUAL_BUS',portStruct.CompiledBusType)


        outPortBlkPos=get_param([ssBlkPath,'/Out1'],'Position');



        sigCovPos=floor((outPortBlkPos+inPortBlkPos)/2);

        blkType=Simulink.variant.reducer.InsertedBlockType.BUS_SUBSYSTEM_SIGNAL_CONVERSION;
        [blkAddPath,blkAddTag]=blkType.getBlockPath();

        sigCovBlkH=add_block(blkAddPath,...
        [ssBlkPath,'/SignalConversion'],...
        'MakeNameUnique','on',...
        'Position',sigCovPos,...
        'ShowName','off',...
        'Tag',blkAddTag);

        rManager.BlocksInserted(end+1)=sigCovBlkH;


        set(sigCovBlkH,'ConversionOutput','Virtual Bus');

        sigCovBlkPortH=get(sigCovBlkH,'PortHandles');

        add_line(ssBlkPath,sigCovBlkPortH.Outport(1),constantBlkDstPortH,'AutoRouting','on');

        constantBlkDstPortH=sigCovBlkPortH.Inport(1);
    end

    add_line(ssBlkPath,constantBlkPortH.Outport,constantBlkDstPortH,'AutoRouting','on');



    blkType=Simulink.variant.reducer.InsertedBlockType.BUS_SUBSYSTEM_OUTPORT;
    [~,blkAddTag]=blkType.getBlockPath();
    set_param([ssBlkPath,'/Out1'],'Tag',blkAddTag);
end

function busObjName=convertSigHierToBusObj(rManager,modelName,sigHier,busStruct)






















    [busObjName,busObj]=convertSigHierToBusObjIntermediate(rManager,modelName,sigHier,busStruct);

    if~isempty(busObjName)
        return;
    end

    tempBusObj=Simulink.Bus();
    if isequal(tempBusObj,busObj)
        return;
    end

    busObjName=createBusObjIfNotPresent(rManager,modelName,busObj);

end

function busElem=convertSigHierToBusElem(rManager,modelName,sigHier,busStruct,sigNum)
























    busElem=Simulink.BusElement();
    busElem.Name=getSigNameFromHier(sigHier,sigNum);

    [existingBusObjName,busObj]=convertSigHierToBusObjIntermediate(rManager,modelName,sigHier,busStruct);

    if~isempty(existingBusObjName)
        busElem.DataType=existingBusObjName;
    elseif~isempty(busObj)
        busObjName=createBusObjIfNotPresent(rManager,modelName,busObj);
        busElem.DataType=busObjName;
    else
        busElem=populateBusElemAttribs(rManager,busElem,busStruct);
    end

end

function[existingBusObjName,newBusObj]=convertSigHierToBusObjIntermediate(rManager,modelName,sigHier,busStruct)

























    existingBusObjName='';
    newBusObj=[];

    if~isempty(sigHier.BusObject)
        existingBusObjName=sigHier.BusObject;
        return;
    end

    children=sigHier.Children;
    if~isempty(children)
        newBusObj=Simulink.Bus();
    end
    childrenBusStructsVec=busStruct.signals;

    for ii=1:numel(children)
        child=children(ii);
        childBusStruct=childrenBusStructsVec(ii);
        newBusObj.Elements(end+1)=convertSigHierToBusElem(rManager,modelName,child,childBusStruct,ii);
    end

end

function sigName=getSigNameFromHier(sigHier,sigNum)













    sigName=['signal',num2str(sigNum)];

    if~isempty(sigHier.SignalName)
        sigName=sigHier.SignalName;
    end

end


function busObjFound=checkIfBusObjIsPresent(modelName,busObj,busVarNames)






    busObjFound='';
    for varIdx=1:numel(busVarNames)
        busVarName=busVarNames{varIdx};
        if Simulink.data.existsInGlobal(modelName,busVarName)&&isequal(busObj,evalinGlobalScope(modelName,busVarName))
            busObjFound=busVarName;
            break;
        end
    end

end



function busObjName=getBusObjName(modelName,busObj)
    busObjName='';

    allVarNames={};
    if~iscell(modelName)
        vars=evalinGlobalScope(modelName,'whos');

        allVarNames={vars.name};
    else
        for ii=1:numel(modelName)
            vars=evalinGlobalScope(modelName{ii},'whos');
            allVarNames=unique([allVarNames,{vars.name}]);
        end
    end

    vars=vars(strcmp({vars.class},'Simulink.Bus'));
    busVarNames={vars.name};


    if~iscell(modelName)
        busObjFound=checkIfBusObjIsPresent(modelName,busObj,busVarNames);
        if~isempty(busObjFound)
            busObjName=busObjFound;
        end
    else
        for ii=1:numel(modelName)
            busObjFound=checkIfBusObjIsPresent(modelName{ii},busObj,busVarNames);
            if isempty(busObjFound)
                continue;
            end
            busObjName=busObjFound;
            break;
        end
    end


    if isempty(busObjName)
        busObjName=matlab.lang.makeUniqueStrings('busObjVRed',allVarNames);
    end
end


function busObjName=createBusObjIfNotPresent(rManager,modelName,busObj)







    busObjName=getBusObjName(modelName,busObj);

    Simulink.variant.reducer.utils.assert(~isempty(busObjName),'Bus object name cannot be empty here');

    function addBusObjName(x)
        idx=Simulink.variant.reducer.utils.searchNameInCell(x,{rManager.ProcessedModelInfoStructsVec.Name});
        Simulink.variant.reducer.utils.assert(~isempty(idx));

        if isempty(rManager.ProcessedModelInfoStructsVec(idx).BusObjectNames)
            rManager.ProcessedModelInfoStructsVec(idx).BusObjectNames={busObjName};
        else
            rManager.ProcessedModelInfoStructsVec(idx).BusObjectNames{end+1}=busObjName;
        end
    end

    function assignLocal(x)
        assigninGlobalScope(x,busObjName,busObj);
        addBusObjName(x);
    end

    if~iscell(modelName)
        assignLocal(modelName);
    else
        cellfun(@(x)assignLocal(x),modelName);
    end

end

function busElem=populateBusElemAttribs(rManager,busElem,busStruct)


    Simulink.variant.reducer.utils.assert(isempty(busStruct.signals),'Non-terminal bus signals reached for attribute specification')

    bMap=rManager.CompiledBusSrcPortAttribsMap;
    srcBlk=busStruct.src;

    Simulink.variant.reducer.utils.assert(bMap.isKey(busStruct.src),'Bus src block not found in the compiled map');
    compiledPortAttribsVec=bMap(srcBlk);

    srcPortNum=busStruct.srcPort;
    srcPortType='outport';

    boolIdx=arrayfun(@(x)searchByPortNumberAndType(x,srcPortNum,srcPortType),compiledPortAttribsVec);

    attrStruct=compiledPortAttribsVec(boolIdx);

    Simulink.variant.reducer.utils.assert(numel(attrStruct)==1,'More than one attrib struct found');

    modAttrStruct=Simulink.variant.reducer.utils.getSettableSignalAttributes(attrStruct);






















    if isfield(modAttrStruct,'SignalType')
        busElem=setAttrib(busElem,'Complexity',modAttrStruct.SignalType);
    end

    if isfield(modAttrStruct,'Dimensions')
        busElem=setAttrib(busElem,'Dimensions',modAttrStruct.Dimensions);
    end

    if isfield(modAttrStruct,'OutDataTypeStr')
        busElem=setAttrib(busElem,'DataType',modAttrStruct.OutDataTypeStr);
    end

    if isfield(modAttrStruct,'OutMin')
        busElem=setAttrib(busElem,'Min',modAttrStruct.OutMin);
    end

    if isfield(modAttrStruct,'OutMax')
        busElem=setAttrib(busElem,'Max',modAttrStruct.OutMax);
    end

    if isfield(modAttrStruct,'SampleTime')
        if strcmp('inf',modAttrStruct.SampleTime)
            modAttrStruct.SampleTime='';
        end
        busElem=setAttrib(busElem,'SampleTime',modAttrStruct.SampleTime);
    end

    if isfield(modAttrStruct,'Unit')
        busElem=setAttrib(busElem,'Unit',modAttrStruct.Unit);
    end
end




function status=searchByPortNumberAndType(struct,num,type)
    status=(struct.PortNumber==num)&&strcmp(type,struct.PortType);
end

function busElem=setAttrib(busElem,attrib,val)
    if~isempty(val)
        try
            busElem.(attrib)=val;
        catch ex %#ok<NASGU>
        end
    end
end


