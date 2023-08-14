function [A,B,C,D] = ssRealization(p,pIsReal,r,D)
%

% Construct a state-space realization for the transfer function represented
% in barycentric form: poles sp, residues r, direct term D:
%   D + sum_k( r*(k) / (z-sp(k)) )
%
% Inputs:
%    p \in C^n  basis poles (interpolation points)
%    pIsReal \in {false(),true()}^n, boolean vector indicating which
%            elements in p are considered real 
%    r \in R^n residues
%    D \in R^1 direct term
%
% Output:
%    sys: Minimal state space realization for the tf represented by (p,r,D)
%
% The residues are always real even if the corresponding starting pole is
% complex. Concretely, if sp(k) and sp(k+1) are a complex-conjugate pair,
% r(k) and r(k+1) hold the real and imaginary parts of r*(k) and r*(k+1):
% r*(k)=r(k)+1i*r(k+1) and r*(k+1)=r(k)-1i*r(k+1). From Appendix A,
% equations (A.5) and (A.6) of Gustavsen&Semlyen 1997 paper.

%   Copyright 2015-2020 The MathWorks, Inc.
if ~isreal(r)
    error('r must be real. see function help.')
end
n = numel(p);
A = zeros(n);
B = zeros(n,1);
C = zeros(1,n);
k = 1;
while k<=n 
   % Note: Balance norms of B,C for optimal scaling
   pk = p(k);
   if pIsReal(k)
      tau = sqrt(abs(r(k)));
      sgn = sign(r(k));
      A(k,k) = real(pk);
      B(k,1) = tau;
      C(1,k) = sgn*tau;
      k = k+1;
   else
      tau = sqrt(norm(r(k:k+1))/2);
      A(k,k) = real(pk);
      A(k,k+1) = imag(pk);
      A(k+1,k) = -imag(pk);
      A(k+1,k+1) = real(pk);
      if tau>0
         B(k,1) = 2*tau;
         C(1,k:k+1) = r(k:k+1)/tau;
      end
      k = k+2;
   end
end
% LocalWords:  sp Gustavsen Semlyen kk cbar
