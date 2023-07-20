function out=roundrotor_standard(in)











    out=ee.internal.blockforwarding.enumerations(in);


    d_transient_option=in.getValue('d_transient_option');
    d_subtransient_option=in.getValue('d_subtransient_option');
    q_transient_option=in.getValue('q_transient_option');
    q_subtransient_option=in.getValue('q_subtransient_option');

    blockName=strrep(gcb,newline,' ');
    if d_transient_option~=d_subtransient_option
        pm_warning('physmod:ee:library:SpecifyTimeConstantD',blockName);
    end
    if q_transient_option~=q_subtransient_option
        pm_warning('physmod:ee:library:SpecifyTimeConstantQ',blockName);
    end

end