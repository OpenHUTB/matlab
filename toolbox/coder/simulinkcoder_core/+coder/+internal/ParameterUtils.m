classdef ParameterUtils<handle
    methods(Static,Access=public)


        function LocalSetBlockParameters(blkH,portPrm,thisHdl)




            isDSMBlk=strcmp(get_param(blkH,'BlockType'),'DataStoreMemory');

            if~isDSMBlk&&portPrm.CompiledPortFrameData(1)==1
                set_param(blkH,'SamplingMode','Frame Based');



            end

            if~strcmp(portPrm.CompiledPortDataType,portPrm.AliasPortDataType)
                set_param(blkH,'OutDataTypeStr',portPrm.AliasPortDataType)
            elseif portPrm.isFixPt||...
                any(strcmp(coder.internal.Utilities.BuiltinType,portPrm.CompiledPortDataType))||...
                (strcmp('half',portPrm.CompiledPortDataType)==1)
                dt=fixdt(portPrm.CompiledPortDataType);
                hasNoDTO=strcmp(thisHdl.actualDataTypeOverride,'Off')||...
                strcmp(thisHdl.actualDataTypeOverride,'UseLocalSettings');


                if hasNoDTO
                    if portPrm.isFixPt
                        dt_str=dt.tostring;
                    else
                        dt_str=portPrm.CompiledPortDataType;
                    end
                else







                    if~portPrm.isScaledDouble






                        dt.DataTypeOverride='Off';
                    end
                    dt_str=dt.tostring;
                end

                set_param(blkH,'OutDataTypeStr',dt_str);

                if isDSMBlk&&portPrm.isScaledDouble
                    set_param(blkH,'ScaledDouble','on');
                end
            elseif strcmp(portPrm.CompiledPortDataType,'fcn_call')
                set_param(blkH,'OutDataTypeStr','Inherit: auto');
            else
                validDataType=false;
                [resolvedDT,varExists]=...
                slResolve(portPrm.CompiledPortDataType,blkH,'variable');
                if varExists&&isa(resolvedDT,'Simulink.DataType')
                    validDataType=true;

                    if(isa(resolvedDT,'Simulink.Bus'))
                        set_param(blkH,'OutDataTypeStr',['Bus: ',portPrm.CompiledPortDataType]);
                    else
                        set_param(blkH,'OutDataTypeStr',portPrm.CompiledPortDataType);
                    end
                elseif Simulink.data.isSupportedEnumClass(portPrm.CompiledPortDataType)
                    validDataType=true;
                    dataTypeExpr=['Enum: ',portPrm.CompiledPortDataType];
                    set_param(blkH,'OutDataTypeStr',dataTypeExpr);
                elseif strncmp(portPrm.CompiledPortDataType,'str',3)

                    stringTypeStr=Simulink.internal.getStringDTExprFromDTName(portPrm.CompiledPortDataType);
                    if~isempty(stringTypeStr)
                        set_param(blkH,'OutDataTypeStr',stringTypeStr);
                        validDataType=true;
                    end
                end

                if validDataType==false
                    set_param(blkH,'OutDataTypeStr','Inherit: auto');
                    disp(DAStudio.message('RTW:buildProcess:CustomDataSSWithSFcn',...
                    portPrm.CompiledPortDataType));
                end
            end

            if portPrm.CompiledPortComplexSignal
                set_param(blkH,'SignalType','complex');
            else


                set_param(blkH,'SignalType','real');
            end


            coder.internal.SampleTimeChecks.LocalSetSampleTime(blkH,portPrm,thisHdl);

            if~isDSMBlk
                strDimsMode='auto';
                if isfield(portPrm,'CompiledPortDimensionsMode')&&...
                    ~isempty(portPrm.CompiledPortDimensionsMode)
                    if portPrm.CompiledPortDimensionsMode==1
                        strDimsMode='Variable';
                    else
                        strDimsMode='Fixed';
                    end
                end
                set_param(blkH,...
                'PortDimensions',portPrm.SymbolicDimensions,...
                'DimensionsMode',strDimsMode);
            end
        end
    end
end
