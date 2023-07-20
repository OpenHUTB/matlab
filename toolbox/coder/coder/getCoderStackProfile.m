function stackProfile=getCoderStackProfile(MATLABFunction)











    if nargin>0
        if iscell(MATLABFunction)&&~isempty(MATLABFunction)
            MATLABFunction=MATLABFunction{1};
        end
        MATLABFunction=convertStringsToChars(MATLABFunction);
    end

    inParser=inputParser;
    inParser.FunctionName=mfilename;
    addRequired(inParser,'MATLABFunction',@ischar);
    parse(inParser,MATLABFunction);


    stackProfile=coder.connectivity.MATLABSILPILInterfaceStore.getInstance().getStackProfileObject(...
    MATLABFunction);

end
