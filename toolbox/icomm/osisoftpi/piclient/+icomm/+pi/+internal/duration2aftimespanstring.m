function span=duration2aftimespanstring(interval)
    if isa(interval,'duration')
        span=sprintf('%d milliseconds',milliseconds(interval));
    elseif isa(interval,'calendarDuration')
        [years,months,days,time]=split(interval,{'years','months','days','time'});
        span=sprintf('%d years %d months %d days %d milliseconds',years,months,days,milliseconds(time));
    end
end