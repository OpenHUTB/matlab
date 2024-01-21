function shs(source)

    if isempty(coder.target)
        isShared=any(strcmpi(source,shareList()));

        if isShared
pcsetshsany
        else
pcsetshs
        end
    end
end


function list=shareList()
    list={'pcplayer','pointCloud'};
end
