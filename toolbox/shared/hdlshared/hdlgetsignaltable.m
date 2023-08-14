function table=hdlgetsignaltable


    if hdlisfiltercoder
        table=hdlshared.HDLEntitySignalTable;
    else

        error(message('HDLShared:directemit:slhdlcodercall',mfilename));
    end
end
