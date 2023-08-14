function [sys, Info] = subspaceid(y, u, Orders, Ft, n4w, n4h)
% P-coded file.

% Discrete-time state-space model estimation using time domain data.
% Inputs:
% y,u:  Output and input data matrices.
%       Represents uniformly sampled time-domain data with Ns observations,
%       Ny outputs and Nu inputs. Ny>0, Nu>=0, Ns>0.
%       y: output data; Ns-by-Ny
%       u: input data; Ns-by-Nu
%
% Orders: Positive integer or a row vector of positive integers.
%
% Ft: Whether the model has feedthrough or not. Logical row vector of
% length Nu, where Nu = number of inputs. Ft is irrelevant for time series
% models (Nu=0).
%
% n4w: Weight choice. One of 'cva' or 'moesp'. Optional. Default: 'moesp'
% n4h: Horizon choice; 'auto' or vector [a b c] where a b c are positive
%      integers. Optional. Default: 'auto'.

% Copyright 1986-2017 The MathWorks, Inc.

ni = nargin;
if ni<5, n4w = 'MOESP'; end
if ni<6, n4h = 'auto'; end
MaxSize = 250e3;
n = ceil(max(Orders));
[Ncap, ny] = size(y); nu = size(u,2);

if n==0
   % Special case: y = D*u
   A = [];
   B = zeros(0,nu);
   C = zeros(ny,0);
   K = zeros(0,ny);
   if nu>0
      D = u\y;
   else
      D = zeros(ny,0);
   end
   x0 = zeros(0,1);
   [sys, Info] = localPackData(A,B,C,D,K,x0,y,u,n4w,[0 0 0]);
   return
end

% Assemble dkx.
% Feedthrough: user supplied
% Estimate K only in time series case
% X0: always estimate
dkx = [any(Ft), nu==0, true]; % X0 free

if ischar(n4h) || isempty(n4h)
   n4h = controllib.internal.subspaceID.estimateN4Horizon(y,u,dkx,n,MaxSize,Ncap);
end

Orders = unique(Orders);
[auxact,MaxSize,nrr] = controllib.internal.subspaceID.adjustN4Horizon(n,n4h,MaxSize,...
   Ncap,ny,nu,dkx,length(Orders)>1);
raa = auxact(1); s1aa = auxact(2); s2aa = auxact(3);

R = controllib.internal.subspaceID.buildR(y,u,MaxSize,nrr,raa,s1aa,s2aa);
ind3 = nu*(raa+s2aa)+ny*s1aa+1:nu*(raa+s2aa)+ny*(raa+s1aa);
ind2 = nu*raa+1:nu*(s2aa+raa)+ny*s1aa;
if strcmp(n4w,'CVA')
   W1 = R(ind3,[ind2 ind3]);
   [ull1,sll1,~] = svd(W1);
   sll1 = sll1(1:raa*ny,1:raa*ny);
   [Un,Sn,~] = svd(pinv(sll1)*ull1'*R(ind3,ind2));
   Un = ull1*sll1*Un;
else
   [Un,Sn,~] = svd(R(ind3,ind2));
end

if length(Orders)>1
   if any(Orders==0)
      error(message('Controllib:estimation:zeroVarOrder'))
   end
   if strcmp(n4w,'CVA')
      [~,Sn1,~] = svd(R(ind3,ind2));
   else
      Sn1 = Sn;
   end
   n = localPickOrder(Sn1,Orders);
end

A = conj(Un(1:ny*(raa-1),1:n)\Un(ny+1:raa*ny,1:n));
C = conj(Un(1:ny,1:n));
if any(~isfinite(A(:)))
   error(message('Controllib:estimation:nonPersistentData'))
end

if dkx(2)==0 || nu==0
   A = localStabilizeMatrix(A);
end

R1 = R(1:nu*raa,1:nu*raa);
R2 = R(s1aa*ny+(raa+s2aa)*nu+1:end,1:s1aa*ny+(raa+s2aa)*nu+ny);

if dkx(2)
   K = controllib.internal.subspaceID.estimateK(R1,R2,Un,n,ny,nu,raa,s1aa,s2aa,A,C);
else
   K = zeros(n,ny);
end

% Always estimate x0.
[B,D,x0] = controllib.internal.subspaceID.linreg(y,u,A,K,C,dkx,Ft,MaxSize);
[sys, Info] = localPackData(A,B,C,D,K,x0,y,u,n4w,n4h);

%--------------------------------------------------------------------------
function [sys, Info] = localPackData(A,B,C,D,K,x0,ym,u,n4w,n4h)
% Pack results and report model quality.

[Ncap, ny] = size(ym); 
nu = size(u,2); nx = size(A,1);
x = ltitr(A-K*C,[K B-K*D],[ym, u],x0);
y = x*C';
if any(D(:))
   y = y + u*D';
end
e = ym-y;

% Determine effective number of parameters in the model (np)
Ft = any(D~=0,1);
np = nx^2 + nx*nu + nx*ny;
np = min(np, nx*(nu+ny)); % identifiability limit
if any(any(K)), np = np + nx*ny; end % disturbance component
if any(Ft), np = np + sum(Ft)*ny; end % feedthrough contribution
np = np + nx; % x0 contribution

% Calculate noise variance and loss.
lambdap = real(e'*e);
Vloss = det(lambdap/Ncap);

sys.A = A;
sys.B = B;
sys.C = C;
sys.D = D;
sys.K = K;
sys.X0 = x0;
sys.NoiseVariance = lambdap/(Ncap-np);

Info.N4Weight = n4w;
Info.N4Horizon = n4h;
Info.Loss = Vloss;

%--------------------------------------------------------------------------
function n = localPickOrder(SS,n)
% Order picking.

dS = diag(SS);
if length(dS)<max(n)
   error(message('Controllib:estimation:subspaceHighMaxOrderSelect'))
end

nmax = max(n);
testo = log(dS);
I = find(testo>(max(testo)+min(testo))/2, 1, 'last');
ndef = max(min(n),min(nmax,I));
[~,I] = min(abs(n-ndef));
ndef = n(I);
n = ndef;

%--------------------------------------------------------------------------
function A = localStabilizeMatrix(A)
% Stabilize a matrix (DT case)

RealA = isreal(A);
[V,D] = eig(A);
if cond(V)>10^8
   [V,D] = schur(A);
   [V,D] = rsf2csf(V,D);
end

if max(abs(diag(D)))<1 
   return
end

[~,n] = size(D);
for kk = 1:n
   if abs(D(kk,kk))>1, D(kk,kk) = 1/D(kk,kk); end
end


A = V*D/V;

if RealA, A = real(A); end
