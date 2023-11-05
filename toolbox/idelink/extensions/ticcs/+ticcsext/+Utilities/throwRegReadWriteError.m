function throwRegReadWriteError(rwException,regname,subfamily)
    if~isempty(findstr(rwException.message,'Given register name'))&&~isempty(findstr(rwException.message,'is invalid'))

        switch subfamily
        case 'C6x'
            subfamily_str=strrep(subfamily,'x','000');
        case{'Rxx','R1x','R2x'}
            subfamily_str=strrep(subfamily,'x','x');
        otherwise
            subfamily_str=strrep(subfamily,'x','00');
        end
        rdException=MException('TICCSEXT:util:RegisterNotSupported',...
        'Register ''%s'' is not a supported register on %s.',regname,subfamily_str);
        throwAsCaller(rdException);
    else
        rdException=MException('TICCSEXT:util:RegReadWriteException',rwException.message);
        throwAsCaller(rdException);
    end

