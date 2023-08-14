function [D,N] = getResponse(B,dp,np)
%

% [D,N] = getResponse(B,dp,np)
%
% Calculate the frequency response of the denominator (D) and the numerator
% (N) given basis functions (B) and identified parameters (dp,np)

%   Copyright 2015-2016 The MathWorks, Inc.

% Denominator's frequency response
D = B*dp.';
% Numerator's frequency response
if nargout>1
    [Ny,Nu] = size(np);
    N = cell(Ny,Nu);
    for kkY=1:Ny
        for kkU=1:Nu
            N{kkY,kkU} = B*np{kkY,kkU}.';
        end
    end    
end
end