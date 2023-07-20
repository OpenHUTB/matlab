%#codegen










function obj=generateConst(func)
    coder.allowpcode('plain');

    if strcmp(func,'sin')||strcmp(func,'cos')
        obj=fi(2/pi,0,16,15);
    elseif strcmp(func,'tan')
        obj=fi(4/pi,0,8,7);
    elseif strcmp(func,'acos')
        obj=fi(pi,0,19,17);
    elseif strcmp(func,'atan')
        obj=fi(pi/2,0,18,17);
    end
end

