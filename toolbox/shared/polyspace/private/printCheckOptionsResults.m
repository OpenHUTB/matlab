function printCheckOptionsResults(ResultDescription,ResultDetails,ResultType)

    strBuff='';
    for descIdx=1:numel(ResultDescription)
        if~isempty(ResultDetails{descIdx})
            for msgIdx=1:numel(ResultDetails{descIdx})
                details=ResultDetails{descIdx}{msgIdx};
                strBuff=sprintf('%s\t%s: %s\n',strBuff,ResultType{descIdx}{msgIdx},details);
            end
        end
    end

    if~isempty(strBuff)
        fprintf(1,'### %s:\n%s\n',message('polyspace:gui:pslink:checkOptionTxt').getString(),strBuff);
    end

