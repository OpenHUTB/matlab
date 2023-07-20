function retErrorMessage=cb_ErrorFcn(blockH,errorID,originalException)









    if nargin<3
        retErrorMessage='';
        return;
    end

    BlockHandle=originalException.handles{1};

    if length(BlockHandle)>1
        if(strcmp(errorID,{'Simulink:Signals:SigAttribPropErr5'}))

            blockPath=originalException.arguments{1};
            signalName=originalException.arguments{6};
            signalLabel=originalException.arguments{3};
            MSLE=MSLException(blockH,message('Simulink:blocks:SubsysErrFcnMsg',blockPath,''));
            MSLE=MSLE.addCause(MException(message('sl_sta_editor_block:message:SignalLabelMismatch',signalName,signalLabel,signalLabel,signalName)));
            retErrorMessage=MSLE;
        else

            retErrorMessage=originalException;
        end
        return;
    end
    if~any(strcmp(get_param(BlockHandle,'BlockType'),{'FromWorkspace','Outport'}))
        if any(strcmp(errorID,{'Simulink:Engine:CallbackEvalErr','Simulink:blocks:SubsysErrFcnMsg'}))

            if~isempty(originalException.cause)
                retErrorMessage=originalException.cause{1};
            else
                retErrorMessage='';
                return;
            end
        elseif strcmp(errorID,{'Simulink:Masking:Bad_Init_Commands'})


            blockPath=originalException.arguments{1};
            retErrorMessage=MSLException(blockH,message('Simulink:blocks:SubsysErrFcnMsg',blockPath,''));
        else
            retErrorMessage=originalException;
            if strcmp(errorID,'Simulink:DataType:OutputPortDataTypeMismatch')
                blockStruct=get(blockH);
                blockPath=[blockStruct.Path,'/',blockStruct.Name];
                suggestion=message('sl_sta_editor_block:message:LaunchSignalEditorAction',...
                num2str(getSimulinkBlockHandle(blockPath),32));
                retErrorMessage=MSLException(getSimulinkBlockHandle(blockPath),...
                originalException,'ACTION',MSLDiagnostic(suggestion));
            end
        end
    else
        retErrorMessage='';
        if~contains(errorID,{'Simulink:blocks:SubsysErrFcnMsg'})
            if~isempty(originalException.handles)



                fromWsBlockHandle=originalException.handles{1};
                signalName=Simulink.signaleditorblock.getSignalNameFromPortHandle(fromWsBlockHandle);
                blockStruct=get(blockH);
                blockPath=[blockStruct.Path,'/',blockStruct.Name];
                if(strcmp(errorID,'Simulink:SimInput:FrmWksStructDataTypeNotBus'))
                    if strcmp(get_param(fromWsBlockHandle,'BlockType'),'FromWorkspace')
                        NeedBusObjectMessage=getString(message('sl_sta_editor_block:message:NeedBusObject',signalName));
                        commandsToRun=sprintf('set_param(''%s'',''ActiveSignal'',''%s'');\nset_param(''%s'',''IsBus'',''on'');\nset_param(''%s'',''OutputBusObjectStr'',''Bus: BusObject'');',blockPath,signalName,blockPath,blockPath);
                        TypeAppropriateBusObjectMsg=getString(message('sl_sta_editor_block:message:TypeAppropriateBusObject'));
                        retErrorMessage=sprintf('%s\n%s\n%s',NeedBusObjectMessage,commandsToRun,TypeAppropriateBusObjectMsg);
                    end
                elseif strcmp(errorID,'Simulink:SimInput:FrmWksDataEmptyHierStructForBus')
                    if isempty(eval(get_param(originalException.handles{1},'VariableName')))

                        MSLE=MSLException(blockH,message('Simulink:blocks:SubsysErrFcnMsg',blockPath,''));
                        MSLE=MSLE.addCause(MException(message('sl_sta_editor_block:message:GroundSignalIsNotSupported',signalName)));
                        retErrorMessage=MSLE;
                    end
                elseif(strcmp(errorID,'Simulink:blocks:InvOutputContinuousSignal'))
                    aMaskObj=get_param(blockPath,'MaskObject');
                    activeSignalParam=aMaskObj.getParameter('ActiveSignal');
                    signals=activeSignalParam.TypeOptions;
                    index=find(strcmp(signalName,signals));
                    MSLE=MSLException(blockH,message('Simulink:blocks:SubsysErrFcnMsg',blockPath,''));
                    dataType=originalException.arguments{3};
                    MSLE=MSLE.addCause(MSLException(message('Simulink:blocks:InvOutputContinuousSignal',index,blockPath,dataType)));
                    retErrorMessage=MSLE;
                elseif(strcmp(errorID,'Simulink:SimInput:FromwksCannotInterpFiOrEnum'))
                    MSLE=MSLException(blockH,message('Simulink:blocks:SubsysErrFcnMsg',blockPath,''));
                    MSLE=MSLE.addCause(MException(message('sl_sta_editor_block:message:InvalidInterpolation',signalName)));
                    retErrorMessage=MSLE;
                elseif(strcmp(errorID,'Simulink:SimInput:FrmWksDataNonBusDataForBus'))
                    MSLE=MSLException(blockH,message('Simulink:blocks:SubsysErrFcnMsg',blockPath,''));
                    MSLE=MSLE.addCause(MException(message('sl_sta_editor_block:message:NonBusDataForBus',signalName)));
                    retErrorMessage=MSLE;
                elseif(strcmp(errorID,'Simulink:SimInput:FromwksNoExtrapWithoutInterp'))
                    retErrorMessage=getString(message('Simulink:SimInput:FromwksNoExtrapWithoutInterp',blockPath));
                elseif(strcmp(errorID,'Simulink:SimInput:FromwksInvMatrixParam'))
                    MSLE=MSLException(blockH,message('Simulink:blocks:SubsysErrFcnMsg',blockPath,''));
                    MSLE=MSLE.addCause(MException(message('sl_sta_editor_block:message:InvalidMatrixParam')));
                    retErrorMessage=MSLE;
                elseif(strcmp(errorID,'Simulink:SimInput:TimeseriesUnsupportedDataType'))
                    MSLE=MSLException(blockH,message('Simulink:blocks:SubsysErrFcnMsg',blockPath,''));
                    MSLE=MSLE.addCause(MException(message('sl_sta_editor_block:message:TimeseriesUnsupportedDataType',signalName)));
                    retErrorMessage=MSLE;
                elseif any(strcmp(errorID,{'Simulink:SimInput:FromWksNotSupportArrayOfBus',...
                    'Simulink:SimInput:FrmWksDataHierStructExtraField'}))
                    MSLE=MSLException(blockH,message('Simulink:blocks:SubsysErrFcnMsg',blockPath,''));
                    MSLE=MSLE.addCause(MException(message('sl_sta_editor_block:message:UnsupportedBusFormat',signalName)));
                    retErrorMessage=MSLE;
                elseif strcmp(errorID,{'Simulink:SimInput:FromWksDataTypeMismatch'})
                    newDataType=originalException.arguments{2};
                    oldDataType=originalException.arguments{3};
                    MSLE=MSLException(blockH,message('Simulink:blocks:SubsysErrFcnMsg',blockPath,''));
                    MSLE=MSLE.addCause(MException(message('sl_sta_editor_block:message:FastRestart_DataTypeMismatch',signalName,newDataType,oldDataType)));
                    retErrorMessage=MSLE;
                elseif strcmp(errorID,{'Simulink:SimInput:FromWksFastRestartDimensionsMismatch'})
                    MSLE=MSLException(blockH,message('Simulink:blocks:SubsysErrFcnMsg',blockPath,''));
                    MSLE=MSLE.addCause(MException(message('sl_sta_editor_block:message:FastRestart_DimensionMismatch',signalName)));
                    retErrorMessage=MSLE;
                elseif strcmp(errorID,{'Simulink:SampleTime:InvTsParamSetting_Vector'})
                    MSLE=MSLException(blockH,message('Simulink:blocks:SubsysErrFcnMsg',blockPath,''));
                    args=originalException.arguments;
                    args{1}=signalName;
                    MSLE=MSLE.addCause(MException(message('Simulink:SampleTime:InvTsParamSetting_Vector',args{:})));
                    retErrorMessage=MSLE;
                elseif strcmp(errorID,{'Simulink:SimInput:FromWksFastRestartComplexityMismatch'})
                    MSLE=MSLException(blockH,message('Simulink:blocks:SubsysErrFcnMsg',blockPath,''));
                    MSLE=MSLE.addCause(MException(message('sl_sta_editor_block:message:FastRestart_ComplexityMismatch',signalName)));
                    retErrorMessage=MSLE;
                elseif strcmp(errorID,{'Simulink:SimInput:FromWksStrNonScalar'})
                    MSLE=MSLException(blockH,message('Simulink:blocks:SubsysErrFcnMsg',blockPath,''));
                    MSLE=MSLE.addCause(MException(message('sl_sta_editor_block:message:NonScalarString',signalName)));
                    retErrorMessage=MSLE;
                elseif strcmp(errorID,{'Simulink:SimInput:FromWksStrNonAscii'})
                    MSLE=MSLException(blockH,message('Simulink:blocks:SubsysErrFcnMsg',blockPath,''));
                    MSLE=MSLE.addCause(MException(message('sl_sta_editor_block:message:NonAsciiString',signalName)));
                    retErrorMessage=MSLE;
                elseif strcmp(errorID,{'Simulink:SimInput:FromWksStrMissing'})
                    MSLE=MSLException(blockH,message('Simulink:blocks:SubsysErrFcnMsg',blockPath,''));
                    MSLE=MSLE.addCause(MException(message('sl_sta_editor_block:message:MissingString',signalName)));
                    retErrorMessage=MSLE;
                elseif strcmp(errorID,{'Simulink:SimInput:TimeseriesUnsupportedIsTimeFirst'})
                    MSLE=MSLException(blockH,message('Simulink:blocks:SubsysErrFcnMsg',blockPath,''));
                    MSLE=MSLE.addCause(MException(message('sl_sta_editor_block:message:TimeseriesUnsupportedIsTimeFirst',signalName)));
                    retErrorMessage=MSLE;
                elseif strcmp(errorID,{'Simulink:SimInput:FromwksNotSupportedFormat'})
                    MSLE=MSLException(blockH,message('Simulink:blocks:SubsysErrFcnMsg',blockPath,''));
                    MSLE=MSLE.addCause(MException(message('sl_sta_editor_block:message:UnsupportedFormat',signalName)));
                    retErrorMessage=MSLE;
                elseif(strcmp(errorID,'Simulink:SimInput:TimetableUnsupportedDataTypeFromWks'))
                    MSLE=MSLException(blockH,message('Simulink:blocks:SubsysErrFcnMsg',blockPath,''));
                    MSLE=MSLE.addCause(MException(message('sl_sta_editor_block:message:TimeseriesUnsupportedDataType',signalName)));
                    retErrorMessage=MSLE;
                elseif(strcmp(errorID,'Simulink:Parameters:InvParamSetting'))
                    if(length(originalException.arguments)==2)
                        paramName=originalException.arguments{2};
                        if(strcmp(paramName,'OutDataTypeStr'))
                            paramName='OutputBusObjectStr';
                        end
                        MSLE=MSLException(blockH,message('Simulink:blocks:SubsysErrFcnMsg',blockPath,''));
                        MSLE=MSLE.addCause(MException(message('sl_sta_editor_block:message:InvParamSettingSignalEditor',paramName)));
                        retErrorMessage=MSLE;
                    else
                        retErrorMessage=originalException;
                    end
                elseif(strcmp(errorID,'Simulink:Parameters:BlkParamUndefined'))
                    if(length(originalException.arguments)==2)
                        paramName=originalException.arguments{2};
                        if(strcmp(paramName,'OutDataTypeStr'))
                            paramName='OutputBusObjectStr';
                        end
                        MSLE=MSLException(blockH,message('Simulink:blocks:SubsysErrFcnMsg',blockPath,''));
                        MSLE=MSLE.addCause(MException(message('sl_sta_editor_block:message:BlkParamUndefinedSignalEditor',paramName)));
                        retErrorMessage=MSLE;
                    else
                        retErrorMessage=originalException;
                    end
                else
                    MSLE=MSLException(blockH,message('Simulink:blocks:SubsysErrFcnMsg',blockPath,''));
                    MSLE=MSLE.addCause(originalException);
                    retErrorMessage=MSLE;
                end
            end
        else
            retErrorMessage=originalException;
        end
    end


    Simulink.signaleditorblock.SimulationData.removeSimulationDataFromHashMap(blockH);

end
