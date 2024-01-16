function[uniqueName,slHandle]=addBlock(~,hC,blkType,blkNameWithPath,makeNameUnique)

    if nargin<5
        makeNameUnique=true;
    end
    blkNameWithPath=convertStringsToChars(blkNameWithPath);
    blkNameWithPath=hdlfixblockname(blkNameWithPath);
    uniqueName=slpir.PIR2SL.getUniqueName(blkNameWithPath);

    if makeNameUnique
        slHandle=add_block(blkType,uniqueName);
        if~isempty(hC)
            name=get_param(slHandle,'Name');
            name=strrep(name,'/','//');
            hC.Name=name;
        end
    else
        slHandle=add_block(blkType,uniqueName);
    end
    if~isempty(hC)
        hC.setGMHandle(slHandle);
    end

end


function charOut=convertStringsToChars(argIn)
    if isstring(argIn)
        charOut=argIn.char;
    else
        charOut=argIn;
    end
end
