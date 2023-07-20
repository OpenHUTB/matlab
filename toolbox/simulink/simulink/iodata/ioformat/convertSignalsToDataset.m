function[aStructToSave,newName,DID_NEED_CONVERSION]=convertSignalsToDataset(signalsIn,signalNamesIn,tempName,varargin)






    if isstring(signalNamesIn)&&~isscalar(signalNamesIn)
        signalNamesIn=cellstr(signalNamesIn);
    end

    if isstring(tempName)&&isscalar(tempName)
        tempName=char(tempName);
    end


    aStrUtil=sta.StringUtil();

    if~isempty(varargin)
        USE_SIMULINK_NAMING=true;
        existingTreeNames=varargin{1};
        for kName=1:length(existingTreeNames)
            aStrUtil.addNameContext(existingTreeNames{kName});
        end
    else
        existingTreeNames=[];
        USE_SIMULINK_NAMING=false;
    end

    newName='';
    aStructToSave=struct;
    DID_NEED_CONVERSION=false;
    if~isempty(signalsIn)

        ds=Simulink.SimulationData.Dataset();

        for kSignal=1:length(signalsIn)


            if isa(signalsIn{kSignal},'Simulink.SimulationData.Dataset')

                if~isempty(existingTreeNames)
                    newStructName=aStrUtil.getUniqueName(signalNamesIn{kSignal});
                    aStrUtil.addNameContext(newStructName);
                    aStructToSave.(newStructName)=signalsIn{kSignal};
                else
                    aStructToSave.(signalNamesIn{kSignal})=signalsIn{kSignal};
                end

            else
                DID_NEED_CONVERSION=true;



                if Simulink.sdi.internal.Util.isStructureWithoutTime(signalsIn{kSignal})

                    signalDataStruct=cell(1,length(signalsIn{kSignal}.signals));
                    signalNames=cell(1,length(signalsIn{kSignal}.signals));

                    for kSig=1:length(signalsIn{kSignal}.signals)
                        signalDataStruct{kSig}=signalsIn{kSignal}.signals(kSig).values;
                        signalNames{kSig}=signalsIn{kSignal}.signals(kSig).label;

                        if isfield(signalsIn{kSignal}.signals(kSig),'blockName')&&...
                            ischar(signalsIn{kSignal}.signals(kSig).blockName)
                            blockNames{kSig}=signalsIn{kSignal}.signals(kSig).blockName;
                        else
                            blockNames{kSig}='';
                        end
                    end


                    ds=addStructuresWandWOTime(ds,[],signalDataStruct,signalNames,blockNames);

                    DID_NEED_CONVERSION=true;
                elseif Simulink.sdi.internal.Util.isStructureWithTime(signalsIn{kSignal})

                    signalDataStruct=cell(1,length(signalsIn{kSignal}.signals));
                    signalNames=cell(1,length(signalsIn{kSignal}.signals));

                    for kSig=1:length(signalsIn{kSignal}.signals)
                        signalDataStruct{kSig}=signalsIn{kSignal}.signals(kSig).values;
                        signalNames{kSig}=signalsIn{kSignal}.signals(kSig).label;

                        if isfield(signalsIn{kSignal}.signals(kSig),'blockName')&&...
                            ischar(signalsIn{kSignal}.signals(kSig).blockName)
                            blockNames{kSig}=signalsIn{kSignal}.signals(kSig).blockName;
                        else
                            blockNames{kSig}='';
                        end
                    end


                    ds=addStructuresWandWOTime(ds,signalsIn{kSignal}.time,signalDataStruct,signalNames,blockNames);

                    DID_NEED_CONVERSION=true;
                elseif isa(signalsIn{kSignal},'Simulink.Timeseries')

                    aTs=slTimeseries2mlTimeseriesInSimulinkSignal(signalsIn{kSignal});
                    ds=ds.addElement(aTs,signalNamesIn{kSignal});

                    DID_NEED_CONVERSION=true;
                elseif isa(signalsIn{kSignal},'Simulink.TsArray')

                    try
                        aConvertedTSArray=Simulink.SimulationData.createStructOfTimeseries(signalsIn{kSignal});
                        ds=ds.addElement(aConvertedTSArray,signalNamesIn{kSignal});
                        DID_NEED_CONVERSION=true;
                    catch

                    end
                else

                    filterStruct.ALLOW_FOR_EACH=false;
                    filterStruct.ALLOW_EMPTY_DS=false;
                    filterStruct.ALLOW_EMPTY_TS=false;


                    if isSimulinkSignalFormat(signalsIn{kSignal},filterStruct)&&~isTimeExpression(signalsIn{kSignal})
                        ds=ds.addElement(signalsIn{kSignal},signalNamesIn{kSignal});
                        DID_NEED_CONVERSION=true;
                    end
                end
            end

        end


        if~USE_SIMULINK_NAMING
            if ds.numElements>0
                allFieldNames=fieldnames(aStructToSave);

                tempName=matlab.lang.makeValidName(tempName);
                newName=matlab.lang.makeUniqueStrings(tempName,allFieldNames);
                aStructToSave.(newName)=ds;
            end

        else
            if ds.numElements>0
                allFieldNames=fieldnames(aStructToSave);
                for k=1:length(allFieldNames)
                    aStrUtil.addNameContext(allFieldNames{k});
                end

                newName=aStrUtil.getUniqueName(tempName);
                aStructToSave.(newName)=ds;
            end
        end

    end


    function ds=addStructuresWandWOTime(ds,time,signalData,signalNames,blockNames)


        for jSig=1:length(signalData)


            if~isempty(time)
                ts=timeseries(signalData{jSig},time);
            else
                ts=timeseries(signalData{jSig});
            end

            aTs=Simulink.SimulationData.Signal();
            aTs.Name=signalNames{jSig};
            aTs.BlockPath=blockNames{jSig};
            aTs.Values=ts;


            ds=ds.addElement(aTs,signalNames{jSig});

        end


        function aTs=slTimeseries2mlTimeseriesInSimulinkSignal(aSL_TS)

            ats=timeseries(aSL_TS.Data,aSL_TS.Time);
            ats.Name=aSL_TS.Name;
            ats.DataInfo.Interpolation=aSL_TS.DataInfo.Interpolation;
            ats.DataInfo.Units=aSL_TS.DataInfo.Units;

            aTs=Simulink.SimulationData.Signal();
            aTs.Name=aSL_TS.Name;
            aTs.BlockPath=aSL_TS.BlockPath;
            if~isempty(aSL_TS.PortIndex)
                aTs.PortIndex=aSL_TS.PortIndex;
            end
            aTs.Values=ats;
