function hLineSeries=plotAsynchronousMachineSaturationFactor(varargin)




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
        getString(message('physmod:ee:library:comments:utils:mask:plotAsynchronousMachineSaturationFactor:error_MagneticSaturationRepresentation')),...
        getString(message('physmod:ee:library:comments:utils:mask:plotAsynchronousMachineSaturationFactor:error_None')),...
        getString(message('physmod:ee:library:comments:utils:mask:plotAsynchronousMachineSaturationFactor:error_OpencircuitLookupTablevVersusI')));
    elseif~(saturation_option==int32(ee.enum.saturation.include))
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


        if isempty(hAxes)
            hFigure=figure;
            hAxes=axes('Parent',hFigure);
        end
        hLineSeries=plot(hAxes,f.psi,f.K_s,'-o');
        xlabel(hAxes,getString(message('physmod:ee:library:comments:utils:mask:plotAsynchronousMachineSaturationFactor:label_MagneticFluxLinkagepsi_mPu')));
        ylabel(hAxes,getString(message('physmod:ee:library:comments:utils:mask:plotAsynchronousMachineSaturationFactor:label_SaturationFactorAppliedToMagneticInductance')));
        grid(hAxes,'on');
        title(hAxes,[blockName,', Lm_unsat = ',num2str(f.L_m(1))],'Interpreter','none');

    case 'ee.enum.unit.si'
        saturation_i_pu=getValue(blockName,'saturation_i','A');
        saturation_v_pu=getValue(blockName,'saturation_v','V');
        Xls=getValue(blockName,'Xls','Ohm');
        Lls=Xls/b.X;
        saturation_i=saturation_i_pu./b.I;
        saturation_v=saturation_v_pu./b.V;
        f=ee.internal.machines.convertAsynchronousSaturation(saturation_i,saturation_v,Lls,ee.enum.unit.si,connection_option);


        if isempty(hAxes)
            hFigure=figure;
            hAxes=axes('Parent',hFigure);
        end
        hLineSeries=plot(hAxes,f.psi*b.psi,f.K_s,'-o');
        xlabel(hAxes,getString(message('physmod:ee:library:comments:utils:mask:plotAsynchronousMachineSaturationFactor:label_MagneticFluxLinkagepsi_mWb')));
        ylabel(hAxes,getString(message('physmod:ee:library:comments:utils:mask:plotAsynchronousMachineSaturationFactor:label_SaturationFactorAppliedToMagneticReactance')));
        grid(hAxes,'on');
        title(hAxes,[blockName,', Xm_unsat = ',num2str(f.L_m(1)*b.X),' Ohm'],'Interpreter','none');

    otherwise

    end

end