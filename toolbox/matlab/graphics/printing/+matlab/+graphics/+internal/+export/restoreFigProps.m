function pj=restoreFigProps(pj,parentFig)




    if isstruct(pj.temp.oldProps)
        restoreProperties=fieldnames(pj.temp.oldProps);



        keyProperties={'ResizeFcn','Units','Position'};
        for i=1:length(keyProperties)
            prop=keyProperties{i};
            if isfield(pj.temp.oldProps,prop)
                set(parentFig,prop,pj.temp.oldProps.(prop));
            end
        end

        remainingProperties=setdiff(restoreProperties,keyProperties);
        for i=1:length(remainingProperties)
            prop=remainingProperties{i};
            set(parentFig,prop,pj.temp.oldProps.(prop));
        end
    end

    if isfield(pj.temp,'CurrentFigure')&&...
        (isempty(pj.temp.CurrentFigure)||ishghandle(pj.temp.CurrentFigure,'figure'))
        set(groot,'CurrentFigure',pj.temp.CurrentFigure);
    end
end
