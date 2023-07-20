function hdlsetsignaltable(table)


    if hdlisfiltercoder
        hdlshared.HDLEntitySignalTable('table',table);
    else


        if hdlispirbased
            error(message('HDLShared:directemit:slhdlcodercall',mfilename));
        end
    end
end

