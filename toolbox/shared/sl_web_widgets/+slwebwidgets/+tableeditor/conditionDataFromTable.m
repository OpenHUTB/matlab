function dataFromTable=conditionDataFromTable(dataFromTable)




    isChar=cellfun(@ischar,{dataFromTable(:).signaldata});


    if any(isChar)


        idxOfChar=find(isChar==1);


        for k=1:length(idxOfChar)


            switch dataFromTable(idxOfChar(k)).signaldata


            case 'Inf'

                dataFromTable(idxOfChar(k)).signaldata=Inf;


            case 'inf'

                dataFromTable(idxOfChar(k)).signaldata=Inf;


            case '-Inf'

                dataFromTable(idxOfChar(k)).signaldata=-Inf;


            case '-inf'

                dataFromTable(idxOfChar(k)).signaldata=-Inf;


            case 'NaN'
                dataFromTable(idxOfChar(k)).signaldata=NaN;


            otherwise


                dataFromTable(idxOfChar(k)).signaldata=str2num(dataFromTable(idxOfChar(k)).signaldata);
            end

        end


    end


    isChar=cellfun(@ischar,{dataFromTable(:).signaltime});


    if any(isChar)

        idxOfChar=find(isChar==1);

        for k=1:length(idxOfChar)

            switch dataFromTable(idxOfChar(k)).signaltime

            case 'Inf'

                dataFromTable(idxOfChar(k)).signaltime=Inf;

            case 'inf'

                dataFromTable(idxOfChar(k)).signaltime=Inf;

            case '-Inf'

                dataFromTable(idxOfChar(k)).signaltime=-Inf;

            case '-inf'

                dataFromTable(idxOfChar(k)).signaltime=-Inf;

            case 'NaN'
                dataFromTable(idxOfChar(k)).signaltime=NaN;

            end

        end


    end
