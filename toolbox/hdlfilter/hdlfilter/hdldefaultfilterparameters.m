function hdldefaultfilterparameters(targetlang)

    if nargin<1
        targetlang='vhdl';
    else
        targetlang=lower(targetlang);
    end

    hdldefaultparameters(targetlang);
    hdlsetparameter('vhdl_package_name',...
    [hdlgetparameter('filter_name'),hdlgetparameter('package_suffix')]);
    hdlsetparameter('tb_name',...
    [hdlgetparameter('filter_name'),hdlgetparameter('tb_postfix')]);
    hdlsetparameter('cast_before_sum',0);
    hdlsetparameter('tbrefsignals',false);



