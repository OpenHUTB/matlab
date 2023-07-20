function portAttributes=util_getIOportBus(blockH,strictBusErrors,runningForDvirSim,toExplodeComplexSignals)




    isBusElemPort=isBusElem(blockH);
    hasBEPOfNotBusType=false;


    ph=get_param(blockH,'porthandles');
    lineH=get_param(blockH,'LineHandles');
    if strcmp(get_param(blockH,'BlockType'),'Inport')
        portH=ph.Outport;
        if(lineH.Outport~=-1)&&~isBusElemPort
            signalName=get_param(lineH.Outport,'Name');
        else

            signalName='';
        end
        isOutPort=false;
    else
        portH=ph.Inport;
        if(lineH.Inport~=-1)&&~isBusElemPort
            signalName=get_param(lineH.Inport,'Name');
        else

            signalName='';
        end
        isOutPort=true;
    end

    compiledportPrm=Simulink.CompiledPortInfo(portH);
    if isOutPort&&runningForDvirSim








        lineH=get_param(portH,'Line');
        if lineH~=-1
            srcPortH=get_param(lineH,'SrcPortHandle');
            if srcPortH~=-1
                srcPortcompiledportPrm=Simulink.CompiledPortInfo(srcPortH);
                compiledportPrm.copySampleTimeInfo(srcPortcompiledportPrm);
            end
        end
    end
    if~isBusElemPort
        portAttributes.Dimensions=util_resolve_dimensions(...
        compiledportPrm.Dimensions,...
        bdroot(blockH));
        portAttributes.BlockPath=getfullname(blockH);
        portAttributes.SignalName=signalName;
        portAttributes.IsStructBus=compiledportPrm.IsStructBus;
        portAttributes.IsVirtualBus=strcmp(get_param(blockH,'UseBusObject'),'on')&&...
        strcmp(get_param(blockH,'BusOutputAsStruct'),'off');
    else


        busSelector=get_param(blockH,'portName');
        blkName=getfullname(blockH);%#ok<NASGU> 


        [busName,dimensions,virtuality]=util_getTopLvlBusDataForBEP(blockH);










        if strcmp(get_param(portH,'CompiledBusType'),'VIRTUAL_BUS')


            dimensions=1;
        end


        portAttributes.Dimensions=util_resolve_dimensions(...
        dimensions,...
        bdroot(blockH));
        portAttributes.BlockPath=getfullname(blockH);
        portAttributes.SignalName=signalName;
        portAttributes.IsVirtualBus=strcmp(virtuality,'VIRTUAL')||strcmp(virtuality,'INHERIT');
    end
    portAttributes.SampleTime=compiledportPrm.SampleTime;
    portAttributes.SampleTimeStr=compiledportPrm.SampleTimeStr;
    portAttributes.SamplingMode=compiledportPrm.SamplingMode;
    portAttributes.IsStruct=false;

    if strictBusErrors
        portAttributes.CompiledBusType=[];
        portAttributes.SignalHierarchy=[];
    elseif isBusElemPort
        portAttributes.CompiledBusType='NON_VIRTUAL_BUS';
        portAttributes.SignalHierarchy=sldvshareprivate('getSignalHirearchyInfo',blockH);
    else
        portAttributes.CompiledBusType=get_param(portH,'CompiledBusType');
        portAttributes.SignalHierarchy=get_param(portH,'SignalHierarchy');
    end








    if~isBusElemPort
        busElemNamePath=cr_to_space(get_param(blockH,'Name'));
    else
        busElemNamePath=get_param(blockH,'portName');


        if~isBus(busName,blockH)&&util_is_builtin_or_fxp_type(busName)
            hasBEPOfNotBusType=true;
            portAttributes.IsStructBus=false;
            portAttributes.CompiledBusType='NOT_BUS';
        end
    end


    modelH=bdroot(blockH);
    dataAccessor=Simulink.data.DataAccessor.create(get_param(modelH,'name'));
    if isBusElemPort&&~hasBEPOfNotBusType
        if~isOutPort

            portAttributes.IsStructBus=true;
        else


            if strcmp(busName,'auto')
                portAttributes.IsStructBus=false;
            else
                portAttributes.IsStructBus=true;
            end
        end
    end
    if~portAttributes.IsStructBus
        if sldvshareprivate('util_is_sltruct_type',compiledportPrm.AliasThruDataType,dataAccessor)
            portAttributes.IsStruct=true;
            structName=compiledportPrm.AliasThruDataType;
            structObj=sldvshareprivate('util_get_sltruct_type_from_name',structName,dataAccessor);
            flatSignalInfo=[];
            portAttributes.compiledInfo=...
            constructLeavesForStruct(structObj,structName,busElemNamePath,flatSignalInfo,dataAccessor,blockH);
        else
            if~isBusElemPort||hasBEPOfNotBusType
                portAttributes.compiledInfo.DataType=compiledportPrm.AliasThruDataType;
                portAttributes.compiledInfo.Complexity=compiledportPrm.Complexity;
                portAttributes.compiledInfo.Dimensions=util_resolve_dimensions(...
                compiledportPrm.Dimensions,...
                bdroot(blockH));
                portAttributes.compiledInfo.SignalPath=busElemNamePath;
                portAttributes.compiledInfo.Used=true;








                if isOutPort
                    if~strictBusErrors
                        portAttributes.IsVirtualBus=~isempty(get_param(portH,'CompiledBusStruct'));
                    else
                        portAttributes.IsVirtualBus=false;
                    end
                    portAttributes.compiledInfo.SampleTime=portAttributes.SampleTime;
                end
            else
                flatSignalInfo=[];
                portAttributes.compiledInfo=getBusCompiledInfo(blockH,flatSignalInfo,busSelector);
                if isempty(portAttributes.compiledInfo)
                    portAttributes.compiledInfo.DataType=compiledportPrm.AliasThruDataType;
                    portAttributes.compiledInfo.Complexity=compiledportPrm.Complexity;
                    portAttributes.compiledInfo.Dimensions=util_resolve_dimensions(...
                    compiledportPrm.Dimensions,...
                    bdroot(blockH));
                    portAttributes.compiledInfo.SignalPath=busElemNamePath;
                    portAttributes.compiledInfo.Used=true;
                end
            end
        end
    else
        if~isBusElemPort
            busName=compiledportPrm.AliasThruDataType;
        end
        try
            busObject=sl('slbus_get_object_from_name_withDataAccessor',busName,true,dataAccessor);
        catch ME
            if(strcmp(ME.identifier,'Simulink:utility:slUtilityBusObjectNotFoundInDataSources'))
                msg=getString(message('Sldv:Setup:BusObjectNotFoundInBaseWorkspace',busSelector));
                causeException=MException('Sldv:Setup:BusObjectNotFoundInBaseWorkspace',msg);
                ME=causeException;
            end
            throw(ME);
        end
        flatSignalInfo=[];
        busPath=regexprep(busName,'^dto(Dbl|Sgl|Scl)(Flt|Fxp)?_','');
        portAttributes.compiledInfo=constructLeaves(dataAccessor,busObject,busPath,busElemNamePath,flatSignalInfo,blockH);
    end

    if toExplodeComplexSignals
        portAttributes.compiledInfo=explodeComplexSignals(portAttributes.compiledInfo);
    end
end

function out=cr_to_space(in)
    out=in;
    if~isempty(in)
        out(in==10)=char(32);
    end
end

function out=isBus(busName,blockH)


    out=false;
    try
        out=~isempty(busName)&&isa(slResolve(busName,blockH),'Simulink.Bus');
    catch Mex %#ok<NASGU> 



    end
end

function flatSignalInfo=constructLeaves(dataAccessor,busObject,busPath,busElemNamePath,flatSignalInfo,blockH)
    for i=1:length(busObject.Elements)
        subBusObject=busObject.Elements(i);
        subBusElemNamePath=sprintf('%s.%s',busElemNamePath,subBusObject.Name);
        busName=subBusObject.DataType;
        [isLeaf,baseType]=isLeafType(busName,dataAccessor,blockH);
        if(isLeaf)
            subBusObject.DataType=baseType;
            flatSignalInfo=push_into_flatSignalInfo(flatSignalInfo,...
            subBusObject,...
            busPath,...
            subBusElemNamePath,...
            blockH);
        else
            [leafebusObject,busName]=Sldv.utils.getBusObjectFromName(busName,true,dataAccessor);

            subBusPath=sprintf('%s.%s',busPath,busName);
            flatSignalInfo=constructLeaves(dataAccessor,leafebusObject,subBusPath,subBusElemNamePath,flatSignalInfo,blockH);
        end
    end
end

function flatSignalInfo=constructLeavesForStruct(structObj,structPath,structElemNamePath,flatSignalInfo,dataAccessor,blockH)
    for i=1:length(structObj.Elements)
        subStructObject=structObj.Elements(i);
        subStructElemNamePath=sprintf('%s.%s',structElemNamePath,subStructObject.Name);
        structName=subStructObject.DataType;
        [isLeaf,baseType]=isLeafType(structName,dataAccessor,blockH);
        if isLeaf
            subStructObject.DataType=baseType;
            if isempty(flatSignalInfo)
                flatSignalInfo=get_struct_object_properties(subStructObject,structPath,subStructElemNamePath,blockH);
            else
                flatSignalInfo(end+1)=get_struct_object_properties(subStructObject,structPath,subStructElemNamePath,blockH);%#ok<AGROW>
            end
        else
            leafestructObject=sldvshareprivate('util_get_sltruct_type_from_name',structName,dataAccessor);
            subStructPath=sprintf('%s.%s',structPath,structName);
            flatSignalInfo=constructLeavesForStruct(leafestructObject,subStructPath,subStructElemNamePath,flatSignalInfo,dataAccessor,blockH);
        end
    end
end


function flatSignalInfo=push_into_flatSignalInfo(flatSignalInfo,subBusObject,busPath,busElemNamePath,blockH)
    if isempty(flatSignalInfo)
        flatSignalInfo=get_bus_object_properties(subBusObject,busPath,busElemNamePath,blockH);
    else
        flatSignalInfo(end+1)=get_bus_object_properties(subBusObject,busPath,busElemNamePath,blockH);
    end
end

function busObjectProperties=get_bus_object_properties(subBusObject,busPath,busElemNamePath,blockH)
    busObjectProperties.DataType=subBusObject.DataType;
    busObjectProperties.Complexity=subBusObject.Complexity;
    busObjectProperties.Dimensions=util_resolve_dimensions(...
    subBusObject.Dimensions,...
    bdroot(blockH));
    busObjectProperties.SampleTime=subBusObject.SampleTime;
    busObjectProperties.SamplingMode=subBusObject.SamplingMode;
    busObjectProperties.BusObjPath=busPath;
    busObjectProperties.SignalPath=busElemNamePath;
    busObjectProperties.Used=true;
end

function structObjectProperties=get_struct_object_properties(subStructObject,structPath,subStructElemNamePath,blockH)
    structObjectProperties.DataType=subStructObject.DataType;
    structObjectProperties.Complexity=subStructObject.Complexity;
    structObjectProperties.Dimensions=util_resolve_dimensions(...
    subStructObject.Dimensions,...
    bdroot(blockH));
    structObjectProperties.StructObjPath=structPath;
    structObjectProperties.SignalPath=subStructElemNamePath;
    structObjectProperties.Used=true;
end


function[out,baseTypeStr]=isLeafType(dataTypeStr,dataAccessor,blockH)
    baseTypeStr=dataTypeStr;
    if util_is_simulink_builtin(dataTypeStr)||...
        util_is_fxp_type(dataTypeStr,blockH)
        out=true;
    else
        [isEnum,className]=util_is_enum_type(dataTypeStr);
        if isEnum
            out=true;
            baseTypeStr=className;
        else
            out=false;
        end
    end
    if~out
        out=strncmp(dataTypeStr,'fixdt',5)||...
        strncmp(dataTypeStr,'numerictype',11);
        if(~out)

            [out,baseTypeStr]=util_is_sim_numeric_type(dataTypeStr,dataAccessor);
        end
        if~out

            [out,baseTypeStr]=util_is_sim_alias_type(dataTypeStr,dataAccessor);
        end
    end
end

function explodedCompiledInfo=explodeComplexSignals(compiledInfo)


    indicesToExplode=findComplexSignals(compiledInfo);
    numToExplode=length(indicesToExplode);
    totalSizeNew=length(compiledInfo)+numToExplode;
    explodedCompiledInfo(totalSizeNew)=compiledInfo(end);
    unexplodedIndex=0;
    explodedIndex=0;
    while explodedIndex<totalSizeNew
        unexplodedIndex=unexplodedIndex+1;
        explodedIndex=explodedIndex+1;
        if ismember(unexplodedIndex,indicesToExplode)
            explodedCompiledInfo(explodedIndex)=compiledInfo(unexplodedIndex);
            explodedIndex=explodedIndex+1;
        end
        explodedCompiledInfo(explodedIndex)=compiledInfo(unexplodedIndex);
    end
end

function indices=findComplexSignals(compiledInfo)
    indices=[];
    for signalIndex=1:length(compiledInfo)
        if strcmp(compiledInfo(signalIndex).Complexity,'complex')
            indices=[indices,signalIndex];%#ok<AGROW>
        end
    end
end


