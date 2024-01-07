function analogChannelTypeUpdate(block)
    channelType=get_param(block,'ChannelType');
    includeXtalk=get_param(block,'IncludeCrosstalkCheckBox');
    xtalkSpec=get_param(block,'CrosstalkSpecification');
    isImpulseResponse=strcmp(channelType,'Impulse response');
    isXtalk=strcmp(includeXtalk,'on');
    isCustom=strcmp(xtalkSpec,'Custom');

    maxNumberOfColumns=7;

    if isImpulseResponse&&isXtalk
        impStr=get_param(block,'ImpulseResponse');
        paramAsDouble=str2double(impStr);
        if isnan(paramAsDouble)
            paramAsNum=str2num(impStr);%#ok<ST2NM>
            if isempty(paramAsNum)
                impMat=slResolve(impStr,bdroot(block));
            else
                impMat=paramAsNum;
            end
        else
            impMat=paramAsDouble;
        end

        [dim1,dim2]=size(impMat);

        if dim1==1&&dim2>1

            crosstalkCount=0;
        elseif dim2>maxNumberOfColumns
            error(message('serdes:callbacks:ImpulseMax7Columns'));
        else
            crosstalkCount=dim2-1;
        end
    else
        crosstalkCount=0;
    end

    offoncell={'off','on'};

    propertyVisibilityTest=[
    true;
    ~isImpulseResponse;
    ~isImpulseResponse;
    ~isImpulseResponse;
    false;
    isImpulseResponse;
    isImpulseResponse;
    true;
    true;
    true;
    true;
    true;
    true;
    true;
    isXtalk&~isImpulseResponse;
    isXtalk&~isImpulseResponse&isCustom;
    isXtalk&~isImpulseResponse&isCustom;
    isXtalk&~isImpulseResponse;
    isXtalk&~isImpulseResponse;
    isXtalk&~isImpulseResponse;
    isXtalk&~isImpulseResponse;
    isXtalk&~isImpulseResponse;
    isXtalk&~isImpulseResponse;
    isXtalk&~isImpulseResponse;
    isXtalk&~isImpulseResponse;
    isXtalk&isImpulseResponse&crosstalkCount>=1;
    isXtalk&isImpulseResponse&crosstalkCount>=1;
    isXtalk&isImpulseResponse&crosstalkCount>=1;
    isXtalk&isImpulseResponse&crosstalkCount>=1;
    isXtalk&isImpulseResponse&crosstalkCount>=2;
    isXtalk&isImpulseResponse&crosstalkCount>=2;
    isXtalk&isImpulseResponse&crosstalkCount>=2;
    isXtalk&isImpulseResponse&crosstalkCount>=2;
    isXtalk&isImpulseResponse&crosstalkCount>=3;
    isXtalk&isImpulseResponse&crosstalkCount>=3;
    isXtalk&isImpulseResponse&crosstalkCount>=3;
    isXtalk&isImpulseResponse&crosstalkCount>=3;
    isXtalk&isImpulseResponse&crosstalkCount>=4;
    isXtalk&isImpulseResponse&crosstalkCount>=4;
    isXtalk&isImpulseResponse&crosstalkCount>=4;
    isXtalk&isImpulseResponse&crosstalkCount>=4;
    isXtalk&isImpulseResponse&crosstalkCount>=5;
    isXtalk&isImpulseResponse&crosstalkCount>=5;
    isXtalk&isImpulseResponse&crosstalkCount>=5;
    isXtalk&isImpulseResponse&crosstalkCount>=5;
    isXtalk&isImpulseResponse&crosstalkCount>=6;
    isXtalk&isImpulseResponse&crosstalkCount>=6;
    isXtalk&isImpulseResponse&crosstalkCount>=6;
    isXtalk&isImpulseResponse&crosstalkCount>=6];

    newVisibilities=offoncell(propertyVisibilityTest+1);
    curVisibilities=get_param(block,'MaskVisibilities');
    if~isequal(curVisibilities,newVisibilities)
        set_param(block,'MaskVisibilities',newVisibilities);
    end


    panelVisibility={
    isXtalk&~isImpulseResponse,'MagnitudePanel';
    isXtalk&~isImpulseResponse,'FEXTStimulusPanel';
    isXtalk&~isImpulseResponse,'NEXTStimulusPanel';
    isXtalk&isImpulseResponse&crosstalkCount>=1,'Stimulus1Panel';
    isXtalk&isImpulseResponse&crosstalkCount>=2,'Stimulus2Panel';
    isXtalk&isImpulseResponse&crosstalkCount>=3,'Stimulus3Panel';
    isXtalk&isImpulseResponse&crosstalkCount>=4,'Stimulus4Panel';
    isXtalk&isImpulseResponse&crosstalkCount>=5,'Stimulus5Panel';
    isXtalk&isImpulseResponse&crosstalkCount>=6,'Stimulus6Panel'};
    blockProps=Simulink.Mask.get(block);
    for ii=1:size(panelVisibility,1)
        panelName=panelVisibility{ii,2};
        panelVisTest=panelVisibility{ii,1};

        newVisibility=offoncell{panelVisTest+1};
        panelProps=blockProps.getDialogControl(panelName);
        if~isequal(panelProps.Visible,newVisibility)
            panelProps.setVisible(newVisibility);
        end
    end
    userNote=blockProps.getDialogControl('NoteToUser');
    if isXtalk&&isImpulseResponse&&crosstalkCount==0
        newVisibility='on';
    else
        newVisibility='off';
    end
    if~isequal(userNote.Visible,newVisibility)
        userNote.setVisible(newVisibility);
    end

end