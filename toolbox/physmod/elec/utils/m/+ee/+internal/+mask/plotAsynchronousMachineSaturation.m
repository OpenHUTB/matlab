function hLineSeries=plotAsynchronousMachineSaturation(varargin)




    import ee.internal.mask.getValue;

    switch nargin
    case 1
        blockName=varargin{1};
        hAxes=[];
    case 2
        blockName=varargin{1};
        hAxes=varargin{2};
    otherwise
        pm_error('physmod:ee:library:IncorrectNumberOfInputs','1','2');
    end

    if ishandle(blockName)
        name=get_param(blockName,'Name');
        parent=get_param(blockName,'Parent');
        blockName=[parent,'/',name];
    end

    baseValues=ee.internal.mask.getPerUnitMachineBase(blockName);
    b=baseValues.b;
    saturation_option=ee.internal.mask.getValue(blockName,'saturation_option','1');


    if saturation_option==int32(ee.enum.saturation.exclude)

        pm_error('physmod:ee:library:IncorrectPlotOption',...
        getString(message('physmod:ee:library:comments:utils:mask:plotAsynchronousMachineSaturation:error_MagneticSaturationRepresentation')),...
        getString(message('physmod:ee:library:comments:utils:mask:plotAsynchronousMachineSaturation:error_None')),...
        getString(message('physmod:ee:library:comments:utils:mask:plotAsynchronousMachineSaturation:error_OpencircuitLookupTablevVersusI')));
    elseif saturation_option~=int32(ee.enum.saturation.include)
        pm_error('physmod:ee:library:IntegerOption',...
        getString(message('physmod:ee:library:comments:utils:mask:plotAsynchronousMachineSaturationFactor:error_MagneticSaturationRepresentation')),'0','1');
    end

    param_unit=get_param(blockName,'param_unit');
    connection_option=get_param(blockName,'connection_option');
    switch param_unit
    case 'ee.enum.unit.pu'

        saturation_i=getValue(blockName,'pu_saturation_i','1');
        saturation_v=getValue(blockName,'pu_saturation_v','1');
        Lls=getValue(blockName,'pu_Lls','1');
        f=ee.internal.machines.convertAsynchronousSaturation(saturation_i,saturation_v,Lls,ee.enum.unit.pu,connection_option);
        Lm=f.original.L_unsaturated;


        if isempty(hAxes)
            hFigure=figure;
            hAxes=axes('Parent',hFigure);
        end


        unsaturated_i=[min(f.original.i),max(f.original.v)./(Lm+Lls)];
        unsaturated_v=unsaturated_i.*(Lm+Lls);

        hLineSeries=plot(hAxes,...
        unsaturated_i,unsaturated_v,...
        f.original.i,f.original.v,'-o',...
        f.derived.i,f.derived.v,'-x');
        xlabel(hAxes,getString(message('physmod:ee:library:comments:utils:mask:plotAsynchronousMachineSaturation:label_NoloadStatorCurrentPu')));
        ylabel(hAxes,getString(message('physmod:ee:library:comments:utils:mask:plotAsynchronousMachineSaturation:label_TerminalVoltagePu')));
        legend(getString(message('physmod:ee:library:comments:utils:mask:plotAsynchronousMachineSaturation:legend_Unsaturated')),...
        getString(message('physmod:ee:library:comments:utils:mask:plotAsynchronousMachineSaturation:legend_Saturated')),...
        getString(message('physmod:ee:library:comments:utils:mask:plotAsynchronousMachineSaturation:legend_Derived')),...
        'Location','SouthEast');
        grid(hAxes,'on');
        title(hAxes,blockName,'Interpreter','none');
        xlim([0,f.original.i(end)]);
        ylim([0,f.original.v(end)]);


    case 'ee.enum.unit.si'
        saturation_i=getValue(blockName,'saturation_i','A');
        saturation_v=getValue(blockName,'saturation_v','V');
        Xls=getValue(blockName,'Xls','Ohm');
        Lls=Xls/b.X;
        saturation_i_pu=saturation_i./b.I;
        saturation_v_pu=saturation_v./b.V;
        f=ee.internal.machines.convertAsynchronousSaturation(saturation_i_pu,saturation_v_pu,Lls,ee.enum.unit.si,connection_option);
        Lm=f.original.L_unsaturated;


        if isempty(hAxes)
            hFigure=figure;
            hAxes=axes('Parent',hFigure);
        end


        unsaturated_i=[min(f.original.i),max(f.original.v)./(Lm+Lls)];
        unsaturated_v=unsaturated_i.*(Lm+Lls);

        hLineSeries=plot(hAxes,...
        unsaturated_i*b.I,unsaturated_v*b.V,...
        f.original.i*b.I,f.original.v*b.V,'-o',...
        f.derived.i*b.I,f.derived.v*b.V,'-x');
        xlabel(hAxes,getString(message('physmod:ee:library:comments:utils:mask:plotAsynchronousMachineSaturation:label_NoloadStatorCurrentA')));
        ylabel(hAxes,getString(message('physmod:ee:library:comments:utils:mask:plotAsynchronousMachineSaturation:label_TerminalVoltageV')));
        legend(getString(message('physmod:ee:library:comments:utils:mask:plotAsynchronousMachineSaturation:legend_Unsaturated')),...
        getString(message('physmod:ee:library:comments:utils:mask:plotAsynchronousMachineSaturation:legend_Saturated')),...
        getString(message('physmod:ee:library:comments:utils:mask:plotAsynchronousMachineSaturation:legend_Derived')),...
        'Location','SouthEast');
        grid(hAxes,'on');
        title(hAxes,blockName,'Interpreter','none');
        xlim([0,f.original.i(end)*b.I]);
        ylim([0,f.original.v(end)*b.V]);

    otherwise

    end

end
