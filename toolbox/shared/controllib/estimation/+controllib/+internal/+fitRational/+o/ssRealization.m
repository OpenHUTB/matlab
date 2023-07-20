function [A,B,C,D] = ssRealization(pVector,pIsRealVector,r,D)
%

% Get a state-space realization for the system represented with orthonormal
% basis functions constructed with poles pVector, residues r, direct term D
%
% Orthogonal basis functions are from Ninness1994_TechRep

%   Copyright 2015-2018 The MathWorks, Inc.

%#codegen
coder.allowpcode('plain');

% Preallocate
n = controllib.internal.util.indexInt(numel(pVector));
A = zeros(n,n,class(pVector));
B = zeros(n,1,class(pVector));
C = zeros(1,n,class(pVector));
F = zeros(1,n,class(pVector));
G = ones(1,1,class(pVector));

% After each iteration:
%   dx  = A(1:k,1:k) x + B(1:k,1) u
%   s_k = F(1,1:k) * x + G u
%    y  = C(1,1:k) * x + D u
% where s_{k+1} = (1-conj(p(k))*z)/(z-p(k)) * s_k
k = controllib.internal.util.indexInt(1);
while k <= n
   p = pVector(k);
   pReal = real(p);
   if pIsRealVector(k)
      % Real pole (bk=1, fk=1-pReal^2, gk=-pReal)
      for j=1:k-1
         A(k,j) = F(1,j);
         F(1,j) = -pReal*F(1,j);
      end
      A(k,k) = pReal;
      B(k,1) = G;
      C(1,k) = r(k) * sqrt(1-pReal^2);
      F(1,k) = 1-pReal^2;
      G = -pReal*G;
      k = k+1;
   else
      % Complex pair (bk=[1;0], gk=|pk|^2)
      [beta1,beta2,mu1,mu2] = controllib.internal.fitRational.o.getBetaAndMu(p);
      pAbsSq = abs(p)^2;
      tau = sqrt(1-pAbsSq);
      for j=1:k-1
         A(k,j) = F(1,j);
         F(1,j) = pAbsSq*F(1,j);
      end
      A(k,k) = 2*pReal;
      A(k+1,k) = 1;
      A(k,k+1) = -pAbsSq;
      B(k,1) = G;
      C(1,k) =  tau * (r(k)*beta1+r(k+1)*beta2);
      C(1,k+1) = tau * (r(k)*mu1+r(k+1)*mu2);
      F(1,k) = 2*pReal*(pAbsSq-1);
      F(1,k+1) = 1-pAbsSq^2;
      G = pAbsSq*G;
      k = k+2;
   end
end

% LocalWords:  Ninness