function c=checkUrbanAverageSpeed(data,params)





    vMode=data.v(data.opMode=='urban');
    c=RDE.functions.constraintInsideBounds(mean(vMode),params.UrbanAverageSpeedRange(1),params.UrbanAverageSpeedRange(2));
end