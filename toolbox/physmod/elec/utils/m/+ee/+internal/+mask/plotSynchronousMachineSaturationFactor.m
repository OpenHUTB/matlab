function hLineSeries=plotSynchronousMachineSaturationFactor(varargin)




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

    switch ee.internal.mask.getValue(blockName,'saturation_option','1')
    case int32(ee.enum.saturation.exclude)

        pm_error('physmod:ee:library:IncorrectPlotOption',...
        getString(message('physmod:ee:library:comments:utils:mask:plotAsynchronousMachineSaturation:error_MagneticSaturationRepresentation')),...
        getString(message('physmod:ee:library:comments:utils:mask:plotAsynchronousMachineSaturation:error_None')),...
        getString(message('physmod:ee:library:comments:utils:mask:plotAsynchronousMachineSaturation:error_OpencircuitLookupTablevVersusI')));
    case int32(ee.enum.saturation.include)

        if isempty(hAxes)
            hFigure=figure;
            hAxes=axes('Parent',hFigure);
        end
        hLineSeries=plot(hAxes,f.saturation.psi,f.saturation.K_s,'-o');
        xlabel(hAxes,getString(message('physmod:ee:library:comments:utils:mask:plotSynchronousMachineSaturationFactor:label_MagneticFluxLinkagepsi_atPu')));
        ylabel(hAxes,getString(message('physmod:ee:library:comments:utils:mask:plotSynchronousMachineSaturationFactor:label_SaturationFactorAppliedToMutualInductances')));
        grid(hAxes,'on');
        title(hAxes,blockName,'Interpreter','none');
    otherwise
        pm_error('physmod:ee:library:IntegerOption',getString(message('physmod:ee:library:comments:utils:mask:plotSynchronousMachineSaturationFactor:error_MagneticSaturationRepresentation')),'0','1');
    end

end