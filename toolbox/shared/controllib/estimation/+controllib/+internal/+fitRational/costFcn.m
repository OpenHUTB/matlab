function J = costFcn(dp,np,y,u,B,Weight,scaleStruct)
%

%   Copyright 2015-2016 The MathWorks, Inc.
[Ny,Nu] = size(np);
J = 0;

den = B*dp.';
den(den==0) = eps;
for kkY=1:Ny
    e = -y(:,kkY);
    for kkU=1:Nu
        e = e + (B*np{kkY,kkU}.')./den .* u(:,kkU);
    end
    e = Weight(:,kkY) .* e;
    J = J + (norm(e)*scaleStruct.Weight*scaleStruct.Y(kkY))^2;
end
% Other nonlinear cost function ideas?
% J = log(WW .* abs((N*np ./ (1+D*dp)) - z)); % Idea: Put WW outside log()?
% J =  WW .* abs( log(N*np ./ (1+D*dp)) - log(z) ); % Note: WW is omitted!
end