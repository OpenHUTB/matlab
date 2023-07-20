function out1=mutual_inductor(in)










    out=in;


    if~isempty(in.getValue('operating_limit_action'))

        if strcmp(in.getValue('operating_limit_action'),'1')
            out=out.setValue('operating_limit_action','2');
        end
    end

    if~isempty(in.getValue('fault_action'))
        fault_action=in.getValue('fault_action');



        switch fault_action
        case '1'
            fault_action='simscape.enum.assert.action.none';
        case '2'
            fault_action='simscape.enum.assert.action.warn';
        case '3'
            fault_action='simscape.enum.assert.action.error';
        otherwise

            fault_action=strrep(fault_action,'ee.enum.faults.faultAction','simscape.enum.assert.action');
        end

        out=out.setValue('fault_action',fault_action);
    end


    out1=ee.internal.blockforwarding.faultEnumerations(out);

end