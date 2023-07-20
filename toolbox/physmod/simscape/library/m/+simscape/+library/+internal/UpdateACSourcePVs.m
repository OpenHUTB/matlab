function pvs=UpdateACSourcePVs(block)







    pvs={};
    blockType=get_param(block,'BlockType');
    isSimscapeBlock=strcmp(blockType,'SimscapeBlock');
    if isSimscapeBlock
        omega=get_param(block,'omega');

        if~strcmp(omega,'0')

            old_unit=get_param(block,'omega_unit');
            Hz_compatible_units=pm_suggestunits('Hz');

            switch old_unit
            case Hz_compatible_units
                pvs{1}='frequency';
                pvs{2}=omega;
                pvs{3}='frequency_unit';
                pvs{4}=old_unit;
            case '1/s'
                pvs{1}='frequency';
                pvs{2}=['(',omega,')/(2*pi)'];
                pvs{3}='frequency_unit';
                pvs{4}='Hz';
            case 'rad/s'
                pvs{1}='frequency';
                pvs{2}=['(',omega,')/(2*pi)'];
                pvs{3}='frequency_unit';
                pvs{4}='Hz';
            case 'rpm'
                pvs{1}='frequency';
                pvs{2}=['(',omega,')/60'];
                pvs{3}='frequency_unit';
                pvs{4}='Hz';
            case 'deg/s'
                pvs{1}='frequency';
                pvs{2}=['(',omega,')/360'];
                pvs{3}='frequency_unit';
                pvs{4}='Hz';
            case 'rev/s'
                pvs{1}='frequency';
                pvs{2}=omega;
                pvs{3}='frequency_unit';
                pvs{4}='Hz';
            otherwise
                pvs{1}='frequency';
                pvs{2}=omega;
                pvs{3}='frequency_unit';
                pvs{4}=old_unit;
            end

            pvs{5}='omega';
            pvs{6}='0';
            pvs{7}='omega_unit';
            pvs{8}='rad/s';
        end
    end
end