function varargout=mdlrefddg_cb(action,varargin)







    warnState=warning('off','backtrace');
    cleanupWarning=onCleanup(@()warning(warnState));

    try
        out=loc_callbackSwitchYard(action,varargin{:});
        for i=1:length(out)
            varargout{i}=out{i};%#ok<AGROW>
        end
    catch E


        throwAsCaller(E);
    end
end



function out=loc_callbackSwitchYard(action,varargin)
    out={};


    dialogH=varargin{1};

    if strncmp(action,'do',2)&&~isempty(dialogH)
        source=dialogH.getDialogSource;
        block=source.getBlock;
    end

    switch action

    case 'doOpen'
        i_doOpen(dialogH,'ModelNameDialog');

    case 'doBrowse'
        tag=varargin{2};
        isSlimDialog=false;
        if(nargin>4)
            if(strcmp(varargin{3},'ForTestingPurposes'))
                FileName=varargin{4};
                PathName=varargin{5};
                FilterIndex=varargin{6};
                i_doBrowse(dialogH,tag,isSlimDialog,FileName,PathName,FilterIndex);
            else
                i_doBrowse(dialogH,tag,isSlimDialog);
            end
        else
            isSlimDialog=varargin{3};
            i_doBrowse(dialogH,tag,isSlimDialog);
        end

    case 'doPreApply'

        try
            out=loc_doPreApply(dialogH,block,source);
        catch me
            out{1}=false;
            out{2}=me.message;
        end

    case 'doClose'
        i_doClose(dialogH);

    case 'EnableBrowse'
        out{1}=i_ShouldBrowseButtonBeEnabled(varargin{:});

    case 'EnableOpen'
        out{1}=i_ShouldOpenButtonBeEnabled(varargin{:});

    case 'EnableModelName'
        out{1}=i_ShouldModelNameBoxBeEnabled(varargin{:});

    case 'EnableSimulationMode'
        out{1}=i_ShouldSimModeBeEnabled(varargin{:});

    case 'EnableParamArgValues'
        out{1}=i_ShouldParamArgValuesBeEnabled(varargin{:});

    case 'doSimulationMode'
        source.UserData.CodeInterfaceActive=...
        i_ShouldCodeInterfaceBeActive(dialogH,block,source,varargin{2});
        slDialogUtil(source,'sync',dialogH,'combobox','SimulationMode');

    case 'SupportIRTPorts'
        out{1}=i_SupportIRTPorts(varargin{:});

    case 'SupportPeriodicEventPorts'
        out{1}=i_SupportPeriodicEventPorts(varargin{:});

    case 'SupportExportedPartitions'
        out{1}=i_supportExportedPartitions(varargin{:});

    case 'ChooseSetPortDiscreteRatesOpt'
        i_ChooseSetPortDiscreteRatesOpt(dialogH);

    case 'SupportSampleTimeParameterization'
        out{1}=i_supportSampleTimeParameterization(varargin{:});

    case 'SetModelArgs'
        loc_SetModelArgs(varargin{:});

    case 'SetInstSpecModelArgs'
        loc_SetInstSpecArguVals(varargin{:});

    case 'doExpandAll'
        i_doExpandAll(dialogH);
    case 'doCollapseAll'
        i_doCollapseAll(dialogH);
    end
end

function i_doCollapseAll(dialogH)
    ssComponent=dialogH.getWidgetInterface('ModelRefArgumentsDDGTreeSpreadsheet');
    ssComponent.collapseAll();
end

function i_doExpandAll(dialogH)
    ssComponent=dialogH.getWidgetInterface('ModelRefArgumentsDDGTreeSpreadsheet');
    ssComponent.expandAll();
end



function isActive=i_ShouldCodeInterfaceBeActive(dialogH,block,...
    source,isSlimDialog)

    simModeProp='SimulationMode';

    propValues=block.getPropAllowedValues(simModeProp);

    widgetValue=dialogH.getWidgetValue('SimulationMode');

    widgetString=propValues{widgetValue+1};
    isActive=shouldCodeInterfaceBeEnabled(widgetString);

    if isSlimDialog
        slDialogUtil(source,'sync',dialogH,'combobox',simModeProp);
    end
end



function isEnabled=i_ShouldBrowseButtonBeEnabled(h)
    isEnabled=~(h.isHierarchySimulating||h.isLinked||...
    (Simulink.harness.internal.isHarnessCUT(h.handle)&&...
    ~Simulink.harness.internal.isActiveHarnessCUTPropEditable(h.handle))||...
    slInternal('IsChildOfVAS',h.handle));
end





function isEnabled=i_ShouldOpenButtonBeEnabled(~,~)
    isEnabled=true;
end



function isEnabled=i_ShouldModelNameBoxBeEnabled(source,block)
    isEnabled=~(source.UserData.DisableWholeDialog||block.isLinked||...
    block.isHierarchySimulating||(Simulink.harness.internal.isHarnessCUT(block.handle)&&...
    ~Simulink.harness.internal.isActiveHarnessCUTPropEditable(block.handle))||...
    slInternal('IsChildOfVAS',source.getBlock.Handle));
end



function isEnabled=i_ShouldSimModeBeEnabled(source,modelName)
    isEnabled=true;

    if(source.UserData.DisableWholeDialog||...
        source.isHierarchySimulating||source.isLinked)
        isEnabled=false;
        return;
    end


    protected=slInternal('getReferencedModelFileInformation',modelName);
    if protected



        runConsistencyChecks='runNoConsistencyChecks';
        opts=Simulink.ModelReference.ProtectedModel.getOptions(modelName,...
        runConsistencyChecks);
        if~isempty(opts)
            if opts.hasSILPILSupportOnly


                isEnabled=opts.hasSILSupport&&opts.hasPILSupport;
            else


                isEnabled=opts.hasSILSupport||opts.hasPILSupport;
            end
            return;
        end
    end
end



function isEnabled=i_ShouldParamArgValuesBeEnabled(source)



    isEnabled=~source.UserData.DisableWholeDialog;


    if(isEnabled)
        blockH=source.getBlock.Handle;
        aMaskObj=Simulink.Mask.get(blockH);
        if~isempty(aMaskObj)
            isEnabled=~aMaskObj.isAutoGeneratedModelBlockMask();
        end
    end

end


function i_doOpen(dialogH,tag)

    if isempty(dialogH)||~ishandle(dialogH)
        DAStudio.error('Simulink:dialog:DDGInvalidDialogHandle','mdlrefddg_cb.m');
    end


    modelName=dialogH.getWidgetValue(tag);
    if isempty(modelName)||~ischar(modelName)
        return;
    end

    if~isempty(modelName)
        import Simulink.ModelReference.ProtectedModel.*;
        protected=slInternal('getReferencedModelFileInformation',...
        modelName);
        if protected

            if isempty(dialogH.getSource.getBlock)||...
                isempty(dialogH.getSource.getBlock.getParent)
                parentName=modelName;
            else
                parentName=dialogH.getSource.getBlock.getParent.Name;
            end
            if~openOrThrowToMessageViewer(parentName,modelName)
                return;
            end
        end
    end



    loc_OpenModel(dialogH,modelName);
end


function loc_OpenModel(dialogH,modelName)





    blockH=dialogH.getDialogSource.getBlock.Handle;








    dialogName=get_param(blockH,'ModelNameInternal');
    [~,modelNameNoExt]=fileparts(modelName);
    differentName=~strcmp(dialogName,modelNameNoExt);

    isProtected=strcmp(get_param(blockH,'ProtectedModel'),'on');
    isDefaultName=strcmp(get_param(blockH,'ModelNameInternal'),...
    slInternal('getModelRefDefaultModelName'));

    if(differentName||isProtected||isDefaultName)
        slInternal('openModelFromModelBlock',blockH,modelName);
    else
        load_system(modelNameNoExt);
        bp=dialogH.getDialogSource.UserData.gcbp;
        bp.open('force','on');
    end
end


function i_doBrowse(dialogH,tag,isSlimDialog,varargin)

    browser=ModelReferenceBrowser();
    browser.browse(dialogH,tag,isSlimDialog,varargin{:});

end



function loc_set_argument_values(block,namesList,valuesList,defaultsList)





    values=[];

    for i=1:length(namesList)
        values.(namesList{i})=valuesList{i};
    end
    set_param(block.Handle,'ParameterArgumentValues',values);
    defaults=strjoin(defaultsList,',');
    set_param(block.Handle,'UsingDefaultArgumentValue',defaults);
end

function loc_set_inst_spec_argument_values(block,hierarchySpreadsheetData)
    paramVal=[];
    for ii=1:numel(hierarchySpreadsheetData)
        paramVal(ii).Name=hierarchySpreadsheetData(ii).m_Name;
        paramVal(ii).Value=hierarchySpreadsheetData(ii).m_Value;
        paramVal(ii).Path=Simulink.BlockPath(hierarchySpreadsheetData(ii).m_RealPath);
        if strcmp(hierarchySpreadsheetData(ii).m_InstanceSpecific,'on')||strcmp(hierarchySpreadsheetData(ii).m_InstanceSpecific,'1')
            boolVal=true;
        end
        if strcmp(hierarchySpreadsheetData(ii).m_InstanceSpecific,'off')||strcmp(hierarchySpreadsheetData(ii).m_InstanceSpecific,'0')
            boolVal=false;
        end
        paramVal(ii).Argument=boolVal;
    end
    if(~isempty(paramVal))
        set_param(block.handle,'InstanceParameters',paramVal);
    end
end


function loc_SetInstSpecArguVals(source)
    block=source.getBlock;
    if isfield(source.UserData,'HierarchySpreadsheetData')
        toSetInstSpecVal=source.UserData.HierarchySpreadsheetData;
        loc_set_inst_spec_argument_values(block,toSetInstSpecVal);
    end
end





function loc_SetModelArgs(source)
    block=source.getBlock;
    if isfield(source.UserData,'m_Children')
        if~isempty(source.UserData.m_Children)
            aModelArgumentNamesList={source.UserData.m_Children(:).m_Name};

            aModelArgumentValuesList={source.UserData.m_Children(:).m_Value};

            aUsingDefaultValues=cellfun(@isempty,{source.UserData.m_Children(:).m_Value});
            aUsingDefaultValues=arrayfun(@num2str,aUsingDefaultValues,'UniformOutput',false);

            loc_set_argument_values(block,aModelArgumentNamesList,aModelArgumentValuesList,aUsingDefaultValues);
        end
    end
end


function out=loc_doPreApply(dialogH,block,source)
    out={};
    if~block.isHierarchyReadonly
        if isfield(source.UserData,'HierarchySpreadsheetData')
            toSetInstSpecVal=source.UserData.HierarchySpreadsheetData;
            loc_set_inst_spec_argument_values(block,toSetInstSpecVal);
        end




        source.UserData.PreApplySimModeEntries=...
        block.getPropAllowedValues('SimulationMode');
        source.UserData.PreApplySimModeWidgetValue=...
        dialogH.getWidgetValue('SimulationMode');


        [noErr,msg]=source.preApplyCallback(dialogH);

        if noErr
            [noErr,msg]=i_doPreApply(dialogH,block,source);
        end
    else
        msg='';noErr=true;
    end

    if i_SupportPeriodicEventPorts(block.Handle)
        showPeriodicEventPorts=...
        dialogH.getWidgetValue('ScheduleRates');
        strcmp(dialogH.getWidgetValue('ScheduleRatesWith'),'Ports');

        if~isempty(showPeriodicEventPorts)&&showPeriodicEventPorts
            SetPortDiscreteRatesOnBlock(dialogH);
        end

    end

    out{2}=msg;
    out{1}=noErr;
end


function[success,err]=i_doPreApply(H,block,dialogSource)

    source=H.getSource;
    myData=source.UserData;
    err='';success=true;



    modelName=block.ModelNameDialog;
    isProtected=slInternal('getReferencedModelFileInformation',modelName);
    simModeWidgetValue=myData.PreApplySimModeWidgetValue;
    if isProtected





        runConsistencyChecks='runNoConsistencyChecks';
        opts=Simulink.ModelReference.ProtectedModel.getOptions(modelName,...
        runConsistencyChecks);
        previousSimMode=myData.PreApplySimModeEntries{myData.PreApplySimModeWidgetValue+1};
        if(strcmp(previousSimMode,'Normal')||(~isempty(opts)&&...
            ((~opts.hasSILSupport&&strcmp(previousSimMode,'Software-in-the-loop (SIL)'))||...
            (~opts.hasPILSupport&&strcmp(previousSimMode,'Processor-in-the-loop (PIL)')))))
            simModeWidgetValue=find(strcmp(myData.PreApplySimModeEntries,'Accelerator'))-1;
        end
    end
    H.setWidgetValue('SimulationMode',simModeWidgetValue);
    source.UserData=rmfield(source.UserData,{'PreApplySimModeEntries',...
    'PreApplySimModeWidgetValue'});


    H.setEnabled('SimulationMode',i_ShouldSimModeBeEnabled(source,modelName));
    H.setEnabled('ModelOpen',i_ShouldOpenButtonBeEnabled('',modelName));


    dialogSource.UserData.CodeInterfaceActive=...
    any(strcmp(block.getPropValue('SimulationMode'),...
    {'Software-in-the-loop (SIL)',...
    'Processor-in-the-loop (PIL)'}));
    H.refresh;


end



function i_doClose(H)

    source=H.getSource;


    if isempty(DAStudio.ToolRoot.getOpenDialogs(H.getSource))
        source.UserData=[];
    end
end

function paramStr=ConstructPortDiscreteRatesParameter(discTs)
    nTs=size(discTs,1);
    paramStr='[';
    if size(discTs,2)==1

        for idx=1:nTs
            paramStr=strcat(paramStr,num2str(discTs(idx)));
            if idx<nTs
                paramStr=strcat(paramStr,',');
            end
        end
    else

        for idx=1:nTs
            paramStr=strcat(paramStr,num2str(discTs(idx,1)));
            paramStr=strcat(paramStr,',');
            paramStr=strcat(paramStr,num2str(discTs(idx,2)));
            if idx<nTs
                paramStr=strcat(paramStr,'; ');
            end
        end
    end
    paramStr=strcat(paramStr,']');
end

function savedInR2016bOrLater=RefModelFoundAndSavedIn16bOrLater(blkObj)
    refModelNameWithExt=get_param(blkObj,'ModelFile');
    fullPath=which(refModelNameWithExt);

    savedInR2016bOrLater=false;




    isProtected=slInternal('getReferencedModelFileInformation',...
    refModelNameWithExt);
    if(isProtected&&~isempty(fullPath))
        try
            R2016bVersion=simulink_version('R2016b');
            versionStr=slInternal('getProtectedModelVersion',fullPath);
            protectedModelVersion=simulink_version(versionStr);
            savedInR2016bOrLater=(protectedModelVersion>=R2016bVersion);
        catch e %#ok


            savedInR2016bOrLater=false;
        end
    else


        try
            refModelName=get_param(blkObj,'ModelName');
            isBlockDiagramLoaded=bdIsLoaded(refModelName);
        catch
            isBlockDiagramLoaded=false;
        end
        if(isBlockDiagramLoaded)


            savedInR2016bOrLater=(get_param(refModelName,'VersionLoaded')>=8.8);
            if(~savedInR2016bOrLater)
                savedInR2016bOrLater=strcmp(get_param(refModelName,'SavedSinceLoaded'),'on');
            end
        else




            mdlFound=true;
            try
                mdlInfo=Simulink.MDLInfo(refModelNameWithExt);
            catch e %#ok

                mdlFound=false;
            end
            if(mdlFound)
                savedInR2016bOrLater=...
                (str2double(mdlInfo.SimulinkVersion)>=8.8);
            end
        end
    end
end



function supportIRTPorts=i_SupportIRTPorts(blkObj)

    supportIRTPorts=true;
    allPorts=get_param(blkObj,'Ports');

    if Simulink.internal.isArchitectureModel(bdroot(blkObj))||sum(allPorts(3:end))>0||Simulink.harness.internal.isHarnessCUT(blkObj)


        supportIRTPorts=false;
    else


        if(strcmp(get_param(bdroot,'ExplicitPartitioning'),'on')&&...
            strcmp(get_param(bdroot,'ConcurrentTasks'),'on'))
            supportIRTPorts=false;
            return;
        end

    end

end

function supportPeriodicEventPorts=i_SupportPeriodicEventPorts(blkObj)
    supportPeriodicEventPorts=...
    strcmp(get_param(blkObj,'IsModelRefExportFunction'),'off')&&...
    i_SupportIRTPorts(blkObj);
end

function supportExportedPartitions=i_supportExportedPartitions(blkObj)
    supportExportedPartitions=...
    i_SupportIRTPorts(blkObj)&&...
    sltp.BlockAccess(blkObj).isValidModelBlockForPartitioning(true);
end

function supportSampleTimeParameterization=i_supportSampleTimeParameterization(blkObj)
    supportSampleTimeParameterization=false;
    if slfeature('SampleTimeParameterization')
        supportSampleTimeParameterization=strcmp(get_param(blkObj,'ParameterizeDiscreteRates'),'on');
    end

end

function tableData=GetDialogPortDiscreteRates(blkH)
    portDiscRates=get_param(blkH,'PortDiscreteRates');
    portDiscRates=str2num(portDiscRates);
    hasOffsets=~isvector(portDiscRates);
    if(hasOffsets)
        numRates=size(portDiscRates,1);
    else
        numRates=length(portDiscRates);
    end


    tableData=cell(numRates,2);

    for rowIdx=1:numRates
        if(hasOffsets)
            period=portDiscRates(rowIdx,1);
            offset=portDiscRates(rowIdx,2);
        else
            period=portDiscRates(rowIdx);
            offset=0;
        end
        tableData{rowIdx,1}=sprintf('%f',period);
        if(offset==0)
            tableData{rowIdx,2}=sprintf('');
        else
            tableData{rowIdx,2}=sprintf('%f',offset);
        end
    end
end

function val=GetValFromString(str)
    if isempty(str)
        val=0;
    else
        val=str2num(str);
    end
end

function ratesVect=GetPortDiscreteRatesFromTable(tableData)


    numRates=size(tableData,1);
    ratesVect=zeros(numRates,2);
    for k=1:numRates
        val=GetValFromString(tableData{k,1});
        ratesVect(k,1)=val;
        val=GetValFromString(tableData{k,2});
        ratesVect(k,2)=val;
    end
end




function retVal=SortDiscreteRates(ratesVect)
    retVal=zeros(size(ratesVect));
    nRates=size(ratesVect,1);
    currPos=1;
    maxVal=max(ratesVect(:,1))+1;
    while currPos<=nRates
        fastestRate=ratesVect(1,:);
        markPos=1;
        for j=2:nRates
            if ratesVect(j,1)<fastestRate(1)
                fastestRate=ratesVect(j,:);
                markPos=j;
            elseif ratesVect(j,1)==fastestRate(1)&&ratesVect(j,2)<fastestRate(2)
                fastestRate=ratesVect(j,:);
                markPos=j;
            end
        end
        retVal(currPos,:)=fastestRate;
        currPos=currPos+1;
        ratesVect(markPos,:)=[maxVal,maxVal];
    end
end

function i_ChooseSetPortDiscreteRatesOpt(dialogH)
    source=dialogH.getSource;
    myData=source.UserData;
    idx=dialogH.getWidgetValue('ScheduleRates');

    myData.PortDiscreteRateOptIdx=uint16(idx);
    if idx==0
        tableData=[];
        myData.RateTableData=tableData;
    else

        tableData=GetDialogPortDiscreteRates(source.getBlock.Handle);
        myData.RateTableData=tableData;
    end

    source.UserData=myData;
    dialogH.refresh;
    dialogH.enableApplyButton(true);
end

function SetPortDiscreteRatesOnBlock(dialogH)
    source=dialogH.getSource;
    myData=source.UserData;
    blockH=source.getBlock.Handle;

    idx=dialogH.getWidgetValue('SpecifyPortDiscreteRates');
    if idx==1
        if isfield(myData,'RateTableData')

            ratesVect=GetPortDiscreteRatesFromTable(myData.RateTableData);

            if isequal(ratesVect(:,2),zeros(size(ratesVect,1),1))
                ratesVect=ratesVect(1:end,1);
                ratesVect=sort(ratesVect);
            else
                ratesVect=SortDiscreteRates(ratesVect);
            end
            paramStr=ConstructPortDiscreteRatesParameter(ratesVect);
            set_param(blockH,'PortDiscreteRates',paramStr);
            set_param(blockH,'AutoFillPortDiscreteRates','off');
        end
    else
        set_param(blockH,'AutoFillPortDiscreteRates','on');
    end

    source.UserData=myData;


end



