function cid=getCID(~,cc)




    cid=class(cc);

    if startsWith(cid,'qe.')
        cid=replaceBetween(cid,1,3,'Simulink.');
    end
