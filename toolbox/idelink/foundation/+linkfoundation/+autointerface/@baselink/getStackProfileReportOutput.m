function[out,hyperlinkCmd]=getStackProfileReportOutput(h,profInfoObj)












    hyperlinkCmd='';
    for i=1:length(profInfoObj)
        if strcmpi(profInfoObj(i).memoryBuffer.growDirection,'down')
            growDirection='ascending';
        else
            growDirection='descending';
        end
        out(i)=struct(...
        'name',profInfoObj(i).memoryBuffer.name,...
        'startAddress',[profInfoObj(i).memoryBuffer.baseAddress,profInfoObj(i).memoryBuffer.addressPage],...
        'endAddress',[profInfoObj(i).memoryBuffer.endAddress,profInfoObj(i).memoryBuffer.addressPage],...
        'stackSize',profInfoObj(i).memoryLength,...
        'growthDirection',growDirection,...
        'usage',profInfoObj(i).wordsUsed);

        hyperlinkCmd=[hyperlinkCmd,'\n'...
        ,'           name: ',profInfoObj(i).memoryBuffer.name,'\n'...
        ,'   startAddress: [',num2str([profInfoObj(i).memoryBuffer.baseAddress,profInfoObj(i).memoryBuffer.addressPage]),']\n'...
        ,'     endAddress: [',num2str([profInfoObj(i).memoryBuffer.endAddress,profInfoObj(i).memoryBuffer.addressPage]),']\n'...
        ,'      stackSize: ',num2str(profInfoObj(i).memoryLength),' MAUs\n'...
        ,'growthDirection: ',growDirection,'\n'];

    end


