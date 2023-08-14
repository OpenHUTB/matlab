%#codegen






function obj=generateSlope(func)
    coder.allowpcode('plain');

    if strcmp(func,'sin')
        Subintervals=coder.customfloat.helpers.half.generateEquidistantSubintervals(func);
        SubintervalsDouble=double(Subintervals);
        TableLength=length(Subintervals)-1;
        SlopeTable=coder.nullcopy(fi(zeros(TableLength,1),0,16,15));
        for i=1:TableLength
            SlopeTable(i)=fi((sin(SubintervalsDouble(i+1))-sin(SubintervalsDouble(i)))/(SubintervalsDouble(i+1)...
            -SubintervalsDouble(i))*pi/2,0,16,15);
        end
    elseif strcmp(func,'cos')
        Subintervals=coder.customfloat.helpers.half.generateEquidistantSubintervals(func);
        SubintervalsDouble=double(Subintervals);
        TableLength=length(Subintervals)-1;
        SlopeTable=coder.nullcopy(fi(zeros(TableLength,1),1,19,17));
        for i=1:TableLength-1
            SlopeTable(i)=fi((cos(SubintervalsDouble(i+1))-cos(SubintervalsDouble(i)))/(SubintervalsDouble(i+1)...
            -SubintervalsDouble(i))*pi/2,1,19,17);
        end


        SlopeTable(end)=fi((sin(SubintervalsDouble(2))-sin(SubintervalsDouble(1)))/(SubintervalsDouble(2)...
        -SubintervalsDouble(1))*pi/2,1,19,17);
    elseif strcmp(func,'tan')
        Subintervals=coder.customfloat.helpers.half.generateEquidistantSubintervals(func);
        SubintervalsDouble=double(Subintervals);
        TableLength=length(Subintervals)-1;
        SlopeTable=coder.nullcopy(fi(zeros(TableLength,1),0,14,13));
        for i=1:TableLength
            SlopeTable(i)=fi((tan(SubintervalsDouble(i+1))-tan(SubintervalsDouble(i)))/(SubintervalsDouble(i+1)...
            -SubintervalsDouble(i))*pi/4,0,14,13);
        end
    end
    obj=SlopeTable;
end