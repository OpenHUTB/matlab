classdef(ConstructOnLoad,Sealed)GeographicRuler...
    <matlab.graphics.axis.decorator.GeographicTickLabelFormatHelper...
    &matlab.graphics.axis.decorator.AxisRulerBase




    properties(Dependent,SetAccess=private)
Limits
    end

    properties(Hidden,AffectsObject)
        PositiveCompassDirection(1,1)string=""
        NegativeCompassDirection(1,1)string=""
        Coordinate(1,1)string=""
    end

    properties(Constant,Access=private)
        DegreeSymbol=string(sprintf('\x00B0'))
        MinuteSymbol=string(sprintf('\x0027'))
        SecondSymbol=string(sprintf('\x0022'))
    end

    properties(Hidden,Transient,AffectsObject)
        LongitudeLabeling(1,1)string="monotonic"





    end


    methods(Access=protected,Hidden=true)
        function varargout=getPropertyGroups(~)
            varargout{1}=matlab.mixin.util.PropertyGroup(...
            {'Limits','TickValues','TickLabelFormat'});
        end
    end


    methods
        function limits=get.Limits(ruler)
            limits=[];
            ds=ancestor(ruler,'matlab.graphics.axis.dataspace.DataSpace','node');
            if~isempty(ds)&&isvalid(ds)
                switch ruler.Coordinate
                case "latitude"
                    if isprop(ds,'LatitudeLimits')
                        limits=ds.LatitudeLimits;
                    end
                case "longitude"
                    if isprop(ds,'LongitudeLimits')
                        limits=ds.LongitudeLimits;
                    end
                end
            end
        end
    end


    methods(Hidden)
        function parent=getParentImpl(ruler,~)
            parent=ancestor(ruler,'matlab.graphics.axis.GeographicAxes','node');
        end


        function out=computeLabels(ruler,ticks,lims)



            if strcmp(ruler.TickLabelsMode,'auto')
                ruler.TickLabels_I={};
                if~isempty(ticks)
                    ticklabels=computeTickLabelStrings(ruler,ticks,lims);
                    ruler.TickLabels_I=cellstr(ticklabels);
                end
            end
            out=ruler.TickLabels_I;
        end


        function lims=doStretchLimits(~,in,~)
            center=(in(1)+in(2))/2;
            span=(in(2)-in(1))/2;
            lims=center+span*[-1.05,1.05];
        end


        function tf=needsSecondaryLabel(~,~)
            tf=false;
        end


        function ticks=doChooseMajorTickValues(ruler,~,layout)













            if strcmp(ruler.TickValuesMode,'auto')
                if ruler.Coordinate=="latitude"
                    ticks=chooseLatitudeTickValues(ruler,layout);
                else
                    ticks=chooseLongitudeTickValues(ruler,layout);
                end
                ruler.NumericTickValues_I=ticks;
            else
                ticks=ruler.NumericTickValues_I;
            end
        end


        function ticks=doChooseMinorTickValues(ruler,updateState)%#ok
            if strcmp(ruler.MinorTickValuesMode,'auto')
                ticks=[];
                ruler.NumericMinorTickValues_I=ticks;
            else
                ticks=ruler.NumericMinorTickValues_I;
            end
        end


        function x=makeNumeric(~,x)

        end


        function x=makeNonNumeric(~,x)

            if~isnumeric(x)
                error(message('MATLAB:graphics:num2ruler:NumericExpected'))
            end
        end
    end


    methods(Access=protected,Hidden)
        function setTickLabelFormatFollowup(obj)

            MarkDirty(obj,'all')
        end
    end


    methods(Access=private)
        function tickValues=chooseLatitudeTickValues(ruler,layout)






            limitsInDegrees=layout(5:6);
            unitsScale=unitsPerDegree(ruler.TickLabelFormat);
            limits=unitsScale*limitsInDegrees;




            charHeight=layout(4);
            rulerLength=lengthInPixels(ruler,layout);
            maxNumIntervals=max(3,min(rulerLength/(5*charHeight),6));


            d=diff(limits);
            if d<=maxNumIntervals

                spacing=nicePow10Multiple(d/maxNumIntervals);
                s=ceil(limits(1)/spacing);
                e=floor(limits(2)/spacing);
                if(e-s)>maxNumIntervals+3


                    spacing=nicePow10Multiple(2*d/maxNumIntervals);
                    s=ceil(limits(1)/spacing);
                    e=floor(limits(2)/spacing);
                end
            else


                choices=tickSpacingChoices(ruler.TickLabelFormat);
                num=floor(d./choices);
                spacing=choices(end);
                k=find(num<=maxNumIntervals,1,'first');
                if~isempty(k)
                    spacing=choices(k);
                end
                s=ceil(limits(1)/spacing);
                e=floor(limits(2)/spacing);
            end


            tickValues=spacing*(s:e)/unitsScale;



            if(spacing==30*unitsScale)||(spacing==45*unitsScale)
                tickValues=unique([-75,tickValues,75]);
            end


            outsideLimits=(tickValues<limitsInDegrees(1))...
            |(tickValues>limitsInDegrees(2));
            tickValues(outsideLimits)=[];
        end


        function tickValues=chooseLongitudeTickValues(ruler,layout)






            limitsInDegrees=layout(5:6);
            unitsScale=unitsPerDegree(ruler.TickLabelFormat);
            limits=unitsScale*limitsInDegrees;




            charWidth=layout(3);
            rulerLength=lengthInPixels(ruler,layout);
            maxNumIntervals=max(3,min(rulerLength/(10*charWidth),8));


            d=diff(limits);
            if d<=maxNumIntervals

                spacing=nicePow10Multiple(d/maxNumIntervals);
                s=ceil(limits(1)/spacing);
                e=floor(limits(2)/spacing);
                ticks=spacing*(s:e)'/unitsScale;
                ticklabels=computeTickLabelStrings(ruler,ticks,limits/unitsScale);
                r=charWidth*sum(strlength(ticklabels))/rulerLength;
                if r>2/3


                    spacing=nicePow10Multiple((3/2)*r*d/maxNumIntervals);
                    s=ceil(limits(1)/spacing);
                    e=floor(limits(2)/spacing);
                end
            else


                choices=tickSpacingChoices(ruler.TickLabelFormat);
                num=floor(d./choices);
                k=find(num<=maxNumIntervals,1,'first');
                if isempty(k)


                    spacing=choices(end);
                else
                    spacing=choices(k);
                end
                s=ceil(limits(1)/spacing);
                e=floor(limits(2)/spacing);



                ticks=spacing*(s:e)'/unitsScale;
                ticklabels=computeTickLabelStrings(ruler,ticks,limits/unitsScale);
                r=charWidth*sum(strlength(ticklabels))/rulerLength;
                if r>2/3
                    if~isempty(k)&&(k<length(choices))


                        spacing=choices(k+1);
                    else
                        spacing=2*spacing;
                    end
                    s=ceil(limits(1)/spacing);
                    e=floor(limits(2)/spacing);
                end
            end


            tickValues=spacing*(s:e)/unitsScale;
        end


        function ticklabels=computeTickLabelStrings(ruler,ticks,lims)

            ticks=ticks(:);
            if ruler.Coordinate=="longitude"
                if ruler.LongitudeLabeling=="ewcyclic"
                    degreesPerCycle=360;
                    centerlon=(lims(1)+lims(2))/2;
                    shift=degreesPerCycle*fix(centerlon/degreesPerCycle);
                    ticks=rem(ticks-shift,degreesPerCycle);
                    lims=lims-shift;
                end
            end
            switch(ruler.TickLabelFormat)
            case "dm"
                ticklabels=computeLabelsInDM(ruler,ticks);
            case "dms"
                ticklabels=computeLabelsInDMS(ruler,ticks);
            case "dd"
                ticklabels=computeLabelsInDD(ruler,ticks,lims);
            case "-dd"
                ticklabels=computeLabelsInSignedDD(ruler,ticks,lims);
            case "-dm"
                ticklabels=computeLabelsInSignedDM(ruler,ticks);
            case "-dms"
                ticklabels=computeLabelsInSignedDMS(ruler,ticks);
            end
        end


        function ticklabels=computeLabelsInDD(ruler,ticks,lims)

            ticklabels=string(formatNumericData(ruler,ticks,lims,0));
            direction=repmat("",size(ticks));
            direction(ticks<0)=ruler.NegativeCompassDirection;
            direction(ticks>0)=ruler.PositiveCompassDirection;
            ticklabels=erase(ticklabels,"-")+ruler.DegreeSymbol+direction;
        end


        function ticklabels=computeLabelsInSignedDD(ruler,ticks,lims)

            ticklabels=string(formatNumericData(ruler,ticks,lims,0));
            ticklabels=ticklabels+ruler.DegreeSymbol;
        end


        function ticklabels=computeLabelsInDM(ruler,ticks)

            [d,m]=degrees2dm(abs(ticks));
            degreeLabels=num2str(d)+ruler.DegreeSymbol;
            minuteLabels=formatMinutes(ruler,m);
            direction=repmat("",size(ticks));
            direction(ticks<0)=ruler.NegativeCompassDirection;
            direction(ticks>0)=ruler.PositiveCompassDirection;
            ticklabels=degreeLabels+minuteLabels+direction;
        end


        function ticklabels=computeLabelsInSignedDM(ruler,ticks)

            [d,m]=degrees2dm(abs(ticks));
            degreeLabels=num2str(d)+ruler.DegreeSymbol;
            minuteLabels=formatMinutes(ruler,m);
            ticklabels=degreeLabels+minuteLabels;
            negative=(ticks<0);
            ticklabels(negative)="-"+ticklabels(negative);
        end


        function ticklabels=computeLabelsInDMS(ruler,ticks)

            [d,m,s]=degrees2dms(abs(ticks));
            degreeLabels=num2str(d)+ruler.DegreeSymbol;
            [minuteLabels,secondLabels]=formatMinutesAndSeconds(ruler,m,s);
            direction=repmat("",size(ticks));
            direction(ticks<0)=ruler.NegativeCompassDirection;
            direction(ticks>0)=ruler.PositiveCompassDirection;
            ticklabels=degreeLabels+minuteLabels+secondLabels+direction;
        end


        function ticklabels=computeLabelsInSignedDMS(ruler,ticks)

            [d,m,s]=degrees2dms(abs(ticks));
            degreeLabels=num2str(d)+ruler.DegreeSymbol;
            [minuteLabels,secondLabels]=formatMinutesAndSeconds(ruler,m,s);
            ticklabels=degreeLabels+minuteLabels+secondLabels;
            negative=(ticks<0);
            ticklabels(negative)="-"+ticklabels(negative);
        end


        function minuteLabels=formatMinutes(ruler,m,exactlyZeroSeconds)



            if nargin<3
                exactlyZeroSeconds=true;
            end
            minuteLabels=formatNumericData(ruler,m,[0,60],0)+ruler.MinuteSymbol;
            exactlyZero=(minuteLabels=="0"+ruler.MinuteSymbol)&exactlyZeroSeconds;
            minuteLabels(exactlyZero)="";
            singleDigit=(strlength(minuteLabels)==2);
            singleDigitBeforeDecimal=(strlength(extractBefore(minuteLabels,"."))==1);
            addLeadingZero=singleDigit|singleDigitBeforeDecimal;
            minuteLabels(addLeadingZero)="0"+minuteLabels(addLeadingZero);
        end


        function[minuteLabels,secondLabels]=formatMinutesAndSeconds(ruler,m,s)


            secondLabels=formatNumericData(ruler,s,[0,60],0)+ruler.SecondSymbol;
            exactlyZeroSeconds=(secondLabels=="0"+ruler.SecondSymbol);
            secondLabels(exactlyZeroSeconds)="";
            singleDigit=(strlength(secondLabels)==2);
            singleDigitBeforeDecimal=(strlength(extractBefore(secondLabels,"."))==1);
            addLeadingZero=singleDigit|singleDigitBeforeDecimal;
            secondLabels(addLeadingZero)="0"+secondLabels(addLeadingZero);
            minuteLabels=formatMinutes(ruler,m,exactlyZeroSeconds);
        end
    end
end


function[d,m]=degrees2dm(v)

    v=round(6000000*v);
    d=fix(v/6000000);
    m=round(v-6000000*d)/100000;
end


function[d,m,s]=degrees2dms(v)

    v=round(3600000*v);
    d=fix(v/3600000);
    v=v-3600000*d;
    m=fix(round(v)/60000);
    s=round(v-60000*m)/1000;
end


function scale=unitsPerDegree(tickLabelFormat)

    switch(tickLabelFormat)
    case{"dd","-dd"}
        scale=1;
    case{"dm","-dm"}
        scale=60;
    case{"dms","-dms"}
        scale=3600;
    end
end


function choices=tickSpacingChoices(tickLabelFormat)


    switch(tickLabelFormat)
    case{"dd","-dd"}
        choices=[1,2,5,10,15,30,45,60,90];
    case{"dm","-dm"}
        choices=[1,2,5,10,15,30];
        choices=[choices,60*[choices,45,60,90]];
    case{"dms","-dms"}
        choices0=[1,2,5,10,15,30];
        choices=[choices0,60*choices0];
        choices=[choices,3600*[choices0,45,60,90]];
    end
end


function dx=nicePow10Multiple(dx)

    powOfTen=10.^floor(log10(dx));
    relSize=dx/powOfTen;
    if relSize<=1.5
        dx=1*powOfTen;
    elseif relSize<=2.75
        dx=2*powOfTen;
    elseif relSize<=4.5
        dx=3*powOfTen;
    elseif relSize<=8.5
        dx=5*powOfTen;
    else
        dx=10*powOfTen;
    end
end


function rulerLengthInPixels=lengthInPixels(ruler,layout)







    ds=ancestor(ruler,...
    'matlab.graphics.axis.dataspace.WebMercatorDataSpace','node');


    dx=diff(ds.XMapLimits);
    dy=diff(ds.YMapLimits);

    if ruler.Coordinate=="latitude"



        rulerLengthInPixels=layout(1)*dy/dx;
    else



        rulerLengthInPixels=layout(2)*dx/dy;
    end
end
