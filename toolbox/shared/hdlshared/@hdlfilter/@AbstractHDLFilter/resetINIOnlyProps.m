function resetINIOnlyProps(~)







    hdlsetparameter('tbrefsignals',false);

    if strcmp('VHDL',hdlgetparameter('target_language'))

        hdlsetparameter('vhdl_package_name',...
        [hdlgetparameter('filter_name'),hdlgetparameter('package_suffix')]);
    end


    hdluniqueprocessname(0);

    hdlsetparameter('entitynamelist',[]);
    hdlsetparameter('entitypathlist',[]);
    hdlsetparameter('entityportlist',[]);
    hdlsetparameter('entityarchlist',[]);
    hdlsetparameter('entitynamelist',[]);
    hdlsetparameter('lasttopleveltargetlang',[]);

    hdlsetparameter('lasttoplevelname',[]);
    hdlsetparameter('lasttoplevelports',[]);
    hdlsetparameter('lasttoplevelportnames',[]);
    hdlsetparameter('lasttopleveldecls',[]);
    hdlsetparameter('lasttoplevelinstance',[]);
    hdlsetparameter('lasttopleveltimestamp',[]);
    hdlsetparameter('filter_excess_latency',0);
end




