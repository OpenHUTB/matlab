function [A,b] = constructMatrices(y,u,B,Weight,Dscale,includeD,includeN,isRelaxed)
%

% Construct least-squares matrices for SK iterations
%
% Inputs:
%    y         - [Nf Ny] complex matrix
%                Nf is the # of frequency points, Ny is the of outputs
%    u         - [Nf Nu] complex matrix
%                Nu is the # of inputs
%    B         - Basis functions evaluated at Nf frequency points. 
%                [Nf Nb] matrix, Nb is the # of basis functions
%    Weight    - [Nf Ny] complex matrix
%    Dscale    - [Nf 1] complex vector
%    includeD  - Scalar boolean. Is estimating denominator parameters?
%                If yes, the first Nb columns in output A will be for
%                denominator parameters
%    includeN  - Scalar boolean. Is estimating numerator parameters?
%    isRelaxed - Scalar boolean. Is using relaxed SK iterations?
%                In the context of vector fitting, this is also called RVF 
%                If true, includeD must be true
%                isRelaxed adds one additional row to (A,b). See ref. [1]
%
% Outputs:
%    A, b matrices for the LSQ problem: minimize ||A*x-b||_2 over x
%
%    The ordering of the parameters in x are:
%        x=[D;        % Denominator, shared across all channels (if includeD=true)
%           N(1,1);   % Numerator, 1st-input to 1st-output
%           N(1,2);   % Numerator, 2nd-input to 1st-output
%           ...
%           N(1,Nu);  % Numerator, Nu-th input to 1st-output
%           N(2,1);   % Numerator, 1st-input to 2nd-output
%           ...
%           N(2,Nu);  % Numerator, Nu-th-input to 2nd-output
%           ...
%           N(Ny,Nu)] % Numerator, Nu-th-input to Ny-th-output
%
%    The structure of the matrix A (assuming includeD and includeN=true)
%           A = [Ad An]
%             = [-W(:,1).*y(:,1).*B W(:,1).*u(:,1).*B W(:,1).*u(:,2).*B         ...                             0]
%               [-W(:,2).*y(:,2).*B         0                 0         W(:,2).*u(:,1).*B W(:,1).*u(:,2).*B ... 0]
%               ...
%
% References:
%    [1] Section IV of Gustavsen, 2006 IEEE Transactions on Power Delivery,
%    "Improving the Pole Relocating Properties of Vector Fitting"

%   Copyright 2015-2018 The MathWorks, Inc.

%#codegen
coder.allowpcode('plain');
coder.internal.prefer_const(includeD, includeN, isRelaxed);

% If using relaxed algorithms, must be estimating the denominator
if isRelaxed
    assert(includeD);
end

% Helper variables
Ny = controllib.internal.util.indexInt(size(y,2)); % # of outputs
Nu = controllib.internal.util.indexInt(size(u,2)); % # of inputs
Nf = controllib.internal.util.indexInt(size(B,1)); % # of frequency points
Nb = controllib.internal.util.indexInt(size(B,2)); % # of basis fcns

% Pre-allocate
[rowSize, colSize, colOffsetD, colOffsetN] = localGetDimensions(...
    Ny, Nu, Nb, Nf, includeD, includeN, isRelaxed);
A = complex(zeros(rowSize, colSize, class(B)));
b = complex(zeros(rowSize, 1, class(B)));

% Start filling in A and b
for kkY=1:Ny
    rowIdx = (kkY-1)*Nf + (1:Nf);
    
    if includeD
        scaleVector = Weight(:,kkY) .* -y(:,kkY);
        scaleVector = scaleVector ./ Dscale;
        A(rowIdx, colOffsetD+(1:Nb)) = cast(bsxfun(@times, scaleVector, B),'like',B);
    else
        b(rowIdx) = Weight(:,kkY) .* y(:,kkY);
    end
    
    if includeN
        for kkU=1:Nu
            scaleVector = Weight(:,kkY) .* u(:,kkU);
            scaleVector = scaleVector ./ Dscale;
            A(rowIdx, (colOffsetN+(kkY-1)*Nb*Nu+(kkU-1)*Nb)+(1:Nb)) = bsxfun(@times,scaleVector,B);
        end
    end
end

% If using relaxed algorithms, set up the last row of (A,b) 
if isRelaxed
   % Eq. (8) in [1] 
   newRow = sum(B, 1, 'native');
   newRow = real(newRow);
   % Get a row scaling
   %
   % Scaling suggestion in Eq. (9) from Ref [1] is not utilized because the
   % resulting new row can have a norm much larger than the rest of the A
   % matrix. This is turn leads to inaccurate solutions.
   %
   % Given that we almost always scale the data and basis functions to have
   % magnitude around 1, just aim to make the new row have norm 1
   rScale = norm(newRow, 2);
   if ~isfinite(rScale) || rScale==cast(0, class(B))
       rScale = cast(1, class(B));
   end
   % Apply the scaling and assign
   newRow = newRow / rScale;
   A(end, colOffsetD+(1:Nb)) = newRow;
   b(end) = cast(1, class(b));
end
end

function [rowSize, colSize, colOffsetD, colOffsetN] = localGetDimensions(Ny, Nu, Nb, Nf, includeD, includeN, isRelaxed)
% Get dimensions of the least squares matrices
%
% Inputs:
%     Ny        - Number of outputs
%     Nu        - Number of inputs
%     Nb        - Number of basis functions
%     Nf        - Number of frequency points
%     includeD  - Estimate denominator parameters?
%     includeN  - Estimate numerator parameters?
%     isRelaxed - Is using relaxed algorithms (Relaxed SK iterations aka RVF)?
%
% Outputs:
%     rowSize   - Row size of the least squares matrix
%     colSize   - Col size of the least squares matrix
%     firstColD - firstColD:firstColD+Nb-1 columns of the matrix correspond 
%                 to the denominator parameters, unless firstColD=-1 which
%                 indicates that denominator parameters are not estimated
%     firstColN - firstColN:end columns of the matrix correspond to the
%                 numerator parameters

% All arguments are nontunable
coder.internal.prefer_const(Ny, Nu, Nb, Nf, includeD, includeN, isRelaxed);

% Get row dimensions
if isRelaxed
    % Relaxed algorithms has an additional row in the LSQ matrices to avoid
    % trivial zero solutions
    rowSize = Nf * Ny + controllib.internal.util.indexInt(1);
else
    rowSize = Nf * Ny;
end

% Get col dimensions
if includeD
    % Columns for the denominator parameters are placed first
    colOffsetD = controllib.internal.util.indexInt(0);
    
    if includeN
        % Estimating the denominator and the numerator
        colSize = Nb + Nb*Nu*Ny;
        colOffsetN = Nb;
    else
        % Even though this function is able to handle this case, it's not
        % currently in use.
        assert(false());
        % colSize = Nb;
        % colOffsetN = controllib.internal.util.indexInt(0);
    end
else
    % No columns for the denominator parameters
    colOffsetD = controllib.internal.util.indexInt(-1);
    
    if includeN
        % Only estimating the numerator
        colSize = Nb*Nu*Ny;
        colOffsetN = controllib.internal.util.indexInt(0);
    else
        % Nothing to do. Not a valid use case for this function
        assert(false());
    end
end
end