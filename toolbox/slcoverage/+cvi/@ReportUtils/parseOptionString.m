
function options=parseOptionString(options,optionStr)




    optionsTable=cvi.ReportUtils.getOptionsTable;

    [rowCnt,colCnt]=size(optionsTable);%#ok<ASGLU>
    for i=1:rowCnt
        if~strcmp(optionsTable{i,1},'>----------')
            tokens=regexp(optionStr,['-',optionsTable{i,3},'\s*=\s*([0,1])'],'tokens');
            if isempty(tokens)
                val=optionsTable{i,4};
            else
                val=strcmp(tokens{1}{1},'1');
            end
            options.(optionsTable{i,2})=val;
        end
    end

