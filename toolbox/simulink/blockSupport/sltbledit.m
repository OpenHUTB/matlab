function sltbledit(varargin)
























    context=varargin{2};

    s=settings;
    if~s.hasGroup('lutdesigner')

        lutdesigner.config.CustomSettings.retrieveCustomConfigFromPrefToSettings();
    end
    if strcmp(get_param(context,'Type'),'block_diagram')










        lutdesigner.open(gcs);

        selectedBlocksInView=setdiff(find_system(gcs,'SearchDepth','1','LookUnderMasks','all','FollowLinks','on','Selected','on'),{gcs});
        if ismember(gcb,selectedBlocksInView)
            lutdesigner.open(gcb);
        end
    else
        lutdesigner.open(context);
    end


