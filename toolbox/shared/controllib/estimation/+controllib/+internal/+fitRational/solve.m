function [x,successfulSolution] = solve(A,b,Aeq,beq,Aineq,bineq,options)
%

% Solve the least squares problem:
%
% minimize ||A*x-b||^2
%    x
% subject to Aeq*x    = beq
%            Aineq*x <= bineq
% where A, b are real- or complex-valued matrices of compatible dimensions.
% However, the returned solution x is always real-valued.
%
% It is assumed that x has (d-1)+NyNu*d parameters. The first d parameters
% belong to the shared denominator, whose first parameter is always 1. NyNu
% is the total number of I/O channels. Each numerator has d+1 parameters.
%
% Inputs:
%   A: See the minimization problem definition. Complex valued matrix.
%   b: See the minimization problem definition. Complex valued vector.
%   Aeq: See the minimization problem definition. Complex valued matrix.
%   beq: See the minimization problem definition. Complex valued vector.
%   Aineq: See the minimization problem definition. Complex valued matrix.
%   bineq: See the minimization problem definition. Complex valued vector.
%
% Outputs:
%   x: Estimated parameters. Real valued
%   successfulSolution: Scalar logical. Are the constraints satisfied?

%   Copyright 2015-2018 The MathWorks, Inc.

% Separate out the real and complex parts of (A,b),(Aeq,beq), (Aineq,bineq)
if ~isreal(A) || ~isreal(b)
    A = [real(A); imag(A)];
    b = [real(b); imag(b)];
end
if ~isreal(Aeq) || ~isreal(beq)
    Aeq = [real(Aeq); imag(Aeq)];
    beq = [real(beq); imag(beq)];
end
if ~isreal(Aineq) || ~isreal(bineq)
    Aineq = [real(Aineq); imag(Aineq)];
    bineq = [real(bineq); imag(bineq)];
end

% Clean-up rows with all 0s
[A,b,Aeq,beq,Aineq,bineq,isFeasible] = localRemoveZeroRows(A,b,Aeq,beq,Aineq,bineq);
if ~isFeasible
    x = NaN(size(A,2),1);
    successfulSolution = false();
    return;
end

% Inequality constrained problems can only be solved via idilslnsh
if ~isempty(Aineq) && ~any(strcmp(options.SolutionMethod,{'idilslnsh'}))
    options.SolutionMethod = 'idilslnsh';
end

switch options.SolutionMethod
    case {'qr','qrro'}
        if strcmp(options.SolutionMethod,'qrro')
            % Order rows before obtaining least squares solution via QR.
            % x=A\b where the rows of A and b are sorted according to the inf norm of
            % the A's rows (max(abs(A),[],2)). Suggested by Gugercin 2014.
            d = max(abs(A),[],2);
            [~,idx] = sort(d,'descend');
            A = A(idx,:);
            b = b(idx);
        end
        if isempty(Aeq)
            % Unconstrained least squares solution via QR
            x = controllib.internal.util.solveLS(A,b);
            
            % AAO: Don't call cond unless necessary. It calls svd, which is
            % practically solving the least squares problem one extra time
            if options.DisplayConditionNumber
                fprintf('cond(A): %.2e\n',cond(A));
            end
        else
            % Constrained least squares solution via two QR decompositions
            %x = localLSQESolverQRKKT(A,b,Aeq,beq);
            x = controllib.internal.fitRational.solveLSQEQR(A,b,Aeq,beq);
        end
    case 'idilslnsh'
        % [x,resnorm,residual,exitflag,output,lambda] = ...
        
        % Scale the cost matrices. These are tricks for: 
        % * lsqlin solving lsq problems via converting them to quadprog.
        % Scaling by AInfSqrt ensures the quadprog cost matrix (H=A.'*A)
        % doesn't overflow.
        % * quadprog dense interior-point alg. enforces constraints
        % relative to the inf norm of the elements of A, Aeq, Aineq.
        AInfSqrt = sqrt(norm(A(:),'inf'));
        AeqInf = norm(Aeq(:),'inf'); % max element in abs(Aeq)
        AineqInf = norm(Aineq(:),'inf'); % max element in abs(Aineq)
        if AInfSqrt~=0
            A = A/AInfSqrt;
            b = b/AInfSqrt;
        end
        AInf = AInfSqrt; % max element in abs(A)
        if ~isempty(AeqInf) && AeqInf~=0
            mScale = AInf./AeqInf;
            Aeq = Aeq * mScale;
            beq = beq * mScale;
        end
        if ~isempty(AineqInf) && AineqInf~=0
            mScale = AInf./AineqInf;
            Aineq = Aineq * mScale;
            bineq = bineq * mScale;
        end

        if options.DisplayConditionNumber
            fprintf('cond(A): %.2e\n',cond(A));
        end
        
        x = idilslnsh(A,b,...
            Aineq,bineq,...
            Aeq,beq,...
            [],[],...
            []);
    otherwise
        assert(false);
end

if nargout>1
    % Verify solution satisfies parameter bounds per absolute and relative
    % tolerances
    successfulSolution = true;
    
    if any(~isfinite(x))
        successfulSolution = false;
        return;
    end
    
    TolAbs = 1e-3;
    TolRel = 1e-3;
    eqTol = max( max(abs(beq)*TolRel), TolAbs );
    if ~isempty(Aeq) && any(abs(Aeq*x-beq)>eqTol)
        successfulSolution = false;
        return;
    end
    
    ineqTol = max( max(abs(bineq)*TolRel), TolAbs );
    if ~isempty(Aineq) && any(Aineq*x-bineq>ineqTol)
        successfulSolution = false;
        return;
    end
end

end

function x = localLSQESolverSVD(A,b,Aeq,beq) %#ok<DEFNU>
% Equality constrained LSQ solution via SVD decomposition
%
% minimize ||A*x-b||^2
%    x
% subject to Aeq*x    = beq
%
% Currently unused: For future testing and research purposes

% Economy SVD with truncation: Get U*S*V.' economy decomposition
% for [N D]. Drop appropriate rows and columns of U, S, V where
% diag(S)<tol, Then get the solution.
if isempty(Aeq)
    [u,s,v] = svd(A,'econ');
    tol = s(1,1)*1e-10; % truncation tolerance
    idx = diag(s)>tol;
    numS = nnz(idx);
    sinv = spdiags(1./diag(s(idx,idx)),0,numS,numS);
    x = v(:,idx)*sinv*u(:,idx).' * b;
else
    nConst = size(Aeq,1);
    % Approach from Lawson&Hanson 1995, Chapter 20
    [u,s,v]=svd(Aeq,0);
    s = s(1:nConst+1:nConst^2);
    tol = max(size(Aeq)) * eps(norm(s,inf));
    idx = s>tol;
    xbar = ((v(:,idx)./s(:,idx))*u(:,idx).') * beq;
    K = v(:,nnz(idx)+1:end); % Null space of Aeq
    % Solve the reduced problem
    [u,s,v] = svd(A*K,'econ');
    tol = s(1,1)*1e-10; % truncation tolerance
    idx = diag(s)>tol;
    numS = nnz(idx);
    sinv = spdiags(1./diag(s(idx,idx)),0,numS,numS);
    y2 = v(:,idx)*sinv*u(:,idx).' * (b-A*xbar);
    x = xbar + K*y2;
end
end

function [A,b,Aeq,beq,Aineq,bineq,isFeasible] = localRemoveZeroRows(A,b,Aeq,beq,Aineq,bineq)
% Clean-up all-zero rows
% * (A,b): If a row of A is all zeros, remove that row from both (A,b).
% These rows capture the points where we cannot reduce the error.
% * (Aeq,beq): If a row of Aeq is all zeros, then the same rows in beq must
% be zeros. If this is true, remove these rows. Otherwise, the problem is
% infeasible.
% * (Aineq,bineq): If a row of Aineq is all zeros, bineq must be
% non-negative. If this is true, remove these rows. Otherwise, the problem
% is infeasible.
isFeasible = true();

% (A,b)
numRows = size(A,1);
idxNonZero = any(A,2); % indices of non-zero rows
if nnz(idxNonZero)~=numRows 
    % There are 0 rows. Eliminate those, cannot reduce the error there
    A = A(idxNonZero,:);
    b = b(idxNonZero);
end

% (Aeq,beq)
if ~isempty(Aeq)
    numRows = size(Aeq,1);
    idxNonZero = any(Aeq,2); % indices of non-zero rows
    if nnz(idxNonZero)~=numRows 
        % There are 0 rows. Make sure those rows have 0 RHS (beq)
        if all(beq(~idxNonZero)==0)
            % RHS is also 0. The constraints are trivially satisfied
            Aeq = Aeq(idxNonZero,:);
            beq = beq(idxNonZero,:);
        else
            % Impossible to satisfy the constraints
            isFeasible = false();
            return;
        end
    end
end

% (Aineq,bineq)
if ~isempty(Aineq)
    numRows = size(Aineq,1);
    idxNonZero = any(Aineq,2); % indices of non-zero rows
    if nnz(idxNonZero)~=numRows
        % There are 0 rows. Make sure those rows have non-negative RHS (bineq)
        if all(bineq(~idxNonZero)>=0)
            % RHS is non-negative. The constraints are trivially satisfied
            Aineq = Aineq(idxNonZero,:);
            bineq = bineq(idxNonZero,:);
        else
            % Impossible to satisfy the constraints
            isFeasible = false();
            return;
        end
    end
end
end

% % Scale the rows and columns of the LSQ matrices
% if options.LSScalingL || options.LSScalingR
%         S1 = geomean(abs(Z))';
%         ix =find(S1==0);
%         S1(ix) = mean(abs(Z(:,ix)));
%     L1 = max(abs(Z),[],2);
%     R1 = max(abs(diag(L1)\Z))';
%
%     R2 = max(abs(Z))';
%     L2 = max(abs(Z/diag(R2)),[],2);
%
%     if options.LSScalingL
%         L = sqrt(L1.*L2);
%     else
%         L=1;
%     end
%     if options.LSScalingR
%         R = sqrt(R1.*R2);
%     else
%         R = 1;
%     end
%     Z = diag(L)\(Z/diag(R));
% end
%
% Revert the scaling
%if options.LSScalingL || options.LSScalingR
%    x = x./R;
%end
