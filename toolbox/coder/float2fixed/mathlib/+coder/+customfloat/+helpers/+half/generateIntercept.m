%#codegen






function obj=generateIntercept(func)
    coder.allowpcode('plain');

    if strcmp(func,'sin')
        Subintervals=coder.customfloat.helpers.half.generateEquidistantSubintervals(func);
        LinearApproxSlope=coder.customfloat.helpers.half.generateSlope(func);
        SubintervalsDouble=double(Subintervals);
        LinearApproxSlopeDouble=double(LinearApproxSlope);
        TableLength=length(Subintervals)-1;
        InterceptTable=coder.nullcopy(fi(zeros(TableLength,1),0,16,15));
        for i=1:TableLength
            InterceptTable(i)=fi(sin(SubintervalsDouble(i))-LinearApproxSlopeDouble(i)*SubintervalsDouble(i)*2/pi,0,16,15);
        end
    elseif strcmp(func,'cos')
        Subintervals=coder.customfloat.helpers.half.generateEquidistantSubintervals(func);
        LinearApproxSlope=coder.customfloat.helpers.half.generateSlope(func);
        SubintervalsDouble=double(Subintervals);
        LinearApproxSlopeDouble=double(LinearApproxSlope);
        TableLength=length(Subintervals)-1;
        InterceptTable=coder.nullcopy(fi(zeros(TableLength,1),0,16,15));
        for i=1:TableLength-1
            InterceptTable(i)=fi(cos(SubintervalsDouble(i))-LinearApproxSlopeDouble(i)*SubintervalsDouble(i)*2/pi,0,16,15);
        end


        InterceptTable(end)=fi(sin(SubintervalsDouble(1))-LinearApproxSlopeDouble(end)*SubintervalsDouble(1)*2/pi,0,16,15);
    elseif strcmp(func,'tan')
        Subintervals=coder.customfloat.helpers.half.generateEquidistantSubintervals(func);
        LinearApproxSlope=coder.customfloat.helpers.half.generateSlope(func);
        SubintervalsDouble=double(Subintervals);
        LinearApproxSlopeDouble=double(LinearApproxSlope);
        TableLength=length(Subintervals)-1;
        InterceptTable=coder.nullcopy(fi(zeros(TableLength,1),1,17,15));
        for i=1:TableLength
            InterceptTable(i)=fi(tan(SubintervalsDouble(i))-LinearApproxSlopeDouble(i)*SubintervalsDouble(i)*4/pi,1,17,15);
        end
    end
    obj=InterceptTable;
end