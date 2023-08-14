function[timeVals,dataVals]=convertClientSideDataToTimeAndData(dataFromTable,dataType,isEnum,isFixDT)





    if isFixDT

        for kRow=1:length(dataFromTable)

            for kCol=2:length(dataFromTable{kRow})

                dataFromTable{kRow}{kCol}=dataFromTable{kRow}{kCol}.value;

            end

        end

    end


    NUM_DATA_POINTS=length(dataFromTable);

    if iscell(dataFromTable)
        PAYLOAD_IS_CELL=true;
        NUM_FLAT_COLUMNS=length(dataFromTable{1});
    else
        PAYLOAD_IS_CELL=false;
        [~,NUM_FLAT_COLUMNS]=size(dataFromTable);
    end


    NUM_FLAT_DATA_COLUMNS=NUM_FLAT_COLUMNS-1;


    timeVals=zeros(NUM_DATA_POINTS,1);


    IS_STRING=false;
    if strcmpi(dataType,'string')
        IS_STRING=true;
        dataVals=repmat("",NUM_DATA_POINTS,NUM_FLAT_DATA_COLUMNS);
    elseif isEnum

        enumVals=enumeration(dataType);
        dataVals=repmat(enumVals(1),NUM_DATA_POINTS,NUM_FLAT_DATA_COLUMNS);
    else
        dataVals=zeros(NUM_DATA_POINTS,NUM_FLAT_DATA_COLUMNS);
    end

    if PAYLOAD_IS_CELL
        for kPoint=1:NUM_DATA_POINTS


            isCell=cellfun(@iscell,dataFromTable(kPoint));

            if isCell
                isChar=cellfun(@ischar,dataFromTable{kPoint});


                if IS_STRING||isEnum

                    isChar(2:end)=false;

                end

                if any(isChar)


                    idxOfChar=find(isChar==1);


                    for k=1:length(idxOfChar)


                        switch dataFromTable{kPoint}{idxOfChar(k)}


                        case 'Inf'

                            dataFromTable{kPoint}{idxOfChar(k)}=Inf;


                        case 'inf'

                            dataFromTable{kPoint}{idxOfChar(k)}=Inf;


                        case '-Inf'

                            dataFromTable{kPoint}{idxOfChar(k)}=-Inf;


                        case '-inf'

                            dataFromTable{kPoint}{idxOfChar(k)}=-Inf;


                        case 'NaN'
                            dataFromTable{kPoint}{idxOfChar(k)}=NaN;


                        otherwise

                            idxNaNComplex=regexpi(dataFromTable{kPoint}{idxOfChar(k)},'\w*NaN[ij]$');
                            idxInfComplex=regexpi(dataFromTable{kPoint}{idxOfChar(k)},'\w*Inf[ij]$');

                            idxPlus=strfind(dataFromTable{kPoint}{idxOfChar(k)},'+');
                            idxMinus=strfind(dataFromTable{kPoint}{idxOfChar(k)},'-');

                            if~isempty(idxNaNComplex)

                                tableCellStr=dataFromTable{kPoint}{idxOfChar(k)};
                                tableRealVal=[];%#ok<NASGU>
                                if~isempty(idxPlus)
                                    tableRealVal=tableCellStr((1:idxPlus(end)-1));
                                else
                                    tableRealVal=tableCellStr((1:idxMinus(end)-1));
                                end

                                resolvedValue=datacreation.internal.resolveMinMaxStr2Num(tableRealVal,dataType);
                                dataFromTable{kPoint}{idxOfChar(k)}=complex(resolvedValue,NaN);

                            elseif~isempty(idxInfComplex)
                                tableCellStr=dataFromTable{kPoint}{idxOfChar(k)};
                                tableRealVal=[];%#ok<NASGU>
                                if~isempty(idxPlus)
                                    tableRealVal=tableCellStr((1:idxPlus(end)-1));
                                    complexVal=Inf;
                                else
                                    tableRealVal=tableCellStr((1:idxMinus(end)-1));
                                    complexVal=-Inf;
                                end

                                resolvedValue=datacreation.internal.resolveMinMaxStr2Num(tableRealVal,dataType);

                                dataFromTable{kPoint}{idxOfChar(k)}=complex(resolvedValue,complexVal);
                            else

                                resolvedValue=datacreation.internal.resolveMinMaxStr2Num(dataFromTable{kPoint}{idxOfChar(k)},dataType);

                                dataFromTable{kPoint}{idxOfChar(k)}=resolvedValue;
                            end
                        end

                    end

                end

            end

            if iscell(dataFromTable{kPoint})
                timeVals(kPoint)=dataFromTable{kPoint}{1};

                if IS_STRING
                    cellDataAsVector=dataFromTable{kPoint}(2:end);
                    dataVals(kPoint,1:NUM_FLAT_DATA_COLUMNS)=string(cellDataAsVector);
                elseif isEnum
                    cellDataAsVector=dataFromTable{kPoint}(2:end);
                    dataVals(kPoint,1:NUM_FLAT_DATA_COLUMNS)=cellfun(@eval,strcat([dataType,'.'],cellDataAsVector));
                else
                    cellDataAsVector=cell2mat(dataFromTable{kPoint}(2:end));
                    dataVals(kPoint,1:NUM_FLAT_DATA_COLUMNS)=cellDataAsVector(1:end);
                end

            else
                timeVals(kPoint)=dataFromTable{kPoint}(1);
                dataVals(kPoint,1:NUM_FLAT_DATA_COLUMNS)=dataFromTable{kPoint}(2:NUM_FLAT_COLUMNS);
            end
        end
    else
        timeVals=dataFromTable(:,1);
        dataVals=dataFromTable(:,2:end);
    end
