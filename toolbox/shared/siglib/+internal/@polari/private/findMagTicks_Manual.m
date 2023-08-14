function[s_axlim,s_ticks,scale,units]=findMagTicks_Manual(axlim,ticks)




    [~,scale,units]=engunits(max(abs(axlim)));
    s_axlim=ensureValidLim(axlim*scale);




    s_ticks=ticks*scale;





end
