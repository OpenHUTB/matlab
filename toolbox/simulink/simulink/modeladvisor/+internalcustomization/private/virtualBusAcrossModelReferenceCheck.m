function ResultDescription=virtualBusAcrossModelReferenceCheck(system)



    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    check=mdladvObj.ActiveCheck();
    checkID=check.getID();

    looper=UpgradeAdvisor.UpgradeLooper();
    checkData=looper.getCheckData(checkID);

    if(isempty(checkData))
        checkData.modelInfo=containers.Map('KeyType','char','ValueType','any');
        checkData.busUsesVardims=containers.Map('KeyType','char','ValueType','logical');
        checkData.upgradedLibraryBlocks=containers.Map('KeyType','char','ValueType','logical');
        looper.setCheckData(checkID,checkData);
    end

    checkData=loc_analyzeOneModel(system,checkData);
    looper.setCheckData(checkID,checkData);

    ResultDescription=loc_ReportResult(mdladvObj,checkData.modelInfo(system));
end



function ResultDescription=loc_ReportResult(mdladvObj,modelInfo)
    inports=modelInfo.inports;
    outports=modelInfo.outports;
    modelBlocks=modelInfo.modelBlocks;

    inportsU=inports(modelInfo.inportNeedsUpdate);
    outportsU=outports(modelInfo.outportNeedsUpdate);
    modelBlocksU=modelBlocks(modelInfo.modelBlockNeedsUpdate);

    ResultDescription={};
    ResultDescription{end+1}=loc_createFormatTable(inportsU,...
    DAStudio.message('ModelAdvisor:engine:MACheckVirtualBusAcrossModelReference_InportInfo'),...
    DAStudio.message('ModelAdvisor:engine:MACheckVirtualBusAcrossModelReference_InportPass'),...
    DAStudio.message('ModelAdvisor:engine:MACheckVirtualBusAcrossModelReference_InportWarn'),...
    DAStudio.message('ModelAdvisor:engine:MACheckVirtualBusAcrossModelReference_InportAction'));

    ResultDescription{end+1}=loc_createFormatTable(outportsU,...
    DAStudio.message('ModelAdvisor:engine:MACheckVirtualBusAcrossModelReference_OutportInfo'),...
    DAStudio.message('ModelAdvisor:engine:MACheckVirtualBusAcrossModelReference_OutportPass'),...
    DAStudio.message('ModelAdvisor:engine:MACheckVirtualBusAcrossModelReference_OutportWarn'),...
    DAStudio.message('ModelAdvisor:engine:MACheckVirtualBusAcrossModelReference_OutportAction'));

    ResultDescription{end+1}=loc_createFormatTable(modelBlocksU,...
    DAStudio.message('ModelAdvisor:engine:MACheckVirtualBusAcrossModelReference_ModelInfo'),...
    DAStudio.message('ModelAdvisor:engine:MACheckVirtualBusAcrossModelReference_ModelPass'),...
    DAStudio.message('ModelAdvisor:engine:MACheckVirtualBusAcrossModelReference_ModelWarn'),...
    DAStudio.message('ModelAdvisor:engine:MACheckVirtualBusAcrossModelReference_ModelAction'));

    noIssue=isempty(inportsU)&&isempty(outportsU)&&isempty(modelBlocksU);

    if noIssue
        mdladvObj.setCheckResultStatus(true);
        mdladvObj.setActionEnable(false);
    else
        mdladvObj.setCheckResultStatus(false);
        mdladvObj.setActionEnable(true);
    end
end




function ft=loc_createFormatTable(blockList,info,passText,warnText,actionText)
    ft=ModelAdvisor.FormatTemplate('ListTemplate');
    ft.setInformation(info);

    if(isempty(blockList))
        ft.setSubResultStatus('Pass');
        ft.setSubResultStatusText(passText);
    else
        ft.setSubResultStatus('Warn');
        ft.setSubResultStatusText(warnText);
        ft.setRecAction(actionText);
        ft.setListObj(cellfun(@(b)get_param(b,'Object'),blockList,'UniformOutput',false));
    end
end




function[checkData]=loc_analyzeOneModel(model,checkData)

    origSimMode=get_param(model,'SimulationMode');
    if(~strcmp(origSimMode,'Normal'))
        set_param(model,'SimulationMode','Normal');
        ocSimMode=onCleanup(@()set_param(model,'SimulationMode',origSimMode));
    end


    didRTWCompile=false;
    if(builtin('_license_checkout','Real-Time_Workshop','quiet')==0)

        try


            output=evalc([model,'([], [], [], ''compileForRTW'');']);
            disp(output);
            didRTWCompile=true;
        catch
            feval(model,[],[],[],'compile');
        end
    else
        feval(model,[],[],[],'compile');
    end
    ocTerm=onCleanup(@()feval(model,[],[],[],'term'));

    modelInfo=[];
    modelInfo.inports=loc_findRootBlockType(model,'Inport');
    modelInfo.outports=loc_findRootBlockType(model,'Outport');





    [~,modelBlocks]=find_mdlrefs(model,'AllLevels',false,...
    'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
    modelBlocks=cellfun(@loc_getRefBlockForBlock,modelBlocks,'UniformOutput',false);
    modelBlocks=unique(modelBlocks);
    upgradedBlocks=checkData.upgradedLibraryBlocks.keys();
    modelInfo.modelBlocks=setdiff(modelBlocks,upgradedBlocks);

    [checkData,modelInfo]=loc_analyzeRootPorts(model,checkData,modelInfo,didRTWCompile);
    [modelInfo]=loc_analyzeModelBlocks(checkData,modelInfo);

    checkData.modelInfo(model)=modelInfo;

    ocTerm.delete();
end




function[modelInfo]=loc_analyzeModelBlocks(checkData,modelInfo)
    modelBlocks=modelInfo.modelBlocks;
    numModelBlocks=length(modelBlocks);
    modelBlockNeedsUpdate=false(1,numModelBlocks);

    for modelIdx=1:numModelBlocks
        modelBlock=modelBlocks{modelIdx};
        system=strtok(modelBlock,'/');
        load_system(system);
        refModel=get_param(modelBlock,'ModelName');

        if(checkData.modelInfo.isKey(refModel))
            refModelInfo=checkData.modelInfo(refModel);
            refOutportNeedsUpdate=refModelInfo.outportNeedsUpdate;
            modelBlockNeedsUpdate(modelIdx)=any(refOutportNeedsUpdate);
        end
    end

    modelInfo.modelBlockNeedsUpdate=modelBlockNeedsUpdate;
end





function[checkData,modelInfo]=loc_analyzeRootPorts(model,checkData,modelInfo,didRTWCompile)
    vbIn=cellfun(@loc_rootPortIsVirtualBus,modelInfo.inports);
    vbOut=cellfun(@loc_rootPortIsVirtualBus,modelInfo.outports);

    numInports=length(modelInfo.inports);
    inportNeedsUpdate=false(1,numInports);

    numOutports=length(modelInfo.outports);
    outportNeedsUpdate=false(1,numOutports);

    hasVB=any(vbIn)||any(vbOut);
    if(hasVB)
        usesFPC=loc_doesModelUsesFunctionPrototypeControl(model);
        usesCPPArgs=loc_doesModelUsesCPPWithArguments(model);

        if(usesFPC||usesCPPArgs)
            inportNeedsUpdate=vbIn;
            outportNeedsUpdate=vbOut;
        else
            for inIdx=1:numInports
                if(vbIn(inIdx)&&~inportNeedsUpdate(inIdx))
                    inport=modelInfo.inports{inIdx};
                    busName=loc_getBusNameForRootPort(inport);
                    [usesVardims,checkData]=loc_doesBusUseVardims(model,busName,checkData);
                    inportNeedsUpdate(inIdx)=usesVardims;
                end
            end

            for outIdx=1:numOutports
                if(vbOut(outIdx)&&~outportNeedsUpdate(outIdx))
                    outport=modelInfo.outports{outIdx};
                    busName=loc_getBusNameForRootPort(outport);
                    [usesVardims,checkData]=loc_doesBusUseVardims(model,busName,checkData);
                    usesStorageClass=loc_doesBusOutportHaveStorageClass(outport,didRTWCompile);
                    nvToVExportFunction=loc_NonVirtualToVirtualInExportFunctionModel(outport,model);
                    outportNeedsUpdate(outIdx)=usesVardims||usesStorageClass||nvToVExportFunction;
                end
            end
        end
    end

    modelInfo.inportNeedsUpdate=inportNeedsUpdate;
    modelInfo.outportNeedsUpdate=outportNeedsUpdate;
end




function nvToVExportFunction=loc_NonVirtualToVirtualInExportFunctionModel(outport,model)

    nvToVExportFunction=false;

    isExportFunction=strcmp(get_param(model,'IsExportFunctionModel'),'on');
    if(isExportFunction)
        phs=get_param(outport,'PortHandles');
        ph=phs.Inport(1);
        busType=get_param(ph,'CompiledBusType');
        nvToVExportFunction=strcmp(busType,'NON_VIRTUAL_BUS');
    end
end





function usesStorageClass=loc_doesBusOutportHaveStorageClass(outport,didRTWCompile)
    if(didRTWCompile)
        phs=get_param(outport,'PortHandles');
        ph=phs.Inport(1);
        storageClass=get_param(ph,'CompiledRTWStorageClass');
        usesStorageClass=~strcmp(storageClass,'Auto');
    else
        usesStorageClass=false;
    end
end





function usesFPC=loc_doesModelUsesFunctionPrototypeControl(model)
    fpcObj=RTW.getFunctionSpecification(model);
    usesFPC=~isempty(fpcObj)&&isa(fpcObj,'RTW.ModelSpecificCPrototype');
end







function usesCPPArgs=loc_doesModelUsesCPPWithArguments(model)
    argObj=RTW.getClassInterfaceSpecification(model);
    usesCPPArgs=~isempty(argObj)&&isa(argObj,'RTW.ModelCPPArgsClass');
end








function[usesVarDims,checkData]=loc_doesBusUseVardims(model,busname,checkData)
    if(checkData.busUsesVardims.isKey(busname))
        usesVarDims=checkData.busUsesVardims(busname);
        return;
    end

    usesVarDims=false;

    busObj=evalinGlobalScope(model,busname);
    numElems=length(busObj.Elements);
    for i=1:numElems
        busElem=busObj.Elements(i);
        busElemDT=busElem.DataType;

        if(loc_isDataTypeBus(busElemDT))
            [usesVarDims,checkData]=loc_doesBusUseVardims(model,loc_getBusNameFromDataType(busElemDT),checkData);
        else
            usesVarDims=strcmp(busElem.DimensionsMode,'Variable');
        end

        if(usesVarDims)
            checkData.busUsesVardims(busname)=usesVarDims;
            return;
        end
    end

    checkData.busUsesVardims(busname)=usesVarDims;
end






function blocks=loc_findRootBlockType(model,type)
    blocks=find_system(model,'SearchDepth',1,'BlockType',type);
end







function isBus=loc_isDataTypeBus(datatype)
    isBus=regexp(datatype,'^Bus:\s');
end








function busName=loc_getBusNameFromDataType(datatype)
    if(loc_isDataTypeBus(datatype))
        busName=regexprep(datatype,'^Bus:\s+','');
    else
        busName=[];
    end
end







function busName=loc_getBusNameForRootPort(port)
    datatype=get_param(port,'OutDataTypeStr');
    busName=loc_getBusNameFromDataType(datatype);
end









function isVB=loc_rootPortIsVirtualBus(port)
    datatype=get_param(port,'OutDataTypeStr');
    if(loc_isDataTypeBus(datatype))
        outputAsStruct=get_param(port,'BusOutputAsStruct');
        isVB=strcmp(outputAsStruct,'off');
    else
        isVB=false;
    end
end







function refBlock=loc_getRefBlockForBlock(block)
    refBlock=get_param(block,'ReferenceBlock');
    if(isempty(refBlock))

        refBlock=block;
    end
end
