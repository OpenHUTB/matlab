function [J,Jd,Jn] = costFcnJacobian(d,n,y,u,B,Weight,scaleStruct)
%

% Analytical jacobian for the costFcn.m

%   Copyright 2015-2016 The MathWorks, Inc.
[Ny,Nu] = size(n);
Np = numel(d); % # of parameters in each den and num
Jn = zeros(Np,Nu,Ny);
Jd = zeros(numel(d),1);
den = (B*d.');
den(den==0) = eps;
num = zeros(size(B,1),Nu);
for kkY=1:Ny
    e = -y(:,kkY);
    for kkU=1:Nu
        num(:,kkU) = B*n{kkY,kkU}.';
        e = e + num(:,kkU)./den.*u(:,kkU);
    end
    conje = conj(e);
    for kkU=1:Nu
        scaling = (scaleStruct.Weight * scaleStruct.Y(kkY))^2;
        absWeightSqTimesU = abs(Weight(:,kkY)).^2 .* u(:,kkU);
        Jn(:,kkU,kkY) = 2 * scaling * ...
            sum(real( B.*(absWeightSqTimesU./den.*conje))).';
        Jd = Jd - 2 * scaling * ...
            sum(real( B.*(absWeightSqTimesU.*(num(:,kkU))./(den.^2)).*conje)).';
    end
end
J = [Jd; Jn(:)];
end