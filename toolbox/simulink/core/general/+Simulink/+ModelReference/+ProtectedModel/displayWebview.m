function displayWebview(fileName)




    import Simulink.ModelReference.ProtectedModel.*;
    [opts,fullName]=getOptions(fileName,'runConsistencyChecksNoPlatform');


    stageName=DAStudio.message('Simulink:protectedModel:ProtectedModelViewMessageViewerStageName');
    stageObj=Simulink.output.Stage(stageName,'ModelName',opts.modelName,'UIMode',true);%#ok<NASGU>


    try
        dstDir=unpack(fullName,'VIEW');
        zipFileName=fullfile(dstDir,'webview',[opts.modelName,'.zip']);
        locCheckWebviewArtifacts(dstDir,zipFileName,opts.modelName);


        unzip(zipFileName,fullfile(dstDir,'webview'));
        htmlFile=fullfile(dstDir,'webview','webview.html');
        locCheckIfHTMLExists(htmlFile,opts.modelName);

        webviewTitle=DAStudio.message('Simulink:protectedModel:ViewForModel',opts.modelName);
        Simulink.report.ReportInfo.openURL(htmlFile,webviewTitle,'helpview([docroot ''/simulink/helptargets.map''],''slWebView'')');

    catch me
        Simulink.output.error(me);
    end
end

function locCheckWebviewArtifacts(dstDir,zipFileName,modelName)
    if~exist(dstDir,'dir')
        error(message('Simulink:protectedModel:ProtectedModelWebviewExtractionUnsuccessful',modelName));
    end
    if~exist(zipFileName,'file')
        error(message('Simulink:protectedModel:ProtectedModelWebviewExtractionUnsuccessful',modelName));
    end
end

function locCheckIfHTMLExists(htmlFile,modelName)
    if~exist(htmlFile,'file')
        error(message('Simulink:protectedModel:ProtectedModelWebviewExtractionUnsuccessful',modelName));
    end
end


