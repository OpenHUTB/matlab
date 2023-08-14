function K = estimateK(R1,R2,Un,n,ny,nu,ra,s1a,s2a,A,C)
% Estimate K.

% Copyright 1986-2017 The MathWorks, Inc.

hl1 = R2(ny+1:ra*ny,1:nu*(s2a+ra)+ny*s1a+ny);
hl2 = [R2(1:ra*ny,1:nu*(s2a+ra)+ny*s1a) zeros(ra*ny,ny)];
vl = [Un(1:(ra-1)*ny,1:n)\hl1;R2(1:ny,1:nu*(s2a+ra)+ny*s1a+ny)];
hl = [Un(:,1:n)\hl2  ;[R1 zeros(nu*ra,(nu*s2a+ny*s1a)+ny)]];

K = vl*pinv(hl);
W = (vl - K*hl)*(vl-K*hl)';

% Q,R,S matrices
Q = W(1:n,1:n);
S = W(1:n,n+1:n+ny);
R = W(n+1:n+ny,n+1:n+ny);

% DARE replacement.
a = A'; b = C';
Q = Q-S/R*S';
a1 = a-b/R*S';
n = size(a,1);

try
   [v,d] = eig([a1+b/R*b'/a1'*Q  -b/R*b'/a1'; -a1'\Q  pinv(a1)']);
   d = diag(d);
   [~,I] = sort(abs(d)); % sort on magnitude of eigenvalues
   chi = v(1:n,I(1:n));
   lambda = v((n+1):(2*n),I(1:n));
   s = real(lambda/chi)';
   K = (a'*s*b+S)/(b'*s*b+R);
catch
   K = zeros(n,ny);
   warning(message('Controllib:estimation:KestFailed'))
end

if any(~isfinite(K(:)))
   K = zeros(n,ny);
   warning(message('Controllib:estimation:KestFailed'))
end
