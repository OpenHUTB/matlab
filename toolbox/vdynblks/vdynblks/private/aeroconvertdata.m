% 单位数据的转换
function Convert=aeroconvertdata(mtype,varargin)

    usys='hybrid';
    if~isempty(varargin)&&length(varargin)==2
        usys=checkUnitSys(mtype,varargin{1},varargin{2});
    end

    switch lower(mtype)
    case 'units'
        switch varargin{1}
        case 'Metric (MKS)'
            Convert.mDotU='kg/s';
            Convert.mU='kg';
            Convert.velU='m/s';
            Convert.iU='kg*m^2';
            Convert.iDotU='kg*m^2/s';
            Convert.accelU='m/s^2';
            Convert.fU='N';
            Convert.lU='m';
            Convert.tU='N*m';
            Convert.mag='nT';
            Convert.u=true;
        case{'English (Velocity in ft/s)','English'}
            Convert.mDotU='slug/s';
            Convert.mU='slug';
            Convert.velU='ft/s';
            Convert.iU='slug*ft^2';
            Convert.iDotU='slug*ft^2/s';
            Convert.accelU='ft/s^2';
            Convert.fU='lb';
            Convert.lU='ft';
            Convert.tU='lb*ft';
            Convert.mag='nG';
            Convert.u=true;
        case 'English (Velocity in kts)'
            Convert.mDotU='slug/s';
            Convert.mU='slug';
            Convert.velU='knot';
            Convert.iU='slug*ft^2';
            Convert.iDotU='slug*ft^2/s';
            Convert.accelU='ft/s^2';
            Convert.fU='lb';
            Convert.lU='ft';
            Convert.tU='lb*ft';
            Convert.mag='nG';
            Convert.u=true;
        otherwise
            Convert.u=true;
        end
    case 'temperature conversion'

        Convert.type=mtype;
        Convert.tdata(1).unit='K';
        Convert.tdata(1).slope=1.0;
        Convert.tdata(1).bias=-273.15;
        Convert.tdata(2).unit='F';
        Convert.tdata(2).slope=5.0/9.0;
        Convert.tdata(2).bias=-32.0*Convert.tdata(2).slope;
        Convert.tdata(3).unit='C';
        Convert.tdata(3).slope=1.0;
        Convert.tdata(3).bias=0.0;
        Convert.tdata(4).unit='R';
        Convert.tdata(4).slope=5.0/9.0;
        Convert.tdata(4).bias=-273.15;
        Convert.units={'K','F','C','R'};




    case 'angle conversion'
        Convert.units={'deg','rad','rev'};
        Convert.type=mtype;
        Convert.tdata(1).unit='deg';
        Convert.tdata(1).slope=pi/180.0;
        Convert.tdata(2).unit='rad';
        Convert.tdata(2).slope=1.0;
        Convert.tdata(3).unit='rev';
        Convert.tdata(3).slope=2*pi;

    case 'length conversion'
        Convert.units={'ft','m','km','in','mi','naut mi'};
        switch usys
        case 'english'
            Convert.type=mtype;
            Convert.tdata(1).unit='ft';
            Convert.tdata(1).slope=1;
            Convert.tdata(2).unit='in';
            Convert.tdata(2).slope=1/12;
            Convert.tdata(3).unit='mi';
            Convert.tdata(3).slope=5280;
        case 'mks'
            Convert.type=mtype;
            Convert.tdata(1).unit='m';
            Convert.tdata(1).slope=1;
            Convert.tdata(2).unit='km';
            Convert.tdata(2).slope=1000;
            Convert.tdata(3).unit='naut mi';
            Convert.tdata(3).slope=1852;
        case 'hybrid'
            Convert.type=mtype;
            Convert.tdata(1).unit='ft';
            Convert.tdata(1).slope=0.3048;
            Convert.tdata(2).unit='m';
            Convert.tdata(2).slope=1.0;
            Convert.tdata(3).unit='km';
            Convert.tdata(3).slope=1000.0;
            Convert.tdata(4).unit='in';
            Convert.tdata(4).slope=0.0254;
            Convert.tdata(5).unit='mi';
            Convert.tdata(5).slope=1609.344;
            Convert.tdata(6).unit='naut mi';
            Convert.tdata(6).slope=1852.0;
        end
    case 'angular velocity conversion'
        Convert.units={'deg/s','rad/s','rpm'};
        Convert.type=mtype;
        Convert.tdata(1).unit='deg/s';
        Convert.tdata(1).slope=pi/180.0;
        Convert.tdata(2).unit='rad/s';
        Convert.tdata(2).slope=1.0;
        Convert.tdata(3).unit='rpm';
        Convert.tdata(3).slope=pi/30;

    case 'velocity conversion'
        Convert.units={'ft/s','m/s','km/s','in/s','km/h','mph','kts','ft/min'};
        switch usys
        case 'english'
            Convert.type=mtype;
            Convert.tdata(1).unit='ft/s';
            Convert.tdata(1).slope=1;
            Convert.tdata(2).unit='in/s';
            Convert.tdata(2).slope=1/12;
            Convert.tdata(3).unit='ft/min';
            Convert.tdata(3).slope=1/60;
            Convert.tdata(4).unit='mph';
            Convert.tdata(4).slope=528/360;
        case 'mks'
            Convert.type=mtype;
            Convert.tdata(1).unit='m/s';
            Convert.tdata(1).slope=1;
            Convert.tdata(2).unit='km/s';
            Convert.tdata(2).slope=1000;
            Convert.tdata(3).unit='km/h';
            Convert.tdata(3).slope=5/18;
            Convert.tdata(4).unit='kts';
            Convert.tdata(4).slope=1852/3600;
        case 'hybrid'
            Convert.type=mtype;
            Convert.tdata(1).unit='ft/s';
            Convert.tdata(1).slope=0.3048;
            Convert.tdata(2).unit='m/s';
            Convert.tdata(2).slope=1.0;
            Convert.tdata(3).unit='km/s';
            Convert.tdata(3).slope=1000.0;
            Convert.tdata(4).unit='in/s';
            Convert.tdata(4).slope=0.0254;
            Convert.tdata(5).unit='km/h';
            Convert.tdata(5).slope=5/18;
            Convert.tdata(6).unit='mph';
            Convert.tdata(6).slope=(528/360)*.3048;
            Convert.tdata(7).unit='kts';
            Convert.tdata(7).slope=1852/3600;
            Convert.tdata(8).unit='ft/min';
            Convert.tdata(8).slope=0.3048/60;
        end
    case 'angular acceleration conversion'
        Convert.units={'deg/s^2','rad/s^2','rpm/s'};
        Convert.type=mtype;
        Convert.tdata(1).unit='deg/s^2';
        Convert.tdata(1).slope=pi/180.0;
        Convert.tdata(2).unit='rad/s^2';
        Convert.tdata(2).slope=1.0;
        Convert.tdata(3).unit='rpm/s';
        Convert.tdata(3).slope=pi/30;

    case 'acceleration conversion'
        Convert.units={'ft/s^2','m/s^2','km/s^2','in/s^2','km/h-s','mph/s','G''s'};
        switch usys
        case 'english'
            Convert.type=mtype;
            Convert.tdata(1).unit='ft/s^2';
            Convert.tdata(1).slope=1;
            Convert.tdata(2).unit='in/s^2';
            Convert.tdata(2).slope=1/12;
            Convert.tdata(3).unit='mph/s';
            Convert.tdata(3).slope=528/360;
        case 'mks'
            Convert.type=mtype;
            Convert.tdata(1).unit='m/s^2';
            Convert.tdata(1).slope=1;
            Convert.tdata(2).unit='km/s^2';
            Convert.tdata(2).slope=1000;
            Convert.tdata(3).unit='km/h-s';
            Convert.tdata(3).slope=5/18;
            Convert.tdata(4).unit='G''s';
            Convert.tdata(4).slope=9.80665;
        case 'hybrid'
            Convert.type=mtype;
            Convert.tdata(1).unit='ft/s^2';
            Convert.tdata(1).slope=0.3048;
            Convert.tdata(2).unit='m/s^2';
            Convert.tdata(2).slope=1.0;
            Convert.tdata(3).unit='km/s^2';
            Convert.tdata(3).slope=1000.0;
            Convert.tdata(4).unit='in/s^2';
            Convert.tdata(4).slope=0.0254;
            Convert.tdata(5).unit='km/h-s';
            Convert.tdata(5).slope=5/18;
            Convert.tdata(6).unit='mph/s';
            Convert.tdata(6).slope=(528/360)*.3048;
            Convert.tdata(7).unit='G''s';
            Convert.tdata(7).slope=9.80665;
        end
    case 'mass conversion'
        Convert.units={'lbm','kg','slug'};
        Convert.type=mtype;
        Convert.tdata(1).unit='lbm';
        Convert.tdata(1).slope=0.45359237;
        Convert.tdata(2).unit='kg';
        Convert.tdata(2).slope=1.0;
        Convert.tdata(3).unit='slug';
        Convert.tdata(3).slope=9.80665*.45359237/0.3048;

    case 'force conversion'
        Convert.units={'lbf','N'};
        Convert.type=mtype;
        Convert.tdata(1).unit='lbf';
        Convert.tdata(1).slope=0.45359237*9.80665;
        Convert.tdata(2).unit='N';
        Convert.tdata(2).slope=1.0;

    case 'pressure conversion'
        Convert.units={'psi','Pa','psf','atm'};
        Convert.type=mtype;
        Convert.tdata(1).unit='psi';
        Convert.tdata(1).slope=0.45359237*9.80665/(0.0254)^2;
        Convert.tdata(2).unit='Pa';
        Convert.tdata(2).slope=1.0;
        Convert.tdata(3).unit='psf';
        Convert.tdata(3).slope=.45359237*9.80665/(0.3048)^2;
        Convert.tdata(4).unit='atm';
        Convert.tdata(4).slope=101325.0;

    case 'density conversion'
        Convert.units={'lbm/ft^3','kg/m^3','slug/ft^3','lbm/in^3'};
        switch usys
        case 'english'
            Convert.type=mtype;
            Convert.tdata(1).unit='slug/ft^3';
            Convert.tdata(1).slope=9.80665/.3048;
            Convert.tdata(2).unit='lbm/ft^3';
            Convert.tdata(2).slope=1;
            Convert.tdata(3).unit='lbm/in^3';
            Convert.tdata(3).slope=12^3;
        case 'mks'
            Convert.type=mtype;
            Convert.tdata(1).unit='kg/m^3';
            Convert.tdata(1).slope=1.0;
        case 'hybrid'
            Convert.type=mtype;
            Convert.tdata(1).unit='lbm/ft^3';
            Convert.tdata(1).slope=0.45359237/(.3048)^3;
            Convert.tdata(2).unit='kg/m^3';
            Convert.tdata(2).slope=1.0;
            Convert.tdata(3).unit='slug/ft^3';
            Convert.tdata(3).slope=0.45359237*(9.80665/.3048)/(.3048)^3;
            Convert.tdata(4).unit='lbm/in^3';
            Convert.tdata(4).slope=0.45359237/(.0254)^3;
        end
    otherwise

        error(message('aero:aeroconvertdata:unknownUnit',mtype));
    end
    function usys=checkUnitSys(mtype,iunit,ounit)





        englishUnits={};
        mksUnits={};
        mtype=lower(mtype);
        switch mtype
        case 'length conversion'
            englishUnits={'in','ft','mi'};
            mksUnits={'m','km','naut mi'};
        case 'velocity conversion'
            englishUnits={'in/s','ft/s','ft/min','mph'};
            mksUnits={'m/s','km/s','km/h','kts'};
        case 'acceleration conversion'
            englishUnits={'in/s^2','ft/s^2','mph/s'};
            mksUnits={'m/s^2','km/s^2','km/h-s','G''s'};
        case 'density conversion'
            englishUnits={'lbm/ft^3','slug/ft^3','lbm/in^3'};
            mksUnits={'kg/m^3'};
        end

        usys='hybrid';
        if(any(strcmpi(englishUnits,ounit))&&any(strcmpi(englishUnits,iunit)))
            usys='english';
        elseif(any(strcmpi(mksUnits,ounit))&&any(strcmpi(mksUnits,iunit)))
            usys='mks';
        end
