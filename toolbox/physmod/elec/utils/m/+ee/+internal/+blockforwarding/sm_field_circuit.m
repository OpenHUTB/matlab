function out=sm_field_circuit(in)











    out=ee.internal.blockforwarding.enumerations(in);


    parameterization_option=in.getValue('parameterization_option');

    blockName=strrep(gcb,newline,' ');
    if parameterization_option=='2'
        pm_warning('physmod:ee:library:AdditionalParamRequired',blockName,...
        getString(message('physmod:ee:library:comments:electromech:sync:sm_field_circuit:Xddd')),...
        getString(message('physmod:ee:library:comments:electromech:sync:sm_field_circuit:Tddd')),...
        getString(message('physmod:ee:library:comments:electromech:sync:sm_field_circuit:Td0dd')));
    end

end