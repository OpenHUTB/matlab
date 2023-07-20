function [ varargout ] = autoicon( varargin )
%AUTOBLKSICON Gateway function to the private directory of Auto Blockset.

%   Copyright 2015-2018 The MathWorks, Inc.

% Check for the correct number of input arguments
if nargin<2
    error(message('autoblks:autoerrAutoIcon:invalidUsage'));
end

% Acquire the block and handle
action = varargin{1};
block  = varargin{2};

if nargin>=3
    context = varargin{3}; % where in the mask is autoicon being called from
end

% Initialize the output
varargout{1}=0;

% Take the correct block action
switch action
    case 'autolibboostshaft' % boost shaft (compressor only or turbocharger)
        varargout{1} = autoblksboostshaft(varargin{2:end});
    case 'autolibclutch' % clutch
        varargout{1} = autoblksclutch(block,context);
    case 'autolibclutchwet' % wet clutch
        varargout{1} = autoblksclutchwet(block,context);
    case 'autolibcompressor' % compressor
        varargout{1} = autoblkscompressor(varargin{2:end});
    case 'autolibdiffals' % active limited slip differential
        varargout{1} = autoblksdiffals(block,context);
    case 'autolibdrivecycle' % drive cycle source
        [varargout{1},varargout{2}] = autoblksdrivecycle(block,context);
    case 'autolibfundflwcv'% flow blocks (control volume)
        varargout{1} = autoblksfundflwcv(block, context);
    case 'autolibfundflwhe'% flow blocks (heat exchanger)
        varargout{1} = autoblksfundflwhe(block, context);
    case 'autolibfundflwfb'% flow blocks (flow boundary)
        varargout{1} = autoblksfundflwfb(block, context);
    case 'autolibfundflwfr'% flow blocks (flow restriction)
        varargout{1} = autoblksfundflwfr(block, context);
    case 'autolibmassfracbussetup' % Setup mass fraction tracking
        varargout{1} = autoblksmassfracbussetup(block, context);
    case 'autolibairmassfracs' % Setup air mass fraction block
        varargout{1} = autoblksairmassfracs(block, context);
    case 'autolibsengexhmassfrac' % Setup exhuast mass fractions
        varargout{1} = autoblksengexhmassfrac(block, context);
    case 'autolibcoreengemissionlookup' % Setup emissions lookup tables
        varargout{1} = autoblkscoreengemissionlookup(block, context);
    case 'autoliboperlong'% longitudinal operator model
        varargout{1} = autoblksoperlong(block, context);
    case 'autolibplanetarygb' % gear box; planetary (single sun-planet pair)
        varargout{1} = autoblksplanetarygb(block,context);
    case 'autolibravingeauxgb' % gear box; Ravingeaux (dual sun-planet pairs)
        varargout{1} = autoblksravingeauxgb(block);
    case 'autolibsgb' % gear box; simple fixed ratio
        varargout{1} = autoblkssgb(block,context);
    case 'autolibshaft' % rotational shaft (inertia, compliance, damping)
        varargout{1} = autoblksshaft(block);
    case 'autolibsidyneng' % dynamic si engine
        varargout{1} = autoblkssidyneng(block, context);
    case 'autolibSGF' % starter motor
        varargout{1} = autoblksSGF(block);
    case 'autolibSGFS' % starter motor
        varargout{1} = autoblksSGFS(block);
    case 'autolibstarter' % starter motor
        varargout{1} = autoblksstarter(block,context);
    case 'autolibtorqueconv' % torque converter
        varargout{1} = autoblkstorqueconv(block,context);
    case 'autolibtransautoman' % automated manual transmission
        varargout{1} = autoblkstransman(block,context);
    case 'autolibtransamtctrl' % automated manual transmission controller
        varargout{1} = autoblkstransamtctrl(block,context);
    case 'autolibtransdct' % dual clutch transmission
        varargout{1} = autoblkstransdct(block,context);
    case 'autolibtransdctctrl' % dual clutch transmission controller
        varargout{1} = autoblkstransdctctrl(block,context);
    case 'autolibtranscvt' % continuously variable transmission
        varargout{1} = autoblkstranscvt(block,context);
    case 'autolibtranscvtctrl' % continuously variable transmission controller
        varargout{1} = autoblkstranscvtctrl(block,context);
    case 'autolibturbine' % turbine
        varargout{1} = autoblksturbine(varargin{2:end});
    case 'autolibswheel'% wheel and tire (simple longitudinal)
        varargout{1} = autoblkswheel(block,context);
    case 'autolibalternator'% reduced lundell alternator
        varargout{1} = autoblksalternator(block,context);
    case 'pbinteriorpmsmcontroller'% interior PMSM controller
        varargout{1} = autoblksinteriorpmsmcontroller(block,context);
    case 'pbexteriorpmsmcontroller'% exterior PMSM controller
        varargout{1} = autoblksexteriorpmsmcontroller(block,context);
    case 'autolibsicoreengine'% autolib SI core engine
        varargout{1} = autoblkssicoreengine(block,context);
    case 'autolibcicoreengine'% autolib CI core engine
        varargout{1} = autoblkscicoreengine(block,context);
    case 'autolibsidynamicengine'% autolib SI core engine
        varargout{1} = autoblkssidynamicengine(block,context);
    case 'autolibcidynamicengine'% autolib CI core engine
        varargout{1} = autoblkscidynamicengine(block,context);
    case 'autolibsicontroller'% autolib SI controller
        varargout{1} = autoblkssicontroller(block,context);
    case 'autolibcicontroller'% autolib CI controller
        varargout{1} = autoblkscicontroller(block,context);
    case 'pbbatteryparamest'% parameter estimation RC battery
        varargout{1} = autoblksparamestbattery(block,context);
    case 'pbbatteryrc'% RC battery
        varargout{1} = autoblksrcbattery(block,context);
    case 'autolibutils'% utilities blocks
        varargout{1} = []; % autoblksutils(block,context);
    case 'autolibvehdyn1dof' % Rigid vehicle body, 1dof (longitudinal)
        varargout{1}=autoblksvehdyn1dof(block,context);
    case 'autolibvehdyn3dof' % Rigid vehicle body, 3dof (longitudinal)
        varargout{1}=autoblksvehdyn3dof(block,context);
    case 'vehdynliblat3dof' % Rigid vehicle body, 3dof (longitudinal)
        varargout{1}=vehdynlat3dof(block,context);    
    case 'autolibvehdyncdt' % Rigid vehicle body, coast down test parameters
        varargout{1}=autoblksvehdyncdt(block,context);
    case 'autolibwetclutch' % double sided wet clutch
        varargout{1}=autoblkswetclutch(block,context);
    case 'pbinductionmachinecontroller'% autoblks IM controller
        varargout{1} = autoblksimcontroller(block,context);
    case 'autolibsiengresize'% autoblks SI engine resize function
        varargout{1} = autoblkssiengresize(block,context);
    case 'autolibciengresize'% autoblks CI engine resize function
        varargout{1} = autoblksciengresize(block,context);
    case 'autolibdatasheetbattery'% autolib datasheet battery model
        varargout{1} = autoblksdatasheetbattery(block,context);
    case 'autolibdcdc'% autolib dc to dc converter
        varargout{1} = autoblksdcdc(block,context);       
    case 'pbfluxpmsmcontroller'% autolib flux based PMSM controller
        varargout{1} = autoblksfluxpmsmcontroller(block,context);
    case 'autolibcoreengpowersetup'
        varargout{1} = autoblkscoreengpowersetup(block, context);
    case 'autolibhevecms' % ECMS block orig
        varargout{1} = autoblkshevecms(block, context);
    case 'autolibecms' % ECMS block new
        varargout{1} = autoblksecms(block, context);
    case 'autolibhevecmstranseff' % Transmission efficiency calculation for ECMS
        varargout{1} = autoblkshevecmstranseff(block, context);
    case 'autolibhevwheel2mtr' % Convert torque from wheel to motor or motor to wheel for ECMS
        varargout{1} = autoblkshevwheel2mtr(block, context);
    case 'autolibsiengcal'% autoblks SI engine calibration function
        varargout{1} = autoblkssiengcal(block,context);
    case 'autolibobdmisf'% autoblks SI OBD Misfire masks initialization function
        varargout{1} = autoblksobdmisf(block,context);    
    case 'autoblksmotorresizeCb'% motor resize
        varargout{1} = autoblksmotorresizeCb(block,context);            
    otherwise
        error(message('autoblks:autoerrAutoIcon:invalidBlock'));
end

if nargout == 0
    clear('varargout');
end

end

%[EOF] autoblksicon.m