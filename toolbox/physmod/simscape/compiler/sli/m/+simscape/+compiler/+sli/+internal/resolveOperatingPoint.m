function op=resolveOperatingPoint(slHandle)




    opExpression=get_param(slHandle,'SimscapeOperatingPoint');

    if isempty(opExpression)
        pm_error('physmod:simscape:compiler:sli:op:OperatingPointNotSet',getfullname(bdroot(slHandle)));
    end

    msg=message('physmod:simscape:compiler:sli:op:InvalidOperatingPointSetting',getfullname(bdroot(slHandle)));


    op=builtin('_simscape_internal_resolve_op',getfullname(slHandle),opExpression);
    if isempty(op)
        me=MException(msg);
        me.throw();
    end

end