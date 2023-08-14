function generateTraceability(~,model,sourceSubsystem,hdlDir,hdlFileNames)




    modelPath=get_param(model,'FileName');
    bLink2Webview=false;
    ssHdl=[];
    if~isempty(sourceSubsystem)
        ssHdl=get_param(sourceSubsystem,'Handle');
    end
    auxiliaryInfo={true,model,ssHdl,sourceSubsystem,modelPath,hdlDir,true,bLink2Webview,false};


    [nempty,ndisabled]=rtwprivate('rtwtags',hdlFileNames,auxiliaryInfo,true,{},true,'utf-8');

    if nempty>0&&ndisabled>0
        error(message('hdlcoder:engine:hyperlinksdisabled'));
    end
end


