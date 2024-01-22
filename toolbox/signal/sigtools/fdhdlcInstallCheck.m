function fdhdlcInstallCheck

    persistent fdhdlinstalled;

    if isempty(fdhdlinstalled)

        privgenhdl_available=(exist('privgeneratehdl','file')==6)...
        ||(exist('privgeneratehdl','file')==2);
        fdhdlinstalled=builtin('license','test','Filter_Design_HDL_Coder')...
        &&builtin('license','checkout','Filter_Design_HDL_Coder')...
        &&~isempty(ver('hdlfilter'))...
        &&privgenhdl_available;
    end

    if~fdhdlinstalled
        fdhdlc_errid='signal:fdhdlc:nofdhdlc';
        error(message(fdhdlc_errid));
    end

end
