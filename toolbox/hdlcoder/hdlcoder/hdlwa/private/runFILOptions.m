function[ResultDescription,ResultDetails]=runFILOptions(system)



    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckErrorSeverity(1);


    [hdriver,~]=hdlcoderargs(system);
    hDI=hdriver.DownstreamIntegrationDriver;



    if isempty(hDI.hFilBuildInfo.BoardObj.ConnectionOptions)

        hDI.hFilBuildInfo.setConnection('');
    end

    mdladvObj.setCheckResultStatus(true);
    ResultDescription={};
    ResultDetails={};

    lb=ModelAdvisor.LineBreak;
    lb=lb.emitHTML;


    text=ModelAdvisor.Text('Successfully run.');
    text=[lb,lb,lb,text.emitHTML,lb];

    ResultDescription{end+1}=text;
    ResultDetails{end+1}='';
