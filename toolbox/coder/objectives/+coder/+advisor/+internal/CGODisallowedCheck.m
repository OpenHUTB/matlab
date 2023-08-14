


function result=CGODisallowedCheck()

    persistent checkID;
    persistent checkHash;

    if isempty(checkID)
        checkID{1}='mathworks.codegen.MdlrefConfigMismatch';
        checkID{2}='Disable signal logging';
        checkID{3}='Check for non-continuous signals driving derivative ports';
        checkID{4}='Set up signal logging';
        checkID{5}='Check update diagram status';
        checkID{6}='Create reference data';
        checkID{7}='Implement logic signals as Boolean data';
        checkID{8}='Check for removing redundant specification between signal objects and blocks';
        checkID{9}='Check for output data type inheritance';
        checkID{10}='Relax input data type settings';
        checkID{11}='Summarize data types';
        checkID{12}='Propose scaling for blocks';
        checkID{13}='Current numerical errors';
        checkID{14}='Analyze logged signals';
    end

    if isempty(checkHash)
        checkHash=coder.advisor.internal.HashMap();

        for i=1:length(checkID)
            checkHash.put(checkID{i},i);
        end
    end

    result.checkID=checkID;
    result.checkHash=checkHash;

    return;
end


