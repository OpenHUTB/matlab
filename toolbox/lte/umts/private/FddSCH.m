
























function out=FddSCH(chs)
    if isfield(chs,'SCH')
        if strcmpi(chs.SCH,'PSCH')
            out=fdd('FddSCH');
        elseif strcmpi(chs.SCH,'SSCH')
            out=fdd('FddSCH',chs.ScramblingCode);
        else
            error('umts:error','The valid values for Sync Channels are ''PSCH'' and ''SSCH''');
        end
    else

        psch=fdd('FddSCH');
        ssch=fdd('FddSCH',chs.ScramblingCode);
        out=psch+ssch;
    end
    out=transpose(out/sqrt(2));
end