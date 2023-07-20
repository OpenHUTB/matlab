function dummy(userdata,cbinfo)
    message=sprintf('%s was clicked',userdata);
    h=msgbox(message,'Success');

    ah=get(h,'CurrentAxes');
    ch=get(ah,'Children');
    set(ch,'FontSize',10)
end