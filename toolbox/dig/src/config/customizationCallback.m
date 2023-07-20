function customizationCallback(userdata,cbinfo)
    userPath=userpath();
    toolstripFolder='sl_toolstrip_plugins';
    pluginName='slCustomization';
    matFileName='fhandle.mat';

    resourceFolder=fullfile(userPath,toolstripFolder,pluginName,pluginName,'resources');
    matFileName=fullfile(resourceFolder,matFileName);

    callbackName=strrep([userdata,'_cb'],':','_');


    cb=load(matFileName,callbackName);


    callbackInfo.studio=cbinfo.studio;
    callbackInfo.userdata=userdata;


    filds=fields(cb);
    eval(['cb.',filds{1},'(callbackInfo)'])
end
