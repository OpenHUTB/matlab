function n4h = estimateN4Horizon(y,u,dkx,order,maxsize,Ncap)
% Determine n4horizon.

% Copyright 1986-2017 The MathWorks, Inc.

ny = size(y,2); nu = size(u,2);
radef = ceil(1.5*order);   % max(1.5*order,ceil(1.5*order/ny));
maxo = ceil(min([4*order,(Ncap-(ny+nu))/2,...
   max(floor(Ncap/(ny+nu+1))-1+order/ny,1)]));

if dkx(2)
   auxord = localAIC(y,u,maxo,ny,maxsize);
   n4h = [radef, auxord, auxord];
else
   auxord = localAIC_noK(y,u,ceil(4*order),ny);
   n4h = [radef, 0, auxord];
end

%--------------------------------------------------------------------------
function n = localAIC(y,u,nmax,p,maxsize)
% Computes the best order of an ARX model using AIC. z is single experiment
% data.

[N,ny] = size(y); nu = size(u,2);
nz = ny+nu;
M = max(floor(maxsize/nz/nmax),nmax+1);
R1 = zeros(0,nmax*nz);
z = [y, u];
for k = nmax:M:N-1
   jj = (k:min(N,k+M-1));
   phi = zeros(length(jj),nmax*nz);
   for kz = 1:nmax
      phi(:,(kz-1)*nz+1:kz*nz) = z(jj-nmax+kz,:);
   end
   
   R1 = triu(qr([R1;phi])); [nr,nrc] = size(R1);
   R1 = R1(1:min(nr,nrc),:);
end
Neff = N-nmax+1;
V(1) = inf;

for k = 0:min(nmax-1,floor((Neff-p-1)/nz))
   V(k+1) = sum(log(diag(R1(k*nz+1:k*nz+p,k*nz+1:k*nz+p)/nr).^2))+2*nz*p*k/Neff;
end
[~,n] = min(V); n = n-1;

%--------------------------------------------------------------------------
function n = localAIC_noK(y,u,nmax,p)
% Alternative to AIC for models with no disturbance component.

z = [y, u];
[N,nz] = size(z);
nu = nz-p;
str = [];
for ku = 1:nmax
   str = [str;[0,ku*ones(1,nu),ones(1,nu)]];
end

w = 0;
for ky = 1:p
   zz = z(:,[ky,p+1:nz]);
   v = controllib.internal.subspaceID.arxstruc(zz,str);
   w = w+v(1,1:end-1);
end

w = log(w)+ 2*(1:nmax)*nu/(N-nmax);
[~,n] = min(w);
