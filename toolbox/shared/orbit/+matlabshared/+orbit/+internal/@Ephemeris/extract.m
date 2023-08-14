function[states,newTT]=extract(TimeTable,time,interpMethod,extrap)%#codegen







    coder.allowpcode('plain');


    time=sort(unique(time));


    newTT=retime(TimeTable,time,interpMethod,"EndValues",extrap);

    if all(ismissing(newTT))


        newTT=retime(TimeTable,time,"nearest","EndValues","extrap");
    else

        newTT=fillmissing(newTT,"spline","EndValues","nearest");
    end



    states=newTT.Variables';
end
