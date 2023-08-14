function[castedDataVals,errMsg]=castEdittedRow(dataValsToCast,dataTypeString,varargin)




    try
        errMsg='';

        if~iscell(dataValsToCast)&&ischar(dataValsToCast)

            resolvedNumber=datacreation.internal.resolveMinMaxStr2Num(dataValsToCast,dataTypeString);



            if(contains(dataValsToCast,'0i')||contains(dataValsToCast,'0j'))&&...
                isreal(resolvedNumber)

                dataValsToCast=complex(resolvedNumber,0);
            else
                dataValsToCast=resolvedNumber;
            end
        end

        if iscell(dataValsToCast)
            hasChar=cellfun(@ischar,dataValsToCast);
            if any(hasChar)

                for kRow=1:length(hasChar)

                    if hasChar(kRow)

                        resolvedNumber=datacreation.internal.resolveMinMaxStr2Num(dataValsToCast{kRow},dataTypeString);

                        if(strcmp('0i',resolvedNumber)||strcmp('0j',resolvedNumber))&&...
                            isreal(resolvedNumber)
                            dataValsToCast{kRow}=complex(resolvedNumber,0);
                        else
                            dataValsToCast{kRow}=resolvedNumber;
                        end
                    end
                end

                dataValsToCast=cell2mat(dataValsToCast);

            end
        end

        castedDataVals=slwebwidgets.doSLCast(dataValsToCast,dataTypeString,varargin{:});


        castedDataVals=slwebwidgets.tableeditor.makeJsonSafe(castedDataVals);


    catch ME_CASTED_ERR

        errMsg=ME_CASTED_ERR.message;
    end
