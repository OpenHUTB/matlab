function c=checkUrbanMinDistance(data,params)





    vMode=data.v(data.opMode=='urban');
    d=sum(vMode)*params.dt;
    c=params.UrbanMinDistance-d;
end
