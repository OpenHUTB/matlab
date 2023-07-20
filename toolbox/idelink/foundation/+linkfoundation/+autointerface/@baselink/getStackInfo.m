function[stacks,resetWords]=getStackInfo(h,varargin)





    if nargin==2
        mapfile=varargin{1};
    else
        mapfile=[];
    end


    stackInfo=h.ide_getProcStackInfo;


    stackDefaultValue='A5';

    lenStacks=length(stackInfo.stackType);
    for i=1:lenStacks




        if isempty(mapfile)
            [stackaddress,stacksize]=ide_querySymbolTableForStackInfo(h,stackInfo.stackType(i));
        else
            [stackaddress,stacksize]=ide_queryMapFileForStackInfo(h,mapfile);
        end


        dataType=['uint',num2str(stackInfo.stackType(i).bitsPerAu)];


        stacks(i)=h.createMemoryObject('MemoryBuffer',...
        [stackInfo.stackType(i).desc],...
        stackaddress,...
        stacksize,...
        dataType,...
        stackInfo.direction);



        resetWords(i)=feval(dataType,...
        hex2dec(repmat(stackDefaultValue,1,(stackInfo.stackType(i).bitsPerAu)/8)));
    end

end

