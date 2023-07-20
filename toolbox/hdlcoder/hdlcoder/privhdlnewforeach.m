function[defaultStmt,implchoices,implpvpairs,currentStmt]=privhdlnewforeach(blocks)




    implchoices={};
    implpvpairs={};
    defaultStmt=[];
    currentStmt=[];

    if ischar(blocks)
        blocks={blocks};
    end


    for ii=1:length(blocks)
        block=blocks{ii};
        hdlCoder=getHDLCoderObject(block);

        if isempty(hdlCoder)
            return;
        end

        [newDefaultStmt,newImpls,newPVPairs,newCurrentStmt]=hdlCoder.hdlNewForEach(block);

        implchoices={implchoices{:},newImpls{:}};%#ok<CCAT>
        implpvpairs={implpvpairs{:},newPVPairs{:}};%#ok<CCAT>

        defaultStmt=[defaultStmt,newDefaultStmt];%#ok<AGROW>
        currentStmt=[currentStmt,newCurrentStmt];%#ok<AGROW>
    end
end

function hdlCoder=getHDLCoderObject(block)
    hdlCoder=[];
    bdr=bdroot(block);


    if~strcmpi(get_param(bdr,'LibraryType'),'None')
        error(message('hdlcoder:makehdl:blockinlibrary'))
    end

    try
        hdlCoder=hdlmodeldriver(bdr);
    catch me
        warning(message('hdlcoder:makehdl:NoHDLCoder'))
        return;
    end
end
