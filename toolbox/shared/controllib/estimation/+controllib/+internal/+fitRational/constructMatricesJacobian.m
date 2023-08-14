function [M,b] = constructMatricesJacobian(y,u,B,Weight,lastN,lastD,lastB)
%

% [M,b] = constructMatricesJacobian(y,u,B,lastN,lastD,Weight,lastB)
%
% Denote our cost fcn as f(x). Construct a linear approximation to the
% f(x)'s jacobian  such that (df/dx evaluated at x) is approximately (M*x).
%
% The approximation M*x is for the scaled f(x), y, u, Weight. Hence the
% results from this function would match perfectly with df/dx only when
% the abovementioned variables are not scaled.
%
% lastD = B*dp.'; 
% lastN = {B*np{1,1}.',B*np{1,2}.',B*np{1,3}.'};
% M = localConstructLSQMatricesIV(y,u,B,lastN,lastD,Weight,B);
% x = [dp.'; np{1,1}.';np{1,2}.';np{1,3}.'];
% J = controllib.internal.fitRational.costFcnJacobian(dp,np,y,u,B,Weight,[1 1 1]);
% [J./(M*x)] % must be = 1

%   Copyright 2015-2016 The MathWorks, Inc.
[Nf,Ny] = size(y); % # of frequency points and the output channels
Nu = size(u,2); % # of input channels
Nb = size(B,2); % # of basis fcns

Bu = zeros(Nf,Nu*Nb);
for kkU=1:Nu
    Bu(:,(kkU-1)*Nb+(1:Nb)) = u(:,kkU) .* B;
end

M11 = zeros(Nf,Nb); % (Ny*Nu+1)*Nb is # of estimated params
M12 = zeros(Nf,(Ny*Nu)*Nb);
M21 = cell(Nu,1);
M22 = cell(Nu,1);
for kkY=1:Ny
    nMult = (abs(Weight(:,kkY)).^2 ./ conj(lastD) ./ lastD);
    dMult = zeros(size(nMult));
    for kkU=1:Nu
        dMult = dMult + u(:,kkU).*lastN{kkY,kkU};
    end
    dMult = conj(dMult./lastD).*nMult;

    M11 = M11 - (dMult.*y(:,kkY)) .* B;
    M12(:,(kkY-1)*Nu*Nb+(1:Nu*Nb)) = dMult.*Bu;
    
    M21{kkY} = zeros(Nu*Nb,Nb);
    M22{kkY} = zeros(Nu*Nb,Nu*Nb);
    for kkU=1:Nu
        M21{kkY}((kkU-1)*Nb+(1:Nb),:) = 2 * real( lastB' * ((conj(u(:,kkU)) .* nMult .* -y(:,kkY)) .* B) );
        M22{kkY}((kkU-1)*Nb+(1:Nb),:) = 2 * real( lastB' * ((conj(u(:,kkU)) .* nMult) .* Bu) );
    end
end
M11 = -2 * real(lastB' * M11);
M12 = -2 * real(lastB' * M12);
M = [M11 M12; vertcat(M21{:}) blkdiag(M22{:})];
b = zeros(size(M,1),1);
end