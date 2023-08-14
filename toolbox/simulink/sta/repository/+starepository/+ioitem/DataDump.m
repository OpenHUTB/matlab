classdef DataDump<handle



    properties
    end


    methods(Static)


        function metaData_struct=appendFiDataToMetaDataStruct(dataVals,metaData_struct)

            metaData_struct.fiOverflowMode=dataVals.OverflowMode;
            metaData_struct.fiRoundMode=dataVals.RoundMode;

            metaData_struct.isfimathlocal=dataVals.isfimathlocal;

            metaData_struct.isFixDT=true;

            fiMathStruct=struct;
            fiMathStruct.CastBeforeSum=dataVals.CastBeforeSum;
            fiMathStruct.MaxProductWordLength=dataVals.MaxProductWordLength;
            fiMathStruct.MaxSumWordLength=dataVals.MaxSumWordLength;
            fiMathStruct.OverflowAction=dataVals.OverflowAction;
            fiMathStruct.ProductBias=dataVals.ProductBias;
            fiMathStruct.ProductFixedExponent=dataVals.ProductFixedExponent;
            fiMathStruct.ProductFractionLength=dataVals.ProductFractionLength;
            fiMathStruct.ProductMode=dataVals.ProductMode;
            fiMathStruct.ProductSlope=dataVals.ProductSlope;
            fiMathStruct.ProductSlopeAdjustmentFactor=dataVals.ProductSlopeAdjustmentFactor;
            fiMathStruct.ProductWordLength=dataVals.ProductWordLength;
            fiMathStruct.RoundingMethod=dataVals.RoundingMethod;
            fiMathStruct.SumBias=dataVals.SumBias;
            fiMathStruct.SumFixedExponent=dataVals.SumFixedExponent;
            fiMathStruct.SumFractionLength=dataVals.SumFractionLength;
            fiMathStruct.SumMode=dataVals.SumMode;
            fiMathStruct.SumSlope=dataVals.SumSlope;
            fiMathStruct.SumSlopeAdjustmentFactor=dataVals.SumSlopeAdjustmentFactor;
            fiMathStruct.SumWordLength=dataVals.SumWordLength;

            metaData_struct.fimath=fiMathStruct;
            metaData_struct.numerictype=dataVals.numerictype;

        end
    end

    methods


        function rootSource=getRootSource(obj)
            rootSource=obj.Name;
        end


        function sourceOfData=getTimeSource(~)
            sourceOfData='';
        end


        function ret=getDataSource(~)
            ret='';
        end


        function blockSource=getBlockSource(~)
            blockSource='';
        end


        function sID=getSID(~)
            sID='';
        end


        function modelSource=getModelSource(~)
            modelSource='';
        end


        function signalLabel=getSignalLabel(obj)
            signalLabel=obj.Name;
        end


        function portIdx=getPortIndex(~)
            portIdx=[];
        end


        function hierRef=getHierarchyReference(~)
            hierRef='';
        end


        function[timeDims,sampleDims]=getTimeAndSampleDims(obj)
            timeDims=getTimeDim(obj);
            sampleDims=getSampleDims(obj);
        end


        function timeDim=getTimeDim(~)
            timeDim=[];
        end


        function sampleDims=getSampleDims(~)
            sampleDims=[];
        end


        function interpVal=getInterpolation(~)
            interpVal='';
        end


        function unitStr=getUnit(~)
            unitStr='';
        end


        function metaData=getMetaData(~)
            metaData=[];
        end


        function dataVals=getTimeAndDataVals(obj)
            dataVals.Time=getTimeValues(obj);
            dataVals.Data=getDataValues(obj);
        end


        function timeVals=getTimeValues(~)
            timeVals=[];
        end


        function dataVals=getDataValues(~)
            dataVals=[];
        end


        function IS_HIERARHICAL=isHierarchical(~)
            IS_HIERARHICAL=true;
        end


        function timeMetaMode=getTimeMetadataMode(~)
            timeMetaMode='';
        end


        function ret=getSampleTimeString(~)
            ret='';
        end

    end



    methods


        function[sigID,leafSigs,runTimeRange]=staCreateSignal(obj,...
            runID,parentSigID,runTimeRange)
            repo=sdi.Repository(true);
            leafSigs=int32.empty;
            sigID=int32.empty;


            [timeDim,sampleDims]=getTimeAndSampleDims(obj);
            dataVals=getTimeAndDataVals(obj);

            hasData=~isempty(dataVals.Data);

            if~hasData
                dataVals=[];
            else

                isComplex=~islogical(dataVals.Data)&&~isreal(dataVals.Data)&&~isstring(dataVals.Data);
                totalChannels=prod(sampleDims);
                allDataVals=dataVals.Data;


                if totalChannels>1



                    foundValidChannel=false;
                    for idx=1:totalChannels
                        dataVals.Data=locGetChannelData(obj,allDataVals,sampleDims,idx);
                        if~isComplex||~isreal(dataVals.Data)
                            foundValidChannel=true;
                            break
                        end
                    end

                    if~foundValidChannel
                        isComplex=false;
                    end
                elseif length(sampleDims)>1


                    dataVals.Data=squeeze(dataVals.Data);
                end


                if isempty(runTimeRange.Start)||dataVals.Time(1)<runTimeRange.Start
                    runTimeRange.Start=dataVals.Time(1);
                end

                if isempty(runTimeRange.Stop)||dataVals.Time(end)>runTimeRange.Stop
                    runTimeRange.Stop=dataVals.Time(end);
                end
            end


            bpath=getBlockSource(obj);
            signalName=(getSignalLabel(obj));









            if hasData
                channelIdx=int32(1);
            else
                channelIdx=int32.empty;
            end


            interleaveMatrices=false;
            sigID=repo.add(...
            repo,...
            int32(runID),...
            getRootSource(obj),...
            getTimeSource(obj),...
            getDataSource(obj),...
            dataVals,...
            bpath,...
            getModelSource(obj),...
            signalName,...
            int32(timeDim),...
            int32(sampleDims),...
            int32(0),...
            channelIdx,...
            getSID(obj),...
            getMetaData(obj),...
            int32(parentSigID),...
            getRootSource(obj),...
            getInterpolation(obj),...
            getUnit(obj),...
            interleaveMatrices);

            obj.ID=sigID;



            hierRef=getHierarchyReference(obj);
            if~isempty(hierRef)
                repo.setSignalHierarchyReference(sigID,hierRef);
            end








            stStr=getSampleTimeString(obj);
            if~isempty(stStr)
                repo.setSignalSampleTimeLabel(sigID,stStr);
            end



            if hasData
                if~isComplex&&totalChannels==1
                    repo.setSignalDataValues(sigID,dataVals);
                    leafSigs=sigID;
                else

                    dataVals.Data=allDataVals;
                    leafSigs=int32(Simulink.HMI.findAllLeafSigIDsForThisRoot(repo,sigID));
                    locUpdateChannelSignals(obj,leafSigs,runID,repo,dataVals,totalChannels,isComplex);

                end

            end
        end


        function locUpdateChannelSignals(obj,leafSigIDs,runID,repo,dataVals,totalChannels,isComplex)

            numLeafSig=length(leafSigIDs);
            for idx=1:numLeafSig
                repo.addSignal(runID,leafSigIDs(idx));
            end


            rootDataSource=getDataSource(obj);
            sampleDims=getSampleDims(obj);
            unitStr=getUnit(obj);
            dtStr='';
            tmMode=getTimeMetadataMode(obj);

            leafBusPath='';
            channelVals.Time=dataVals.Time;
            sigIdx=1;
            for channelIdx=1:totalChannels
                [channelData,idxStr]=locGetChannelData(obj,dataVals.Data,sampleDims,channelIdx);


                if isa(obj,'starepository.ioitem.NDimensionalTimeSeries')||...
                    (isa(obj,'starepository.ioitem.SLTimeTable')&&~strcmp(obj.Properties.Dimension,'1'))

                    s=Simulink.sdi.getSignal(leafSigIDs(sigIdx));
                    metaStruct=s.getMetaData();
                    metaStruct.NDimIdxStr=idxStr;
                    s.setMetaData(metaStruct);

                    if isComplex
                        cmplx_parent=repo.getSignalParent(leafSigIDs(sigIdx));
                        s=Simulink.sdi.getSignal(cmplx_parent);
                        metaStruct_cmplParent=s.getMetaData();
                        metaStruct_cmplParent.NDimIdxStr=idxStr;
                        s.setMetaData(metaStruct_cmplParent);
                    end

                end



                channelVals.Data=channelData;
                repo.setSignalDataValues(leafSigIDs(sigIdx),channelVals);
                if~isempty(tmMode)
                    repo.setSignalTmMode(leafSigIDs(sigIdx),tmMode);
                end
                if~isempty(unitStr)
                    repo.setUnit(leafSigIDs(sigIdx),unitStr);
                end
                if~isempty(dtStr)
                    repo.setSignalDomainType(leafSigIDs(sigIdx),dtStr);
                end
                if~isempty(leafBusPath)
                    repo.setLeafBusSignal(leafSigIDs(sigIdx),locRepInvalidChars(leafBusPath));
                end


                if isComplex
                    if~isempty(tmMode)
                        repo.setSignalTmMode(leafSigIDs(sigIdx+1),tmMode);
                    end
                    if~isempty(unitStr)
                        repo.setUnit(leafSigIDs(sigIdx+1),unitStr);
                    end
                    if~isempty(dtStr)
                        repo.setSignalDomainType(leafSigIDs(sigIdx+1),dtStr);
                    end
                    if~isempty(leafBusPath)
                        repo.setLeafBusSignal(leafSigIDs(sigIdx+1),locRepInvalidChars(leafBusPath));
                    end


                    realID=leafSigIDs(sigIdx);
                    complexID=leafSigIDs(sigIdx+1);



                    sibOrderReal=sta.ChildOrder();
                    sibOrderReal.ParentID=obj.ID;
                    sibOrderReal.ChildID=realID;
                    sibOrderReal.SignalOrder=1;

                    sibOrderImg=sta.ChildOrder();
                    sibOrderImg.ParentID=obj.ID;
                    sibOrderImg.ChildID=complexID;
                    sibOrderImg.SignalOrder=2;

                    realMetaStruct.DataType=obj.Properties.DataType;
                    realMetaStruct.SignalType=obj.Properties.SignalType;
                    realMetaStruct.SampleTime=obj.Properties.SampleTime;
                    realMetaStruct.Min='';
                    realMetaStruct.Max='';
                    if isa(obj,'starepository.ioitem.NDimensionalTimeSeries')||...
                        (isa(obj,'starepository.ioitem.SLTimeTable')&&~strcmp(obj.Properties.Dimension,'1'))
                        realMetaStruct.NDimIdxStr=idxStr;
                    end
                    realMetaStruct.FileName=obj.FileName;
                    realMetaStruct.LastKnownFullFile=obj.LastKnownFullFile;
                    tempWhich=which(obj.LastKnownFullFile);

                    fileInfo=dir(tempWhich);
                    if~isempty(fileInfo)
                        realMetaStruct.LastModifiedDate=fileInfo.date;
                    else
                        realMetaStruct.LastModifiedDate='';
                    end



                    if isa(obj,'starepository.ioitem.SLTimeTable')
                        realMetaStruct.dataformat='sl_timetable';
                    end

                    complexMetaStruct=realMetaStruct;

                    s=Simulink.sdi.getSignal(realID);
                    s.setMetaData(realMetaStruct);
                    s=Simulink.sdi.getSignal(complexID);
                    s.setMetaData(complexMetaStruct);

                    repo.setSignalDataSource(leafSigIDs(sigIdx),sprintf('real(%s%s)',rootDataSource,idxStr));
                    repo.setSignalDataSource(leafSigIDs(sigIdx+1),sprintf('imag(%s%s)',rootDataSource,idxStr));
                    sigIdx=sigIdx+2;



                else
                    repo.setSignalDataSource(leafSigIDs(sigIdx),[rootDataSource,idxStr]);
                    sigIdx=sigIdx+1;
                end


            end
        end


        function[ret,idxStr]=locGetChannelData(~,dataVals,sampleDims,channelIdx)
            dimIdx=cell(size(sampleDims));
            [dimIdx{:}]=ind2sub(sampleDims,channelIdx);
            channel=cell2mat(dimIdx);
            numDims=length(channel);
            S.type='()';
            if numDims==1
                S.subs=[':',dimIdx];
                idxStr=sprintf('(:,%d)',channel);
            else
                S.subs=[dimIdx,':'];
                idxStr=sprintf('%d,',channel);
                idxStr=sprintf('(%s:)',idxStr);
            end

            ret=squeeze(subsref(dataVals,S));


            if~isreal(dataVals)&&isreal(ret)
                complexPart_FcnH=str2func(class(ret));
                ret=complex(ret,complexPart_FcnH(zeros(length(ret),1)));
            end
        end

    end


    methods


        function metaData_struct=appendFiDataToMetaDataStructImpl(obj,dataVals,metaData_struct)

            metaData_struct=starepository.ioitem.DataDump.appendFiDataToMetaDataStruct(dataVals,metaData_struct);

        end

    end

end

