function A=getData(h)








    if isfinite(h.Increment)


        numIntervals=min(length(h.End),length(h.Start));
        if numIntervals==0
            A=[];
            return
        end
        if length(h.End)~=length(h.Start)
            warning(message('Simulink:TimeInfo:DifferingStartAndEnd'));
        end


        if all(h.End(1:numIntervals)<h.Start(1:numIntervals))
            A=[];
            return
        end


        A=[];

        if numIntervals==1&&~isnan(h.IntervalLength),


            L=cast(h.IntervalLength,class(h.Start));
            A=h.Start+h.Increment*(0:L-1)';
        else
            for k=1:numIntervals,
                A1=(h.Start(k):h.Increment:h.End(k))';



                if(h.End(k)-A1(end))>(A1(end)+h.Increment-h.End(k))
                    A1=[A1;A1(end)+h.Increment];%#ok<AGROW>
                end
                A=[A;A1];%#ok<AGROW>
            end
            A=sort(A);
        end
    else
        A=h.Time_;
    end
