function p = map(w,Ts)
%

% For Ts=0, map points on the imaginary axis onto the unit circle
% For Ts>0, map points on the unit circle onto another unit circle
%
% Inputs:
%    w:  Frequency points in rad/s
%    Ts: Sample time for the original domain
% Outputs:
%    p.q:        Mapped points on the unit disk
%    p.alpha:    alpha parameter in q=(-s-alpha)/(s-alpha), only available
%                when Ts=0
%    p.b:        beta parameter in q=(z+b)/(bz+1), only available when Ts>0
%    p.mappedTs: Sample time such that we can revert this mapping via:
%                   sys = ltipack.zpkdata(...,mappedTs)
%                   sys = d2c(sys,Ts)
%                      or
%                   sys = d2d(sys,Ts)

%   Copyright 2015-2019 The MathWorks, Inc.

% Take the unique points in w for mapping parameter calculation. Otherwise
% we have at least 2 points that can't be separated at all. This would make
% our mapping algorithm fail.
wUnique = localGetUniqueFrequencyPoints(w);

% Mapping:
%    1) Use wUnique for calculating the mapping parameter
%    2) Apply the mapping on vector w
if Ts==0
    p = localContinuousToDiscreteMap(w,wUnique);
    p.mappedTs = 2/p.alpha;
else
    p = localDiscreteToDiscreteMap(w,wUnique,Ts);
    p.mappedTs = (1-p.b)/(1+p.b)*Ts;
end
end

function p = localDiscreteToDiscreteMap(w,wUnique,Ts)
% w is the original frequency grid provided by the user
% wUnique is the unique points in w
%
% Assumptions: max(w)<=pi/Ts (Nyquist freq) (Asserted in validateData.m)

% We need at least 2 frequency points in wUnique to calculate the optimally
% spaced transformed grid. When there is only one point, skip the mapping
if numel(wUnique)==1
    % Only 1 point. Skip the mapping
    p.b = 0;
else
    % 2 points or more. Calculate the optimal mapping: level set approach
    
    % AAO: check for edge cases: if w(1)=0, or w(2)=pi
    theta = wUnique*Ts;
    dtheta = theta(2:end)-theta(1:end-1);
    sinTheta1 = sin(theta(1:end-1));
    sinTheta2 = sin(theta(2:end));
    cosTheta1 = cos(theta(1:end-1));
    cosTheta2 = cos(theta(2:end));
    f = sinTheta2 - sinTheta1;
    g = sin(dtheta);
    h = cosTheta2 + cosTheta1;
    k = cos(dtheta);
    
    % Initial b guess
    d = g./f;
    % d must be >=1 or <=-1, but this may not be true due to numerical issues
    % Example:
    % Ts=1.3; w = logspace(-2,log10(pi/Ts),100); theta=w*Ts;
    % sin(pi-theta(end-1)) / ( sin(pi) - sin(theta(end-1)) )
    d(d>0 & d<1) = 1;
    d(d<0 & d>-1) = -1;
    b = -d+sign(d).*sqrt(d.^2-1);
    % d=Inf when t1=pi-t2. In this case b=0
    b(isinf(d)) = 0;
    b = mean(b);
    
    % Start the iteration
    bMax = Inf;
    maxIter = 20;
    iter = 1;
    while (bMax-b)>1e-3 && abs(1-b/bMax)>1e-3 && iter<=maxIter
        iter = iter+1;
        TargetAngle = min( ...
            dtheta + ...
            2*( atan2(-b*sinTheta2,1+b*cosTheta2)-atan2(-b*sinTheta1, 1+b*cosTheta1) ) ...
            );
        % TargetAngle = min( ...
        %  atan2( sinTheta2, cosTheta2+b ) - ...
        %  atan2( b*sinTheta2, b*cosTheta2+1 ) - ...
        %  atan2( sinTheta1, cosTheta1+b ) + ...
        %  atan2( b*sinTheta1, b*cosTheta1+1 ) );
        % TargetAngle = min( angle((zz(2:end)+b)./(b*zz(2:end)+1)./(zz(1:end-1)+b).*(b*zz(1:end-1)+1) )); % zz=exp(1i*theta);
        l = tan((TargetAngle-dtheta)/2);
        aa = k.*l+g;
        bb = (l.*h+f)./aa;
        detSqrt = real(sqrt(bb.^2-4*l./aa)); % real(): safeguard, should never hit this except numerical issues
        bMin = max((-bb-detSqrt))/2;
        bMax = min((-bb+detSqrt))/2;
        b = (bMin+bMax)/2;
    end
    p.b = b;
end

% Perturb b so that there is little chance it exactly coincides with a pole
% of the model to be identified. While doing so ensure b is not pushed
% outside its valid range -1<b<1. See localContinuousToDiscreteMap for the
% rationale
p.b = p.b*(1+pi/8999);
if p.b>=1
    p.b = 1/(1+pi/8999);
elseif p.b<=-1
    p.b = -1/(1+pi/8999);
end
% Get the mapped points on the unit disk: q=(z+b)/(b*z+1). The inverse
% mapping is z=(q-b)/(1-bq)
p.q = (exp(1i*w*Ts)+p.b) ./ (p.b*exp(1i*w*Ts)+1); 
end

function p = localContinuousToDiscreteMap(w,wUnique)
% w is the original frequency grid provided by the user
% wUnique is the unique points in w

% wUnique must have at least 2 frequency points to calculate the optimally
% spaced transformed grid
if numel(wUnique)==1
    % Only 1 point. Map it to 1i.
    Alpha = wUnique(1);
else
    % 2+ points. Find the optimal mapping via Suat's level set approach
    dw = diff(wUnique);
    a0 = sqrt(wUnique(2:end).*wUnique(1:end-1));
    
    % Initial alpha value
    if a0(1)==0
        Alpha = mean(a0);
    else
        % geometric mean for vector with positive entries
        Alpha = exp(sum(log(a0))/numel(a0));
    end
    % Alpha calculated above gives a TargetAngle (per definition below)
    % that is feasible for all (w(k+1), w(k)) pairs
    
    AlphaMax = Inf;   
    maxIter = 20;
    iter = 1;
    while AlphaMax-Alpha>1e-3 && abs(1-Alpha/AlphaMax)>1e-3 && iter<=maxIter
        iter = iter + 1;
        
        TargetAngle = 2 * min(atan(wUnique(2:end)/Alpha) - atan(wUnique(1:end-1)/Alpha));
        
        K = cot(TargetAngle/2) * dw/2;
        a0DivK = a0 ./ K;
        dK = sqrt(1-a0DivK).*sqrt(1+a0DivK); % sqrt(1-a0DivK.^2)
        dK = real(dK);
        AlphaMax = min(K .* (1 + dK));
        AlphaMin = max(K .* a0DivK.^2 ./ (1 + dK)); % max(K .* (1 - dK))        
        Alpha = sqrt(AlphaMin*AlphaMax);
        % Alternative code for testing
        %b = -dw / tan(TargetAngle/2);
        %det = sqrt(b.^2-4*a0.^2);
        %Alpha = 0.5*sqrt(min(-b+det)*max(-b-det));
    end
end
p.alpha = Alpha;

% Perturb alpha so that there is little chance it exactly coincides with a
% pole of the model to be identified. If the model has a pole as s=alpha,
% the LSQ matrices are rank deficient regardless of the choice of basis fcns
%
% alpha is in the range (0,inf). There is no risk of pushing alpha out
% of bounds by this perturbation, unlike the discrete case
p.alpha = p.alpha * (1+pi/8999);
if p.alpha == 0
    p.alpha = pi/8999;
end
% Get the mapped points on the unit disk: q=(alpha+s)/(alpha-s). Inverse
% mapping is s=alpha*(q-1)/(q+1)
p.q = (p.alpha+1i*w) ./ (p.alpha-1i*w); 
end

function wUnique = localGetUniqueFrequencyPoints(w)
% w:       Set of points where system's frequency response is evaluated.
%          validateData guarantees that w is >=0, finite. The values in w
%          may not be unique if user provides data from multiple experiments.
% wUnique: Unique points in w
%
% This fcn uses a relative tolerance for comparison, instead of strict
% equality check in unique() which is sensitive to eps perturbations.

% Sort the frequency points. The first point is always included. For the
% rest, look at the ratio between kk and (kk+1)-th point. Be careful about
% div-by-0
tol = 1+1e-10;

wSorted = sort(w);
wSorted(wSorted==0) = eps; % pre-process: protect against div by 0
wUnique = wSorted([true; (wSorted(2:end)./wSorted(1:end-1))>tol]);
wUnique(wUnique==eps) = 0; % Revert pre-processing: protection for div by 0
end

% function p = localfitfrdMappingMethod(wUnique,Ts)
% % Mapping via the method used in fitfrd. This is a simplified version that
% % ignores some edge cases.
% %
% % Unused. For future research and testing purposes.
% if Ts==0
%     % continuous
%     if wUnique(1)==0
%         w1 = wUnique(2);
%     else
%         w1 = wUnique(1);
%     end
%     w2 = wUnique(end);
%     p = sqrt(w1*w2);
% else
%     % discrete
%     t1 = wUnique(1)*Ts;
%     t2 = wUnique(end)*Ts;
%     ct = (1+cos(t1+t2))/(cos(theta(1))+cos(theta(2)));
%     tm = acos(ct);
%     
%     assert(all(diff([0 tm pi])>0)); % Angle tm must satisfy 0<tm<pi
%     
%     cm = cos(tm);
%     sm = sin(tm);
%     if abs(cm)<10*eps
%         p = 0;
%     else
%         p = (sm-1)/cm;
%     end
% end
% end