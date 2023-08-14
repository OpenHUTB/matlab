function modeHelper(modename,object,arg)

    if isempty(object)
        object=gcf;
    end
    validArgs={'on','off','toggle','noaction'};
    lowerArg=lower(arg);
    if(~ismember(lowerArg,validArgs))
        error(message('MATLAB:pan:unrecognizedinput'));
    end
    if matlab.graphics.interaction.internal.isWebAxes(object)
        matlab.graphics.interaction.webmodes.toggleMode(object,modename,lowerArg);
    elseif matlab.ui.internal.isUIFigure(object)
        ax=findall(object,'Type','axes');
        for i=1:numel(ax)
            matlab.graphics.interaction.webmodes.toggleMode(ax(i),modename,lowerArg);
        end
    end