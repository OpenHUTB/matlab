function [B,pIsReal] = constructBasisMatrix(p,q)
%

% Inputs:
%    p -  basis poles (interpolation points)
%    q -  [Nf 1] vector. Points on the unit disk, basis of fitting. Nf is 
%         the number of frequency points

%   Copyright 2015-2018 The MathWorks, Inc.

% Find the real poles with tolerance, with the assumption that complex
% elements in ksi come in conjugate pairs
pIsReal = controllib.internal.fitRational.findRealElements(p);

% Construct basis functions only if not performing static gain fitting
if numel(p)>0
    % B = [1 1./(q-p(1)) 1./(q-p(2)) ... 1./(q-p(n))]
    if ~isrow(p)
        p = p.'; % just change the orientation (not conjugate transpose)
    end
    % AAO: division by 0 if u contains any of the poles in sp    
    B = [ones(size(q)) 1./(q-p)];

    % Ensure that residues come in perfect conjugate pairs. From Appendix A,
    % equations (A.5) and (A.6) of Gustavsen&Semlyen 1997 paper.
    kk = 1;
    while kk < numel(p) % <: no need to check if the last pole is complex
        if pIsReal(kk)
            % real pole, move on
            kk = kk+1;
        else
            % complex pole
            %
            % complex pole sp(kk) sets the cols kk and kk+1
            v1 = B(:,kk+1);
            v2 = B(:,kk+2);
            B(:,kk+1) = v1+v2;
            B(:,kk+2) = 1i*(v1-v2);
            kk = kk+2;
        end
    end
else
    B = ones(size(q));
end
end
