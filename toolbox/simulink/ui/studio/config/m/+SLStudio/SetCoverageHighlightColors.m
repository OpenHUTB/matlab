function SetCoverageHighlightColors(method,varargin)

    switch(lower(method))
    case 'set_backgroundforeground_color'
        applyBackgroundForegroundHighlighting(varargin{:});
    case 'set_screen_color'
        applyScreenHighlighting(varargin{:});
    otherwise,
        error(message('Simulink:studio:unknownMethod'));
    end
end

function applyBackgroundForegroundHighlighting(blockH,bgColor,fgColor)

    if nargin<3
        error(message('Simulink:studio:insufficientInputs'));
    end
    uniqueColor=length(bgColor)==length(blockH);
    if uniqueColor&&...
        ~isempty(fgColor)&&length(fgColor)<length(bgColor)
        error(message('Simulink:studio:bgColorLongerThanFg'));
    end


    model=[];
    transactionStarted=false;

    for i=1:length(blockH)

        try

            diagElement=SLM3I.SLDomain.handle2DiagramElement(blockH(i));
            if~isempty(diagElement)
                model=diagElement.diagram.model;
                model.beginTransaction;
                transactionStarted=true;
            end
            if uniqueColor
                set_param(blockH(i),'BackgroundColor',bgColor{i});
                if~isempty(fgColor{i})
                    set_param(blockH(i),'ForegroundColor',fgColor{i});
                end
            else
                set_param(blockH(i),'BackgroundColor',bgColor{1});
                if~isempty(fgColor)
                    set_param(blockH(i),'ForegroundColor',fgColor{1});
                end
            end

            if transactionStarted
                model.commitTransaction;
                transactionStarted=false;
            end
        catch Mex %#ok<NASGU>
            if transactionStarted
                model.commitTransaction;
                transactionStarted=false;
            end
        end
    end
end

function applyScreenHighlighting(systemH,screenColor)

    if nargin<2
        error(message('Simulink:studio:insufficientInputs'));
    end
    model=[];
    transactionStarted=false;

    uniqueColor=length(screenColor)==length(systemH);

    for i=1:length(systemH)

        try
            diagram=[];

            if strcmpi(get_param(systemH(i),'Type'),'block_diagram')
                diagram=SLM3I.SLDomain.handle2Diagram(systemH(i));
            else
                diagElement=SLM3I.SLDomain.handle2DiagramElement(systemH(i));
                if~isempty(diagElement)
                    diagram=diagElement.diagram;
                end
            end
            if~isempty(diagram)
                model=diagram.model;
                model.beginTransaction;
                transactionStarted=true;
            end
            if uniqueColor
                set_param(systemH(i),'ScreenColor',screenColor{i});
            else
                set_param(systemH(i),'ScreenColor',screenColor{1});
            end

            if transactionStarted
                model.commitTransaction;
                transactionStarted=false;
            end
        catch Mex %#ok<NASGU>
            if transactionStarted
                model.commitTransaction;
                transactionStarted=false;
            end
        end

    end
end
