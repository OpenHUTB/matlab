function [R, fail] = buildR(y,u,maxsize,nrr,ra,s1a,s2a)
%Build Hankel matrices.

% Copyright 1986-2017 The MathWorks, Inc.

[Ncap,l] = size(y); m = size(u,2); 
nele = floor(maxsize/(nrr));
assert(nele>0, 'buildR: Increase MaxSize.');

msa = max(s1a,s2a); nohanrow = msa+ra;
R = [];
H1 = zeros(nrr,nrr+min(nele,Ncap)-nohanrow+1);
z = [y, u];
nloop = floor((Ncap-nohanrow)/nele-eps)+1;
for kk = 1:nloop
   jj = 1+(kk-1)*nele:min(Ncap,kk*nele+nohanrow-1);
   Y = localBlockHankel(z(jj,1:l),nohanrow);
   if m>0
      U = localBlockHankel(z(jj,l+1:end),nohanrow);
   else
      U = [];
   end
   UF = U(m*msa+1:m*(msa+ra),:);
   UP = U(1:m*s2a,:);
   YF = Y(l*msa+1:l*(msa+ra),:);
   YP = Y(1:l*s1a,:);
   H = [UF; UP; YP; YF];
   if ~isempty(R)
      H1(:,1:min(ncR,nrr)+length(jj)-nohanrow+1) =...
         [H,R(1:min(nrR,nrr),1:min(ncR,nrr))];
   else
      H1(:,1:length(jj)-nohanrow+1) = H; ncR = 0;
   end
   
   R = triu(qr(H1(:,1:min(ncR,nrr)+length(jj)-nohanrow+1)'))';
   [nrR,ncR] = size(R);
end  %for kk


if nrR>=ncR
   error(message('Controllib:estimation:tooFewSamples'))
end
fail = 0;
R = R(:,1:nrR);

%--------------------------------------------------------------------------
function y = localBlockHankel(x,i,j)
% Construct Block Hankel Matrix.

[N,p] = size(x);
if nargin < 3, j = N-i+1; end
y = zeros(p*i,j);
for ii = 1:i
   y((ii-1)*p+1:ii*p,1:j) = x(ii:j+ii-1,:)';
end
