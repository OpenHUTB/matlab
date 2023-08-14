function varargout=assert_api(method,blockH,varargin)








    dialogH=get_param(blockH,'UserData');
    if~isempty(dialogH)&&ishghandle(dialogH,'figure')
        UD=get(dialogH,'UserData');
        savedUD=[];
    else
        UD=[];


        fromWsH=find_system(blockH,'FollowLinks','on','LookUnderMasks','all',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'BlockType','FromWorkspace');
        savedUD=get_param(fromWsH,'SigBuilderData');
    end

    switch(method)
    case 'groupIndex'
        if~isempty(UD)
            varargout{1}=UD.current.dataSetIdx;
            varargout{2}=length(UD.dataSet);
        else
            varargout{1}=savedUD.dataSetIdx;
            varargout{2}=length(savedUD.dataSet);
        end

    otherwise
        DAStudio.error('Sigbldr:sigbldr:APIAssertUnrecognizedMethod',method);
    end
