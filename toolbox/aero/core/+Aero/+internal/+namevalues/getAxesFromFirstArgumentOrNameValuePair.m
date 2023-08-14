function[args,cax]=getAxesFromFirstArgumentOrNameValuePair(args)





    [args,cax]=Aero.internal.namevalues.findAndTrimNameValuePair(args,"Parent");

    if isempty(cax)
        if isa(args{1},"matlab.graphics.axis.Axes")
            cax=args{1};
            args(1)=[];
        else

            cax=gca;
        end
    end
end