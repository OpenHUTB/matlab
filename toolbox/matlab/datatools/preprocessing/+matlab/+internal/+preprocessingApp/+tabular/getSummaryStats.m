function stats=getSummaryStats(v)



    stats=struct;

    stats.Type=class(v);
    try
        stats.NumUniqueValues=length(unique(v));
    catch
        if iscell(v)
            stats.NumUniqueValues=length(unique(cellfun(@num2str,v,"UniformOutput",0)));
        end
    end
    stats.HasDuplicates=stats.NumUniqueValues~=length(v);
    if~iscalendarduration(v)
        if~iscell(v)
            stats.IsSorted=issorted(v,'monotonic');
        else
            try
                stats.IsSorted=issorted(v);
            catch
                stats.IsSorted=issorted(cell2mat(v));
            end
        end
    end

    if size(v,1)==1




        stats.NumMissing=double(ismissing(v));
    else
        stats.NumMissing=sum(ismissing(v));
    end
    stats.Min=NaN;
    stats.Max=NaN;
    stats.Mean=NaN;
    stats.Median=NaN;
    stats.Mode=NaN;
    stats.SD=NaN;

    if isnumeric(v)||isdatetime(v)||isduration(v)
        stats.Min=min(v);
        stats.Max=max(v);
        stats.Mean=mean(v,"omitnan");
        stats.Median=median(v,"omitnan");
        stats.Mode=mode(v);
        if isinteger(v)
            stats.SD=std(double(v),"omitnan");
        else
            stats.SD=std(v,"omitnan");
        end
    end
end
