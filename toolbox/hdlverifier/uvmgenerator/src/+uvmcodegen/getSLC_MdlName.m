


function SLC_MdlName=getSLC_MdlName(block_name)


    if isempty(which('coder.internal.Utilities.LocalFindFirstInvalidChar'))


        SLC_MdlName=block_name;
        return;
    end

    firstchar=coder.internal.Utilities.LocalFindFirstValidChar(block_name);
    if(firstchar==0)
        SLC_MdlName='sfun_target';
    else
        lastchar=coder.internal.Utilities.LocalFindFirstInvalidChar(block_name((firstchar+1):end));
        if lastchar==0
            SLC_MdlName=block_name(firstchar:end);
        else
            lastchar=lastchar+firstchar-1;
            SLC_MdlName=block_name(firstchar:lastchar);
        end
    end
end