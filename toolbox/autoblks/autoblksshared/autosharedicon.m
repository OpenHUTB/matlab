function [ varargout ] = autosharedicon( varargin )
    %AUTOBLKSSHAREDICON Gateway function to the private directory of
    %shared automotive blocks.

    %   Copyright 2015-2021 The MathWorks, Inc.
    
    % Check for the correct number of input arguments
    if nargin<2
        error(message('autoblks_shared:autosharederrAutoIcon:invalidUsage'));
    end
    
    % Acquire the block and handle
    action   = varargin{1};
    block  = varargin{2};
    
    autoshared(block);
    
    % get mask callback context
    if nargin>=3
        context = varargin{3}; % where in the mask is autoicon being called from
    end
    
    % Initialize the output
    varargout{1}=0;
    
    % Take the correct block action
    switch action
        case 'autolibdrivecycle' % drive cycle source
            [varargout{1},varargout{2},varargout{3},varargout{4},varargout{5}] = autoblksdrivecycle(block,context);
        case 'autoliboperlong'% longitudinal operator model
            varargout{1} = autoblksoperlong(block, context);
        case 'autolibSGF' % simplified Savitzky-Golay differentiator
            varargout{1} = autoblksSGF(block);
        case 'autolibSGFS' % single simplified Savitzky-Golay differentiator
            varargout{1} = autoblksSGFS(block);
        case 'autolibswheel'% wheel and tire (simple longitudinal)
            varargout{1} = autoblkswheel(block,context);
        case 'autolibutils'% utilities blocks
            varargout{1} = []; % autoblksutils(block,context);
        case 'autolibvehdyn1dof' % Rigid vehicle body, 1dof (longitudinal)
            varargout{1}=autoblksvehdyn1dof(block,context);
        case 'autolibvehdyn3dof' % Rigid vehicle body, 3dof (longitudinal)
            varargout{1}=autoblksvehdyn3dof(block,context);
        case 'autoblksvehdynlnginplnmoto' % Rigid motorcycle body with suspension, (in-plane longitudinal)
            varargout{1}=autoblksvehdynlnginplnmoto(block,context);
        case 'autoblksvehdynmotochain' % Motorcycle chain, (in-plane longitudinal)
            varargout{1}=autoblksvehdynmotochain(block,context); 
        case 'vehdynliblat3dof' % Rigid vehicle body, 3dof (lateral)
            varargout{1}=vehdynlat3dof(block,context);
        case 'autolibvehdyn3doflatr' % Rigid vehicle body, 3dof (lateral, restricted features)
            varargout{1}=autoblksvehdyn3doflat(block,context);
        case 'autolibvehdyncdt' % Rigid vehicle body, coast down test parameters
            varargout{1}=autoblksvehdyncdt(block,context);
        case 'autolibrotdamp' % rotational spring damper
            varargout{1}=autoblksrotdamp(block,context);
        case 'autolibrotdampcplr' % rotational spring damper coupler
            varargout{1}=autoblksrotdampcplr(block,context);
        case 'autolibrotinert' % rotational inertia
            varargout{1}=autoblksrotinert(block,context);
        case 'autolibdiffopen' % differential
            varargout{1} = autoblksdiffopen(block,context);
        case 'autolibtransfercaseopen' % transfercase
            varargout{1} = autoblkstransfercase(block,context);
        case 'autolibdiffls' % limited slip differential
            varargout{1} = autoblksdiffls(block,context);
        case 'autolibdiffas' % active slip differential
            varargout{1} = autoblksdiffas(block,context);    
        case 'autolibtransidealfixed' % ideal fixed gear transmission
            varargout{1} = autoblkstransidealfixed(block,context);
        case 'autolibmappedengine'% autolib mapped engine
            varargout{1} =autoblksmappedengine(varargin{2:end});
        case 'autolibsimappedengine'% autolib SI mapped engine
            varargout{1} =autoblkssimappedengine(block,context);
        case 'autolibcimappedengine'% autolib CI mapped engine
            varargout{1} =autoblkscimappedengine(block,context);
        case 'pbgenericelectricmachine'% autoblks mapped motor
            varargout{1} = autoblksmappedmotor(block,context);
        case 'autolibpowerbusutil' % power accounting bus util
            varargout{1} = autoblkspowerbusutil(block,context);
        case 'pbinteriorpmsm'% interior PMSM
            varargout{1} = autoblksinteriorpmsm(block,context);
        case 'pbexteriorpmsm'% exterior PMSM
            varargout{1} = autoblksexteriorpmsm(block,context);
        case 'pbfluxpmsm'% autolib flux based PMSM
            varargout{1} = autoblksfluxpmsm(block,context);
        case 'pbthreephaseinverter'% autolib inverter
            varargout{1} = autoblksthreephaseinverter(block,context);
        case 'pbinductionmachine'% Induction machine
            varargout{1} = autoblksim(block,context);
        case 'autolibsimpleengine'% autolib simple engine
            varargout{1} = autoblkssimpleengine(block,context);
        case 'autolibshift'% autoblks shift schedulers function
            varargout{1} = autoblksshift(block,context);
        otherwise
            error(message('autoblks_shared:autosharederrAutoIcon:invalidBlock'));
    end
    if nargout == 0
        clear('varargout');
    end
end