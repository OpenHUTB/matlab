function autoDataPackage(varargin)





    if nargin<1
        aMode='1';
    else
        block=varargin{1};
        aMode=get_param(block,'aMode');
    end
    switch aMode
    case '1'
        matlab.addons.supportpackage.internal.explorer.showSupportPackages('AUTODRIVECYCLE','tripwire');
    case '2'
        matlab.addons.supportpackage.internal.explorer.showSupportPackages('MANEUVER','tripwire');
    otherwise
        matlab.addons.supportpackage.internal.explorer.showSupportPackages('AUTODRIVECYCLE','tripwire');
    end