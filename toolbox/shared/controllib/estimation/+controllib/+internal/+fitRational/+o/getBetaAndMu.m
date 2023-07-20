function [beta1,beta2,mu1,mu2] = getBetaAndMu(p)
%

% Ninness94_TechRep provides a way to generate real-coefficient orthogonal
% basis functions for complex-conjugate pole pairs. There are infinite
% choices for the coefficients of these basis functions.
%
% This is used when:
% -Constructing the basis functions and when
% -Forming the identified system
% The same beta and mu must be used for these 2 tasks

%   Copyright 2015-2020 The MathWorks, Inc.

%#codegen
coder.allowpcode('plain');
pReal = real(p);
pAbsSq = abs(p)^2;
% Compute x,y such that x'*M*x=y'*M*y=|1-p^2|^2, y'*M*x=0, and x'*y=0.
[u,d] = schur([1+pAbsSq 2*pReal;2*pReal 1+pAbsSq]);
x = sqrt(d(2,2))*u(:,1);
y = sqrt(d(1,1))*u(:,2);
beta1 = x(1);  mu1 = x(2);
beta2 = y(1);  mu2 = y(2);

% M = [1+pAbsSq 2*pReal;2*pReal 1+pAbsSq];
% [p abs(p)-1]
% [x,y]
% abs([[x'*M*x y'*M*y]-abs(1-p^2)^2 x'*y x'*M*y])