function [B,ksiIsReal] = constructBasisMatrix(ksi,q)
%

% Construct orthogonal rational basis functions on unit disk
%
% Inputs:
%    ksi - Np-element vector, basis poles (interpolation points)
%    q   - Nf-element vector, points on the unit disk (frequency grid)
%
% Outputs:
%    B         - [Nf Np+1] basis matrix
%    ksiIsReal - [Np 1] vector. Indicates which elements in ksi were
%                considered to be real for constructing B
%
% Reference: NinnessGustafsson_1994TechRep A Unifying Construction Of
% Orthonormal Bases For system Identification
%
% z in the paper is denoted as q
% ksi_n in paper is denoted as ksi(n)

%   Copyright 2015-2018 The MathWorks, Inc.

%#codegen
coder.allowpcode('plain'); 

%% Validate assumptions
assert(isvector(ksi));
assert(iscolumn(q));
assert(all(abs(ksi)<1));

%% Construction

% Pre-allocation. The first column of B is just 1s
B = complex(ones(numel(q), numel(ksi)+1, class(q)));

% Find the real poles with tolerance, with the assumption that complex
% elements in ksi come in conjugate pairs
ksiIsReal = controllib.internal.fitRational.findRealElements(ksi);

% Quick return if performing static gain fitting (no basis poles)
if numel(ksi)==0
    return;
end

% AAO: use d=1 to get proper basis functions instead of strictly proper ones?

% Two-pass construction:
% 1) Use Eq. (16) to construct an initial set of basis vectors
% 2) Look for bases corresponding to complex-conjugate poles. Replace them
% using Eq. (15)
%
% First pass: The equation right above Eq. (16) in the paper

% The first column of B is just 1. Start construction from column 2
realONE = cast(1,class(q)); 
B(:,2) = realONE ./ (q-ksi(1));
for kk=2:numel(ksi)
    B(:,kk+1) = (realONE-conj(ksi(kk-1))*q) ./ (q-ksi(kk)) .* B(:,kk);
end
% Apply column scaling
%
% Implicit expansion version
% assert(isrow(ksi));
% B = B.*[realONE sqrt(realONE-abs(ksi).^2)];
% Version with loop, for code generation
for kk=2:numel(ksi)+1
    columnScaling = sqrt(realONE-abs(ksi(kk-1))^2);
    B(:,kk) = columnScaling * B(:,kk);
end

% Non-uniform sampling of frequency points leads to column lengths
% differ from 1. We can scale them. This scaling must also be
% incorporated in the ssRealization code.
%
% Bc = zeros(1,numel(sp));
% B(:,1) = 1 ./ (u-sp(1));
% Bc(1) = norm(B(:,1));
% for kk=2:numel(sp)
%     B(:,kk) = (1-conj(sp(kk-1))*u) ./ (u-sp(kk)) .* B(:,kk-1);
%     Bc(kk) = norm(B(:,kk));
% end
% B = B./Bc;
% Bc = sqrt(1-abs(sp).^2).*Bc;

% Second pass: Find bases corresponding to complex-conjugate pole pairs,
% replace them with using Eq. (15)
kk = controllib.internal.util.indexInt(1);
while kk < numel(ksi)
    if ksiIsReal(kk)
        % real pole. move on.
        kk = kk+1;
    else
        % complex pole-pair
        ksiConj = conj(ksi(kk));
        oneMinusKsiConjSquared = realONE - ksiConj^2;
        % Solution of Eq. (17) with the assumption beta=mu.
        [beta1,beta2,mu1,mu2] = controllib.internal.fitRational.o.getBetaAndMu(ksi(kk));
        % Get c0, c1, c0Prime, c1Prime from the Eq following (16) that
        % relates beta,mu to these.
        c0 = (beta1+ksiConj*mu1)/oneMinusKsiConjSquared;
        c1 = (ksiConj*beta1+mu1)/oneMinusKsiConjSquared;
        c0Prime = (beta2+ksiConj*mu2)/oneMinusKsiConjSquared;
        c1Prime = (ksiConj*beta2+mu2)/oneMinusKsiConjSquared;
        % Eq (15)
        % The columns kk+1 and kk+2 of B correspond to the complex
        % conjugate poles [ksi(kk) ksi(kk+1)]
        B1 = B(:,kk+1);
        B2 = B(:,kk+2);
        B(:,kk+1) = c0*B1 + c1*B2;
        B(:,kk+2) = c0Prime*B1 + c1Prime*B2;
        kk = kk+2;
    end
end
end


