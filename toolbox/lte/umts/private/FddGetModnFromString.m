




function out=FddGetModnFromString(modulation)
    if~(ischar(modulation)||isstring(modulation))
        out=modulation;
    else
        switch upper(modulation)
        case 'QPSK',out=0;
        case 'BPSK',out=0;
        case '4PAM',out=1;
        case '16QAM',out=1;
        case '64QAM',out=2;
        otherwise
            error('umts:error','The modulation parameter is not one of (''BPSK'',''QPSK'',''16QAM'',''64QAM'' or ''4PAM'')');
        end
    end
end
