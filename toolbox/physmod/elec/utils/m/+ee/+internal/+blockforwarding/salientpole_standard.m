function out=salientpole_standard(in)











    out=ee.internal.blockforwarding.enumerations(in);


    d_transient_option=in.getValue('d_transient_option');
    d_subtransient_option=in.getValue('d_subtransient_option');

    blockName=strrep(gcb,newline,' ');
    if d_transient_option~=d_subtransient_option
        pm_warning('physmod:ee:library:SpecifyTimeConstantD',blockName);
    end

end