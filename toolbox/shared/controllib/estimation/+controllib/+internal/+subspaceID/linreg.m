function [B,D,x0] = linreg(y,u,A,K,C,dkx,ft,maxsize)
% Compute B, D and X0 using linear least squares.

% Copyright 1986-2017 The MathWorks, Inc.

% K may be zero if focus is simulation.
% ft: Feedthrough flag (1-by-nu logical)

% noBe means that B is known and not estimated
[Ncap,ny] = size(y); nu = size(u,2);
z = [y, u];
nx = size(A,1);
n = nu*nx+nx;
if dkx(1)
   n = n+ny*sum(ft);
end
nz = ny+nu;
rowmax = max(n*ny,nx+nz);
M = floor(maxsize/rowmax);
NoK = norm(K,1)==0;
R1 = [];
X0 = zeros(nx,1);
dXk = zeros(nx,nx);
X00 = eye(nx,nx);
for kc = 1:M:Ncap
   jj = (kc:min(Ncap,kc-1+M));
   if jj(end)<Ncap
      jjz = [jj,jj(end)+1];
   else
      jjz = jj;
   end
   psi = zeros(ny*length(jj),n);
   if NoK
      e = z(jj,1:ny);
   else     
      KB = K;
      zte = z(jjz,1:ny);      
      xf = ltitr(A-K*C,KB,zte,X0);
      X0 = xf(end,:)';
      yh = xf*C';
      % We use the good K even for an OE model
      e = z(jj,1:ny) - yh(1:length(jj),:);
   end
   evec = e(:);
   kl = 1;
   for kx = 1:nx
      for ku = 1:nu
         dB = zeros(nx,1); dB(kx,1) = 1;         
         xx = ltitr(A-K*C, dB, z(jjz,ny+ku), dXk(:,kx));
         psitemp = xx*C';
         dXk(:,kx) = xx(end,:).';
         psitemp = psitemp(1:length(jj),:);
         psi(:,kl) = psitemp(:); kl = kl+1;
      end
   end
   if dkx(1)
      for ky = 1:ny
         for ku = find(ft)
            psitemp = ...
               [zeros(length(jjz),ky-1),z(jjz,ny+ku),...
               zeros(length(jjz),ny-ky)];
            psitemp = psitemp(1:length(jj),:);
            psi(:,kl) = psitemp(:); kl = kl+1;
         end
      end
   end
   
   %% x0
   for kx = 1:nx
      xx = ltitr(A-K*C, zeros(nx,1), zeros(length(jjz),1), X00(:,kx));
      psitemp = xx*C';
      X00(:,kx) = xx(end,:).';
      psitemp = psitemp(1:length(jj),:);
      psi(:,kl) = psitemp(:); kl = kl+1;
   end
   R1 = triu(qr([R1;[psi,evec] ])); [nrr,nrc] = size(R1);
   R1 = R1(1:min(nrr,nrc),:);
end 

% *** Compute the estimate of B and D ***
g = pinv(R1(1:n,1:n))*R1(1:n,n+1);
B1 = reshape(g(1:nx*nu),nu,nx).';
D1 = zeros(ny,nu);

if dkx(1)
   nud = sum(ft);
   Dtemp = reshape(g(nx*nu+1:n-nx),nud,ny).';
   D1(:,ft) = Dtemp;
   B1 = B1+K*D1;
end

if dkx(3)
   x0 = reshape(g(n-nx+1:end),[nx,1]);
else
   x0 = zeros(nx,1);
end

B = B1; D = D1;
