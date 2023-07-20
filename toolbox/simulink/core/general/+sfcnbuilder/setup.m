function setup(blockHandle,rtwsimTest,varargin)



    if nargin<3
        openSFBGUI=true;
    else
        openSFBGUI=varargin{1};
    end

    ad=sfcnbuilder.setupdata(blockHandle,rtwsimTest);
    try
        str=['val = [[.9  0.75 0.75 1 1 .9 .9 1]'',[1 1 0.75 0.75 .9 .9 1 .9]''];'...
        ,'try , sys = get_param(gcb,''SfunBuilderFcnName'');',...
        'if isempty(sys), sys = get_param(gcb,''FunctionName''); end,',...
        'catch, sys = get_param(gcb,''FunctionName''); end'];
        set_param(ad.inputArgs,'MaskInitialization',str);
    end
    sfunctionName=get_param(blockHandle,'FunctionName');

    ad.SfunWizardData.ExternalDeclaration=loc_strtrim(ad.SfunWizardData.ExternalDeclaration);
    ad.SfunWizardData.IncludeHeadersText=loc_strtrim(ad.SfunWizardData.IncludeHeadersText);
    ad.SfunWizardData.LibraryFilesText=loc_strtrim(ad.SfunWizardData.LibraryFilesText);
    ad.SfunWizardData.UserCodeTextmdlStart=loc_strtrim(ad.SfunWizardData.UserCodeTextmdlStart);
    ad.SfunWizardData.UserCodeText=loc_strtrim(ad.SfunWizardData.UserCodeText);
    ad.SfunWizardData.UserCodeTextmdlUpdate=loc_strtrim(ad.SfunWizardData.UserCodeTextmdlUpdate);
    ad.SfunWizardData.UserCodeTextmdlDerivative=loc_strtrim(ad.SfunWizardData.UserCodeTextmdlDerivative);
    ad.SfunWizardData.UserCodeTextmdlTerminate=loc_strtrim(ad.SfunWizardData.UserCodeTextmdlTerminate);


    if~isfield(ad.SfunWizardData,'InputPorts')
        ad=i_moveFields(ad);
        ad=i_moveParamsFields(ad);
        ad=sfcnbuilder.sfunbuilderports('Create',ad.inputArgs,...
        ad.SfunWizardData.Majority,...
        ad.SfunWizardData.InputPorts,...
        ad.SfunWizardData.OutputPorts,...
        ad.SfunWizardData.Parameters,ad);
    else
        ad=sfcnbuilder.sfunbuilderports('Create',ad.inputArgs,...
        ad.SfunWizardData.Majority,...
        ad.SfunWizardData.InputPorts,...
        ad.SfunWizardData.OutputPorts,...
        ad.SfunWizardData.Parameters,ad);

    end



    if(strcmp(get_param(bdroot(gcbh),'Name'),'simulink3')||...
        strcmp(get_param(bdroot(gcbh),'Name'),'simulink'))
        ad.isSimulink3=1;
    else
        set_param(bdroot(blockHandle),'Lock','off');
        ad.isSimulink3=0;
    end


    sfunblkWizData=ad.SfunWizardData;
    selectionIndex=0;
    usingSampleTimeAsParameter=false;
    for k=1:length(ad.SfunWizardData.Parameters.Name)
        paramName=ad.SfunWizardData.Parameters.Name{k};
        if(~isempty(paramName)&&strcmp(paramName,sfunblkWizData.SampleTime))
            sfunblkWizData.SampleTimeValue=ad.SfunWizardData.Parameters.Name{k};
            usingSampleTimeAsParameter=true;
            selectionIndex=2;
            break;
        end
    end
    if(strcmp(sfunblkWizData.SampleTime,getString(message('Simulink:dialog:inheritedLabel')))||...
        strcmp(sfunblkWizData.SampleTime,getString(message('Simulink:dialog:continuousLabel')))||...
        strcmp(sfunblkWizData.SampleTime,'Continuous')||...
        strcmp(sfunblkWizData.SampleTime,'Inherited'))
        sampTime=[];
    else
        sampTime=str2num(sfunblkWizData.SampleTime);
    end

    if~usingSampleTimeAsParameter
        if(~isempty(sampTime)&&sampTime>0)
            sfunblkWizData.SampleTimeValue=sfunblkWizData.SampleTime;
            selectionIndex=2;
        else
            sfunblkWizData.SampleTimeValue='';
            if(strcmp(sfunblkWizData.SampleTime,getString(message('Simulink:dialog:continuousLabel')))||...
                strcmp(sfunblkWizData.SampleTime,'Continuous'))
                selectionIndex=1;
            end
        end
    end

    switch selectionIndex
    case 0
        ad.SfunWizardData.SampleMode='Inherited';
    case 1
        ad.SfunWizardData.SampleMode='Continuous';
    case 2
        ad.SfunWizardData.SampleMode='Discrete';
    end


    copiedBlocks={};
    block.BlockHandle=blockHandle;
    block.AppData=ad;
    block.SfunName=sfunctionName;
    block.CopiedBlocks=copiedBlocks;
    block.views=[];

    sfunctionbuilderMgr=sfunctionbuilder.internal.sfunctionbuilderMgr.getInstance();
    SfunWizardData=sfunctionbuilderMgr.addBlock(block);

    if openSFBGUI
        blockHandle=block.BlockHandle;
        sfunctionbuilderMgr.loadJavaScriptUI(blockHandle,SfunWizardData);
    end

end


function ad=i_moveFields(ad)


    ad.SfunWizardData.InputPorts.Name={'u'};
    ad.SfunWizardData.InputPorts.Dims={'1-D'};
    ad.SfunWizardData.InputPorts.Dimensions={['[',ad.SfunWizardData.InputPortWidth,',1]']};
    ad.SfunWizardData.InputPorts.DataType={ad.SfunWizardData.InputDataType0};
    ad.SfunWizardData.InputPorts.Frame={ad.SfunWizardData.InFrameBased0};
    ad.SfunWizardData.InputPorts.Bus={ad.SfunWizardData.InBusBased0};
    ad.SfunWizardData.InputPorts.Busname={ad.SfunWizardData.InBusname0};
    ad.SfunWizardData.InputPorts.Complexity={ad.SfunWizardData.InputSignalType0};


    ad.SfunWizardData.OutputPorts.Name={'y'};
    ad.SfunWizardData.OutputPorts.Dims={'1-D'};
    ad.SfunWizardData.OutputPorts.Dimensions={['[',ad.SfunWizardData.OutputPortWidth,',1]']};
    ad.SfunWizardData.OutputPorts.DataType={ad.SfunWizardData.OutputDataType0};
    ad.SfunWizardData.OutputPorts.Frame={ad.SfunWizardData.OutFrameBased0};
    ad.SfunWizardData.OutputPorts.Bus={ad.SfunWizardData.OutBusBased0};
    ad.SfunWizardData.OutputPorts.Busname={ad.SfunWizardData.OutBusname0};
    ad.SfunWizardData.OutputPorts.Complexity={ad.SfunWizardData.OutputSignalType0};
end


function ad=i_moveParamsFields(ad)

    if str2num(ad.SfunWizardData.NumberOfParameters)==0
        ad.SfunWizardData.Parameters.Name={''};
        ad.SfunWizardData.Parameters.DataType={''};
        ad.SfunWizardData.Parameters.Complexity={''};
    else
        n=0;
        for k=1:str2num(ad.SfunWizardData.NumberOfParameters)
            ad.SfunWizardData.Parameters.Name{k}=['param',num2str(n)];
            ad.SfunWizardData.Parameters.DataType{k}='real_T';
            ad.SfunWizardData.Parameters.Complexity{k}='real';
            n=n+1;
        end
    end
end

function s=loc_strtrim(str)
    if isempty(str)
        s='';
    else
        s=strtrim(str);
    end
end
