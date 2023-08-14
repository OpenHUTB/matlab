function lineInfo=linePathToStruct(linePath)




    hp=string(linePath);
    separatorIndices=regexp(hp,"#","start");

    lineInfo=struct(...
    'Path',hp.extractBefore(separatorIndices(end-1)),...
    'ZOrder',str2double(hp.extractBetween(separatorIndices(end-1)+1,separatorIndices(end)-1)),...
    'Points',hp.extractAfter(separatorIndices(end))...
    );
end
