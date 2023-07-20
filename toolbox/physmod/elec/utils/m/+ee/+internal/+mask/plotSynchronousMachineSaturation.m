function hLineSeries=plotSynchronousMachineSaturation(varargin)




    switch nargin
    case 1
        blockName=varargin{1};
        usePu=true;
        hAxes=[];
    case 2
        blockName=varargin{1};
        usePu=varargin{2};
        hAxes=[];
    case 3
        blockName=varargin{1};
        usePu=varargin{2};
        hAxes=varargin{3};
    otherwise
        pm_error('physmod:ee:library:IncorrectNumberOfInputs','1','3');
    end

    if ishandle(blockName)
        name=get_param(blockName,'Name');
        parent=get_param(blockName,'Parent');
        blockName=[parent,'/',name];
    end

    if~usePu
        pm_error('physmod:ee:library:SiUnavailable');
    end

    f=ee.internal.mask.getSynchronousMachineParametersFundamental(blockName);

    switch f.saturation_option
    case 0
        pm_error('physmod:ee:library:IncorrectPlotOption',...
        getString(message('physmod:ee:library:comments:utils:mask:plotAsynchronousMachineSaturation:error_MagneticSaturationRepresentation')),...
        getString(message('physmod:ee:library:comments:utils:mask:plotAsynchronousMachineSaturation:error_None')),...
        getString(message('physmod:ee:library:comments:utils:mask:plotAsynchronousMachineSaturation:error_OpencircuitLookupTablevVersusI')));
    case 1

        if isempty(hAxes)
            hFigure=figure;
            hAxes=axes('Parent',hFigure);
        end


        unsaturated_ifd=[min(f.saturation.original.ifd),max(f.saturation.original.Vag)./f.saturation.original.L_unsaturated];
        unsaturated_Vag=unsaturated_ifd.*f.saturation.original.L_unsaturated;

        hLineSeries=plot(hAxes,...
        unsaturated_ifd,unsaturated_Vag,...
        f.saturation.original.ifd,f.saturation.original.Vag,'-o',...
        f.saturation.derived.ifd,f.saturation.derived.Vag,'-x');
        xlabel(hAxes,'i_{fd}, pu');
        ylabel(hAxes,getString(message('physmod:ee:library:comments:utils:mask:plotSynchronousMachineSaturation:label_AirgapVoltagePu')));
        legend(getString(message('physmod:ee:library:comments:utils:mask:plotSynchronousMachineSaturation:legend_Unsaturated')),...
        getString(message('physmod:ee:library:comments:utils:mask:plotSynchronousMachineSaturation:legend_Saturated')),...
        getString(message('physmod:ee:library:comments:utils:mask:plotSynchronousMachineSaturation:legend_Derived')),...
        'Location','SouthEast');
        grid(hAxes,'on');
        title(hAxes,blockName,'Interpreter','none');
        xlim([0,f.saturation.original.ifd(end)]);
        ylim([0,f.saturation.original.Vag(end)]);
    otherwise
        pm_error('physmod:ee:library:IntegerOption',getString(message('physmod:ee:library:comments:utils:mask:plotSynchronousMachineSaturation:error_MagneticSaturationRepresentation')),'0','1');
    end

end
