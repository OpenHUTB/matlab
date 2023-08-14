function hLineSeries=plotAsynchronousMachineTorqueVersusSpeed(varargin)





    import ee.internal.mask.getValue;

    switch nargin
    case 1
        blockName=varargin{1};
        usePu=false;
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



    componentPath=get_param(blockName,'ComponentPath');
    if~ee.internal.mask.isComponentAsynchronousMachine(componentPath)
        pm_error('physmod:ee:library:InputNotAsynchronousMachine',blockName);
    end

    baseValues=ee.internal.mask.getPerUnitMachineBase(blockName);
    b=baseValues.b;
    VRated=b.VRated;

    param_unit=getValue(blockName,'param_unit','1');
    saturation_option=getValue(blockName,'saturation_option','1');
    switch param_unit
    case int32(ee.enum.unit.pu)
        Rs=getValue(blockName,'pu_Rs','1').*b.R;
        Xls=getValue(blockName,'pu_Lls','1').*b.X;
        Rrd=getValue(blockName,'pu_Rrd','1').*b.R;
        Xlrd=getValue(blockName,'pu_Llrd','1').*b.X;
        if saturation_option==int32(ee.enum.saturation.exclude)
            Xm=getValue(blockName,'pu_Lm','1').*b.X;
        else

            pm_error('physmod:ee:library:IncorrectPlotOption',...
            getString(message('physmod:ee:library:comments:utils:mask:plotAsynchronousMachineTorqueVersusSpeed:error_MagneticSaturationRepresentation')),...
            getString(message('physmod:ee:library:comments:utils:mask:plotAsynchronousMachineTorqueVersusSpeed:error_OpencircuitLookupTableVversusI')),...
            getString(message('physmod:ee:library:comments:utils:mask:plotAsynchronousMachineTorqueVersusSpeed:error_None')));
        end
    case int32(ee.enum.unit.si)
        Rs=getValue(blockName,'Rs','Ohm');
        Xls=getValue(blockName,'Xls','Ohm');
        Rrd=getValue(blockName,'Rrd','Ohm');
        Xlrd=getValue(blockName,'Xlrd','Ohm');
        if saturation_option==int32(ee.enum.saturation.exclude)
            Xm=getValue(blockName,'Xm','Ohm');
        else

            pm_error('physmod:ee:library:IncorrectPlotOption',...
            getString(message('physmod:ee:library:comments:utils:mask:plotAsynchronousMachineTorqueVersusSpeed:error_MagneticSaturationRepresentation')),...
            getString(message('physmod:ee:library:comments:utils:mask:plotAsynchronousMachineTorqueVersusSpeed:error_OpencircuitLookupTableVversusI')),...
            getString(message('physmod:ee:library:comments:utils:mask:plotAsynchronousMachineTorqueVersusSpeed:error_None')));
        end
    otherwise

    end



    Xss=Xls+Xm;
    Xrrd=Xlrd+Xm;


    wElectrical=b.wElectrical;
    wMechanical_lower=0.8*b.wMechanical;
    wMechanical_upper=1.2*b.wMechanical;
    wMechanical_double=2*b.wMechanical;
    wMechanical=[0:10:wMechanical_lower,wMechanical_lower:1:wMechanical_upper,wMechanical_upper:10:wMechanical_double];
    slip=(wElectrical-wMechanical.*b.nPolePairs)./wElectrical;
    Te_delta=3*b.nPolePairs*(Xm^2/wElectrical)*Rrd*slip*VRated^2./...
    ((Rs*Rrd+slip*(Xm^2-Xss*Xrrd)).^2+(Rrd*Xss+slip*Rs*Xrrd).^2);
    Te_wye=Te_delta/3;


    if isempty(hAxes)
        hFigure=figure;
        hAxes=axes('Parent',hFigure);
    end
    if~usePu
        hLineSeries=plot(hAxes,wMechanical,Te_delta,wMechanical,Te_wye);
        xlabel(hAxes,getString(message('physmod:ee:library:comments:utils:mask:plotAsynchronousMachineTorqueVersusSpeed:label_MechanicalSpeedRads')));
        ylabel(hAxes,getString(message('physmod:ee:library:comments:utils:mask:plotAsynchronousMachineTorqueVersusSpeed:label_TorqueNm')));
        legend(getString(message('physmod:ee:library:comments:utils:mask:plotAsynchronousMachineTorqueVersusSpeed:legend_Delta')),getString(message('physmod:ee:library:comments:utils:mask:plotAsynchronousMachineTorqueVersusSpeed:legend_Wye')));
    else
        hLineSeries=plot(hAxes,wMechanical./b.wMechanical,Te_delta./b.torque,wMechanical./b.wMechanical,Te_wye./b.torque);
        xlabel(hAxes,getString(message('physmod:ee:library:comments:utils:mask:plotAsynchronousMachineTorqueVersusSpeed:label_MechanicalSpeedPu')));
        ylabel(hAxes,getString(message('physmod:ee:library:comments:utils:mask:plotAsynchronousMachineTorqueVersusSpeed:label_TorquePu')));
        legend(getString(message('physmod:ee:library:comments:utils:mask:plotAsynchronousMachineTorqueVersusSpeed:legend_Delta')),getString(message('physmod:ee:library:comments:utils:mask:plotAsynchronousMachineTorqueVersusSpeed:legend_Wye')));
    end
    grid(hAxes,'on');
    title(hAxes,blockName,'Interpreter','none');

end