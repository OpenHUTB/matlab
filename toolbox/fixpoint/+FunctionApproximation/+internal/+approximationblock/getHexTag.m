function hexTag=getHexTag(blockPath)






    hexAPI=@(x)char(fixed.internal.utility.shaHex(x));
    hexTag=hexAPI([blockPath,hexAPI(randi(2^52,16,1)),hexAPI(datestr(now,'yyyymmddTHHMMSSFFF'))]);
end
