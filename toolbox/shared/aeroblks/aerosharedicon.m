function varargout=aerosharedicon(varargin)
    % AEROSHAREDICON Gateway function to the private directory of Shared Aerospace
    %   Blockset.
    
    %   Copyright 2015-2017 The MathWorks, Inc.
    
    if nargin==0
        error(message('shared_aeroblks:sharedaeroicon:invalidUsage'));
    end
    action = varargin{1};
    p={};
         
    switch action
        % Icons for aerolib blocks:
        case 'shared'
        case 'shared3dofbody'
            if (length(varargin) < 2)
                shared3dofbody(gcb);
            else
                p{1} = shared3dofbody(gcb,varargin{2});
            end
        case 'shared6dofbody'
            if (length(varargin) < 2)
                shared6dofbody(gcb);
            else
                p{1} = shared6dofbody(gcb,varargin{2});
            end
        case 'sharedconversion'
            if (length(varargin) < 2)
                sharedconversion(gcb);
            else
                [p{1},p{2},p{3}]= sharedconversion(gcb,varargin{2});
            end
        case 'sharedang2quat'
            sharedang2quat(gcb);
        case 'sharedquat2ang'
            sharedquat2ang(gcb);
            
        case 'shareddcm2ang'
            shareddcm2ang(gcb);
            
        case 'sharedang2dcm'
            sharedang2dcm(gcb);
            
        otherwise
            error(message('shared_aeroblks:sharedaeroicon:invalidBlock'));
    end
    
    if nargout ~= 0
        varargout = cell(nargout,1);
    end
    
    if ~isempty(p)
        for i=1:nargout
            varargout(i)={p{i}};
        end
    else
        % return dummy values
        for i=1:nargout
            varargout(i)={0};
        end
    end
end

%[EOF] aerosharedicon.m
