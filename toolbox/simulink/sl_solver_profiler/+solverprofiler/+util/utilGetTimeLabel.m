
function t=utilGetTimeLabel
    t=datestr(clock,0);
    t=strrep(t,'-','_');
    t=strrep(t,' ','_');
    t=strrep(t,':','_');
end