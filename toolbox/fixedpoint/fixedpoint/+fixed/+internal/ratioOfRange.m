function[ratio_of_range,lowerbound,upperbound]=ratioOfRange(T,minValue,maxValue)




    ratio_of_range=[];
    lowerbound=[];
    upperbound=[];

    if isscaledtype(T)



        [lowerbound,upperbound]=range(fi([],T));
        lowerbound=double(lowerbound);
        upperbound=double(upperbound);
        rng=upperbound-lowerbound;
        if rng==0
            rng=eps;
        end


        bias=T.Bias;
        minValue=minValue-bias;
        maxValue=maxValue-bias;
        lowerbound=lowerbound-bias;
        upperbound=upperbound-bias;
        ratio_of_range=0;





        if(lowerbound==0&&minValue<0)||(upperbound==0&&minValue>0)
            ratio_of_range=max(ratio_of_range,(abs(minValue)+rng)/rng);
        elseif(lowerbound<0&&minValue<0)||(lowerbound>0&&minValue>0)
            ratio_of_range=max(ratio_of_range,minValue/lowerbound);
        elseif(upperbound<0&&minValue<0)||(upperbound>0&&minValue>0)
            ratio_of_range=max(ratio_of_range,minValue/upperbound);
        end


        if(lowerbound==0&&maxValue<0)||(upperbound==0&&maxValue>0)
            ratio_of_range=max(ratio_of_range,(abs(maxValue)+rng)/rng);
        elseif(lowerbound<0&&maxValue<0)||(lowerbound>0&&maxValue>0)
            ratio_of_range=max(ratio_of_range,maxValue/lowerbound);
        elseif(upperbound<0&&maxValue<0)||(upperbound>0&&maxValue>0)
            ratio_of_range=max(ratio_of_range,maxValue/upperbound);
        end

    end
end
