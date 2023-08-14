
function[]=collectTestBenchData(this,SLdata)






    dispMsg=message('hdlcoder:hdldisp:CollectingData');
    hdldisp(dispMsg);

    if isa(SLdata,'Simulink.SimulationData.Dataset')
        collectTBDataFromDataset(this,SLdata);
    else
        errMsg=message('hdlcoder:engine:UnexpectedDatasetType');
        hDrv=hdlcurrentdriver;
        hDrv.addTestbenchCheck(hDrv.ModelName,'error',errMsg);
        error(errMsg);
    end
end

function collectTBDataFromDataset(this,SLdata)
    IO=[this.InportSrc,this.OutportSnk];
    TSArray=[];
    structElemArray=cell(1,numel(IO));
    ii=1;
    busPortSimulationLengthArr=zeros(1,numel(IO));
    while ii<=length(IO)
        blockPath=get_param(IO(ii).SLPortHandle,'Parent');





        [ds,idxs]=SLdata.find('BlockPath',blockPath);
        if length(idxs)>1
            loggingPortName=findLoggingName(IO(ii));
            el=ds.getElement(loggingPortName);
        else
            el=ds.getElement(1);
        end
        vals=el.Values;
        extractedData=vals;
        if isstruct(vals)

            extractedData=extractRecordData(vals);
            TSArray=[TSArray,extractedData];%#ok<AGROW>
        else
            TSArray=[TSArray,vals];
        end

%#ok<AGROW>

        hD=hdlcurrentdriver;
        if(~hD.getParameter('generaterecordtype'))
            ii=length(TSArray)+1;
        elseif(IO(ii).isRecordPort)


            [simulationLength1,MinimumRate1]=findSimulationLength(extractedData);
            busPortSimulationLength=floor(simulationLength1/MinimumRate1)+1;
            for kk=1:numel(vals)
                busPortSimulationLengthArr(ii)=busPortSimulationLength;


                structElemArray{ii}=getStructElem(vals(kk));
                ii=ii+1;
            end
        else

            for kk=1:numel(extractedData)
                structElemArray{ii}=false;
                ii=ii+1;
            end
        end
    end
    collectPortData(this,TSArray,structElemArray,busPortSimulationLengthArr);
end
function collectPortData(this,TSArray,structElemArray,busPortSimulationLengthArr)
    [simulationLength,MinimumRate]=findSimulationLength(TSArray);
    jj=1;
    for ii=1:length(this.InportSrc)
        port=this.InportSrc(ii);
        SLType=port.PortSLType;
        loggingPortName=findLoggingName(port);
        if(strcmp(SLType,'bus'))
            busPortSimulationLength=busPortSimulationLengthArr(ii);
            [HDLrate,datalength,datawidth,dataIsConstant,...
            loggedData,TStime,TIinc,jj]=findTimeSeriesInfobus(jj,TSArray,structElemArray{ii},SLType,simulationLength,MinimumRate,loggingPortName,busPortSimulationLength);


            if(dataIsConstant)
                loggedData=convertToScalarStruct(loggedData);
            end
        else
            timeObj=TSArray(jj);
            timeData=timeObj.TimeInfo;
            loggingPortName=findLoggingName(port);
            [HDLrate,datalength,datawidth,dataIsConstant,...
            loggedData,TStime,TIinc]=findTimeSeriesInfo(...
            timeData,timeObj,SLType,simulationLength,MinimumRate,loggingPortName);
            jj=jj+1;
        end
        if isempty(loggedData)
            errMsg=message('hdlcoder:engine:NoDataForTB',this.ModelConnection.ModelName);
            hDrv=hdlcurrentdriver;
            hDrv.addTestbenchCheck(hDrv.ModelName,'error',errMsg);
            error(errMsg);
        end

        if(isstruct(loggedData))
            checkLoggedDatabus(loggedData,loggingPortName);
        else
            checkLoggedData(loggedData,loggingPortName);
        end

        if isSLEnumType(SLType)
            realPart=loggedData;
            imagPart=[];

        elseif(strcmp(SLType,'bus'))
            realPart=loggedData;
            imagPart=[];
        else
            [realPart,imagPart]=resolveComplex(loggedData);
        end
        port.data=realPart;
        port.data_im=imagPart;
        port.HDLSampleTime=HDLrate;
        port.datalength=datalength;
        port.dataIsConstant=dataIsConstant;
        port.VectorPortSize=datawidth;
        port.timeseries=TStime;
        port.SLSampleTime=TIinc;
        this.InportSrc(ii)=port;
    end

    inputOffset=length(this.InportSrc);
    for ii=1:length(this.OutportSnk)
        port=this.OutportSnk(ii);
        SLType=port.PortSLType;
        loggingPortName=findLoggingName(port);
        if(strcmp(SLType,'bus'))

            busPortSimulationLength=busPortSimulationLengthArr(inputOffset+ii);
            [HDLrate,datalength,datawidth,dataIsConstant,...
            loggedData,TStime,TIinc,jj]=findTimeSeriesInfobus(jj,TSArray,structElemArray{inputOffset+ii},SLType,simulationLength,MinimumRate,loggingPortName,busPortSimulationLength);
            if(dataIsConstant)
                loggedData=convertToScalarStruct(loggedData);
            end
        else


            timeObj=TSArray(jj);
            timeData=timeObj.TimeInfo;
            loggingPortName=findLoggingName(port);
            [HDLrate,datalength,datawidth,dataIsConstant,...
            loggedData,TStime,TIinc]=findTimeSeriesInfo(...
            timeData,timeObj,SLType,simulationLength,MinimumRate,loggingPortName);
            jj=jj+1;
        end
        if(isstruct(loggedData))
            checkLoggedDatabus(loggedData,loggingPortName);
        else
            checkLoggedData(loggedData,loggingPortName);
        end

        if isSLEnumType(SLType)
            realPart=loggedData;
            imagPart=[];

        elseif(strcmp(SLType,'bus'))
            realPart=loggedData;
            imagPart=[];
        else
            [realPart,imagPart]=resolveComplex(loggedData);
        end
        port.data=realPart;
        port.data_im=imagPart;
        port.HDLSampleTime=HDLrate;
        port.datalength=datalength;
        port.dataIsConstant=dataIsConstant;
        port.VectorPortSize=datawidth;
        port.timeseries=TStime;
        port.SLSampleTime=TIinc;
        this.OutportSnk(ii)=port;
    end
end



function[HDLrate,datalength,datawidth,dataIsConstant,loggedData,TStime,TIinc]=...
    findTimeSeriesInfo(TimeInfoArray,timeObj,SLType,simulationLength,MinimumRate,loggingPortName)

    TIinc=TimeInfoArray(1).Increment;
    TIlen=TimeInfoArray(1).Length;
    TIend=TimeInfoArray(1).End;
    TIstart=TimeInfoArray(1).Start;
    for i=2:length(TimeInfoArray)
        if(isnan(TIinc)&&~isnan(TimeInfoArray(i).Increment))||...
            (~isnan(TIinc)&&TIinc~=TimeInfoArray(i).Increment)
            error(message('hdlcoder:engine:TimeSeriesInconsistentHybrid',loggingPortName));
        end
        if TimeInfoArray(i).Length~=TIlen
            error(message('hdlcoder:engine:TimeSeriesInconsistent','lengths'));
        end
        if TimeInfoArray(i).End~=TIend
            error(message('hdlcoder:engine:TimeSeriesInconsistent','end times'));
        end
        if TimeInfoArray(i).Start~=TIstart
            error(message('hdlcoder:engine:TimeSeriesInconsistent','start times'));
        end
    end


    SLdatalength=TIlen;
    if isfinite(TIinc)
        HDLrate=TIinc;
        datalength=SLdatalength;
    else
        if isValidTimeInfo(TimeInfoArray(1))
            simTime=TIend-TIstart;
            HDLrate=simTime/(SLdatalength-1);
            datalength=SLdatalength;
        elseif isa(TimeInfoArray,'tsdata.timemetadata')



            HDLrate=MinimumRate;
            datalength=SLdatalength;
        else
            HDLrate=MinimumRate;
            datalength=ceil(simulationLength/MinimumRate);
        end
    end

    if isa(timeObj,'Simulink.TsArray')
        timeData=timeObj.flatten;
        loggedData=[];
        TStime=timeData{1}.Time;
        for i=1:length(timeData)
            if timeData{i}.Time~=TStime
                error(message('hdlcoder:engine:TimeSeriesInconsistent','Time fields'));
            end
            rData=timeData{i}.data;
            [row,col,~]=size(rData);
            if ndims(rData)>2 %#ok<ISMAT>
                rData=squeeze(rData);
                if(row>1)||(col>1)
                    rData=l_transpose(rData);
                end
            end
            loggedData=[loggedData,rData];%#ok<AGROW>
        end
    else
        loggedData=timeObj.data;
        TStime=timeObj.Time;
    end

    if(~strcmp(SLType,'bus'))
        [dataSize,dataBp,dataSign]=hdlgetsizesfromtype(SLType);
        if dataSize~=0
            if isempty(strfind(SLType,'uint'))&&isempty(strfind(SLType,'int'))&&~isSLEnumType(SLType)&&isempty(strfind(SLType,'str'))
                loggedData=fi(loggedData,dataSign,dataSize,dataBp);
            end
        end
    end


    if ndims(loggedData)>2 %#ok<ISMAT>


        if ndims(loggedData)==3
            [row,col,~]=size(loggedData);
            loggedData=squeeze(loggedData);
            if(row>1&&col>1)
                datawidth=[row,col];
            else
                if~(row==1&&col==1)
                    loggedData=l_transpose(loggedData);
                end
                datawidth=max(row,col);
            end
        else

            [row,col,depth,~]=size(loggedData);
            datawidth=[row,col,depth];
        end
    else
        dSize=size(loggedData);
        if SLdatalength~=dSize(1)
            loggedData=l_transpose(loggedData);
            datawidth=dSize(1);
        else
            datawidth=dSize(2);
        end
    end


    if datawidth==1
        dataIsConstant=isempty(loggedData)||all(loggedData(:)==loggedData(1));
    else
        dataIsConstant=1;
        if ndims(loggedData)>2 %#ok<ISMAT>
            for ii=1:datalength
                if ndims(loggedData)==3

                    dataIsConstant=dataIsConstant&&isequal(loggedData(:,:,ii),loggedData(:,:,1));
                else

                    dataIsConstant=dataIsConstant&&isequal(loggedData(:,:,:,ii),loggedData(:,:,:,1));
                end
            end
        else
            for ii=1:datawidth
                dataIsConstant=dataIsConstant&&all(loggedData(:,ii)==loggedData(1,ii));
            end
        end
    end
end






function cplxData=l_transpose(cplxData)
    trans=transpose(cplxData);
    if isreal(cplxData)
        cplxData=trans;
    else
        if isreal(trans)
            cplxData=complex(trans);
        else
            cplxData=trans;
        end
    end
end



function[simLength,minSampleTime]=findSimulationLength(TSArray)
    simLength=0;
    for i=1:length(TSArray)
        tmd=TSArray(i).TimeInfo;
        simLength=max(simLength,tmd.End-tmd.Start);
    end

    if simLength==0
        simLength=1;
        minSampleTime=1;
    else
        minSampleTime=simLength;
        for i=1:length(TSArray)
            tmd=TSArray(i).TimeInfo;
            if isfinite(tmd.Increment)
                if tmd.Increment<minSampleTime
                    minSampleTime=tmd.Increment;
                end
            else
                possibleMin=simLength/(tmd.Length-1);
                if possibleMin<minSampleTime
                    minSampleTime=possibleMin;
                end
            end
        end
    end
end


function valid=isValidTimeInfo(logdata)

    if logdata.Length==0||logdata.Length==1&&logdata.End==0&&logdata.Start==0

        valid=0;
    else
        valid=1;
    end
end


function loggingName=findLoggingName(port)
    loggingName=port.loggingPortName;
    if isfield(port,'hasFeedBack')
        if port.hasFeedBack==1
            loggingName=port.feedBackPort;
        end
    end
end


function[realPart,imagPart]=resolveComplex(data)
    sl_type=class(data);
    if(strcmp(sl_type(1:3),'str'))
        tempdata=convertStringsToChars(data);


        if iscell(tempdata)
            data=cell2mat(tempdata);
        else
            data=tempdata;
        end
    end
    realPart=real(data);
    if isreal(data)
        imagPart=[];
    else
        imagPart=imag(data);
    end
end


function checkLoggedData(loggedData,Name)
    sl_type=class(loggedData);
    if(strcmp(sl_type(1:3),'str'))


        templog=convertStringsToChars(loggedData);
        if iscell(templog)
            loggedData=cell2mat(templog);
        else
            loggedData=templog;
        end
    end

    data_r=reshape(loggedData,1,prod(size(loggedData)));%#ok<PSIZE> % reshape data

    if(any(isnan(data_r))||any(isinf(data_r)))&&~targetcodegen.targetCodeGenerationUtils.isFloatingPointMode()
        errMsg=message('hdlcoder:engine:invaliddataerror',Name);
        hDrv=hdlcurrentdriver;
        hDrv.addTestbenchCheck(hDrv.ModelName,'error',errMsg);
        error(errMsg);
    end
end


function TSArray=extractRecordData(vals)
    TSArray=[];
    for ii=1:numel(vals)
        fields=fieldnames(vals(ii));
        for jj=1:numel(fields)
            elemVal=vals(ii).(fields{jj});
            if isstruct(elemVal)
                TSArray=[TSArray,extractRecordData(elemVal)];%#ok<AGROW>
            else
                TSArray=[TSArray,elemVal];%#ok<AGROW>
            end
        end
    end
end



function[HDLrate,datalength,datawidth,dataIsConstant,...
    loggedData,TStime,TIinc,jj]=findTimeSeriesInfobus(jj,TSArray,structelem,...
    SLType,simulationLength,MinimumRate,loggingPortName,portSimulationLength)
    dataIsConstant1=1;
    fields=fieldnames(structelem);
    for ii=1:numel(fields)
        elemVal=structelem.(fields{ii});
        if isstruct(elemVal)
            [HDLrate,datalength,datawidth,dataIsConstant,...
            loggedData,TStime,TIinc,jj]=findTimeSeriesInfobus(jj,TSArray,elemVal,...
            SLType,simulationLength,MinimumRate,loggingPortName,portSimulationLength);
            loggedData1.(fields{ii})=loggedData;
            dataIsConstant1=dataIsConstant&&dataIsConstant1;

        else
            timeObj=TSArray(jj);
            timeData=timeObj.TimeInfo;
            [HDLrate,datalength,datawidth,dataIsConstant,...
            loggedData,TStime,TIinc]=findTimeSeriesInfo(...
            timeData,timeObj,SLType,simulationLength,MinimumRate,loggingPortName);

            jj=jj+1;
            if(size(loggedData,1)==1&&portSimulationLength>1)
                for i=2:portSimulationLength
                    loggedData(i,:)=loggedData(i-1,:);
                end
            end
            loggedData1.(fields{ii})=loggedData;
            dataIsConstant1=dataIsConstant&&dataIsConstant1;
        end
    end
    datawidth=1;
    loggedData=loggedData1;
    dataIsConstant=dataIsConstant1;
end
function checkLoggedDatabus(loggedData,loggingPortName)
    fields=fieldnames(loggedData);
    for i=1:numel(fields)
        elemVal=loggedData.(fields{i});
        if(isstruct(elemVal))
            checkLoggedDatabus([loggedData.(fields{i})],loggingPortName);
        else
            checkLoggedData([loggedData.(fields{i})],loggingPortName);
        end
    end
end
function structElem=getStructElem(vals)
    fields=fieldnames(vals);
    for jj=1:numel(fields)
        elemVal=vals.(fields{jj});
        if isstruct(elemVal)
            structElem.(fields{jj})=getStructElem(elemVal);
        else
            structElem.(fields{jj})=true;
        end
    end
end
function LUTData=convertToScalarStruct(loggedData)
    fields=fieldnames(loggedData);
    for jj=1:numel(fields)
        elemVal=loggedData.(fields{jj});
        if(isstruct(elemVal))
            LUTData.(fields{jj})=convertToScalarStruct(elemVal);
        else
            LUTData.(fields{jj})=elemVal(1,:);
        end
    end
end

