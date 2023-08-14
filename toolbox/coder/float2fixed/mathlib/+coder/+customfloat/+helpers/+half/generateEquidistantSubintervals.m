%#codegen










function equidistant_intervals_obj=generateEquidistantSubintervals(func)
    coder.allowpcode('plain');

    if strcmp(func,'sin')||strcmp(func,'cos')
        equidistant_intervals_obj=fi(linspace(0,1,33)*pi/2,0,16,15);
    elseif strcmp(func,'tan')
        equidistant_intervals_obj=fi(linspace(0,1,33)*pi/4,0,16,15);
    end
end

