function y=isSimdService(aService,instructionSetString)
    if isempty(aService.For)
        y=false;
    else
        y=strcmp(aService.For.Id,instructionSetString);
    end
end