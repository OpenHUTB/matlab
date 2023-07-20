function c=checkRuralMinDistance(data,params)





    vMode=data.v(data.opMode=='rural');
    d=sum(vMode)*params.dt;
    c=params.RuralMinDistance-d;
end
