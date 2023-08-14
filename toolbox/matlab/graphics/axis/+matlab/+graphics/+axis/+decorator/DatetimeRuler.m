classdef(ConstructOnLoad)DatetimeRuler<...
    matlab.graphics.axis.decorator.ScalableAxisRuler&...
    matlab.graphics.mixin.AxesParentable&...
    matlab.graphics.data.AbstractNonNumericConverter




    properties(AffectsObject,NeverAmbiguous)
        TickLabelFormatMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end
    properties(Dependent)
        TickLabelFormat;
    end
    properties(Hidden,Dependent)
        Exponent;
        ReferenceDate;
        DataFormat='';
    end
    properties(Hidden,AffectsObject)
        TickLabelFormat_I=matlab.graphics.axis.decorator.DatetimeRuler.localeFormat('uuuuMMMdd');
        ReferenceDate_I=datetime(0,'convertFrom','posixtime');
        Exponent_I=0;
        ExponentMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end
    properties(Access=?tmatlab_graphics_axis_decorator_DatetimeRuler_tickpick)
        TickCache=[];
        TickCacheInputs=[];
        TickLabelCache={};
        TickLabelCacheInputs={};
        DataFormat_I='';
        DataFormatRange=[];
        ScaleFormat_I='';
    end

    methods(Access='protected',Hidden=true)
        function varargout=getPropertyGroups(~)
            varargout{1}=matlab.mixin.util.PropertyGroup(...
            {'Limits','TickValues','TickLabelFormat'});
        end
    end

    methods
        function out=get.TickLabelFormat(ruler)
            if strcmp(ruler.TickLabelFormatMode,'auto')
                forceFullUpdate(ruler,'all','TickLabelFormat');




                if strcmp(ruler.TickLabelsMode,'manual')
                    fmt=computeFormats(ruler,ruler.TickValues_I,ruler.Limits_I);
                    if~isequal(ruler.TickLabelFormat_I,fmt)
                        ruler.TickLabelFormat_I=fmt;
                    end
                end
            end
            out=ruler.TickLabelFormat_I;
        end

        function set.TickLabelFormat(ruler,val)

            if~isequal(val,ruler.TickLabelFormat_I)
                if~ischar(val)||isempty(val)
                    error(message('MATLAB:graphics:DatetimeRuler:Format'));
                end
                if~isempty(ruler.ReferenceDate_I)&&...
                    strcmp(ruler.ReferenceDate_I.TimeZone,'UTCLeapSeconds')&&...
                    ~strcmp(ruler.ReferenceDate_I.Format,val)
                    error(message('MATLAB:graphics:DatetimeRuler:LeapSecondFormat'));
                end
                try
                    cellstr(datetime('now'),val);
                catch
                    error(message('MATLAB:graphics:DatetimeRuler:Format'));
                end
                ruler.TickLabelFormat_I=val;
                ruler.TickLabelFormatMode='manual';
            end
        end

        function set.TickLabelFormatMode(ruler,val)
            ruler.TickLabelFormatMode=val;
        end

        function val=get.ReferenceDate(ruler)
            val=ruler.ReferenceDate_I;
        end

        function set.ReferenceDate(~,~)


            error(message('MATLAB:graphics:DatetimeRuler:ReferenceDateReadOnly'));
        end

        function set.ReferenceDate_I(ruler,val)
            if~isequal(val,ruler.ReferenceDate_I)
                ruler.ReferenceDate_I=dateshift(val,'start','day');
            end
        end

        function val=get.DataFormat(ruler)
            val=ruler.DataFormat_I;
        end

        function set.DataFormat(ruler,val)


            ruler.DataFormat_I=val;
            if~isempty(val)
                ruler.DataFormatRange=computeRange(val);
            end
        end

        function out=get.Exponent(ruler)
            out=ruler.Exponent_I;
        end

        function set.Exponent(ruler,val)

            if~isscalar(val)||~isnumeric(val)||round(val)~=val||~isfinite(val)
                error(message('MATLAB:graphics:DatetimeRuler:Exponent'));
            end
            ruler.Exponent_I=val;
            ruler.ExponentMode='manual';
        end
    end

    methods(Hidden)
        function y=makeNumeric(ruler,x)

            if isempty(x)
                y=zeros(size(x));
            elseif isnumeric(x)
                y=x;
            elseif~isa(x,'datetime')
                error(message('MATLAB:graphics:DatetimeRuler:NonNumericType'));
            else
                y=days(x-ruler.ReferenceDate_I);
            end
        end

        function y=makeNonNumeric(ruler,x)


            if isa(x,'datetime')
                y=x;
            elseif isempty(x)
                y=reshape(datetime.empty,size(x));
            else
                if~isnumeric(x)
                    error(message('MATLAB:graphics:DatetimeRuler:NonNumericType'));
                end
                x1=x(:);
                x1=double(x1)*86400000;
                x2=x1(isfinite(x1));
                if isempty(x2)
                    maxval=1;
                else
                    maxval=max(1,max(abs(x2)));
                end



                maxDoublePrec=50;

                e=maxDoublePrec-floor(log2(maxval));
                x1=pow2(round(pow2(x1,e)),-e);
                y=milliseconds(x1)+ruler.ReferenceDate_I;
                y=reshape(y,size(x));
            end
        end

        function y=format(ruler,x,dtlims,fmt)




            if nargin==2
                fmt=ruler.TickLabelFormat;
                dtlims=ruler.Limits_I;
            end

            y=x;
            tz=ruler.ReferenceDate_I.TimeZone;
            if~isempty(x)&&~strcmp(tz,'UTCLeapSeconds')
                prefFormatRange=ruler.DataFormatRange;
                prefFormat=ruler.DataFormat_I;
                minPrecision=1;
                if~isempty(fmt)
                    range=computeRange(fmt);
                    minPrecision=range(end);
                    if strcmp(ruler.TickLabelFormatMode,'manual')
                        prefFormat=ruler.TickLabelFormat_I;
                        prefFormatRange=range;
                    end
                    if minPrecision==2
                        minPrecision=3;
                    end
                end
                includeYear=true;
                fmt=DatetimeTicksFormat(x,dtlims,prefFormatRange,prefFormat,includeYear,minPrecision);
                cleanup=disableFormatWarning;
                y.Format=fmt;
                delete(cleanup)
            end
        end

        function addData(~,~)

        end

        function validateLimits(ruler,lims)%#ok

            valid=true;
            if~isa(lims,'datetime')
                valid=false;
            elseif numel(lims)~=2
                valid=false;
            elseif~(lims(1)<lims(2))
                valid=false;
            end
            if~valid
                error(message('MATLAB:graphics:DatetimeRuler:Limits'));
            end
        end

        function[lims,numlims]=setLimitsDelegate(ruler,inlims)

            validateLimits(ruler,inlims);
            lims=inlims;
            numlims=makeNumeric(ruler,lims);
        end

        function dtlims=convertNumericLimits(ruler,numlims)

            dtlims=makeNonNumeric(ruler,numlims);
            fmt=ruler.TickLabelFormat_I;
            dtlims=format(ruler,dtlims,dtlims,fmt);
        end

        function validateTicks(ruler,ticks)%#ok

            if isempty(ticks)
                return;
            end
            valid=true;
            if~isa(ticks,'datetime')
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
                error(message('MATLAB:graphics:DatetimeRuler:Ticks'));
            end
        end

        function[ticks,numticks]=setTicksDelegate(ruler,inticks)

            validateTicks(ruler,inticks);
            ticks=inticks;
            numticks=makeNumeric(ruler,ticks);
        end

        function dtticks=convertNumericTicks(ruler,numticks)

            dtticks=makeNonNumeric(ruler,numticks);
            lims=ruler.Limits_I;
            fmt=ruler.TickLabelFormat_I;
            dtticks=format(ruler,dtticks,lims,fmt);
        end

        function out=computeLabels(ruler,ticks,lims)

            if strcmp(ruler.TickLabelsMode,'manual')
                out=ruler.TickLabels_I;
                return;
            end

            inputs={ticks,ruler.TickLabelFormat_I,ruler.TickLabelFormatMode};
            if isequal(inputs,ruler.TickLabelCacheInputs)
                out=ruler.TickLabelCache;
                ruler.TickLabels_I=out;
                return;
            end

            dtticks=makeNonNumeric(ruler,ticks);
            dtlims=makeNonNumeric(ruler,lims);
            [fmt,scalefmt]=computeFormats(ruler,dtticks,dtlims);
            cleanup=disableFormatWarning;
            out=cellstr(dtticks,fmt);
            delete(cleanup)
            if strcmp(ruler.TickLabelFormatMode,'auto')
                ruler.TickLabelFormat_I=fmt;
            end
            ruler.ScaleFormat_I=scalefmt;
            ruler.TickLabelCache=out;
            ruler.TickLabelCacheInputs=inputs;
            ruler.TickLabels_I=out;
        end

        function[tickfmt,scalefmt]=computeFormats(ruler,dtticks,dtlims)
            if strcmp(ruler.TickLabelFormatMode,'manual')
                tickfmt=ruler.TickLabelFormat_I;
                scalefmt=computeSecondaryFormat(tickfmt);
            elseif strcmp(dtticks.TimeZone,'UTCLeapSeconds')
                tickfmt=dtticks.Format;
                scalefmt='';
            else
                includeYear=false;
                minPrecision=1;
                tickfmt=DatetimeTicksFormat(dtticks,dtlims,ruler.DataFormatRange,ruler.DataFormat_I,includeYear,minPrecision);
                scalefmt=computeSecondaryFormat(tickfmt);
            end
        end

        function out=doStretchLimits(ruler,in,allowZero)%#ok
            out=in;
            range=in(2)-in(1);
            [cuts,inds,incr]=getPickerTables;
            cross=find(range>=cuts,1);
            if isempty(cross)


                return;
            end
            inc=incr(cross);
            ind=inds(cross);
            if inc<0


                return;
            end
            dtlims=ruler.makeNonNumeric(in);


            dvlow=daylightSavingAdjustedDateVec(dtlims(1));
            tv=[1,1,1,0,0,0];
            if ind==3&&inc>1

                dvlow=daylightSavingAdjustedDateVec(ruler.ReferenceDate);
                tv(1:(ind-1))=dvlow(1:(ind-1));
                tv(ind)=nicedays(in(1),inc,-1,dvlow(ind));
            else
                tv(1:(ind-1))=dvlow(1:(ind-1));
                tv(ind)=nicenum(dvlow,ind,inc,-1);
            end
            tz=ruler.ReferenceDate_I.TimeZone;
            dt1=daylightSavingAdjustedDateVecToDatetime(tv,tz);


            dvhigh=daylightSavingAdjustedDateVec(dtlims(2));
            tv=[1,1,1,0,0,0];
            if~isequal(tv(ind+1:end),dvhigh(ind+1:end))
                dvhigh(ind)=dvhigh(ind)+0.5;
            end
            if ind==3&&inc>1

                tv(1:(ind-1))=dvlow(1:(ind-1));
                tv(ind)=nicedays(in(2),inc,1,dvlow(ind));
            else
                tv(1:(ind-1))=dvhigh(1:(ind-1));
                tv(ind)=nicenum(dvhigh,ind,inc,1);
            end
            dt2=daylightSavingAdjustedDateVecToDatetime(tv,tz);

            out=ruler.makeNumeric([dt1,dt2]);
        end

        function visible=needsSecondaryLabel(ruler,lims)%#ok
            visible=~strcmp(ruler.TickLabelMode,'manual');
        end

        function str=computeSecondaryLabelString(ruler)

            str='';
            ticks=ruler.NumericTickValues_I;
            lims=ruler.NumericLimits;



            inset=(lims(2)-lims(1)).*1e-8.*[1,-1];
            lims=lims+inset;

            if~isempty(ticks)&&~strcmp(ruler.TickLabelMode,'manual')&&~isempty(ruler.ScaleFormat_I)
                dtlims=makeNonNumeric(ruler,lims);
                cleanup=disableFormatWarning;
                str=char(dtlims(1),ruler.ScaleFormat_I);
                str2=char(dtlims(2),ruler.ScaleFormat_I);
                if~isequal(str,str2)
                    str=[str,'-',str2];
                end
                delete(cleanup)
                str=[str,'   '];
            end
        end

        function ticks=doChooseMajorTickValues(ruler,us,layout)%#ok


            if strcmp(ruler.TickValuesMode,'auto')
                if strcmp(ruler.TickLabelRotationMode,'auto')
                    angle=0;
                else
                    angle=ruler.TickLabelRotation_I;
                end
                cacheInputs={layout,angle,ruler.NumericLimits,ruler.TickLabelFormat_I};
                if isequal(cacheInputs,ruler.TickCacheInputs)
                    ticks=ruler.TickCache;
                else
                    ticks=simple_tickpick(layout,ruler);
                    ruler.TickCache=ticks;
                    ruler.TickCacheInputs=cacheInputs;
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

        function ticks=pickTicks(ruler,layout)
            ticks=simple_tickpick(layout,ruler);
        end
    end
    methods(Hidden,Static)
        function fmt=localeFormat(pieces)

            locale=matlab.internal.datetime.getDatetimeSettings('locale');
            fmt=matlab.internal.datetime.getDefaults('localeformat',locale,pieces);
        end
    end
end

function tickFormat=DatetimeTicksFormat(ticks,lims,dataRange,dataFormat,includeYear,minPrecision)



    span=days(lims(2)-lims(1));
    time_eps=span*1e-20;
    limsIn=[lims(1)+time_eps,lims(2)-time_eps];
    dvLimsIn=datevec(limsIn);
    start=any(bsxfun(@ne,dvLimsIn,dvLimsIn(1,:)),1);
    start=find(start,1,'first');
    if isempty(start)||includeYear
        start=1;
    elseif start==3
        start=2;
    else
        start=min(start,4);
    end


    dvTicks=datevec(ticks);
    stop=[any(dvTicks(:,1)~=dvTicks(1,1),1),any(dvTicks(:,2:3)~=1,1),any(dvTicks(:,4:6)~=0,1)];
    stop=find(stop,1,'last');
    if isempty(stop)
        start=1;stop=3;
    elseif stop==4
        stop=5;
    end
    stop=max(stop,minPrecision);

    if stop<start
        stop=6;
    end

    if all(dvTicks(:,6)==round(dvTicks(:,6)))||span>=0.9


        tokens={'u','MMM','dd','HH','mm','ss'};
    else

        seconds_gaps=seconds(diff(ticks));


        if all(seconds_gaps(:)>.005)

            tokens={'u','MMM','dd','HH','mm','ss.SSS'};
        else
            subsec=abs(median(seconds_gaps(:)));
            exp=-log10(subsec);
            nudge=exp-0.0001;
            digs=max(4,min(9,ceil(nudge)));
            S=repmat('S',1,digs);
            tokens={'u','MMM','dd','HH','mm',['ss.',S]};
        end
    end
    if isequal(dataRange,[start,stop])
        tickFormat=dataFormat;
    else
        parts=strjoin(tokens(start:stop));
        tickFormat=matlab.graphics.axis.decorator.DatetimeRuler.localeFormat(parts);
    end
end

function[cuts,inds,incr]=getPickerTables

    yr=366;
    qr=92;
    mo=31;
    wk=7;
    hr=1/24;
    min=hr/60;
    sec=min/60;
    subcut=[30,10,5,2,1];
    subind=[1,1,1,2,2];
    subinc=[10,2,1,30,15];

    cuts=[5*yr,2*yr,yr,qr,2*mo,mo,2*wk-1,wk-1,2,1,12*hr,6*hr,2*hr,hr,subcut*min,subcut*sec];
    inds=[1,2,2,2,3,3,3,3,4,4,4,4,5,5,(subind+4),(subind+5)];
    incr=[-1,6,3,1,14,7,3,1,12,6,2,1,30,15,subinc,subinc];


    cuts(inds>6)=[];
end

function y=nicedays(day,step,dir,dvlow)
    y=nicenum(day,1,step,dir)+dvlow;
end

function y=nicenum(v,ind,step,dir)


    if ind==2||ind==3
        offset=1;
    else
        offset=0;
    end
    y=(v(ind)-offset)/step;
    if dir>0
        y=ceil(y);
    else
        y=floor(y);
    end
    y=y*step+offset;
end

function ticks=simple_tickpick(layout_data,ruler)






    lims=layout_data(5:6);
    range=(lims(2)-lims(1))*(1+1e-5);
    [cuts,inds,incr]=getPickerTables;
    cross=find(range>=cuts,1);
    tv=[1,1,1,0,0,0];
    dtlims=ruler.makeNonNumeric(lims);
    tz=ruler.ReferenceDate_I.TimeZone;
    if isempty(cross)
        s=second(dtlims);
        if s(1)>s(2)
            s(2)=s(2)+60;
        end
        t=ruler.chooseNumericTicks(s)-s(1);
        ticks=ruler.makeNumeric(dtlims(1)+seconds(t));
        return
    end
    inc=incr(cross);
    if inc<0
        yrs=year(dtlims);
        t=ruler.chooseNumericTicks(yrs);
        t=t(t==fix(t));
        tv=t(:).*[1,0,0,0,0,0]+[0,1,1,0,0,0];
        ticks=ruler.makeNumeric(datetime(tv,'TimeZone',tz))';
        return
    end
    [ticks,refTicks]=simplePickOnce(ruler,inds(cross),inc,tv,lims,dtlims);
    if isempty(ticks)
        tickspan=1;
    else
        tickspan=(ticks(end)-ticks(1))/(lims(2)-lims(1));
    end
    overlap=computeTickOverlap(refTicks,length(ticks),layout_data,ruler,dtlims,tickspan);
    if overlap<1&&cross>2
        if overlap>0.6
            ticks=simplePickOnce(ruler,inds(cross),incr(cross)*2,tv,lims,dtlims);
        else
            cross=cross-1;
            tv=[1,1,1,0,0,0];
            ticks=simplePickOnce(ruler,inds(cross),incr(cross),tv,lims,dtlims);
        end
    end
end

function overlap=computeTickOverlap(refTicks,nticks,layout_data,ruler,dtlims,tickspan)

    overlap=inf;
    if strcmp(ruler.TickLabelRotationMode,'auto')
        angle=0;
    else
        angle=ruler.TickLabelRotation_I;
    end
    if angle==0
        axle_dx=abs(layout_data(1));
        axle_dy=abs(layout_data(2));
        if 10*axle_dy<axle_dx
            fmt=computeFormats(ruler,refTicks,dtlims);
            cleanup=disableFormatWarning;
            str=cellstr(refTicks,fmt);
            delete(cleanup)
            len=max(length(str{1}),length(str{2}));
            width=len*layout_data(3);
            nfit=tickspan*axle_dx/width;
        else
            height=1.2*layout_data(4);
            nfit=axle_dy/height;
        end
        overlap=(nfit+1)/nticks;
    end
end

function[ticks,refTicks]=simplePickOnce(ruler,ind,inc,tv,lims,dtlims)
    ticks=[];
    if ind==3&&inc>1

        dvlow=daylightSavingAdjustedDateVec(ruler.ReferenceDate);
        tv(1:(ind-1))=dvlow(1:(ind-1));
        tv(ind)=nicedays(lims(1),inc,-1,dvlow(ind));
    else
        dvlow=daylightSavingAdjustedDateVec(dtlims(1));
        tv(1:(ind-1))=dvlow(1:(ind-1));
    end
    tz=ruler.ReferenceDate_I.TimeZone;
    dt1=daylightSavingAdjustedDateVecToDatetime(tv,tz);
    d=ruler.makeNumeric(dt1);
    eps=1e-14*max(abs(lims));
    firstTick=dt1;
    secondTick=dt1;
    sawSecondTick=false;
    while d<=lims(2)+eps*d&&length(ticks)<50
        if d>=lims(1)-eps&&(isempty(ticks)||d>ticks(end))
            ticks(end+1)=d;%#ok
        end
        tv(ind)=tv(ind)+inc;
        tick=daylightSavingAdjustedDateVecToDatetime(tv,tz);
        d=ruler.makeNumeric(tick);
        if~sawSecondTick
            secondTick=tick;
            sawSecondTick=true;
        end
    end
    refTicks=[firstTick,secondTick];
end

function range=computeRange(val)
    range=[1,3];
    hit=false(1,6);







    hit(1)=any(val=='y'|val=='u');
    hit(2)=any(val=='M'|val=='Q');
    hit(3)=any(val=='d'|val=='D'|val=='W');
    hit(4)=any(val=='h'|val=='H');
    hit(5)=any(val=='m');
    hit(6)=any(val=='s'|val=='S');
    if any(hit)
        range=[find(hit,1),find(hit,1,'last')];
    end
end

function fmt=computeAutoFormat(range,tokens)
    if nargin==1
        tokens={'u','MMM','dd','HH','mm','ss'};
    end
    parts=strjoin(tokens(range(1):range(2)));
    fmt=matlab.graphics.axis.decorator.DatetimeRuler.localeFormat(parts);
end

function scalefmt=computeSecondaryFormat(tickfmt)
    r=computeRange(tickfmt);
    if r(1)==1
        scalefmt='';
    else
        scalefmt=computeAutoFormat([1,r(1)-1]);
    end
end

function cleanup=disableFormatWarning
    oldwarn=warning('off','MATLAB:datetime:FormatConflict_mM');



    [msg,id]=lastwarn;
    cleanup=onCleanup(@()restoreWarningState(oldwarn,msg,id));
end

function restoreWarningState(state,msg,id)
    warning(state);
    lastwarn(msg,id);
end

function dv=daylightSavingAdjustedDateVec(dt)





...
...
...
...
...


    midnight=dateshift(dt,'start','day');
    sinceMidnight=datevec(dt-midnight);



...
...
...
...
...
    sinceMidnight(:,4)=sinceMidnight(:,4)+24*sinceMidnight(:,3);
    sinceMidnight(:,3)=0;

    dv=datevec(midnight)+sinceMidnight;

end

function dt=daylightSavingAdjustedDateVecToDatetime(dv,tz)



    dt=datetime(dv(1:3),TimeZone=tz);
    dt=dt+duration(dv(4:6));

end
