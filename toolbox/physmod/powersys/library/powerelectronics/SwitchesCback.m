function SwitchesCback(block,Device)









    Snubber=get_param(block,'Snubber');
    Rs=get_param(block,'Rs');
    Cs=get_param(block,'Cs');


    OldSnubber=Snubber;

    if strcmp(Rs,'0')
        Snubber=strrep(Snubber,'R','');
        Rs='1.0';
    end

    if strcmpi(Cs,'inf')
        Snubber=strrep(Snubber,'C','');
        Cs='1.0';
    end

    if isempty(Snubber)


        Snubber='no';
    end


    if~strcmp(Snubber,OldSnubber)
        set_param(block,'Snubber',Snubber','Rs',Rs,'Cs',Cs)
    end



    if strcmpi(Rs,'inf')

        Snubber='no';
        Rs='1.0';
        set_param(block,'Snubber',Snubber','Rs',Rs);

    elseif strcmpi(Cs,'0')

        Snubber='no';
        Cs='1.0';
        set_param(block,'Snubber',Snubber','Cs',Cs);

    end



    MaskVisibilities=get_param(block,'MaskVisibilities');
    switch Device
    case 'Breaker'
        R=3;
        C=2;
    otherwise
        R=2;
        C=1;
    end
    switch Snubber
    case 'no'
        MaskVisibilities{end-R}='off';
        MaskVisibilities{end-C}='off';
    case 'R'
        MaskVisibilities{end-R}='on';
        MaskVisibilities{end-C}='off';
    case 'C'
        MaskVisibilities{end-R}='off';
        MaskVisibilities{end-C}='on';
    case 'RC'
        MaskVisibilities{end-R}='on';
        MaskVisibilities{end-C}='on';
    end
    set_param(block,'MaskVisibilities',MaskVisibilities);



    switch Device

    case 'Breaker'

        return

    otherwise

        ports=get_param(block,'ports');
        Measurement=(ports(2)==1);
        showMeasPort=get_param(block,'Measurements');

        if~Measurement&&strcmp(showMeasPort,'on')
            replace_block(block,'Followlinks','on','SearchDepth',1,'Name','m','Outport','noprompt');
        elseif Measurement&&strcmp(showMeasPort,'off')
            replace_block(block,'Followlinks','on','SearchDepth',1,'Name','m','Terminator','noprompt');
        end

        if strcmp(get_param(block,'MaskType'),'Diode')
            if strcmp(showMeasPort,'on')
                set_param(block,'MaskIconFrame','on');
                set_param(block,'MaskIconOpaque','off');
            else
                set_param(block,'MaskIconFrame','off');
                set_param(block,'MaskIconOpaque','on');
            end
        end
    end