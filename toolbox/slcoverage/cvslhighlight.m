function cvslhighlight(method,varargin)




    try

        oldwarn=warning('off','Simulink:Commands:SetParamLinkChangeWarn');
        switch(lower(method))
        case 'apply'
            apply_color(varargin{:});
        case 'apply_style'
            apply_style(varargin{:});
        case 'revert'
            model_revert(varargin{:});
        case 'revert_block'
            block_revert(varargin{:});
        otherwise
            error(message('Slvnv:simcoverage:cvslhighlight:UnknownMethod'));
        end
        warning(oldwarn.state,'Simulink:Commands:SetParamLinkChangeWarn');
    catch MEx
        rethrow(MEx);
    end

    function block_revert(blockH)
        if SlCov.CovStyle.IsFeatureEnabled()
            modelH=bdroot(blockH);
            styleSession=cvi.Informer.getCovStyleSession(modelH);
            if isa(styleSession,'SlCov.CovStyle.Session')
                styleSession.revertBlockHighlighting(blockH);
            end
            return
        end

        modelH=bdroot(blockH);
        modelColorData=get_param(modelH,'covColorData');
        if isempty(modelColorData)
            return;
        end

        isDirty=strcmp(get_param(modelH,'dirty'),'on');



        SLStudio.SetCoverageHighlightColors('set_backgroundforeground_color',blockH,{'white'},{'black'});

        if strcmpi(get_param(blockH,'BlockType'),'SubSystem')
            SLStudio.SetCoverageHighlightColors('set_screen_color',blockH,{'white'});
        end

        if~isDirty
            set_param(modelH,'dirty','off');
        end



        function apply_color(modelH,blockH,fgColor,bgColor,systemH,screenColor)

            if nargin<6
                systemH=[];
                screenColor={};
            end
            colorFG=true;
            try
                if strcmpi(get_param(modelH,'SampleTimeColors'),'on')
                    colorFG=false;
                end
            catch %#ok<CTCH>
            end
            modelColorData=get_param(modelH,'covColorData');
            isDirty=strcmp(get_param(modelH,'dirty'),'on');


            if isempty(modelColorData)
                modelColorData=cvi.Informer.covcolordata_struct;
            end

            if~isempty(blockH)


                [newBlks,~]=setdiff(blockH,modelColorData.mappedBlks);

                fgcolors=get_param(newBlks,'ForegroundColor');
                bgcolors=get_param(newBlks,'BackgroundColor');

                modelColorData.mappedBlks=[modelColorData.mappedBlks;newBlks(:)];
                if~colorFG
                    fgcolors=cell(size(newBlks));
                end
                if~iscell(fgcolors)
                    fgcolors={fgcolors};
                end
                if~iscell(bgcolors)
                    bgcolors={bgcolors};
                end
                if isempty(modelColorData.FGColor)
                    modelColorData.FGColor=fgcolors;
                else
                    modelColorData.FGColor=[modelColorData.FGColor;fgcolors(:)];
                end

                if isempty(modelColorData.BGColor)
                    modelColorData.BGColor=bgcolors;
                else
                    modelColorData.BGColor=[modelColorData.BGColor;bgcolors(:)];
                end





                SLStudio.SetCoverageHighlightColors('set_backgroundforeground_color',blockH,{bgColor},{fgColor});
            end

            if~isempty(systemH)
                [newSys,~]=setdiff(systemH,modelColorData.systems);
                screenColors=get_param(newSys,'ScreenColor');
                if~iscell(screenColors)
                    screenColors={screenColors};
                end

                modelColorData.systems=[modelColorData.systems;newSys(:)];
                modelColorData.screenColors=[modelColorData.screenColors;screenColors(:)];


                if(~isempty(systemH))
                    SLStudio.SetCoverageHighlightColors('set_screen_color',systemH,{screenColor});
                else
                    for i=1:length(systemH)
                        set_param(systemH(i),'ScreenColor',screenColor);
                    end
                end
            end

            set_param(modelH,'covColorData',modelColorData);


            if~isDirty
                set_param(modelH,'dirty','off');
            end

            function model_revert(modelH)
                if SlCov.CovStyle.IsFeatureEnabled()
                    styleSession=cvi.Informer.getCovStyleSession(modelH);
                    if isa(styleSession,'SlCov.CovStyle.Session')
                        styleSession.revertAllHighlighting();
                    end
                    return
                end

                modelColorData=get_param(modelH,'covColorData');
                isDirty=strcmp(get_param(modelH,'dirty'),'on');

                if isempty(modelColorData)
                    return;
                end

                blockH=modelColorData.mappedBlks;
                fgColor=modelColorData.FGColor;
                bgColor=modelColorData.BGColor;



                isValid=ishandle(blockH);
                blockH(~isValid)=[];
                fgColor(~isValid)=[];
                bgColor(~isValid)=[];

                if(~isempty(blockH))
                    warning_state=warning('off');%#ok<WNOFF>
                    SLStudio.SetCoverageHighlightColors('set_backgroundforeground_color',blockH,bgColor,fgColor);
                    warning(warning_state);
                else
                    for i=1:length(blockH)

                        try
                            set_param(blockH(i),'BackgroundColor',bgColor{i});
                            if~isempty(fgColor{i})
                                set_param(blockH(i),'ForegroundColor',fgColor{i})
                            end

                        catch Mex %#ok<NASGU>
                        end
                    end
                end

                systems=modelColorData.systems;
                screenColors=modelColorData.screenColors;



                isValid=ishandle(systems);
                systems(~isValid)=[];
                screenColors(~isValid)=[];



                if(~isempty(systems))
                    SLStudio.SetCoverageHighlightColors('set_screen_color',systems,screenColors)
                else
                    for i=1:length(systems)

                        try
                            set_param(systems(i),'ScreenColor',screenColors{i});
                        catch Mex %#ok<NASGU>
                        end
                    end
                end

                set_param(modelH,'covColorData',[]);


                if~isDirty
                    set_param(modelH,'dirty','off');
                end

                function apply_style(styleSession,covResults)
                    if isa(styleSession,'SlCov.CovStyle.Session')
                        append=true;
                        styleSession.applyHighlighting(covResults,append);
                    end



