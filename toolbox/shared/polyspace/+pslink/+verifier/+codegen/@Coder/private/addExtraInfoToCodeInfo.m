function addExtraInfoToCodeInfo(self)

    try
        if~isempty(self.codeInfo)

            for ii=1:numel(self.codeInfo.Types)
                dataType=pslink.verifier.codegen.Coder.getCoderType(self.codeInfo.Types(ii));
                if isa(dataType,'embedded.structtype')
                    try
                        [val,ok]=slResolve(dataType.Identifier,self.slModelName);

                        if ok&&~isfield(self.drsInfo.busInfo,dataType.Identifier)
                            if isempty(self.drsInfo.busInfo)
                                self.drsInfo.busInfo=struct(dataType.Identifier,val);
                            else
                                self.drsInfo.busInfo.(dataType.Identifier)=val;
                            end
                        end
                    catch me %#ok<NASGU>
                    end
                end
            end

            for ii=1:numel(self.codeInfo.Inports)
                pslink.verifier.codegen.Coder.addAllDynamicProperties(self.codeInfo.Inports(ii));
                nSetDataUsageInCode(self.codeInfo.Inports(ii));
                if self.codeInfo.Inports(ii).UsageKind==0


                    self.mustWriteAllData=true;
                end

            end
            for ii=1:numel(self.codeInfo.Outports)
                pslink.verifier.codegen.Coder.addAllDynamicProperties(self.codeInfo.Outports(ii));
                nSetDataUsageInCode(self.codeInfo.Outports(ii));

            end
            for ii=1:numel(self.codeInfo.Parameters)
                pslink.verifier.codegen.Coder.addAllDynamicProperties(self.codeInfo.Parameters(ii));
                nSetDataUsageInCode(self.codeInfo.Parameters(ii));
            end
            for ii=1:numel(self.codeInfo.DataStores)
                pslink.verifier.codegen.Coder.addAllDynamicProperties(self.codeInfo.DataStores(ii));
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
                            skipSignal=slResolveExplicitOnly&&~strcmpi(get_param(blkH,'StateMustResolveToSignalObject'),'on');
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
                            pslinkprivate('pslinkMessage','warning','pslink:unexpectedErrorForSignal',...
                            signalName,...
                            me.message);
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
        switch class(data.Implementation)
        case{'RTW.Variable','RTW.StructExpression','RTW.TypedCollection'}
            dataImpl=data.Implementation;
            if isa(dataImpl,'RTW.TypedCollection')
                dataImpl=dataImpl.Elements(1);
            end
            if~isa(dataImpl,'RTW.PointerVariable')&&dataImpl.isDefined
                uKind=1;
            else
                if isa(dataImpl,'RTW.StructExpression')&&...
                    ~strcmpi(self.cgLanguage,'C++ (Encapsulated)')
                    dataImpl=dataImpl.BaseRegion;
                elseif~isa(dataImpl,'RTW.Variable')

                    dataImpl=[];
                end
                if~isempty(dataImpl)&&isempty(dataImpl.Owner)&&...
                    isempty(dataImpl.DeclarationFile)&&...
                    isempty(dataImpl.DefinitionFile)&&...
                    isempty(dataImpl.StorageSpecifier)
                    uKind=2;
                end
            end
        case{'RTW.Argument','coder.types.Argument'}
            uKind=2;
        case{'RTW.AutosarSenderReceiver','RTW.AutosarInterRunnable',...
            'RTW.AutosarErrorStatus','RTW.AutosarCalibration'}
            uKind=3;

        case 'RTW.AutosarClientServer'

        otherwise

        end
        data.UsageKind=uKind;
    end


    function nCleanup()

    end

end



