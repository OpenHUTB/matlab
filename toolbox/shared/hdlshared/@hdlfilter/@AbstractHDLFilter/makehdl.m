function makehdl(this)






    hdlmakecodegendir;


    this.emit;



    latencymsg=getString(message('HDLShared:hdlfilter:codegenmessage:latency',latency(this)));
    fprintf('%s\n',latencymsg);


    this.hdlwritepackage;

    [topports,topdecls,topinst]=hdlentityports(hdlentitytop);
    hdlsetparameter('lasttopleveltargetlang',hdlgetparameter('target_language'));
    hdlsetparameter('lasttoplevelname',hdlentitytop);
    hdlsetparameter('lasttoplevelports',topports);
    hdlsetparameter('lasttoplevelportnames',hdlentityportnames);
    hdlsetparameter('lasttopleveldecls',topdecls);
    hdlsetparameter('lasttoplevelinstance',topinst);
    hdlsetparameter('lasttopleveltimestamp',datestr(now,31));


    if hdlgetparameter('gen_eda_scripts')
        hdlsetparameter('hdlcompilescript',true);
        hdlsetparameter('hdlcompiletb',false);
        hdlsetparameter('hdlsimscript',false);
        hdlsetparameter('hdlsimprojectscript',false);
        if~strcmpi(hdlgetparameter('hdlsynthtool'),'none')
            hdlsetparameter('hdlsynthscript',true);
        else
            hdlsetparameter('hdlsynthscript',false);
        end
        hdlsetparameter('hdlmapfile',false);
    else

        hdlsetparameter('hdlcompilescript',false);
        hdlsetparameter('hdlcompiletb',false);
        hdlsetparameter('hdlsimscript',false);
        hdlsetparameter('hdlsimprojectscript',false);
        hdlsetparameter('hdlsynthscript',false);
        hdlsetparameter('hdlmapfile',false);
    end



    hE=filterhdlcoder.EDAScripts;
    hE.writeAllScripts;




end


