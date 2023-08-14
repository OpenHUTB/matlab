function steer=SteerTransitionControl(driftDirection,beta,maxSteer)
%#codegen
    coder.allowpcode('plain');








    betaTar=0;

    steerRatio=9;

    steer=((driftDirection==-1).*((maxSteer).*(beta<betaTar)+0.*(beta>=betaTar))...
    +(driftDirection==+1).*((maxSteer).*(beta>betaTar)+0.*(beta<=betaTar))).*steerRatio;
