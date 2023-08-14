function testBenchComponents(this)





    slConnection=this.ModelConnection;

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


    SLoutportHandles=slConnection.getOutportHandles;

    this.OutportSnk=[];


    for m=1:length(SLoutportHandles);
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


    inportSrcHandles=slConnection.getInportSrcHandles;

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
            for i=1:length(inportSrcHandles);
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


    function[srcName,LogName]=findSrcName(SLHandle)
        blkName=get_param(get_param(SLHandle,'Parent'),'Name');
        portNumber=get_param(SLHandle,'PortNumber');
        srcName=regexprep(regexprep(blkName,'\s',''),'-','_');
        LogName=[srcName,'_',num2str(portNumber)];


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
