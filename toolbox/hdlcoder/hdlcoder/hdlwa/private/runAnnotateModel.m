function[ResultDescription,ResultDetails]=runAnnotateModel(system)



    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckErrorSeverity(1);

    ResultDescription={};
    ResultDetails={};


    hModel=bdroot(system);
    hdriver=hdlmodeldriver(hModel);


    hDI=hdriver.DownstreamIntegrationDriver;

    try

        logTxt=evalc('hDI.runAnnotateModel');

        if numel(logTxt)>0
            crs=findstr(logTxt,char(10));
            startP=1;
            for i=1:numel(crs)
                endP=crs(i);
                ttt=logTxt(startP:endP);
                ResultDescription{end+1}=ttt;
                startP=endP+1;
                ResultDetails{end+1}='';
            end
        end

    catch me


        [ResultDescription,ResultDetails]=publishFailedMessage(mdladvObj,me.message);

        return;
    end

    Result=true;
    needEnableAction=true;
    mdladvObj.setCheckResultStatus(Result);
    mdladvObj.setActionEnable(needEnableAction);

    lb=ModelAdvisor.LineBreak;
    lb=lb.emitHTML;

    text=ModelAdvisor.Text('Highlighted the critical path(s) on the model.');
    text=[lb,lb,lb,text.emitHTML,lb];

    ResultDescription{end+1}=text;
    ResultDetails{end+1}='';
