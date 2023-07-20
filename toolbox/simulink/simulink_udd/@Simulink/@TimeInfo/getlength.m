function outLength=getlength(this,~)



    if~isempty(this.Increment)&&...
        ~isnan(this.Increment)&&this.Increment>0
        numIntervals=min(length(this.Start),length(this.End));
        if~any(isnan(this.IntervalLength))
            outLength=sum(this.IntervalLength);
        else
            outLength=0;
            for k=1:numIntervals
                if this.End(k)-this.Start(k)>=0
                    outLength=outLength+round((this.End(k)...
                    -this.Start(k))/this.Increment)+1;
                end
            end
        end

    elseif~isempty(this.Time_)
        outLength=length(this.Time_);
    else

        outLength=this.Length_;
    end