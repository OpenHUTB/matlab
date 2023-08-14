function fileName=createFileNameFromDUTName(dut,postfix)




    [~,dutName,~]=fileparts(dut);
    dutName=matlab.lang.makeValidName(dutName,'Prefix','dut');
    if nargin<2||isempty(postfix)
        fileName=dutName;
    else
        fileName=sprintf('%s_%s',dutName,postfix);
    end

end