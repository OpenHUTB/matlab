function[h,b]=shortPeriodBasePlot(args,category)




    args=matlab.graphics.internal.convertStringToCharArgs(args);


    [args,cax]=Aero.internal.namevalues.getAxesFromFirstArgumentOrNameValuePair(args);

    cax=newplot(cax);

    [args,level]=Aero.internal.namevalues.findAndTrimNameValuePair(args,'Level');

    if isempty(level)
        level='all';
    else
        if~any(strcmpi(string(level),["1","2","3","all"]))
            error(message("aero_graphics:shortPeriod:mustBeLevel"))
        end
        level=lower(string(level));
    end

    switch category
    case "A"
        [bounds,tags]=Aero.internal.FlyingQualities.MIL8785C.Longitudinal.ShortPeriod.categoryABounds(level);
    case "B"
        [bounds,tags]=Aero.internal.FlyingQualities.MIL8785C.Longitudinal.ShortPeriod.categoryBBounds(level);
    case "C"
        [bounds,tags]=Aero.internal.FlyingQualities.MIL8785C.Longitudinal.ShortPeriod.categoryCBounds(level);
    end


    h=plot(cax,args{:});



    changeLinesToMarkers(h)

    b=plotboundary(cax,bounds,tags);

    xlabel(cax,"n/\alpha ~ g's/RAD");
    ylabel(cax,"\omega_{n_{SP}} ~ RAD/SEC",Interpreter="tex");
    cax.XScale='log';
    cax.YScale='log';

    title(cax,["MIL-F-8785C Short-Period Frequency Requirements";"Category "+category+" Flight Phases"])

end

function b=plotboundary(cax,bounds,tags)
%#ok<*AGROW>

    n=1;




    b=repmat(Aero.graphics.primitive.BoundaryLine,0);




    for i=1:numel(bounds)
        blines=bounds{i};

        for j=1:numel(blines)
            if isempty(blines{j})

                continue
            end
            b(n)=boundaryline(cax,blines{j}(:,1),blines{j}(:,2),Tag=tags(i));
            if j==1
                b(n).DisplayName=tags(i);
            else

                b(n).Annotation.LegendInformation.IconDisplayStyle="off";
            end
            n=n+1;
        end
    end

    b=b(:);

end