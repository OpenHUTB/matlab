function [x, isSingular, xCovSqrt, A, b, Aeq, beq] = solveLSQEQR(A,b,Aeq,beq,calculateCovarianceSqrt)
%

%   Copyright 2018 The MathWorks, Inc.

% Solve equality constrained linear least-squares problem (LSQE) via QR
%     minimize ||A*x-b|| over x subject to Aeq*x=beq
%
% Assumptions:
% * All (A,b,Aeq,beq) must be either double or single
% * All (A,b,Aeq,beq) must be real-valued
% * (b, beq) must have only one column
% * (Aeq,beq) pair is feasible. No errors are thrown if this is violated
%
% Notes:
% * If calculateCovarianceSqrt=true, then E[x*x']=xCovSqrt*xCovSqrt'.
% If calculateCovarianceSqrt=false, then xCovSqrt=-1
% * Use the output arguments (A,b,Aeq,beq) to avoid copies in codegen
%
% References: 
%  [1] Lawson&Hanson, 1995, Chapter 20
%  [2] NASA Technical Memorandum 33-807, 1976, The Covariance Matrix for 
%      the Solution Vector of an Equality-Constrained Least-Squares Problem

%#codegen
coder.allowpcode('plain');
coder.columnMajor;
if nargin < 5
    calculateCovarianceSqrt = false();
else
    coder.internal.prefer_const(calculateCovarianceSqrt);
end

% Quick solution if there are no constraints
if isempty(Aeq) || isempty(beq)
    % Ensure both are empty simultaneously
    assert(isempty(Aeq) && isempty(beq));
    % Solve
    [x,isSingular,~,xCovSqrt,A,b] = controllib.internal.util.solveLS(A, b, calculateCovarianceSqrt);
    return;
end

% Validate the assumptions
% * Only single column unknowns and constraints are supported
%
% Unchecked assumptions:
% * (Aeq, beq) is feasible
localValidateInputs(A,b,Aeq,beq);

% Calculate pseudo-inverse and right null space of Aeq via QR
[Q,R,e] = qr(Aeq','vector');
beq = beq(e); % permute beq like columns on transpose(Aeq)

% Determine row rank of Aeq
tol = getToleranceR(R);
rowRankAeq = controllib.internal.util.indexInt(0); % m=rowRankAeq
while rowRankAeq<size(R,2) && abs(R(rowRankAeq+1,rowRankAeq+1))>tol
    rowRankAeq = rowRankAeq + 1;
end

if isempty(coder.target)
    % Get a solution to Aeq*x=beq from transpose(Aeq)'s QR
    beq(1:rowRankAeq,:) =  (R(1:rowRankAeq,1:rowRankAeq)')\beq(1:rowRankAeq,:);
    x = Q(:,1:rowRankAeq)*beq(1:rowRankAeq,:); % (xbar,Q1) in the reference is (x,Q(:,1:rowRankAeq)) here
    
    % Q2, denoted as K here, is an orthonormal basis for Aeq's right null
    % space. Extract K, then solve the reduced problem
    K = Q(:,rowRankAeq+1:end);
    [xbar, isSingular,~,xCovSqrt,A,b] = controllib.internal.util.solveLS(A*K,b-A*x,calculateCovarianceSqrt);
    x = x + K*xbar;
    if calculateCovarianceSqrt
        % K*xCovSqrt is a valid square-root for the covariance matrix even
        % though it's not square. Zero-padding is for consistency with code
        % generation, where fixed-size matrices are utilized
        xCovSqrt = [K*xCovSqrt zeros(numel(x),numel(x)-size(xCovSqrt,2),'like',A)];
    end
else
    indexONE = controllib.internal.util.indexInt(1);
    
    % beq(1:rowRankAeq,:) =  (R(1:rowRankAeq,1:rowRankAeq)')\beq(1:rowRankAeq,:);
    beq = controllib.internal.util.xtrsm('L', 'U', 'T', 'N', cast(1,'like',A), R, beq, rowRankAeq);
    % x = Q(:,1:rowRankAeq)*beq(1:rowRankAeq,:)
    x = zeros(size(A,2),size(beq,2),'like',A);
    x = controllib.internal.util.xgemm('N', 'N',...
        Q, [indexONE size(Q,1)], [indexONE rowRankAeq], ...
        beq, [indexONE rowRankAeq], [indexONE size(beq,2)], ...
        x);
    
    % Replacement for
    %   K = Q(:,rowRankAeq+1:end);
    %   [xbar, isSingular] = controllib.internal.fitRational.solveLS(A*K,b-A*x);
    % via
    %   K = Q(:,rowRankAeq+1:end);
    %   b = b - A*x;
    %   A(:,1:size(K,2)) = A*K;
    %   A(:,size(K,2)+1:end) = 0;
    %   [xbar, isSingular] = controllib.internal.fitRational.solveLS(A, b);
    b = controllib.internal.util.xgemm('N', 'N',...
        A, [indexONE size(A,1)], [indexONE size(A,2)], ...
        x, [indexONE size(x,1)], [indexONE size(x,2)], ...
        b, indexONE, indexONE, ...
        -ones('like',x), ones('like',x)); % b - A*x
    A = controllib.internal.util.xgemm('N', 'N',...
        A, [indexONE size(A,1)], [indexONE size(A,2)], ...
        Q, [indexONE size(Q,1)], [rowRankAeq+1 size(Q,2)], ...
        A); % A*K=A*Q(:,rowRankAeq+1:end) is stored in A's first rowRankA columns
    % Cannot use column indexing in A per fixed-size code generation
    % requirement. coder.internal.qrsolve and coder.internal.lapack.xgeqp3
    % do not allow operating on sub-matrices.
    % * Zero out the extra columns on A, solve with the whole A matrix. For
    % most problems of interest rowRankAeq is small (limited waste).
    % * Covariance calculations in solveLS should be skipped (third
    % argument false()) since it will be all Infs due to 0 columns.
    % Returned A's upper triangle will have the necessary information to
    % calculate what's needed here
    ZERO = zeros('like',A);
    ONE = ones('like',A);
    for kkC = size(A,2)-rowRankAeq+indexONE:size(A,2)
        A(:,kkC) = ZERO;
    end
    [xbar,~,rankA,~,A,b,jpvt] = controllib.internal.util.solveLS(A,b,false());
    isSingular = rankA ~= size(A,2)-rowRankAeq;
    % Calculate square-root of the covariance of x, if requested
    if calculateCovarianceSqrt
        xCovSqrt = zeros(size(A,2),'like',A);
        if isSingular
            xCovSqrt(:) = inf('like',A);
        else
            % Calculate covariance
            for kkC = 1:rankA
                for kkR = 1:kkC
                    xCovSqrt(kkR, kkC) = ONE;
                end
            end
            xCovSqrt = controllib.internal.util.xtrsm('L', 'U', 'N', 'N', cast(1,'like',A), A, xCovSqrt, rankA, rankA);
            xCovSqrt(jpvt,:) = xCovSqrt;
        end
    end
    
    % x = x + K * xbar;
    % xCov = K * xbarCholCov
    x = controllib.internal.util.xgemm('N', 'N',...
        Q, [indexONE size(Q,1)], [rowRankAeq+indexONE size(Q,2)], ...
        xbar, [indexONE size(Q,2)-rowRankAeq], [indexONE size(xbar,2)], ...
        x, indexONE, indexONE, ...
        ones('like',x), ones('like',x));
    if calculateCovarianceSqrt
        xCovSqrt = controllib.internal.util.xgemm('N', 'N',...
            Q, [indexONE size(Q,1)], [rowRankAeq+indexONE size(Q,2)], ...
            xCovSqrt, [indexONE size(Q,2)-rowRankAeq], [indexONE size(xCovSqrt,2)], ...
            xCovSqrt);
    end
end

% Debug
% fprintf('cond(A*K): %.2e\n',cond(A*K));
end

function tol = getToleranceR(R)
epsR = eps(class(R));
scale = min( sqrt(epsR), epsR * 10 * cast(max(size(R)), 'like', epsR));
tol = scale*abs(R(1));
end

function localValidateInputs(A,b,Aeq,beq)
% All inputs must be real-valued
% * All complex-valued case is handled by the algorithm as well, but is
% untested
% * Mix of real- and complex-valued matrices is not supported
assert(isreal(A) && isreal(b) && isreal(Aeq) && isreal(beq));
% Validate dimensions
assert(size(A,1)==size(b,1));
assert(size(Aeq,1)==size(beq,1));
% Only single column unknown vectors are supported as of now
assert(size(b,2)==1);
assert(size(beq,2)==1);
end

% function x = localLSQESolverQRKKT(A,b,Aeq,beq) %#ok<DEFNU>
% % Equality constrained least squares solution via two QRs
% %
% % minimize ||A*x-b||^2 over x subject to Aeq*x  = beq
% %
% % This solution approach assumes Aeq is right invertible.
% %
% % Currently unused: For future testing and research purposes. Before using
% % this for general release, likely the \ operator must be replaced with
% % linsolve (g1671531).
%
% % AAO: Optimize memory usage by eliminating the variables Q1,
% % Q2. These are already in Q. Transpose operations can be
% % optimized as well.
% % AAO: Check for the assumptions:
% % A1) [A; Aeq] is left invertible (rank([A;Aeq])=size(A,2))
% % A2) Aeq is right invertible (rank(Aeq)=size(Aeq,1))
% nConst = size(Aeq,1);
% [Q,R] = qr([A; Aeq],0);
% Q1 = Q(1:end-nConst,:);
% Q2 = Q(end+1-nConst:end,:);
% [Qtilde,Rtilde] = qr(Q2.',0);
%
% % uu = (Rtilde.')\beq;
% % cc = Qtilde.' * Q1.' * b - uu;
% % ww = Rtilde\cc;
% % yy = Q1.' * b - Q2.' * ww;
% % x = R\yy;
% %Exact same approach, inlined
% x = R\(b.'*Q1-(Rtilde\((Q1*Qtilde).'*b-(Rtilde.')\beq)).'*Q2).';
% end

% LocalWords:  controllib qrsolve lapack xgeqp
