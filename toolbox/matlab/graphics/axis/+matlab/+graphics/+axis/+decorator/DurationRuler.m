classdef(ConstructOnLoad)DurationRuler<...
    matlab.graphics.axis.decorator.ScalableAxisRuler&...
    matlab.graphics.mixin.AxesParentable&...
    matlab.graphics.data.AbstractNonNumericConverter




    properties(AffectsObject)
        TickLabelFormat='';
    end

    properties(AffectsObject,NeverAmbiguous)
        ExponentMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    properties(Dependent=true,AffectsObject)
        Exponent;
    end
    properties(Hidden=true)
        Exponent_I=0;
        Converter=@days;
        SecondaryRoot=[];
    end

    methods(Access='protected',Hidden=true)
        function varargout=getPropertyGroups(~)
            varargout{1}=matlab.mixin.util.PropertyGroup(...
            {'Limits','TickValues','TickLabelFormat'});
        end
    end

    methods
        function set.TickLabelFormat(ruler,val)
            if~isequal(val,ruler.TickLabelFormat)
                valid=true;
                if~ischar(val)||isempty(val)
                    valid=false;
                else
                    try
                        cellstr(days(1),val);
                    catch
                        valid=false;
                    end
                end
                if~valid
                    error(message('MATLAB:graphics:DurationRuler:Format'))
                end
                ruler.TickLabelFormat=val;
                ruler.computeSecondaryRoot;
            end
        end

        function set.Exponent(ruler,val)
            if~isequal(val,ruler.Exponent_I)
                if~isscalar(val)||~isnumeric(val)||~(fix(val)==val)||~isfinite(val)
                    error(message('MATLAB:graphics:DurationRuler:Exponent'))
                end
                ruler.Exponent_I=full(double(val));
                ruler.ExponentMode='manual';
            end
        end
        function val=get.Exponent(ruler)
            if strcmp(ruler.ExponentMode,'auto')
                forceFullUpdate(ruler,'all','Exponent');
            end
            val=ruler.Exponent_I;
        end
        function set.ExponentMode(ruler,val)
            ruler.ExponentMode=val;
        end

        function y=makeNumeric(ruler,x)
            if isempty(x)
                y=zeros(size(x));
            elseif isnumeric(x)
                y=x;
            elseif~isa(x,'duration')
                error(message('MATLAB:graphics:DurationRuler:NonNumericType'));
            else
                y=ruler.Converter(x);
            end
        end

        function y=makeNonNumeric(ruler,x)
            if isa(x,'duration')
                y=x;
            elseif isempty(x)
                y=reshape(duration.empty,size(x));
            elseif~isnumeric(x)
                error(message('MATLAB:graphics:DurationRuler:NonNumericType'));
            else
                y=ruler.Converter(x);
                if~isempty(ruler.TickLabelFormat)
                    y.Format=ruler.TickLabelFormat;
                end
            end
        end


        function val=convertToTickLabelFormatUnits(ruler,val)






            if isscalar(ruler.TickLabelFormat)
                ind=ruler.TickLabelFormat=='ydhms';
                if any(ind)
                    converter={@years,@days,@hours,@minutes,@seconds};
                    tickLabelFormatFun=converter{ind};
                    val=tickLabelFormatFun(ruler.Converter(val));
                end
            end
        end

        function val=convertToInternalNumericUnits(ruler,val)






            if isscalar(ruler.TickLabelFormat)
                ind=ruler.TickLabelFormat=='ydhms';
                if any(ind)
                    converter={@years,@days,@hours,@minutes,@seconds};
                    tickLabelFormatFun=converter{ind};
                    val=ruler.Converter(tickLabelFormatFun(val));
                end
            end
        end

        function y=format(~,x)
            y=x;
        end

        function addData(~,~)

        end

        function validateLimits(ruler,lims)%#ok
            valid=true;
            if~isa(lims,'duration')
                valid=false;
            elseif numel(lims)~=2
                valid=false;
            elseif~(lims(1)<lims(2))
                valid=false;
            end
            if~valid
                error(message('MATLAB:graphics:DurationRuler:Limits'))
            end
        end

        function[lims,numlims]=setLimitsDelegate(ruler,inlims)
            validateLimits(ruler,inlims);
            if isa(inlims,'duration')
                lims=inlims;
            else
                lims=makeNonNumeric(ruler,inlims);
            end
            numlims=makeNumeric(ruler,lims);
        end

        function dlims=convertNumericLimits(ruler,numlims)
            dlims=makeNonNumeric(ruler,numlims);
        end

        function validateTicks(ruler,ticks)%#ok
            if isempty(ticks)
                return;
            end
            valid=true;
            if~isa(ticks,'duration')
                valid=false;
            elseif~isvector(ticks)
                valid=false;
            else
                for k=2:length(ticks)
                    if~(ticks(k-1)<ticks(k))
                        valid=false;
                        break;
                    end
                end
            end
            if~valid
                error(message('MATLAB:graphics:DurationRuler:Ticks'))
            end
        end

        function[ticks,numticks]=setTicksDelegate(ruler,inticks)
            validateTicks(ruler,inticks);
            if isa(inticks,'duration')
                ticks=inticks;
            else
                ticks=makeNonNumeric(ruler,inticks);
            end
            numticks=makeNumeric(ruler,ticks);
        end

        function dtticks=convertNumericTicks(ruler,numticks)
            dtticks=makeNonNumeric(ruler,numticks);
        end

        function out=computeLabels(ruler,ticks,lims)
            if strcmp(ruler.TickLabelsMode,'auto')
                if isempty(ticks)
                    ruler.TickLabels_I={};
                else
                    fmt=ruler.TickLabelFormat;
                    if isscalar(fmt)

                        ind=fmt=='ydhms';
                        converter={@years,@days,@hours,@minutes,@seconds};
                        fun=converter{ind};
                        if~isequal(fun,ruler.Converter)
                            dticks=makeNonNumeric(ruler,ticks);
                            ticks=fun(dticks);
                        end
                        out=ruler.formatNumericData(ticks,lims,ruler.Exponent_I);
                    else
                        dticks=makeNonNumeric(ruler,ticks);
                        dlims=makeNonNumeric(ruler,lims);
                        out=duration_tickformat(dticks,dlims,ruler);
                    end
                    ruler.TickLabels_I=out;
                end
            end
            out=ruler.TickLabels_I;
        end

        function out=formatData(ruler,x)
            dt=makeNonNumeric(ruler,x);
            dtlims=makeNonNumeric(ruler,ruler.NumericLimits);
            fmt=ruler.TickLabelFormat;
            if isscalar(fmt)

                ind=fmt=='ydhms';
                converter={@years,@days,@hours,@minutes,@seconds};
                fun=converter{ind};
                if~isequal(fun,ruler.Converter)
                    out=fun(dt);
                else
                    out=x;
                end
            else

                out=duration_tickformat(dt,dtlims,ruler);
            end
        end

        function out=doStretchLimits(ruler,in,allowZero)%#ok
            center=(in(1)+in(2))/2;
            span=(in(2)-in(1))/2;
            lims=[center-span*1.05,center+span*1.05];
            out=lims;
        end

        function visible=needsSecondaryLabel(ruler,lims)
            if strcmp(ruler.ExponentMode,'auto')



                lims=convertToTickLabelFormatUnits(ruler,lims);


                low_exp=findBestExponent(lims(1));
                high_exp=findBestExponent(lims(2));
                mid=mean(lims);
                mid_exp=findBestExponent(mid);
                ruler.Exponent_I=median([low_exp,mid_exp,high_exp]);
            end
            visible=isscalar(ruler.TickLabelFormat)&&~strcmp(ruler.TickLabelMode,'manual');
        end

        function computeSecondaryRoot(ruler)
            fmt=ruler.TickLabelFormat;
            if isscalar(fmt)
                ind=fmt=='ydhms';
                converter={@years,@days,@hours,@minutes,@seconds};
                fun=converter{ind};
                str=char(fun(2));
                strs=regexp(str,'[^\d\s]*$','match');
                ruler.SecondaryRoot=strs{1};
            else
                ruler.SecondaryRoot='';
            end
        end

        function str=computeSecondaryLabelString(ruler)
            ticks=ruler.NumericTickValues_I;
            str='';
            fmt=ruler.TickLabelFormat;
            if~isempty(ticks)&&isscalar(fmt)&&~strcmp(ruler.TickLabelMode,'manual')
                if~ischar(ruler.SecondaryRoot)
                    computeSecondaryRoot(ruler);
                end
                if ruler.Exponent_I~=0
                    str=['\times10^{',num2str(ruler.Exponent_I),'} ',ruler.SecondaryRoot];
                else
                    str=ruler.SecondaryRoot;
                end
            end
        end

        function ticks=doChooseMajorTickValues(ruler,us,layout)%#ok
            if strcmp(ruler.TickValuesMode,'auto')
                fmt=ruler.TickLabelFormat;
                if isscalar(fmt)

                    lims=layout(5:6);



                    lims=convertToTickLabelFormatUnits(ruler,lims);
                    ticks=ruler.chooseNumericTicks(lims);



                    ticks=convertToInternalNumericUnits(ruler,ticks);
                else
                    ticks=duration_tickpick(layout,ruler);
                end
                ruler.NumericTickValues_I=ticks;
            else
                ticks=ruler.NumericTickValues_I;
            end
        end

        function ticks=doChooseMinorTickValues(ruler,us)%#ok
            if strcmp(ruler.MinorTickValuesMode,'auto')
                ticks=[];
                ruler.NumericMinorTickValues_I=ticks;
            else
                ticks=ruler.NumericMinorTickValues_I;
            end
        end

    end
end

function out=duration_tickformat(dticks,~,ruler)
    fmt=ruler.TickLabelFormat;
    if isscalar(fmt)
        ind=fmt=='ydhms';
        converter={@years,@days,@hours,@minutes,@seconds};
        fun=converter{ind};
        ticks=fun(dticks);
        ticks=ticks(:);
        out=strtrim(cellstr(num2str(ticks)));
    else
        out=cellstr(dticks,fmt);
    end
end

function[ticks,limits]=duration_tickpick(layout_data,ruler)
    lims=layout_data(5:6);
    trye=0;
    targetCoverage=.66;
    coverageTolerance=0.01;

    nticksLowerBound=0;
    nticksUpperBound=20;
    nticks=round((nticksUpperBound+nticksLowerBound)/2);

    limits=makeNonNumeric(ruler,lims);
    [tryTicks,tryLims]=DurationTicks(nticks,limits,true);
    strs=duration_tickformat(tryTicks,tryLims,ruler);
    str1=strs{1};
    axle_dx=abs(layout_data(1));
    axle_dy=abs(layout_data(2));

    if 10*axle_dy<axle_dx
        width=length(str1)*layout_data(3);
        coverage=(nticks*width)/axle_dx;
    else
        height=layout_data(4)*2;
        coverage=(nticks*height)/axle_dy;
    end

    while coverage>1||(trye<15&&abs(coverage-targetCoverage)>coverageTolerance)||(trye==0)
        trye=trye+1;
        if coverage>targetCoverage
            nticksUpperBound=nticks;
        else
            nticksLowerBound=nticks;
        end
        nticksNew=round((nticksUpperBound+nticksLowerBound)/2);
        if nticksNew==nticks
            if(coverage>targetCoverage)&&~isequal(nticks,1)
                nticks=nticks-1;
            end
            [ticks,limits]=DurationTicks(nticks,limits,true);
            break
        else
            nticks=nticksNew;
        end

        [tryTicks,tryLims]=DurationTicks(nticks,limits,true);
        strs=duration_tickformat(tryTicks,tryLims,ruler);
        str1=strs{1};
        if 10*axle_dy<axle_dx
            width=length(str1)*layout_data(3);
            newCoverage=(nticks*width)/axle_dx;
        else
            height=layout_data(4)*2;
            newCoverage=(nticks*height)/axle_dy;
        end


        if coverage<.95&&(abs(newCoverage-targetCoverage)>abs(coverage-targetCoverage))
            if trye==1
                ticks=tryTicks;
                limits=tryLims;
            end
            break
        else
            coverage=newCoverage;
            ticks=tryTicks;
            limits=tryLims;
        end

    end
    ticks=makeNumeric(ruler,ticks);
end

function[ticks,lims]=DurationTicks(nticks,lims,padLimits)



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

    lmin=lims(1);
    lmax=lims(2);


    xrange=lmax-lmin;
    xscale=max(abs(lims));


    if seconds(xrange)<max(10*eps(seconds(xscale)),realmin)



        ticks=mean(lims);
    else
        if nticks==1
            tmid=mean([lmin,lmax]);
            if xrange<seconds(1)
                step=nicePow10Multiple(seconds(xrange));
                ticks=step*round(tmid/step,'Seconds');
            elseif xrange<minutes(1)
                ticks=round(tmid,'Seconds');
            elseif xrange<hours(1)
                ticks=round(tmid,'Minutes');
            elseif xrange<days(1)
                ticks=round(tmid,'Hours');
            else
                ticks=round(tmid,'Days');
            end


        elseif xrange<seconds(1)

            step=nicePow10Multiple(max(seconds(xrange)/(nticks-1),eps(seconds(xscale))));

            if padLimits
                leftTick=step*floor((seconds(lmin)+.40*step)/step);
                rightTick=step*ceil((seconds(lmax)-.40*step)/step);
            else
                leftTick=step*ceil(seconds(lmin)/step);
                rightTick=step*floor(seconds(lmax)/step);
            end
            ticks=seconds(leftTick:step:rightTick);

        elseif xrange>=years(12)

            ndays=days(xrange);
            step=days(nicePow10Multiple(max(ndays/nticks,1)));
            if padLimits
                leftTick=step*floor((lmin+.40*step)/step);
                rightTick=step*ceil((lmax-.40*step)/step);
            else
                leftTick=step*ceil(lmin/step);
                rightTick=step*floor(lmax/step);
            end
            ticks=leftTick:step:rightTick;

        else
            if xrange<minutes(15)

                scaleFactor=seconds(1);
                niceTickIntervals=[1,5,10,15,30,60,120,180,240,300]*scaleFactor;
            elseif xrange<hours(3)

                scaleFactor=minutes(1);
                niceTickIntervals=[1,5,10,15,30,60]*scaleFactor;
            elseif xrange<days(14)

                scaleFactor=hours(1);
                niceTickIntervals=[1,2,3,4,5,6,12,24,48,72]*scaleFactor;
            elseif xrange<years(2)

                scaleFactor=days(1);
                niceTickIntervals=[1,2,3,4,5,10,15,20,30,50,100,150,300]*scaleFactor;
            elseif xrange<years(4)

                scaleFactor=days(30);
                niceTickIntervals=[1,2,3,4,5,6,10,20]*scaleFactor;
            else

                scaleFactor=days(100);
                niceTickIntervals=[1,2,3,4,5,10,15,20]*scaleFactor;
            end

            [~,i]=min(abs(xrange./niceTickIntervals-nticks));
            step=niceTickIntervals(i);

            if padLimits
                leftTick=step*floor((lmin+.40*step)/step);
                rightTick=step*ceil((lmax-.40*step)/step);
            else
                leftTick=step*ceil(lmin/step);
                rightTick=step*floor(lmax/step);
            end
            ticks=leftTick:step:rightTick;

        end


        if isempty(ticks),ticks=(lmin+lmax)/2;end
    end
end

function val=findBestExponent(x)
    val=floor(log10(abs(x)));
    if-2<=val&&val<=3
        val=0;
    end
end

