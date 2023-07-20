
function unique_name=getUniqueName(matFile,networkName,dataType,inputSizes)



    unique_name=[matFile,'_',networkName,'_',dataType,'_'];

    for i=1:numel(inputSizes)

        unique_name=[unique_name...
        ,coder.const(@num2str,inputSizes{i}(1)),'_'...
        ,coder.const(@num2str,inputSizes{i}(2)),'_'...
        ,coder.const(@num2str,inputSizes{i}(3)),'_'...
        ,coder.const(@num2str,inputSizes{i}(4)),'_'];
    end

end
