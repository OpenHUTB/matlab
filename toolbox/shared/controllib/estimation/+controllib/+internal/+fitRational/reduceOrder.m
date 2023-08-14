function Gred = reduceOrder(G,desiredOrder,hasFeedthrough)
%

%   Copyright 2017-2022 The MathWorks, Inc.

% Model reduction for ZPK models via subspace approach
%
% Estimation MIMO models via fitRational yields a model with McMillan
% degree min(Ny,Nu)*numberOfPoles. This routine is utilized to reduce the
% degree to numberOfPoles.

% AAO: hasFeedthrough=false case is weak.
% AAO: Use MagnitudeScaling approach of fitRational here
% AAO: Use the user-specified weight during reduction?

% This routiune requires System Identification Toolbox.

if nargin<3
   hasFeedthrough = true;
end

Ts = G.Ts;
assert(Ts~=-1);

G = zpk(G);
if Ts==0
   [minW,maxW] = localFindInterestingFrequencyRangeCT(G.z,G.p{1});
   w = logspace(log10(minW),log10(maxW),2000).';
else
   w = linspace(0,pi/Ts,2000).';
end
% AAO: Ensure that poles of G does not coincide with w. ToDo
data = unpack(idfrd.make(idfrd(G,w)), [], false);

% AAO: Just get impulse response from G, then do subspace directly instead
% of G->frd->impulse? (what if sys is unstable?!)
ny = data.Ny; nu = data.Nu;
Gred = idpack.ssdata.createTemplate(ny,nu,desiredOrder,Ts,all(hasFeedthrough,1),false);
Options = n4sidOptions('EstCovar',false,'OutputWeight',eye(ny));
Gred = n4sid_frequency(Gred, data, desiredOrder, Options);

end

%----------------------------------------------------------------------------------------
function [minW,maxW] = localFindInterestingFrequencyRangeCT(zCT,pCT)
% Given zeros zCT, poles pCT of a continuous-time system, pick the minimum
% and maximum frequency beyond which there are no interesting dynamics.
% Specifically, below minW (rad/s) and above maxW (rad/s) system dynamics
% are (approximately) either constant or have constant magnitude slope.

% Check the denominator
[~,minW] = controllib.internal.fitRational.findMinimumFrequencyContinuousTime(pCT);
[~,maxW] = controllib.internal.fitRational.findMaximumFrequencyContinuousTime(pCT);
% Check the numerator
[Ny,Nu] = size(zCT);
for kkY=1:Ny
   for kkU=1:Nu
      [~,cMinW] = controllib.internal.fitRational.findMinimumFrequencyContinuousTime(zCT{kkY,kkU});
      [~,cMaxW] = controllib.internal.fitRational.findMaximumFrequencyContinuousTime(zCT{kkY,kkU});
      minW = min(minW, cMinW);
      maxW = max(maxW, cMaxW);
   end
end
end

