


classdef CaptureVector<handle
    properties
        ModelConnection;
OrigSllog
        OrigSllogName='dpig_origsllog';
SllogBasePath
        OutLogNamePrefix='dpig_out';
        InLogNamePrefix='dpig_in';
DpiDataVec

OutportNameList
InportNameList
VectorPortNameMap
OutportSnk
InportSrc

TestPointsToCaptureKeys
TestPointsLoggingSignalNames
TestPointLoggingRawNames
TestPointLoggingFlatNames


AccessFcnInterface
    end

    properties(Access=private)
OutportLoggedNameList
    end

    methods
        function this=CaptureVector(subsysPath,subsysName,InterfaceSelected)
            this.ModelConnection=dpigen.SimulinkConnection(subsysPath,subsysName);
            this.ModelConnection.initModel();
            this.ModelConnection.termModel();


            this.AccessFcnInterface=InterfaceSelected;


            if~strcmp(this.AccessFcnInterface,'None')
                [this.TestPointsToCaptureKeys,this.TestPointsLoggingSignalNames,this.TestPointLoggingFlatNames,this.TestPointLoggingRawNames]=this.ModelConnection.getTestPointsToCapture();
            else
                this.TestPointsToCaptureKeys={};
            end












            bp=regexprep(this.ModelConnection.System,['^',this.ModelConnection.ModelName,'[/]{0,1}'],'');

            if(isempty(bp))

                this.SllogBasePath=this.OrigSllogName;

            else


                bp=regexprep(bp,'//','__xxxx__');


                bps=regexp(bp,'/','split');



                bpsp=cellfun(@(x)(sprintf('(''%s'')',x)),bps,'UniformOutput',false);


                bpsp=regexprep(bpsp,'__xxxx__','/');


                bp=sprintf('%s.',bpsp{:});


                this.SllogBasePath=[this.OrigSllogName,'.',bp(1:end-1)];
            end
        end


        function saveToMatFile(this,dataStruct,tbdir)

            if(~isempty(this.DpiDataVec))
                data=this.DpiDataVec.inVec;
                for m=1:numel(data)
                    tmp1=[this.InLogNamePrefix,num2str(m)];
                    tmp2=data{m};
                    l_printdatafile(tbdir,tmp1,tmp2);
                end
                data=this.DpiDataVec.outVec;
                for m=1:numel(data)
                    tmp1=[this.OutLogNamePrefix,num2str(m)];
                    tmp2=data{m};
                    l_printdatafile(tbdir,tmp1,tmp2);
                end
                data=this.DpiDataVec.TestPointVec;
                for m=1:numel(data)
                    tmp1=[this.TestPointLoggingFlatNames{m}];
                    tmp2=data{m};
                    l_printdatafile(tbdir,tmp1,tmp2);
                end
            else
                error(message('HDLLink:DPITestbench:NoDataStruct',dataStruct));
            end

        end

        function numVectors=genVectors(this)




            try
                this.testBenchComponents();


                if strcmpi(get_param(bdroot(this.ModelConnection.ModelName),'StopTime'),'inf')
                    error(message('HDLLink:DPIG:InfiniteSimulationNotSupported'));
                end


                this.ModelConnection.initModelForTBGen(this.OrigSllogName,this.OutLogNamePrefix,this.InLogNamePrefix);
                this.ModelConnection.simulateModel();

                this.OrigSllog=eval(this.OrigSllogName);
                numVectors=this.sllog2dpivec();




            catch ME
                this.ModelConnection.restoreModelFromTBGen();
                this.ModelConnection.termModel();
                baseME=MException(message('HDLLink:DPIG:ModelSimulationFailed'));
                newME=addCause(baseME,ME);
                throw(newME);
            end

            this.ModelConnection.restoreModelFromTBGen();
            this.ModelConnection.termModel();

        end

        function numVectors=sllog2dpivec(this)












            if(~isempty(this.InportSrc))
                inputPortNames={this.InportSrc.loggingPortName};
            else
                inputPortNames={};
            end
            if(~isempty(this.OutportSnk))
                outputPortNames=this.OutportLoggedNameList;
            else
                outputPortNames={};
            end

            [inLogSignals,inLogSignalsTimeInfo]=l_FlattenSignalLogs(this.OrigSllog,inputPortNames,{});
            [outLogSignals,outLogSignalsTimeInfo]=l_FlattenSignalLogs(this.OrigSllog,outputPortNames,{});
            [TestPointLogSignals,TestPointLogSignalsTimeInfo]=l_FlattenSignalLogs(this.OrigSllog,this.TestPointsLoggingSignalNames,this.TestPointLoggingRawNames);
            inSamples=l_getSampleCounts(inLogSignalsTimeInfo);
            outSamples=l_getSampleCounts(outLogSignalsTimeInfo);
            TestPointSamples=l_getSampleCounts(TestPointLogSignalsTimeInfo);



            samples=[inSamples,outSamples];
            numVectors=max(samples);
            l_sampleCountCheck(samples,TestPointSamples);




            this.DpiDataVec.inVec=l_dataConversion(inLogSignals,inSamples,numVectors);
            this.DpiDataVec.outVec=l_dataConversion(outLogSignals,outSamples,numVectors);
            this.DpiDataVec.TestPointVec=l_dataConversion(TestPointLogSignals,TestPointSamples,numVectors);
        end

        function testBenchComponents(this)



            component.SLBlockName='';
            component.loggingPortName='';
            component.SLPortHandle=-1;
            component.SLSampleTime={};
            component.HDLSampleTime={};
            component.timeseries={};
            component.data={};
            component.data_im={};
            component.HDLPortName={};
            component.PortVType={};
            component.PortSLType={};
            component.datalength={};
            component.dataIsConstant=0;
            component.dataIsComplex=0;
            component.dataWidth=0;
            component.HDLNewType={};
            component.VectorPortSize={};
            component.procedureName={};
            component.procedureInput={};
            component.procedureOutput={};
            component.ClockName='';
            component.ClockEnable='';
            component.ClockEnableSigIdx=0;
            component.dataRdEnb='';
            component.srcDoneSigIdx=0;
            component.snkDoneSigIdx=0;
            component.hasFeedBack=0;
            component.feedBackPort=0;

            vportMap.expNameList={};
            vportMap.Handle=[];


            SLoutportHandles=this.ModelConnection.getOutportHandles;

            this.OutportSnk=[];


            for m=1:length(SLoutportHandles)
                snkComponent=component;
                SLportHandle=SLoutportHandles(m);
                HDLPortName=[this.OutLogNamePrefix,num2str(m)];
                snkComponent.SLPortHandle=SLportHandle;
                snkComponent.HDLPortName{end+1}=HDLPortName;

                snkComponent.loggingPortName=HDLPortName;




                vportMap.expNameList{end+1}=HDLPortName;
                vportMap.Handle=[vportMap.Handle,SLportHandle];

                this.OutportSnk=[this.OutportSnk,snkComponent];
                this.OutportNameList{end+1}=snkComponent.loggingPortName;
            end




















            [~,ia,ic]=unique(SLoutportHandles,'stable');
            OutportNameList_ia=this.OutportNameList(ia);
            this.OutportLoggedNameList=OutportNameList_ia(ic);


            inportSrcHandles=this.ModelConnection.getInportSrcHandles;











            OutputSIDSrcBlks=unique(arrayfun(@(x)get_param(get_param(x,'Parent'),'SID'),...
            SLoutportHandles,...
            'UniformOutput',false));
            InputSIDSrcBlks=unique(arrayfun(@(x)get_param(get_param(x,'Parent'),'SID'),...
            inportSrcHandles,...
            'UniformOutput',false));
            assert(length(unique([InputSIDSrcBlks,OutputSIDSrcBlks]))==length([InputSIDSrcBlks,OutputSIDSrcBlks]),...
            message('HDLLink:DPITestbench:PassThroughSignalLoggingNotSupported'));

            this.InportSrc=[];
            for m=1:length(inportSrcHandles)
                if inportSrcHandles(m)~=-1
                    srcComponent=component;
                    srcName=findSrcName(inportSrcHandles(m));
                    srcComponent.SLBlockName=srcName;
                    srcComponent.loggingPortName=[this.InLogNamePrefix,num2str(m)];
                    SLportHandle=inportSrcHandles(m);
                    srcComponent.SLPortHandle=inportSrcHandles(m);
                    [hasFeedBack,feedBackPort]=checkForFeedBack(this,inportSrcHandles(m));

                    if hasFeedBack
                        srcComponent.feedBackPort=feedBackPort;
                        srcComponent.hasFeedBack=hasFeedBack;
                    end
                    for i=1:length(inportSrcHandles)
                        if inportSrcHandles(i)==inportSrcHandles(m)
                            HDLPortName=srcComponent.loggingPortName;

                            srcComponent.HDLPortName{end+1}=HDLPortName;

                            vportMap.expNameList{end+1}=HDLPortName;
                            vportMap.Handle=[vportMap.Handle,SLportHandle];


                        end
                    end
                    this.InportSrc=[this.InportSrc,srcComponent];
                    this.InportNameList{end+1}=srcComponent.SLBlockName;
                    inportSrcHandles(inportSrcHandles==inportSrcHandles(m))=-1;
                end
            end

            this.VectorPortNameMap=vportMap;
        end
    end
end

function[flatSignalLogs,flatSignalTimeInfo]=l_FlattenSignalLogs(origSignalLog,loggedSigNames,loggedRawNames)

    flatSignalLogs=containers.Map;
    flatSignalTimeInfo=containers.Map;
    count=1;
    StructPathKeyToCount=containers.Map;
    for ii=1:length(loggedSigNames)
        sigN=loggedSigNames{ii};
        Temptsobj=origSignalLog.getElement(sigN);
        if isa(Temptsobj,'Simulink.SimulationData.Dataset')
            Temptsobj=Temptsobj.getElement(loggedRawNames{ii});
        end

        tsobj=Temptsobj.Values;




        n_GetElementData(tsobj,false,sigN);

    end

    function n_GetElementData(inputobj,IsVectorOfBuses,StructFieldPath)

        if isstruct(inputobj)&&numel(inputobj)>1

            for iii=1:numel(inputobj)
                n_GetElementData(inputobj(iii),true,StructFieldPath);
            end
        elseif isstruct(inputobj)

            fieldnames=fields(inputobj);
            for m=1:numel(fieldnames)


                n_GetElementData(inputobj.(fieldnames{m}),IsVectorOfBuses,[StructFieldPath,'_',fieldnames{m}]);
            end
        else

            if(~isa(inputobj,'Simulink.Timeseries')&&~isa(inputobj,'timeseries'))
                error(message('HDLLink:DPITestbench:NotTsObj',sigN));
            end

            if(~isnumeric(inputobj.Data)&&~islogical(inputobj.Data))
                error(message('HDLLink:DPITestbench:ToMATNonNumeric',sigN));
            end


            if IsVectorOfBuses

                if~isKey(StructPathKeyToCount,StructFieldPath)


                    StructPathKeyToCount(StructFieldPath)=num2str(count);

                    flatSignalLogs(StructPathKeyToCount(StructFieldPath))=[];
                    flatSignalTimeInfo(StructPathKeyToCount(StructFieldPath))=inputobj.TimeInfo;


                    count=count+1;
                end

                if isa(inputobj.Data,'embedded.fi')


                    if~ismatrix(inputobj.Data)
                        error(message('HDLLink:DPITestbench:FixedPointMultiDimensionalArraysNotSupported'));
                    end
                    flatSignalLogs(StructPathKeyToCount(StructFieldPath))=vertcat(flatSignalLogs(StructPathKeyToCount(StructFieldPath)),l_GetProperlyTransformedData(inputobj.Data));
                else




                    flatSignalLogs(StructPathKeyToCount(StructFieldPath))=cat(ndims(l_GetProperlyTransformedData(inputobj.Data))-1,flatSignalLogs(StructPathKeyToCount(StructFieldPath)),l_GetProperlyTransformedData(inputobj.Data));
                end

            else
                flatSignalLogs(num2str(count))=l_GetProperlyTransformedData(inputobj.Data);
                flatSignalTimeInfo(num2str(count))=inputobj.TimeInfo;
                count=count+1;
            end
        end
    end
end

function samples=l_getSampleCounts(loggedSigsTimeInfo)
    samples=zeros(1,length(loggedSigsTimeInfo));
    for idx=1:numel(samples)
        samples(idx)=loggedSigsTimeInfo(num2str(idx)).Length;
    end
end



function l_sampleCountCheck(IOsamples,TPsamples)

    uniquesamples=unique(IOsamples);






    uniqueTestPointSample=unique(TPsamples);

    if(~((length(uniqueTestPointSample)==1)||...
        (length(uniqueTestPointSample)==2&&~isempty(find(uniqueTestPointSample==1,1))))...
        )&&~isempty(TPsamples)


        error(message('HDLLink:DPITestbench:TestPointDiffNumSamples',sprintf('%d ',uniqueTestPointSample)));
    end


    if(~all(uniquesamples))
        error(message('HDLLink:DPITestbench:NoData'));
    end

end

function TransformedData=l_GetProperlyTransformedData(Data)






    if ismatrix(Data)
        TransformedData=Data.';
    else





        TransformedData=Data;
    end
end


function dpivec=l_dataConversion(loggedSigs,samples,numVectors)

    dpivec={};

    for ii=1:length(loggedSigs)
        isConst=l_isConstantSig(samples(ii),numVectors);


        if(isConst)
            if ndims(loggedSigs(num2str(ii)))>1
                data=reshape(loggedSigs(num2str(ii)),numel(loggedSigs(num2str(ii))),1);
            else
                data=loggedSigs(num2str(ii));
            end
            dpivec{ii}=repmat(data,numVectors,1);%#ok<AGROW>
        else
            if~isreal(loggedSigs(num2str(ii)))
                dpivec{end+1}=real(loggedSigs(num2str(ii)));%#ok<AGROW>
                dpivec{end+1}=imag(loggedSigs(num2str(ii)));%#ok<AGROW>
            else
                dpivec{end+1}=loggedSigs(num2str(ii));%#ok<AGROW>
            end
        end
    end

end

function isConst=l_isConstantSig(numSamples,numVectors)
    if(numSamples==1&&numVectors>=2)
        isConst=true;
    else
        isConst=false;
    end
end

function l_printdatafile(tbdir,varname,vardata)

    if isenum(vardata)
        enumName=class(vardata);
        try
            enumType=Simulink.data.getEnumTypeInfo(enumName,'StorageType');
        catch
            error(message('HDLLink:DPITargetCC:InvalidEnumStorageType'));
        end

        if strcmp(enumType,'int')
            enumType='int32';
        end

        castFunc=str2func(enumType);
        vardata=castFunc(vardata);
    end
    hexdata=l_convert2hex(reshape(vardata,numel(vardata),1));

    filename=[tbdir,filesep,varname,'.dat'];
    fid=fopen(filename,'w');
    if fid==-1
        error('Failed to open file %d for write',filename);
    end
    hexdata=[hexdata,repmat('\n',size(hexdata,1),1)];
    hexdata=reshape(hexdata',1,numel(hexdata));
    fprintf(fid,hexdata(:)');
    fclose(fid);
end

function out=l_convert2hex(data)

    if isa(data,'embedded.fi')
        if data.issigned
            if data.WordLength>64
                out=ll_getSignedFixedPointData();
                return;
            else





                data=storedInteger(data(:));
            end
        else
            out=hex(data(:));
            return;
        end
    end

    if isinteger(data)||islogical(data)





        if isa(data,'int8')
            data=typecast(data,'uint8');
        elseif isa(data,'int16')
            data=typecast(data,'uint16');
        elseif isa(data,'int32')
            data=typecast(data,'uint32');
        elseif isa(data,'int64')||isa(data,'uint64')


            UnformattedHexOut=dec2hex(typecast(data,'uint32'),8);
            sz=size(UnformattedHexOut);
            Temp=reshape(UnformattedHexOut',sz(2)*2,[]);
            Temp=Temp';
            out=[Temp(:,sz(2)+1:end),Temp(:,1:sz(2))];
            return;
        end
        out=dec2hex(data(:));
    elseif isfloat(data)
        out=num2hex(data(:));
    else
        error(message('HDLLink:DPITargetCC:dpigInvalidDataTypeCapture',class(data),'input or output'));
    end
    function OutStr=ll_getSignedFixedPointData()

        if any(bitget(data,data.WordLength))||mod(data.WordLength,64)==0


            OutStr=hex(data(:));
        else


            OutStr=hex(bitconcat(fi(uint64(bitget(data,data.WordLength))*intmax('uint64'),0,64-mod(data.WordLength,64),0),data));
        end
    end
end


function[srcName,LogName]=findSrcName(SLHandle)
    blkName=get_param(get_param(SLHandle,'Parent'),'Name');
    portNumber=get_param(SLHandle,'PortNumber');
    srcName=regexprep(regexprep(blkName,'\s',''),'-','_');
    LogName=[srcName,'_',num2str(portNumber)];
end

function[status,feedBackLoggingPort]=checkForFeedBack(this,inportSrcHandles)
    status=0;
    feedBackLoggingPort='';
    for i=1:length(this.OutportSnk)
        if inportSrcHandles==this.OutportSnk(i).SLPortHandle
            status=1;
            feedBackLoggingPort=this.OutportSnk(i).loggingPortName;
            break;
        end
    end
end
