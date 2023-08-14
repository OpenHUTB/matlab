function prepareFigureFor(fig,callerName)










    whiteList={'toolbox\matlab\embeddedoutputs','toolbox\matlab\connector2',...
    'toolbox\matlab\graph2d','toolbox\matlab\graph3d',...
    'toolbox\matlab\graphics','toolbox\matlab\plottools',...
    'toolbox\matlab\scribe','toolbox\matlab\uicomponents',...
    'toolbox\matlab\uitools','toolbox\symbolic\graphics',...
    'toolbox\shared\controllib','toolbox\matlab\toolstrip',...
    'toolbox\matlab\images','toolbox\matlab\specgraph',...
    'toolbox\matlab\datamanager'};

    if contains(callerName,whiteList)||contains(callerName,strrep(whiteList,'\','/'))


        if~isempty(fig)&&isvalid(fig)&&isa(fig,'matlab.ui.Figure')&&strcmp(fig.BeingDeleted,'off')
            triggerFigureView(fig);
        end
    end
end
