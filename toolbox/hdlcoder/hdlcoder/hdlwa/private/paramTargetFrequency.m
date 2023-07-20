function paramTargetFrequency(taskobj)





    mdladvObj=taskobj.MAObj;


    system=mdladvObj.System;
    hModel=bdroot(system);
    hDriver=hdlmodeldriver(hModel);
    hDI=hDriver.DownstreamIntegrationDriver;


    inputParams=mdladvObj.getInputParameters(taskobj.MAC);
    targetFreq=inputParams{1};


    try

        freq=str2double(targetFreq.Value);

        if~isfinite(freq)||~isreal(freq)||freq<0
            error(message('hdlcoder:setTargetFrequency:DCMOutputFrequencyNan',DAStudio.message('HDLShared:hdldialog:FPGASystemClockFrequency'),targetFreq.Value));
        end

        if strcmpi(hDI.get('Tool'),'Microchip Libero SoC')&&hDI.isGenericWorkflow


            if(freq~=0)
                freq=0;
                hDI.setTargetFrequency(freq);
                hDI.saveTargetFrequencyToModel(hModel,freq);
                me=MException(message('hdlcoder:setTargetFrequency:ZeroTargetFrequencyLiberoSoC'));
                throw(me);
            end
        end

        if(freq~=hDI.getTargetFrequency)
            hDI.setTargetFrequency(freq);
            hDI.saveTargetFrequencyToModel(hModel,freq);
        end

    catch ME
        hf=errordlg(ME.message,'Error','modal');

        set(hf,'tag','HDL Workflow Advisor error dialog');
        setappdata(hf,'MException',ME);


        uiwait(hf);


        hMAExplorer=mdladvObj.MAExplorer;
        if~isempty(hMAExplorer)&&~isempty(hMAExplorer.getDialog)
            currentDialog=hMAExplorer.getDialog;
            currentDialog.setWidgetValue('InputParameters_1',num2str(hDI.getTargetFrequency));
        end
    end



    utilAdjustTargetFrequency(mdladvObj,hDI);
end

