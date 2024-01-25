function span=duration2aftimespan(interval)
    if isa(interval,'duration')
        span=OSIsoft.AF.Time.AFTimeSpan(0,0,0,0,0,0,milliseconds(interval));
    elseif isa(interval,'calendarDuration')
        [years,months,days,time]=split(interval,{'years','months','days','time'});
        span=OSIsoft.AF.Time.AFTimeSpan(years,months,days,0,0,0,milliseconds(time));
    end
end