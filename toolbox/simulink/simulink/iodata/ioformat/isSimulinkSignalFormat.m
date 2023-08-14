function[bool]=isSimulinkSignalFormat(aVar,varargin)




















    if nargin>0
        aVar=convertStringsToChars(aVar);
    end

    if nargin>1&&isstruct(varargin{1})
        filterDataTypeStruct=varargin{1};


        if~isfield(filterDataTypeStruct,'ALLOW_FOR_EACH')
            filterDataTypeStruct.ALLOW_FOR_EACH=true;
        end

        if~isfield(filterDataTypeStruct,'ALLOW_EMPTY_DS')
            filterDataTypeStruct.ALLOW_EMPTY_DS=true;
        end

        if~isfield(filterDataTypeStruct,'ALLOW_EMPTY_TS')
            filterDataTypeStruct.ALLOW_EMPTY_TS=true;
        end

        if~isfield(filterDataTypeStruct,'ALLOW_DATASORE_MEM')
            filterDataTypeStruct.ALLOW_DATASORE_MEM=true;
        end

        if~isfield(filterDataTypeStruct,'ALLOW_TIME_TABLE')
            filterDataTypeStruct.ALLOW_TIME_TABLE=true;
        end

    else
        filterDataTypeStruct.ALLOW_FOR_EACH=true;
        filterDataTypeStruct.ALLOW_EMPTY_DS=true;
        filterDataTypeStruct.ALLOW_EMPTY_TS=true;
        filterDataTypeStruct.ALLOW_DATASORE_MEM=true;
        filterDataTypeStruct.ALLOW_TIME_TABLE=true;
    end



    bool=false;


    if isa(aVar,'Simulink.ModelDataLogs')||...
        isa(aVar,'Simulink.Timeseries')||...
        isa(aVar,'Simulink.TsArray')
        return;
    end

    if isa(aVar,'Simulink.SimulationData.Dataset')||isa(aVar,'Simulink.SimulationData.DatasetRef')

        if~isscalar(aVar)||...
            isempty(aVar)
            return;
        end

        if aVar.getLength==0&&filterDataTypeStruct.ALLOW_EMPTY_DS
            bool=true;
            return;
        end


        for kSeq=1:aVar.getLength
            bool=isSimulinkSignalFormat(aVar.getElement(kSeq),filterDataTypeStruct)&&...
            ~isa(aVar.getElement(kSeq),'Simulink.SimulationData.Dataset')&&...
            ~isa(aVar.getElement(kSeq),'Simulink.SimulationData.DatasetRef')&&...
            ~(isstruct(aVar.getElement(kSeq))&&~isBusSignal(aVar.getElement(kSeq)));


            if bool==false
                return
            end
        end

    elseif isSLTimeTable(aVar)&&filterDataTypeStruct.ALLOW_TIME_TABLE

        bool=true;
        return;

    elseif(Simulink.sdi.internal.Util.isSDISupportedType(aVar)&&~isa(aVar,'Simulink.SimulationOutput'))||...
        isGroundSignal(aVar)||...
        Simulink.sdi.internal.Util.isSimulationDataElement(aVar)||...
        isTimeExpression(aVar)



        if Simulink.sdi.internal.Util.isMATLABTimeseries(aVar)





            if isempty(aVar)&&~filterDataTypeStruct.ALLOW_EMPTY_TS
                return
            end

            if~isscalar(aVar)
                return
            end

            boolDataEmpty=timeSeriesEmptyCheck(aVar);
            isUnsupportedData=timeSeriesUnsupportedCheck(aVar);


            if boolDataEmpty||isUnsupportedData

                return;
            end
        end


        if Simulink.sdi.internal.Util.isSimulationDataElement(aVar)


            if isa(aVar.Values,'Simulink.ModelDataLogs')||...
                isa(aVar.Values,'Simulink.Timeseries')||...
                isa(aVar.Values,'Simulink.TsArray')
                return;
            end


            if Simulink.sdi.internal.Util.isMATLABTimeseries(aVar.Values)


                if isa(aVar,'Simulink.SimulationData.DataStoreMemory')&&...
                    ~filterDataTypeStruct.ALLOW_DATASORE_MEM

                    return;
                end



                if Simulink.sdi.internal.Util.isMATLABTimeseries(aVar.Values)&&...
                    isempty(aVar.Values)&&...
                    ~filterDataTypeStruct.ALLOW_EMPTY_TS
                    return;
                elseif isscalar(aVar.Values)&&((timeSeriesEmptyCheck(aVar.Values)&&~filterDataTypeStruct.ALLOW_FOR_EACH)...
                    ||timeSeriesUnsupportedCheck(aVar.Values))
                    return
                elseif~isscalar(aVar.Values)&&~isempty(aVar.Values)&&(Simulink.sdi.internal.Util.isMATLABTimeseries(aVar.Values))

                    IS_LOGGED_FOREACH=isLoggedForEachFormat(aVar);

                    if(IS_LOGGED_FOREACH&&~filterDataTypeStruct.ALLOW_FOR_EACH)||~IS_LOGGED_FOREACH
                        return
                    end

                end

            elseif(isSLTimeTable(aVar.Values)&&~isempty(aVar.Values))&&filterDataTypeStruct.ALLOW_TIME_TABLE

                bool=true;
                return;

            elseif((iscell(aVar.Values)&&isempty(aVar.Values))||...
                (isa(aVar.Values,'timetable')&&isempty(aVar.Values)))

                if filterDataTypeStruct.ALLOW_EMPTY_TS&&...
                    filterDataTypeStruct.ALLOW_TIME_TABLE
                    bool=true;
                    return;
                else
                    return;
                end
            end
        end

        bool=true;
        return


    elseif isBusSignal(aVar,filterDataTypeStruct.ALLOW_TIME_TABLE)

        bool=true;

    elseif is2dDataArray(aVar)

        bool=true;
    elseif isDataArray(aVar)

        bool=true;


    elseif isFunctionCallSignal(aVar)
        bool=true;

    elseif(isDerivedSignal(aVar))
        bool=true;
    end

end

function boolDataEmpty=timeSeriesEmptyCheck(aVar)





    boolDataEmpty=(isempty(aVar.Data)||isempty(aVar.Time));


end

