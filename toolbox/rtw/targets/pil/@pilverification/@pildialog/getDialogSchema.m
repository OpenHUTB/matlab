function dlgStruct=getDialogSchema(obj,dummy)%#ok<INUSD>












    tagPrefix='tag_';


    configurationRow=1;
    widget=[];
    widget.Name=message('PIL:pil:XILBlockMaskSimulinkComponentLabel').getString;
    widget.Type='text';
    widget.Tag=[tagPrefix,'PILAlgorithmLabel'];

    widget.ColSpan=[1,1];
    widget.RowSpan=[configurationRow,configurationRow];
    PILAlgorithmLabel=widget;



    widget=[];
    widget.Type='text';
    componentPath=obj.Block.ComponentPath;

    widget.Name=i_getShortStringVersion(componentPath);
    widget.ToolTip=componentPath;
    widget.Tag=[tagPrefix,'PILComponentPath'];

    widget.ColSpan=[2,4];
    widget.RowSpan=[configurationRow,configurationRow];
    PILAlgorithm=widget;


    configurationRow=configurationRow+1;
    widget=[];
    widget.Name=message('PIL:pil:XILBlockMaskGeneratedCodeLabel').getString;
    widget.Type='text';
    widget.Tag=[tagPrefix,'PILCodeDirLabel'];

    widget.ColSpan=[1,1];
    widget.RowSpan=[configurationRow,configurationRow];
    PILCodeDirLabel=widget;



    widget=[];
    widget.Type='text';
    codeDir=obj.Block.CodeDir;

    widget.Name=i_getShortStringVersion(codeDir);
    widget.ToolTip=codeDir;
    widget.Tag=[tagPrefix,'PILCodeDir'];

    widget.ColSpan=[2,4];
    widget.RowSpan=[configurationRow,configurationRow];
    PILCodeDir=widget;

    if obj.isSIL
        showConnectivityConfig=false;
    else
        showConnectivityConfig=true;
    end

    if showConnectivityConfig

        configurationRow=configurationRow+1;
        widget=[];
        widget.Name=message('PIL:pil:XILBlockMaskTargetConnectivityLabel').getString;
        widget.Type='text';
        widget.Tag=[tagPrefix,'PILConfigLabel'];

        widget.ColSpan=[1,1];
        widget.RowSpan=[configurationRow,configurationRow];
        PILConfigLabel=widget;



        widget=[];
        widget.Type='text';
        if obj.isSIL
            maskConfigName='SIL';
        else
            maskConfigName=obj.Block.ConfigName;
        end
        widget.Name=maskConfigName;
        widget.Tag=[tagPrefix,'PILConfig'];

        widget.ColSpan=[2,4];
        widget.RowSpan=[configurationRow,configurationRow];
        PILConfig=widget;
    end




    if strcmp(obj.get_param('BlockType'),'SubSystem')


        lXrelModelArgNames=rtw.pil.SILPILBlock.getModelArgNames(obj.Block);
    else
        lXrelModelArgNames={};
    end



    configurationRow=configurationRow+1;
    widget=[];
    widget.Type='text';
    msgObj=message('PIL:pil:XILParamsLabel');
    widget.Name=msgObj.getString;
    widget.Tag=[tagPrefix,'XILParamsLabel'];

    widget.ColSpan=[1,1];
    widget.RowSpan=[configurationRow,configurationRow];
    XILParamsLabel=widget;


    widget=[];
    widget.Type='textbrowser';
    msgObj=message('PIL:pil:XILParamsTooltip');
    widget.ToolTip=msgObj.getString;

    widget.MaximumSize=[20000,75];


    lAllParametersStr=obj.Block.Parameters;
    text=i_getGlobalTunableParameters(lAllParametersStr,lXrelModelArgNames);
    if isempty(text)
        msgObj=message('PIL:pil:XILParamsNoParams');
        text=msgObj.getString;
    end
    widget.Text=text;
    widget.Tag=[tagPrefix,'XILParams'];

    widget.ColSpan=[2,4];
    widget.RowSpan=[configurationRow,configurationRow];
    XILParams=widget;



    paramsgroup.Type='group';
    paramsgroup.Name=message('PIL:pil:XILBlockMaskConfigurationLabel').getString;
    paramsgroup.Tag=[tagPrefix,'ParamsGroup'];
    paramsgroup.LayoutGrid=[configurationRow,2];

    paramsgroup.ColSpan=[1,1];
    paramsgroup.RowSpan=[2,2];

    paramsgroup.ColStretch=[0,1];

    paramsgroup.Items={
PILAlgorithmLabel...
    ,PILAlgorithm...
    ,PILCodeDirLabel...
    ,PILCodeDir...
    ,XILParams...
    ,XILParamsLabel};

    if showConnectivityConfig
        paramsgroup.Items{end+1}=PILConfigLabel;
        paramsgroup.Items{end+1}=PILConfig;
    end


    if isempty(lXrelModelArgNames)
        mdlargsgroup=[];
    else
        nModelArgs=numel(lXrelModelArgNames);
        lModelArgEdits=cell(1,nModelArgs);
        for kModelArg=1:numel(lXrelModelArgNames)
            configurationRow=configurationRow+1;
            widget=[];
            widget.Type='edit';
            widget.Name=sprintf('%s:',lXrelModelArgNames{kModelArg});
            widget.Tag=[tagPrefix,lXrelModelArgNames{kModelArg}];
            widget.ColSpan=[1,4];
            widget.RowSpan=[configurationRow,configurationRow];
            lValue=get_param(obj,lXrelModelArgNames{kModelArg});
            if isempty(lValue)
                lValue='';
            end
            widget.Value=lValue;
            lModelArgEdits{1,kModelArg}=widget;
        end

        msgObj=message('PIL:pil:XILMdlArgsLabel');
        text=msgObj.getString;

        configurationRow=configurationRow+1;
        mdlargsgroup.Type='group';
        mdlargsgroup.Name=text;
        mdlargsgroup.Tag=[tagPrefix,'MdlArgsGroup'];
        mdlargsgroup.LayoutGrid=[1,2];
        mdlargsgroup.ColSpan=[1,1];
        mdlargsgroup.RowSpan=[configurationRow,configurationRow];
        mdlargsgroup.ColStretch=[0,1];
        mdlargsgroup.Items=lModelArgEdits;
    end


    widget=[];
    if obj.isSIL
        type='SIL';
    else
        type='PIL';
    end
    widget.Name=['Verify the behavior of a Simulink component through a ',type,' simulation.'];
    widget.Type='text';
    widget.Tag=[tagPrefix,'PILDescriptionLabel'];
    widget.ColSpan=[1,1];
    widget.RowSpan=[1,1];
    PILDescriptionLabel=widget;


    descgroup.Type='group';
    if obj.isSIL
        descgroup.Name='Software-in-the-Loop (SIL) verification';
    else
        descgroup.Name='Processor-in-the-Loop (PIL) verification';
    end
    descgroup.Tag=[tagPrefix,'DescGroup'];
    descgroup.LayoutGrid=[1,1];

    descgroup.ColSpan=[1,1];
    descgroup.RowSpan=[1,1];
    descgroup.Items={PILDescriptionLabel};



    panel.Type='panel';
    panel.Tag=[tagPrefix,'Panel'];
    if isempty(mdlargsgroup)
        panel.Items={paramsgroup,descgroup};
    else
        panel.Items={paramsgroup,mdlargsgroup,descgroup};
    end

    panel.LayoutGrid=[3,1];

    panel.RowStretch=[0,0,1];

    dlgStruct.LayoutGrid=[1,1];
    dlgStruct.Items={panel};


    dlgStruct.HelpMethod='helpCallback';

    dlgStruct.CloseMethod='closeCallback';
    dlgStruct.CloseMethodArgs={'%dialog'};
    dlgStruct.CloseMethodArgsDT={'handle'};


    dlgStruct.PreApplyMethod='preApplyCallback';
    dlgStruct.PreApplyArgs={'%dialog'};
    dlgStruct.PreApplyArgsDT={'handle'};


    dlgStruct.DialogTag=['tag_pilblock_',obj.get_param('Name')];



    [isLibrary,isLocked]=obj.isLibraryBlock(obj.Block);
    if isLibrary&&isLocked
        dlgStruct.DisableDialog=true;
    elseif any(strcmp(obj.Root.SimulationStatus,{'running','paused'}))

        dlgStruct=obj.disableNonTunables(dlgStruct);
    end


    function shortStringVersion=i_getShortStringVersion(originalString)
        maxLength=50;
        origLength=length(originalString);
        shortLength=min(origLength,maxLength);
        if shortLength<origLength
            shortStringVersion=[originalString(1:shortLength),'...'];
        else
            shortStringVersion=originalString;
        end


        function text=i_getGlobalTunableParameters(lAllParametersStr,lXrelModelArgNames)


            lAllParametersCell=split(lAllParametersStr,{', ',','});
            if numel(lAllParametersCell)==1&&isequal(lAllParametersCell,'')
                lAllParametersCell={};
            end


            lGlobalParametersCell=setdiff(lAllParametersCell(:),lXrelModelArgNames(:),'stable');


            text=strjoin(lGlobalParametersCell,', ');

