function exportToSimulink(obj,~)





    obj.massToolstripEnable(false);
    obj.pParameters.setPanelsEnable(false);
    drawnow();


    verInfo=ver;
    installedProducts={verInfo.Name}';
    isSimulinkInstalled=ismember('Simulink',installedProducts);

    if~isSimulinkInstalled
        uiwait(errordlg(getString(message('comm:waveformGenerator:Need2InstallSimulink')),...
        getString(message('comm:waveformGenerator:DialogTitle')),'modal'));

        obj.massToolstripEnable(true);
        obj.pParameters.setPanelsEnable(true);
        return
    elseif~license('checkout','SIMULINK')
        uiwait(errordlg(getString(message('comm:waveformGenerator:NoSimulinkLicense')),...
        getString(message('comm:waveformGenerator:DialogTitle')),'modal'));

        obj.massToolstripEnable(true);
        obj.pParameters.setPanelsEnable(true);
        return
    end


    try
        waveform=obj.pParameters.CurrentDialog.generateWaveform();
        if isempty(waveform)

            obj.massToolstripEnable(true);
            obj.pParameters.setPanelsEnable(true);
            return
        end
    catch e
        obj.pParameters.CurrentDialog.errorFromException(e);

        obj.massToolstripEnable(true);
        obj.pParameters.setPanelsEnable(true);
        return
    end


    obj.setStatus(getString(message('comm:waveformGenerator:Exporting')));


    if isLibrary(gcs)||isLinked(gcs)

        system=uniqueSystem;
        new_system(system,'Model');
    else

        system=gcs;
        if isempty(system)
            system='Untitled';
            new_system(system,'Model');
        end
    end


    [blockName,maskTitleName,waveNameText]=obj.pParameters.CurrentDialog.getMaskTextWaveName();
    try
        add_block('simulink/User-Defined Functions/MATLAB Function',strcat(system,['/',blockName]),...
        'MakeNameUnique','on','Tag','BlockGeneratedWWGApp');
    catch e
        obj.pParameters.CurrentDialog.errorFromException(e);

        obj.massToolstripEnable(true);
        obj.pParameters.setPanelsEnable(true);
        return
    end
    thisBlock=gcb;


    position=get_param(thisBlock,'Position');
    blockSize=[0,0,130,60];
    blockPosition=[position(1:2),position(1:2)];
    position=blockPosition+blockSize;
    set_param(thisBlock,'Position',position);


    MFBScriptCode=getMFBScriptCode();
    MFBScriptCode=indentcode(MFBScriptCode);
    MFBConfig=get_param(thisBlock,'MATLABFunctionConfiguration');
    MFBConfig.FunctionScript=MFBScriptCode;




    MFBHandle=find(slroot,'-isa','Stateflow.EMChart','Path',thisBlock);
    for i=1:size(MFBHandle.Inputs,1)-1
        MFBHandle.Inputs(1).Tunable=0;
        MFBHandle.Inputs(1).Scope='Parameter';
    end
    MFBHandle.Inputs.Tunable=0;
    MFBHandle.Inputs.Scope='Parameter';


    maskHandle=Simulink.Mask.create(thisBlock);


    sw=StringWriter;


    sw=exportGenerationCode(obj,sw);
    sw=exportImpairmentsCode(obj,sw);


    indentCode(sw);


    [configline,configParam]=obj.pParameters.CurrentDialog.getConfigParam();
    maskParamInitializaton=getMaskParamInitializaton(configline,configParam);
    initFcnCode=[sw.string,maskParamInitializaton];
    maskHandle.Initialization=initFcnCode;


    outVar.WaveformConfig=obj.pParameters.CurrentDialog.getConfiguration;
    Fs=getSampleRate(obj.pParameters.CurrentDialog)*double(obj.pParameters.FilteringDialog.Sps);
    waveform=obj.pParameters.FilteringDialog.filter(waveform);
    waveform=obj.impairWaveform(waveform,Fs);
    outVar.WaveformLength=length(waveform);
    outVar.Fs=Fs;


    set_param(thisBlock,'UserData',outVar);
    set_param(thisBlock,'UserDataPersistent','on');


    DescGroup=maskHandle.addDialogControl('group','DescGroupVar');
    DescGroup.Prompt=maskTitleName;
    DescTextVar=maskHandle.addDialogControl('text','DescTextVar');
    descPart1=getString(message('comm:waveformGenerator:maskDescriptionPart1',obj.pParameters.CurrentDialog.getAppLink,waveNameText));
    descPart2=getString(message('comm:waveformGenerator:maskDescriptionPart2',obj.pParameters.CurrentDialog.getUserDataText));
    DescTextVar.Prompt=[descPart1,'<br></br><br>',descPart2,'</br>'];
    DescTextVar.moveTo(DescGroup);


    ParamGroupVar=maskHandle.addDialogControl('group','ParameterGroupVar');
    ParamGroupVar.Prompt='Parameters';

    textFsDialog=maskHandle.addDialogControl('text','textFs');
    textFsDialog.Prompt=[getString(message('comm:waveformGenerator:sampleRateParam')),' ',num2str(outVar.Fs*1e-6,'%.9g'),' MHz'];
    textFsDialog.moveTo(ParamGroupVar);

    textWfLengthDialog=maskHandle.addDialogControl('text','textWFLength');
    textWfLengthDialog.Prompt=[getString(message('comm:waveformGenerator:waveLengthParam')),' ',num2str(length(waveform)),' samples'];
    textWfLengthDialog.moveTo(ParamGroupVar);

    samplesPerFrameParam=maskHandle.addParameter('Type','edit','Prompt',...
    getString(message('comm:waveformGenerator:samplesFrameParam')),...
    'Name','nsamps','Container','ParameterGroupVar','Tunable','off','Value','1');
    samplesPerFrameParam.DialogControl.PromptLocation='left';

    finalDataParam=maskHandle.addParameter('Type','popup','Prompt',...
    getString(message('comm:waveformGenerator:endDataParam')),...
    'Name','OutputAfterFinalValue','Container','ParameterGroupVar','Tunable','off',...
    'TypeOptions',{getString(message('comm:waveformGenerator:endDataCyclic')),...
    getString(message('comm:waveformGenerator:endDataZero'))});
    finalDataParam.DialogControl.PromptLocation='left';

    ParamGroupVar.Visible='on';


    maskHandle.addParameterConstraint('Name','samplesFrameConstraint',...
    'Parameters',{'nsamps'},'Rules',{'DataType','integer','Dimension'...
    ,{'scalar'},'Complexity',{'real'},'Sign',{'positive'},'Finiteness',{'finite'}});


    maskHandle.Type=maskTitleName;
    maskHandle.Help=obj.pParameters.CurrentDialog.getBlockLink();


    maskHandle.Display=obj.pParameters.CurrentDialog.getIconDrawingCommand();
    maskHandle.RunInitForIconRedraw='on';


    blockName=erase(blockName,'/');
    blockPath=strcat(system,['/',blockName]);
    if isMaskOff(blockPath)
        open_system(system);
    end


    obj.setStatus(getString(message('comm:waveformGenerator:Exported2Simulink',obj.pCurrentWaveformType)));


    obj.massToolstripEnable(true);
    obj.pParameters.setPanelsEnable(true);

end


function scriptCode=getMFBScriptCode()

    scriptCode=sprintf(['function wf = wfGenerator(waveform, nsamps, OutputAfterFinalValue)',newline,newline...
    ,'%% Create persistent variable',newline...
    ,'persistent src;',newline,newline...
    ,'%% Preallocate output',newline...
    ,'wf = complex(zeros(nsamps,size(waveform,2)));',newline,newline...
    ,'if isempty(src)',newline...
    ,'%% Get action when signal ends',newline...
    ,'if OutputAfterFinalValue == 1',newline...
    ,'signalEndAction = ''Cyclic repetition'';',newline...
    ,'else',newline...
    ,'signalEndAction = ''Set to zero'';',newline...
    ,'end',newline,newline...
    ,'%% Initialize persistent dsp.SignalSource to get current frame ',newline...
    ,'src = dsp.SignalSource(waveform,nsamps,''SignalEndAction'',signalEndAction);',newline...
    ,'end',newline,newline...
    ,'%% Extract current frame',newline...
    ,'wf(:,:) = src();',newline,newline...
    ,'end']);

end

function newSystem=uniqueSystem()



    newSystem='Untitled';

    while(systemExist(newSystem))
        [numSuff,prefix]=namenum(newSystem);
        if isempty(numSuff)
            newSystem=[newSystem,'1'];%#ok<AGROW> % System name did not end with a number
        else
            newSystem=[prefix,num2str(numSuff+1)];
        end
    end

end

function[suffix,prefix]=namenum(system)




    suffix=[];
    prefix=system;
    if isempty(system)||~ischar(system)||system(end)<'0'||system(end)>'9'
        return;
    end
    [~,columns]=find((system<'0')|(system>'9'));
    maxColumn=max(columns);
    prefix=system(1:maxColumn);
    suffix=str2double(system(maxColumn+1:end));

end

function x=isLinked(system)





    x=false;
    try
        if~isempty(system)
            x=strcmpi(get_param(bdroot(system),'staticlinkstatus'),'resolved');
        end
    catch ME %#ok<NASGU>
    end
end

function y=isLibrary(system)

    y=~isempty(system);
    if y
        y=strcmpi(get_param(bdroot(system),'BlockDiagramType'),'library');
    end
end

function z=systemExist(path)



    systemType=sysType(path);
    z=strcmp(systemType,'model')|strcmp(systemType,'subsystem')|strcmp(systemType,'block');
end

function systemType=sysType(path)








    try
        blockType=get_param(path,'BlockType');
        if strcmp(blockType,'SubSystem')
            systemType='subsystem';
        else
            systemType='block';
        end
        return
    catch ME %#ok<NASGU>
        try
            get_param(path,'Version');
            systemType='model';
            return
        catch ME %#ok<NASGU>
            try
                get_param(path,'Name');
                systemType='entity';
            catch ME %#ok<NASGU>
                systemType='none';
            end
        end
    end
end

function maskIsOff=isMaskOff(blockPath)



    seps=strfind(blockPath,'/');

    maskIsOff=local_isMaskOff(blockPath(1:seps(end)-1));

    function maskIsOff=local_isMaskOff(systemPath)

        seps=strfind(systemPath,'/');

        if isempty(seps)



            maskIsOff=true;
        elseif strncmpi(get_param(systemPath,'mask'),'on',2)


            maskIsOff=false;
        else


            maskIsOff=local_isMaskOff(systemPath(1:seps(end)-1));
        end

    end
end

function maskParamInitializaton=getMaskParamInitializaton(configline,configParam)

    maskParamInitializaton=sprintf(['%%%% Configuring block: update parameters and UserData',newline...
    ,'%% Get current block',newline...
    ,'thisBlock = gcb;',newline,newline...
    ,'%% Set info parameters',newline...
    ,'maskHandle = Simulink.Mask.get(thisBlock);',newline...
    ,'textFsDialog = maskHandle.getDialogControl(''textFs'');',newline...
    ,'textFsDialog.Prompt = [''',getString(message('comm:waveformGenerator:sampleRateParam')),' '' num2str(Fs*1e-6,''%%.9g'') '' MHz''];',newline...
    ,'textWfLengthDialog = maskHandle.getDialogControl(''textWFLength'');',newline...
    ,'textWfLengthDialog.Prompt = [''',getString(message('comm:waveformGenerator:waveLengthParam')),' '' num2str(length(waveform)) '' samples''];',newline,newline...
    ,'%% Set sample time of the block',newline...
    ,'set_param(thisBlock, ''SystemSampleTime'', num2str(nsamps/Fs,''%%.20g''));',newline,newline...
    ,'%% Update UserData',newline...
    ,configline...
    ,'outVar.WaveformConfig = ',configParam,';',newline...
    ,'outVar.WaveformLength = length(waveform);',newline...
    ,'outVar.Fs = Fs;',newline...
    ,'set_param(thisBlock, ''UserData'', outVar);']);
end

