function [zo,po,ko] = revertMapZPK(z,p,k,Ts,mapParams,useCtrlFcns)
%

% We need to revert the bilinear 'halfplane to disk' or 'disk to disk'
% mapping we had performed.
%
% If shared controls functionality is available, utilize those. Otherwise,
% use simpler approaches.
%
% Inputs:
%    z:           Identified zeros in the transformed domain. [Ny Nu] cell,
%                 containing column vectors
%    p:           Identified poles in the transformed domain. Column vector
%    k:           Identified gains in the transformed domain. [Ny Nu] matrix
%    Ts:          Sample time of data. Scalar.
%    mapParams:   Parameters utilized for domain mapping. Struct
%    useCtrlFcns: Whether to use shared controls functionality. Scalar
%
% Outputs:
%    zo: Identified zeros in the original domain, [Ny Nu] cell
%    po: Identified poles in the original domain, Column vector
%    ko: Identified gains in the original domain, [Ny Nu] matrix

%   Copyright 2015-2017 The MathWorks, Inc.

[Ny,Nu] = size(z);

if useCtrlFcns
    % Set the appropriate 'sample time' for the estimated discrete model in
    % the transformed domain, then use d2c/d2d to revert our mapping.
    conversionOpt = struct('Method','tustin','PrewarpFrequency',0);
    sys = ltipack.zpkdata(z,repmat({p},Ny,Nu),k,mapParams.mappedTs);
    if Ts==0
        sys = d2c(sys,conversionOpt);
    else
        sys = d2d(sys,Ts,conversionOpt);
    end
    zo = sys.z;
    po = sys.p{1};
    ko = sys.k;
else
    [zo,po,ko] = localRevertMapZPK(z,p,k,Ts,mapParams);
end
end

function [zo,po,ko] = localRevertMapZPK(z,p,k,Ts,mapParams)
[Ny,Nu] = size(z);
zo = cell(Ny,Nu);
ko = zeros(Ny,Nu);

% Find relative degree and insert the appropriate p/z at inf
Np = numel(p);
Nz = zeros(Ny,Nu);
for kk=1:Ny*Nu
    Nz(kk) = numel(z{kk});
end
maxNz = max(max(Nz));
relDeg = Np-Nz;

if Ts==0 % d2c replacement for zpk systems
    % map poles
    [po,pScale] = localRevertMapD2C(p,mapParams.alpha,maxNz-Np);
    % map zeros and gain
    logk = log(k);
    sumlogpScale = sum(log(pScale));
    for kk=1:Ny*Nu
        [zo{kk},zScale] = localRevertMapD2C(z{kk},mapParams.alpha,relDeg(kk));
        %ko(kk) = real( k(kk)*prod(zScale)/prod(pScale) );
        ko(kk) = real(exp( logk(kk) + sum(log(zScale)) - sumlogpScale ));
    end
else % d2d replacement for zpk systems
    % map poles
    [po,pScale] = localRevertMapD2D(p,mapParams.b,maxNz-Np);
    % map zeros and gain
    logk = log(k);
    sumlogpScale = sum(log(pScale));
    for kk=1:Ny*Nu
        [zo{kk},zScale] = localRevertMapD2D(z{kk},mapParams.b,relDeg(kk));
        %ko(kk) = real( k(kk)*prod(zScale)/prod(pScale) );
        ko(kk) = real(exp( logk(kk) + sum(log(zScale)) - sumlogpScale ));
    end
end
end

function [rs,kScale] = localRevertMapD2C(rq,alpha,rDeg)
% Given polynomial p(q)=k*(q-r(1))*(q-r(2))...
%    find the equivalent polynomial (with a transformed domain)
% p(s)=k*prod(kScale)*(s-po(1))*(s-po(2))...
%    where q=(alpha+s)/(alpha-s)
%
% rq in C^n, alpha in R^1, rs in C^m where m<=n, kScale in C^n

% AAO: Handle case where rq(i) is +-Inf? This is quite unlikely, because
%      this means rs(i) is alpha. We choose alpha to be a transcendental
%      number

atInf = isinf(rq);
atMinus1 = rq==-1; % AAO: likely using a tolerance is better to detect ro that will be at Inf

rs = zeros(numel(rq),1);
kScale = zeros(numel(rq),1);

% rq at infinity
kScale(atInf) = sign(rq(atInf))*Inf;
rs(atInf) = alpha;
% finite rq values that do not hit the edge case rq=-1
rqFiniteNotMinus1 = rq(~atMinus1 & ~atInf);
rs(~atMinus1 & ~atInf) = alpha*(rqFiniteNotMinus1-1)./(rqFiniteNotMinus1+1);
kScale(~atMinus1 & ~atInf) = 1+rqFiniteNotMinus1;
% edge case: rq=-1 only modify the gain, there is no root in s domain
kScale(atMinus1) = 2*alpha;
rs(atMinus1) = [];

% add the roots and gain scaling from reldeg
if rDeg
    kScale = [kScale; -ones(rDeg,1)];
    rs = [rs; alpha*ones(rDeg,1)];
end

% make this fcn compatible with d2c for empty poles/zeros
if isempty(rs)
    rs = zeros(0,1); % instead of [1 0]
end
end

function [rz,kScale] = localRevertMapD2D(rq,b,rDeg)
% Given polynomial p(q)=k*(q-rq(1))*(q-rq(2))...
%    find the equivalent polynomial (with a transformed domain)
% p(z)=k*prod(kScale)*(z-rz(1))*(z-rz(2))...
%    where q=(z+b)/(b*z+1)
%
% rq in C^n, alpha in R^1, rz in C^m where m<=n, kScale in C^n

if b==0 % no transformation. quick return, avoid issues with 1/b
   rz = rq;
   kScale = 1;
   return;
end

atInf = isinf(rq);
at1Overb = abs(1-b*rq)<1e-14; % AAO: is this a good tolerance? Watch out for structured estimation

rz = zeros(numel(rq),1);
kScale = zeros(numel(rq),1);

% rq at infinity
kScale(atInf) = -sign(rq(atInf))*Inf;
rz(atInf) = -1/b;
% finite rq values that do not hit the edge case rq=1/b
rqFiniteNot1Overb = rq(~at1Overb & ~atInf);
kScale(~at1Overb & ~atInf) = 1-b*rqFiniteNot1Overb;
rz(~at1Overb & ~atInf) = (rqFiniteNot1Overb-b)./(1-b*rqFiniteNot1Overb);
% edge case: rq=1/b modify the gain, there is no root in z domain
kScale(at1Overb) = b-rq(at1Overb);
rz(at1Overb) = [];

% add the roots and gain scaling from reldeg
if rDeg
    kScale = [kScale; b*ones(rDeg,1)];
    rz = [rz; ones(rDeg,1)/(-b)];
end

% make this fcn compatible with d2d for empty poles/zeros
if isempty(rz)
    rz = zeros(0,1); % instead of [1 0]
end
end

% LocalWords:  halfplane Ny zo po ko Prewarp kk rq AAO ro reldeg rz
