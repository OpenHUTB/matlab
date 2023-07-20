function result=checkfrequency(h,freq)





    result=[];

    freq=squeeze(freq);
    if isvector(freq)&&isnumeric(freq)&&isreal(freq)&&...
        all(freq>=0)&&~any(isinf(freq))&&~any(isnan(freq))
        result=unique(sort(freq(:)));
    end


    if~isa(h,'rfdata.rfdata')&&~isa(h,'rfckt.datafile')&&...
        ~isa(h,'rfckt.passive')&&~isa(h,'rfmodel.rfmodel')
        index=find(result==0.0);
        if~isempty(index)
            minfreq=eps;
            if index(end)<numel(result)
                minfreq=0.001*result(index(end)+1);
                if minfreq>1
                    minfreq=1;
                end
            end
            result(index)=minfreq;
        end
    end


    if isempty(result)
        if isempty(h.Block)
            rferrhole=h.Name;
        else
            rferrhole=upper(class(h));
        end
        error(message('rf:rfbase:rfbase:checkfrequency:FrequencyNotRight',...
        rferrhole));
    end