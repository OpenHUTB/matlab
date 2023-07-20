function V = arxstruc(z,nn)
%Compute loss functions for families of ARX-models.

% Copyright 1986-2017 The MathWorks, Inc.

[Ncap,nz] = size(z);
nu = nz-1;
IsReal = isreal(z);
nm = size(nn,1);

% Fix the orders for frequency domain data with the extra "initial" inputs
nnorig = nn;
[nmorig,nlorig] = size(nnorig);

if nz>1
   na = nn(:,1); nb = nn(:,2:1+nu); nk = nn(:,2+nu:1+2*nu);
else
   na = nn(:,1); nb = zeros(nm,1); nk = zeros(nm,1);
end

nma = max(na);
if nu>0
   nbkm = max(nb+nk,[],1)-ones(1,nu);
   nbord = nb-(nk==0); nbkm2 = max(nbord,[],1);
else
   nbkm = 0; nbkm2 = 0;
end

nkm = min(nk,[],1);
n = nma+sum((nbkm-nkm))+nu;
if nn==0, return, end

% *** construct regression matrix ***
nnm = max(max(na+ones(nm,1)), max(nbkm2));
jj = nnm:Ncap;
phi = zeros(length(jj),n);

for kl = 1:nma
   phi(:,kl) = -z(jj-kl,1);
end
ss = nma;
for ku = 1:nu
   nnkm = nkm(ku);
   nend = nbkm(ku)+nnkm;
   
   for kl = nnkm:nend
      I = jj>kl;
      phi(I,ss+kl+1-nnkm) = z(jj(I)-kl,ku+1);
      
   end
   ss = ss+nend-nnkm+1;
end

v1 = z(nnm+1:Ncap,1)'*z(nnm+1:Ncap,1);
R = phi'*phi;
F = phi'*z(jj,1);

V = zeros(nlorig+1,nmorig);
jj = 0;
for j = 1:nm
   estparno = na(j)+sum(nb(j,:));
   if estparno>0
      jj = jj+1;
      s = 1:na(j);
      rs = nma;
      for ku = 1:nu
         s = [s,rs+nk(j,ku)-nkm(ku)+1:rs+nb(j,ku)+nk(j,ku)-nkm(ku)];
         rs = rs+nbkm(ku)-nkm(ku)+1;
      end
      
      RR = R(s,s);
      FF = F(s);
      if IsReal
         RR = real(RR); FF = real(FF);
      end
      
      TH = pinv(RR)*FF;
      V(1,jj) = (v1-FF'*TH)/Ncap;
      V(1,jj) = max(V(1,jj),eps);
      V(2:nlorig+1,jj) = nnorig(j,:)';
   end
end

V(1,jj+1) = Ncap;
V(2,jj+1) = v1/Ncap;
V = V(:,1:jj+1);
V = real(V);
