function [M, logMScale] = getMapPolynomialCoefficients(pOrder,pVariable,basisFcnType,basisFcnPoles,mapParams)
%

% fitRational parametrizes rational functions differently than the standard
% numerator/denominators expressed as simple polynomials. Differences:
%
% * fitRational uses a 'half place to disk' or 'disk to disk' mapping
% * fitRational may not use monomials as basis functions, but instead use
% barycentric or orthogonal barycentric basis functions
%
% Parametrization in fitRational and numerator/denominator polynomial
% coefficients are related via a linear map: xPoly = Mbar * xFitRational
% where Mbar = diag(exp(logMScale)) * M. This mapping is used when user
% specifies constraints on the transfer function coefficients.

%   Copyright 2018 The MathWorks, Inc.

%#codegen
coder.allowpcode('plain');

assert(isscalar(pOrder) && isnumeric(pOrder) && fix(pOrder)==pOrder);

switch pVariable
    case 's'
        [M, logMScale] = localGetMapS(pOrder,basisFcnType,basisFcnPoles,mapParams);
    case 'z'
        [M, logMScale] = localGetMapZ(pOrder,basisFcnType,basisFcnPoles,mapParams);
    otherwise
        assert(false);
end
end

function [M,logMScale] = localGetMapS(pOrder,basisFcnType,basisFcnPoles,mapParams)
alphaTest = 0.3;
% Choose s on the unit disk, calculate z
s = exp(1i*2*pi/(pOrder+1)*(0:pOrder).');
q = (alphaTest+s)./(alphaTest-s);
switch basisFcnType
    case 'OVF'
        assert(pOrder==numel(basisFcnPoles));
        assert(iscolumn(basisFcnPoles));
        A = controllib.internal.fitRational.o.constructBasisMatrix(basisFcnPoles,q);
        Binv = controllib.internal.fitRational.evaluatePolynomial(basisFcnPoles,q).*(alphaTest-s).^pOrder;
    case 'VF'
        assert(pOrder==numel(basisFcnPoles));
        assert(iscolumn(basisFcnPoles));
        A = controllib.internal.fitRational.b.constructBasisMatrix(basisFcnPoles,q);        
        Binv = controllib.internal.fitRational.evaluatePolynomial(basisFcnPoles,q).*(alphaTest-s).^pOrder;
    case 'SP'
        A = controllib.internal.fitRational.sp.constructBasisMatrix(q,pOrder);
        Binv = (alphaTest-s).^pOrder;
    otherwise
        assert(false);
end
C = controllib.internal.fitRational.sp.constructBasisMatrix(s,pOrder)/(pOrder+1);
% C is orthogonal, with C*C'=eye/(pOrder+1). No need for C\(A.*Binv)
M = C'*bsxfun(@times,A,Binv);
M = real(M);
% Need to scale back to the original alpha we used for bilinear
% mapping. This can lead to overflows. Just keep the log of the scale
% factor we need on the rows of the map M. Do the scaling in the end.
%
% M = M.*(mapParams.alpha/alphaTest).^((0:d).');
logMScale = (0:pOrder).' * log(mapParams.alpha/alphaTest); % can overflow with large d and mapParams.alpha/alphaTest
end

function [M,logMScale] = localGetMapZ(pOrder,basisFcnType,basisFcnPoles,mapParams)
% Choose z on the unit disk, calculate q
z = exp(1i*2*pi/(pOrder+1)*(0:pOrder).');
q = (z+mapParams.b)./(mapParams.b*z+1);
switch basisFcnType
    case 'OVF'
        assert(pOrder==numel(basisFcnPoles));
        assert(iscolumn(basisFcnPoles));
        A = controllib.internal.fitRational.o.constructBasisMatrix(basisFcnPoles,q);
        Binv = controllib.internal.fitRational.evaluatePolynomial(basisFcnPoles,q).*(mapParams.b*z+1).^pOrder;
    case 'VF'
        assert(pOrder==numel(basisFcnPoles));
        assert(iscolumn(basisFcnPoles));
        A = controllib.internal.fitRational.b.constructBasisMatrix(basisFcnPoles,q);
        Binv = controllib.internal.fitRational.evaluatePolynomial(basisFcnPoles,q).*(mapParams.b*z+1).^pOrder;
    case 'SP'
        A = controllib.internal.fitRational.sp.constructBasisMatrix(q,pOrder);
        Binv = (mapParams.b*z+1).^pOrder;
    otherwise
        assert(false);
end
C = controllib.internal.fitRational.sp.constructBasisMatrix(z,pOrder)/(pOrder+1);
% C is orthogonal, with C*C'=eye/(pOrder+1). No need for C\(A.*Binv)
M = C'*bsxfun(@times,A,Binv); 
M = real(M);
% Skip row scaling in the discrete case. log(1)=0
logMScale = zeros(pOrder+1,1);
end