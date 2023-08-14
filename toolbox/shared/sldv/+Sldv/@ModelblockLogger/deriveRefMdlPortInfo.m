function deriveRefMdlPortInfo(obj)

    TopLevelModelH=obj.TopLevelModelH;
    globalData=obj.globalDsmData;
    modelBlockH=obj.ModelBlockH;
    model=get_param(TopLevelModelH,'name');
    if~isstruct(globalData)
        try
            str=evalc('feval(model,[],[],[],''compileForSizes'');');
            if nargin<3||isempty(obj.refMdlToMdlBlk)


                [obj.refMdlToMdlBlk,obj.globalRefSig]=createCompiledMdlInfo(TopLevelModelH);
            end

            globalData=Sldv.ModelblockLogger.deriveDSWExecPriorToMdlBlk(modelBlockH,...
            TopLevelModelH,...
            obj.refMdlToMdlBlk,...
            obj.globalRefSig);
            obj.globalDsmData=globalData;
            feval(model,[],[],[],'term')
        catch Mex
            feval(model,[],[],[],'term');
            rethrow(Mex);
        end
    end





    referencedModelName=get_param(modelBlockH,'ModelName');
    refmodelH=get_param(referencedModelName,'Handle');
    [InputPortInfo,OutputPortInfo,flatInfo]=...
    Sldv.DataUtils.generateIOportInfo(refmodelH);

    SampleTimes=flatInfo.SampleTimes;
    mdlBlockIO=[];
    [InputPortInfo,globalVarInfo,unsuppSigs]=addGlobalVarsPortInfo(refmodelH,InputPortInfo,globalData,modelBlockH);
    if~isempty(unsuppSigs)
        error('Sldv:SubsystemLogger:GlobalWithBusNotSupported',...
        getString(message('Sldv:SubsystemLogger:GlobalWithBusNotSupported',referencedModelName)));
    end
    mdlBlockIO.Handle=refmodelH;
    mdlBlockIO.InputPortInfo=InputPortInfo;
    mdlBlockIO.OutputPortInfo=OutputPortInfo;
    mdlBlockIO.flatInfo=flatInfo;
    mdlBlockIO.SampleTimes=SampleTimes;
    mdlBlockIO.globalVarInfo=globalVarInfo;
    obj.subsystemIO=mdlBlockIO;
end

function[InputPortInfo,globalVarInfo,unsuppSigs]=addGlobalVarsPortInfo(refmodelH,InputPortInfo,globalData,modelBlockH)

    globalVarsUsage=globalData.varsUsage;
    dsmMap=globalData.dsmMap;
    globalVarInfo=[];
    sigInfo=[];
    unsuppSigs={};
    parentST=get_param(modelBlockH,'CompiledSampleTime');
    if iscell(parentST)
        parentST=parentST{1};
    end
    for i=1:length(globalVarsUsage)
        v=globalVarsUsage(i);
        signalObj=evalinGlobalScope(refmodelH,v.Name);
        sigInfo.BlockPath=[];
        sigInfo.SignalName=v.Name;
        sigInfo.Dimensions=signalObj.Dimensions;
        sigInfo.DataType=signalObj.DataType;

        if strncmp(sigInfo.DataType,'Bus:',4)

            unsuppSigs{end+1}=v.Name;%#ok<AGROW>
        end

        sigInfo.Complexity=signalObj.Complexity;
        sigInfo.LoggingInfo=copy(signalObj.LoggingInfo);
        sigInfo.SampleTime=signalObj.SampleTime;
        [~,SampleTimeStr]=Sldv.utils.getSampleTime([signalObj.SampleTime,0]);
        sigInfo.SampleTimeStr=SampleTimeStr;
        sigInfo.SignalLabels=v.Name;
        sigInfo.ParentSampleTime=parentST;
        sigInfo.priorWriters=dsmMap(v.Name);
        globalVarInfo{end+1}=sigInfo;%#ok<AGROW>
    end
    InputPortInfo=[InputPortInfo,globalVarInfo];

end

function[refMdlToMdlBlk,globalRefSig]=createCompiledMdlInfo(model)
    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);
    [~,handleToTreeIdx,refMdlToMdlBlk]=Analysis.createMdlStructureTree(model,[]);
    allBlkH=handleToTreeIdx.keys;
    globalRefSig=filterGlobals();

    function globals=filterGlobals()
        idx=cellfun(@(b)strcmpi(get(b,'type'),'block')&&...
        strcmpi(get_param(b,'BlockType'),'DataStoreMemory')&&...
        strcmp(get(b,'GlobalDataStore'),'on'),...
        allBlkH);
        allBlkH=allBlkH(idx);
        if~isempty(allBlkH)
            allBlkH=[allBlkH{:}];
            globals=get(allBlkH,'DataStoreName');
        else
            globals=[];
        end
    end
end
