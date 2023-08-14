function[hdlbody]=hdlandsignals(this,DoneOut,DoneSignals)%#ok








    if hdlgetparameter('isvhdl')
        if(isempty(DoneSignals))
            hdlbody=['  ',hdlsignalname(DoneOut),' <= ''1'''];
        else
            hdlbody=['  ',hdlsignalname(DoneOut),' <= ',hdlsignalname(DoneSignals(1))];
            for i=2:length(DoneSignals)
                hdlbody=[hdlbody,' AND ',hdlsignalname(DoneSignals(i))];
            end
        end
    else
        if(isempty(DoneSignals))
            hdlbody=['  assign ',hdlsignalname(DoneOut),' = 1'];
        else
            hdlbody=['  assign ',hdlsignalname(DoneOut),' = ',hdlsignalname(DoneSignals(1))];
            for i=2:length(DoneSignals)
                hdlbody=[hdlbody,' && ',hdlsignalname(DoneSignals(i))];
            end
        end
    end

    hdlbody=[hdlbody,';\n\n'];