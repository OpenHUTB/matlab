function addExtraInfoToCodeInfo(self,linkDataOnly)

    needUpdate=isempty(self.traceInfo)||self.inputFullRange==false||self.outputFullRange==false||self.paramFullRange==false;
    needTermination=false;
    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>

    try

        if needUpdate
            if~strcmpi(get_param(self.slModelName,'SimulationStatus'),'initializing')
                evalc('feval(self.slModelName, [],[], [], ''compileForRTW'')');
                needTermination=true;
            end
        end

        if isempty(self.traceInfo)
            self.dlinkInfo=pslink.util.LinksData.ExtractLinksData(self.slModelName,true,self.slModelFileName,self.slModelVersion);
        end
        if~linkDataOnly&&~isempty(self.codeInfo)

            for ii=1:numel(self.codeInfo.Types)
                currentType=self.codeInfo.Types(ii);
                currentType=pslink.verifier.ec.Coder.getCoderType(currentType);
                if isa(currentType,'embedded.structtype')
                    try
                        [val,ok]=slResolve(currentType.Identifier,self.slModelName);

                        if ok&&~isfield(self.drsInfo.busInfo,currentType.Identifier)
                            if isempty(self.drsInfo.busInfo)
                                self.drsInfo.busInfo=struct(currentType.Identifier,val);
                            else
                                self.drsInfo.busInfo.(currentType.Identifier)=val;
                            end
                        end
                    catch me %#ok<NASGU>
                    end
                end
            end
            signalResolutionControl=get_param(self.slModelName,'SignalResolutionControl');
            noSignalResolution=strcmp(signalResolutionControl,'None');
            slResolveExplicitOnly=strcmp(signalResolutionControl,'UseLocalSettings');

            for ii=1:numel(self.codeInfo.InternalData)
                pslink.verifier.ec.Coder.addAllDynamicProperties(self.codeInfo.InternalData(ii));
                nSetDataUsageInCode(self.codeInfo.InternalData(ii));
                if self.codeInfo.InternalData(ii).UsageKind~=3||...
                    self.inputFullRange||...
                    ~isvarname(self.codeInfo.InternalData(ii).GraphicalName)

                    continue
                end
                lines=find_system(self.slSystemName,'findall','on',...
                'type','line',...
                'name',self.codeInfo.InternalData(ii).GraphicalName);
                if isempty(lines)

                    continue
                end

                if noSignalResolution
                    continue;
                end

                hasMustResolvedObject=false;
                for jj=1:numel(lines)
                    mustResolveToSigObject=get(lines(jj),'MustResolveToSignalObject');
                    if ischar(mustResolveToSigObject)
                        hasMustResolvedObject=hasMustResolvedObject||strcmpi(get(lines(jj),'MustResolveToSignalObject'),'on');
                    else
                        hasMustResolvedObject=hasMustResolvedObject||mustResolveToSigObject;
                    end
                end

                if slResolveExplicitOnly&&~hasMustResolvedObject
                    continue
                end

                try
                    slObj=slResolve(self.codeInfo.InternalData(ii).GraphicalName,self.slSystemName);
                    if isa(slObj,'Simulink.Signal')
                        self.codeInfo.InternalData(ii).SLObj=slObj;
                    end
                catch me
                    if hasMustResolvedObject
                        warning('pslink:unexpectedErrorForSignal',message('polyspace:gui:pslink:unexpectedErrorForSignal',...
                        self.codeInfo.InternalData(ii).GraphicalName,...
                        me.message).getString());
                    end
                end
            end

            for ii=1:numel(self.codeInfo.Inports)
                pslink.verifier.ec.Coder.addAllDynamicProperties(self.codeInfo.Inports(ii));
                nSetDataUsageInCode(self.codeInfo.Inports(ii));
                if self.codeInfo.Inports(ii).UsageKind==0
                    self.mustWriteAllData=true;
                end
                blkH=pslink.util.SimulinkHelper.getHandleFromID(self.codeInfo.Inports(ii).SID);
                if~isempty(blkH)&&self.inputFullRange==false
                    ports=get_param(blkH,'PortHandles');
                    pObj=get_param(ports.Outport(1),'Object');
                    if isprop(pObj,'CompiledSignalObject')
                        self.codeInfo.Inports(ii).SLObj=pObj.CompiledSignalObject;
                    else
                        if pObj.isSignalLabelResolved
                            self.codeInfo.Inports(ii).SLObj=iResolveSignal(self.slSystemName,pObj.SignalNameFromLabel,pObj.SignalObject);
                        end
                    end
                    [minVal,maxVal]=pslink.util.SimulinkHelper.getSlBlockOutMinMaxValues(get_param(blkH,'Object'));
                    self.codeInfo.Inports(ii).BlkMinMax={double(minVal),double(maxVal)};
                end
            end
            for ii=1:numel(self.codeInfo.Outports)
                pslink.verifier.ec.Coder.addAllDynamicProperties(self.codeInfo.Outports(ii));
                nSetDataUsageInCode(self.codeInfo.Outports(ii));
                blkH=pslink.util.SimulinkHelper.getHandleFromID(self.codeInfo.Outports(ii).SID);
                if~isempty(blkH)&&self.outputFullRange==false
                    ports=get_param(blkH,'PortHandles');
                    pObj=get_param(ports.Inport(1),'Object');
                    if isprop(pObj,'CompiledSignalObject')
                        self.codeInfo.Outports(ii).SLObj=pObj.CompiledSignalObject;
                    else
                        if numel(pObj.Line)==1&&pObj.Line>0
                            lObj=get_param(pObj.Line(1),'Object');
                            if lObj.isSignalLabelResolved
                                self.codeInfo.Outports(ii).SLObj=iResolveSignal(self.slSystemName,lObj.Name,lObj.SignalObject);
                            end
                        end
                    end
                    [minVal,maxVal]=pslink.util.SimulinkHelper.getSlBlockOutMinMaxValues(get_param(blkH,'Object'));
                    self.codeInfo.Outports(ii).BlkMinMax={double(minVal),double(maxVal)};
                end
            end
            for ii=1:numel(self.codeInfo.Parameters)
                pslink.verifier.ec.Coder.addAllDynamicProperties(self.codeInfo.Parameters(ii));
                nSetDataUsageInCode(self.codeInfo.Parameters(ii));
                if self.paramFullRange==false
                    if~isempty(self.codeInfo.Parameters(ii).SID)
                        blkH=pslink.util.SimulinkHelper.getHandleFromID(self.codeInfo.Parameters(ii).SID);
                        if~isempty(blkH)
                            blkObj=get_param(blkH,'Object');
                            if isa(blkObj,'Simulink.Constant')&&pslink.util.SimulinkHelper.slBlockHasOutMinMaxProp(blkObj)
                                [minVal,maxVal]=pslink.util.SimulinkHelper.getSlBlockOutMinMaxValues(blkObj);
                                self.codeInfo.Parameters(ii).BlkMinMax={double(minVal),double(maxVal)};
                            elseif isa(blkObj,'Simulink.Gain')&&pslink.util.SimulinkHelper.slBlockHasParamMinMaxProp(blkObj)
                                [minVal,maxVal]=pslink.util.SimulinkHelper.getSlBlockParamMinMaxValues(blkObj);
                                self.codeInfo.Parameters(ii).BlkMinMax={double(minVal),double(maxVal)};
                            else

                                continue
                            end
                        end
                    else
                        try
                            paramName=self.codeInfo.Parameters(ii).GraphicalName;
                            [slObj,~]=slResolve(paramName,self.slModelName,'variable');
                            if isa(slObj,'Simulink.Parameter')
                                self.codeInfo.Parameters(ii).SLObj=slObj;
                            end
                        catch me
                            warning('pslink:unexpectedErrorForParameter',...
                            message('polyspace:gui:pslink:unexpectedErrorForParameter',...
                            self.codeInfo.Parameters(ii).GraphicalName,...
                            me.message).getString());
                        end
                    end
                end
            end
            for ii=1:numel(self.codeInfo.DataStores)
                pslink.verifier.ec.Coder.addAllDynamicProperties(self.codeInfo.DataStores(ii));
                nSetDataUsageInCode(self.codeInfo.DataStores(ii));

                if self.inputFullRange==false
                    skipSignal=true;
                    signalName='';
                    context=[];
                    if~isempty(self.codeInfo.DataStores(ii).SID)
                        blkH=pslink.util.SimulinkHelper.getHandleFromID(self.codeInfo.DataStores(ii).SID);
                        if~isempty(blkH)
                            [minVal,maxVal]=pslink.util.SimulinkHelper.getSlBlockOutMinMaxValues(get_param(blkH,'Object'));
                            self.codeInfo.DataStores(ii).BlkMinMax={double(minVal),double(maxVal)};
                            skipSignal=(noSignalResolution||...
                            (slResolveExplicitOnly&&...
                            strcmp(get_param(blkH,'StateMustResolveToSignalObject'),'off')));
                            signalName=get_param(blkH,'DataStoreName');
                            context=getfullname(blkH);
                        end
                    else

                        skipSignal=false;
                        signalName=self.codeInfo.DataStores(ii).GraphicalName;
                        context=self.slSystemName;
                    end
                    if~skipSignal&&~isempty(signalName)&&~isempty(context)
                        try
                            slObj=slResolve(signalName,context);
                            if isa(slObj,'Simulink.Signal')
                                self.codeInfo.DataStores(ii).SLObj=slObj;
                            end
                        catch me
                            warning('pslink:unexpectedErrorForSignal',...
                            message('polyspace:gui:pslink:unexpectedErrorForSignal',...
                            signalName,...
                            me.message).getString());
                        end
                    end
                end
            end
        end

    catch Me %#ok<NASGU> 
        self.hasInternalError=true;
        self.mustWriteAllData=true;
        nCleanup();
    end

    nCleanup();


    function nSetDataUsageInCode(data)
        uKind=0;
        if isa(data.Implementation,'RTW.Variable')||isa(data.Implementation,'RTW.StructExpression')
            if~isa(data.Implementation,'RTW.PointerVariable')&&data.Implementation.isDefined
                uKind=1;
            else
                dataImpl=[];
                if isa(data.Implementation,'RTW.Variable')
                    dataImpl=data.Implementation;
                elseif isa(data.Implementation,'RTW.StructExpression')&&...
                    ~strcmpi(self.cgLanguage,'C++ (Encapsulated)')
                    dataImpl=data.Implementation.BaseRegion;
                else

                end
                if~isempty(dataImpl)&&isempty(dataImpl.Owner)&&...
                    isempty(dataImpl.DeclarationFile)&&...
                    isempty(dataImpl.DefinitionFile)&&...
                    isempty(dataImpl.StorageSpecifier)
                    uKind=2;
                end
            end
        elseif isa(data.Implementation,'RTW.Argument')||...
            isa(data.Implementation,'coder.types.Argument')
            uKind=2;

        elseif isa(data.Implementation,'RTW.AutosarSenderReceiver')||...
            isa(data.Implementation,'RTW.AutosarInterRunnable')||...
            isa(data.Implementation,'RTW.AutosarErrorStatus')||...
            isa(data.Implementation,'RTW.AutosarCalibration')
            uKind=3;

        elseif isa(data.Implementation,'RTW.AutosarClientServer')
        else

        end

        data.UsageKind=uKind;
    end


    function nCleanup()
        if needTermination
            evalc('feval(self.slModelName, [],[], [], ''term'')');
            needTermination=false;
        end
    end

end


function slObj=iResolveSignal(context,signalName,slObjCandidate)

    slObj=[];
    if~isempty(slObjCandidate)&&isa(slObjCandidate,'Simulink.Signal')
        slObj=slObjCandidate;
        return
    end

    try
        res=slResolve(signalName,context);
        if isa(res,'Simulink.Signal')
            slObj=res;
        end
    catch Me
        slObj=[];
        warning('pslink:unexpectedErrorForSignal',...
        message('polyspace:gui:pslink:unexpectedErrorForSignal',...
        signalName,...
        Me.message).getString());
    end

end



