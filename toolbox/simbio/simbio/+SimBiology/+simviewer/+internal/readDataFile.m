function out=readDataFile(fullFile)














    try
        t=readFileIntoTable(fullFile);
        header=getHeader(t);



        numericTable=varfun(@convertNumber,t);


        if~isempty(header)
            header=matlab.lang.makeValidName(header);
            header=matlab.lang.makeUniqueStrings(header);
            numericTable.Properties.VariableNames=header;
            numericTable=numericTable(2:end,:);
        else
            numericTable.Properties.VariableNames=t.Properties.VariableNames;
        end


        props=numericTable.Properties.VariableNames;
        colsToDrop=[];
        for i=1:length(props)
            val=props{i};
            column=numericTable.(val);

            if(length(find(cellfun(@isnan,num2cell(column))))==length(column))
                colsToDrop(end+1)=i;%#ok<AGROW>
            end
        end

        if~isempty(colsToDrop)
            numericTable(:,colsToDrop)=[];
        end
    catch
        out=dataset;
        return;
    end


    out=table2dataset(numericTable);

end


function out=readFileIntoTable(fullfile)

    [~,~,ext]=fileparts(fullfile);
    if strcmp(ext,'.txt')


        [~,delimiter,~]=importdata(fullfile);
        out=readtable(fullfile,'Format','auto','ReadVariableNames',false,'Delimiter',delimiter);
    else
        out=readtable(fullfile,'Format','auto','ReadVariableNames',false);
    end
end





function out=convertNumber(val)
    out=val;
    if~isnumeric(val)
        out=str2double(val);
    end
end















function out=getHeader(t)
    try
        firstRow=t{1,:};
    catch

        out={};
        return;
    end

    if~isempty(firstRow)

        if isa(firstRow,'double')
            out={};
            return;
        end




        for i=1:length(firstRow)
            val=firstRow{i};
            if strcmp(val,'NaN')||(isnumeric(str2double(val))&&~isnan(str2double(val)))
                out={};
                return;
            end
        end
    end

    out=firstRow;
end