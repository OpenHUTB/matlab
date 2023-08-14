function hdlwa_exportToScript(hWC)


    MAObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    modelName=MAObj.modelName;
    dutName=hdlget_param(modelName,'HDLSubsystem');
    hdriver=hdlmodeldriver(modelName);
    hDI=hdriver.DownstreamIntegrationDriver;


    [FileName,PathName]=uiputfile('*.m','Export Workflow Configuration','hdlworkflow.m');


    if(FileName==0)
        return;
    end

    file=fullfile(PathName,FileName);


    h=waitbar(0,DAStudio.message('hdlcoder:workflow:ExportToScript'));
    pause(0.01);
    waitbar(0.4,h,DAStudio.message('hdlcoder:workflow:ExportToScript'));



    try
        hWC.export('Filename',file,'DUT',dutName,'Comments',true,'Headers',true,'Overwrite',true,'Warn',false,...
        'DownstreamDriver',hDI);

        waitbar(0.8,h,DAStudio.message('hdlcoder:workflow:ExportSuccess'));
    catch me
        hf=errordlg(me.message,'Error','modal');

        set(hf,'tag','HDL Workflow Advisor error dialog');
        setappdata(hf,'MException',me);


        uiwait(hf);
    end


    waitbar(1,h);
    pause(1);
    delete(h);
end