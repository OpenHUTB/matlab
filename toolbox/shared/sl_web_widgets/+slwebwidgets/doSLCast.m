function castedDataVals=doSLCast(dataValsToCast,dataTypeString,varargin)



    builtinDataTypeStrings=slwebwidgets.BuiltInSlDataTypes.getDataTypeStrings;



    if any(strcmp(class(dataTypeString),{'Simulink.NumericType','embedded.numerictype'}))
        castedDataVals=fi(dataValsToCast,dataTypeString);
        return;
    end

    if any(strcmp(builtinDataTypeStrings,...
        dataTypeString))||~isempty(enumeration(dataTypeString))


        if isfi(dataValsToCast)&&...
            strcmpi(dataTypeString,'half')

            dataValsToCast=double(dataValsToCast);

        end


        if isa(dataValsToCast,'half')&&...
            ~isempty(enumeration(dataTypeString))
            dataValsToCast=double(dataValsToCast);
        end

        castH=str2func(dataTypeString);
        castedDataVals=castH(dataValsToCast);

        if isempty(enumeration(dataTypeString))
            WAS_NOT_REAL=~isreal(dataValsToCast);
            IS_NOW_REAL=isreal(castedDataVals);


            if any(WAS_NOT_REAL&IS_NOW_REAL)&&length(dataValsToCast)==1

                castedDataVals=...
                complex(castedDataVals,0);
            end
        end
    else

        dTObject=eval(dataTypeString);
        if any(strcmp(class(dTObject),{'Simulink.NumericType','embedded.numerictype'}))

            if isempty(varargin)
                castedDataVals=fi(dataValsToCast,dTObject);
            else
                castedDataVals=fi(dataValsToCast,dTObject,'OverflowMode',varargin{1},...
                'RoundMode',varargin{2});
            end
        else
            DAStudio.error('sl_web_widgets:authorinsert:qualifyDataNonSimulinkSupport');
        end
    end
