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
        Convert.units={'K','F','C','R'};
        tdata(1).unit='K';
        tdata(1).slope=1.0;
        tdata(1).bias=-273.15;
        tdata(2).unit='F';
        tdata(2).slope=5.0/9.0;
        tdata(2).bias=-32.0*tdata(2).slope;
        tdata(3).unit='C';
        tdata(3).slope=1.0;
        tdata(3).bias=0.0;
        tdata(4).unit='R';
        tdata(4).slope=5.0/9.0;
        tdata(4).bias=-273.15;
        Convert.tdata=tdata;




    case 'angle conversion'
        Convert.units={'deg','rad','rev'};
        Convert.type=mtype;
        tdata(1).unit='deg';
        tdata(1).slope=pi/180.0;
        tdata(2).unit='rad';
        tdata(2).slope=1.0;
        tdata(3).unit='rev';
        tdata(3).slope=2*pi;
        Convert.tdata=tdata;

    case 'length conversion'
        Convert.units={'ft','m','km','in','mi','naut mi'};
        switch usys
        case 'english'
            Convert.type=mtype;
            tdata(1).unit='ft';
            tdata(1).slope=1;
            tdata(2).unit='in';
            tdata(2).slope=1/12;
            tdata(3).unit='mi';
            tdata(3).slope=5280;
        case 'mks'
            Convert.type=mtype;
            tdata(1).unit='m';
            tdata(1).slope=1;
            tdata(2).unit='km';
            tdata(2).slope=1000;
            tdata(3).unit='naut mi';
            tdata(3).slope=1852;
        case 'hybrid'
            Convert.type=mtype;
            tdata(1).unit='ft';
            tdata(1).slope=0.3048;
            tdata(2).unit='m';
            tdata(2).slope=1.0;
            tdata(3).unit='km';
            tdata(3).slope=1000.0;
            tdata(4).unit='in';
            tdata(4).slope=0.0254;
            tdata(5).unit='mi';
            tdata(5).slope=1609.344;
            tdata(6).unit='naut mi';
            tdata(6).slope=1852.0;
        end
        Convert.tdata=tdata;

    case 'angular velocity conversion'
        Convert.units={'deg/s','rad/s','rpm'};
        Convert.type=mtype;
        tdata(1).unit='deg/s';
        tdata(1).slope=pi/180.0;
        tdata(2).unit='rad/s';
        tdata(2).slope=1.0;
        tdata(3).unit='rpm';
        tdata(3).slope=pi/30;
        Convert.tdata=tdata;

    case 'velocity conversion'
        Convert.units={'ft/s','m/s','km/s','in/s','km/h','mph','kts','ft/min'};
        switch usys
        case 'english'
            Convert.type=mtype;
            tdata(1).unit='ft/s';
            tdata(1).slope=1;
            tdata(2).unit='in/s';
            tdata(2).slope=1/12;
            tdata(3).unit='ft/min';
            tdata(3).slope=1/60;
            tdata(4).unit='mph';
            tdata(4).slope=528/360;
        case 'mks'
            Convert.type=mtype;
            tdata(1).unit='m/s';
            tdata(1).slope=1;
            tdata(2).unit='km/s';
            tdata(2).slope=1000;
            tdata(3).unit='km/h';
            tdata(3).slope=5/18;
            tdata(4).unit='kts';
            tdata(4).slope=1852/3600;
        case 'hybrid'
            Convert.type=mtype;
            tdata(1).unit='ft/s';
            tdata(1).slope=0.3048;
            tdata(2).unit='m/s';
            tdata(2).slope=1.0;
            tdata(3).unit='km/s';
            tdata(3).slope=1000.0;
            tdata(4).unit='in/s';
            tdata(4).slope=0.0254;
            tdata(5).unit='km/h';
            tdata(5).slope=5/18;
            tdata(6).unit='mph';
            tdata(6).slope=(528/360)*.3048;
            tdata(7).unit='kts';
            tdata(7).slope=1852/3600;
            tdata(8).unit='ft/min';
            tdata(8).slope=0.3048/60;
        end
        Convert.tdata=tdata;

    case 'angular acceleration conversion'
        Convert.units={'deg/s^2','rad/s^2','rpm/s'};
        Convert.type=mtype;
        tdata(1).unit='deg/s^2';
        tdata(1).slope=pi/180.0;
        tdata(2).unit='rad/s^2';
        tdata(2).slope=1.0;
        tdata(3).unit='rpm/s';
        tdata(3).slope=pi/30;
        Convert.tdata=tdata;

    case 'acceleration conversion'
        Convert.units={'ft/s^2','m/s^2','km/s^2','in/s^2','km/h-s','mph/s','G''s'};
        switch usys
        case 'english'
            Convert.type=mtype;
            tdata(1).unit='ft/s^2';
            tdata(1).slope=1;
            tdata(2).unit='in/s^2';
            tdata(2).slope=1/12;
            tdata(3).unit='mph/s';
            tdata(3).slope=528/360;
        case 'mks'
            Convert.type=mtype;
            tdata(1).unit='m/s^2';
            tdata(1).slope=1;
            tdata(2).unit='km/s^2';
            tdata(2).slope=1000;
            tdata(3).unit='km/h-s';
            tdata(3).slope=5/18;
            tdata(4).unit='G''s';
            tdata(4).slope=9.80665;
        case 'hybrid'
            Convert.type=mtype;
            tdata(1).unit='ft/s^2';
            tdata(1).slope=0.3048;
            tdata(2).unit='m/s^2';
            tdata(2).slope=1.0;
            tdata(3).unit='km/s^2';
            tdata(3).slope=1000.0;
            tdata(4).unit='in/s^2';
            tdata(4).slope=0.0254;
            tdata(5).unit='km/h-s';
            tdata(5).slope=5/18;
            tdata(6).unit='mph/s';
            tdata(6).slope=(528/360)*.3048;
            tdata(7).unit='G''s';
            tdata(7).slope=9.80665;
        end
        Convert.tdata=tdata;

    case 'mass conversion'
        Convert.units={'lbm','kg','slug'};
        Convert.type=mtype;
        tdata(1).unit='lbm';
        tdata(1).slope=0.45359237;
        tdata(2).unit='kg';
        tdata(2).slope=1.0;
        tdata(3).unit='slug';
        tdata(3).slope=9.80665*.45359237/0.3048;
        Convert.tdata=tdata;

    case 'force conversion'
        Convert.units={'lbf','N'};
        Convert.type=mtype;
        tdata(1).unit='lbf';
        tdata(1).slope=0.45359237*9.80665;
        tdata(2).unit='N';
        tdata(2).slope=1.0;
        Convert.tdata=tdata;

    case 'pressure conversion'
        Convert.units={'psi','Pa','psf','atm'};
        Convert.type=mtype;
        tdata(1).unit='psi';
        tdata(1).slope=0.45359237*9.80665/(0.0254)^2;
        tdata(2).unit='Pa';
        tdata(2).slope=1.0;
        tdata(3).unit='psf';
        tdata(3).slope=.45359237*9.80665/(0.3048)^2;
        tdata(4).unit='atm';
        tdata(4).slope=101325.0;
        Convert.tdata=tdata;

    case 'density conversion'
        Convert.units={'lbm/ft^3','kg/m^3','slug/ft^3','lbm/in^3'};
        switch usys
        case 'english'
            Convert.type=mtype;
            tdata(1).unit='slug/ft^3';
            tdata(1).slope=9.80665/.3048;
            tdata(2).unit='lbm/ft^3';
            tdata(2).slope=1;
            tdata(3).unit='lbm/in^3';
            tdata(3).slope=12^3;
        case 'mks'
            Convert.type=mtype;
            tdata(1).unit='kg/m^3';
            tdata(1).slope=1.0;
        case 'hybrid'
            Convert.type=mtype;
            tdata(1).unit='lbm/ft^3';
            tdata(1).slope=0.45359237/(.3048)^3;
            tdata(2).unit='kg/m^3';
            tdata(2).slope=1.0;
            tdata(3).unit='slug/ft^3';
            tdata(3).slope=0.45359237*(9.80665/.3048)/(.3048)^3;
            tdata(4).unit='lbm/in^3';
            tdata(4).slope=0.45359237/(.0254)^3;
        end
        Convert.tdata=tdata;

    otherwise
        error(message('aero:aeroconvertdata:unknownUnit',mtype));
    end
    function usys=checkUnitSys(mtype,iunit,ounit)





        englishUnits={};
        mksUnits={};

        switch lower(mtype)
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