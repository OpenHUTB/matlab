function propout=utManageDataStorage(tsin,eventdata,varname,writeflag,varargin)














    var=hds.variable(varname);
    idx=find(tsin.Cache_.Variables==var);


    if isempty(idx)

        tsin.Cache_.Variables=[tsin.Cache_.Variables;var];
        switch varname
        case 'Data'
            ValueArray=Simulink.TimeseriesArray('Data');
            ValueArray.Metadata.Interpolation=tsdata.interpolation('zoh');
            tsin.Data_=[tsin.Data_;ValueArray];

        case 'Time'
            ValueArray=tsdata.timeseriesArray('Time');
            tsin.Data_=[tsin.Data_;ValueArray];
            tsin.setgrid('Time');

        case 'Quality'
            ValueArray=tsdata.timeseriesArray('Quality');
            tsin.Data_=[tsin.Data_;ValueArray];
        end
    else

        ValueArray=tsin.Data_(idx);
    end


    if~isempty(ValueArray.metadata)
        ValueArray.GridFirst=ValueArray.metadata.GridFirst;
    end


    if~writeflag

        propout=ValueArray.getArray;


        if strcmp(varname,'Time')&&~isempty(propout)
            try
                [NewValue,GridSize,SampleSize]=...
                utCheckArraySize(tsin,{propout},var,ValueArray.GridFirst);
                if~isequal(SampleSize,[1,1])
                    error(message('Simulink:Logging:SlTimeseriesDataStorageArraySize'));
                end
            catch
                warning(message('Simulink:Logging:SlTimeseriesDataStorageArraySize'));
            end
        end

    else
        if strcmp(ValueArray.ReadOnly,'off')


            if~isempty(eventdata)


                try
                    [NewValue,GridSize,SampleSize]=...
                    utCheckArraySize(tsin,{eventdata},var,ValueArray.GridFirst);
                catch
                    try
                        [NewValue,GridSize,SampleSize]=...
                        utCheckArraySize(tsin,{eventdata},var,...
                        ~ValueArray.GridFirst);
                        ValueArray.GridFirst=~ValueArray.GridFirst;

                        if strcmp(ValueArray.Variable.Name,'Data')
                            ValueArray.MetaData=setGridFirst(ValueArray.MetaData,ValueArray.GridFirst);
                        end
                    catch
                        error(message('Simulink:Logging:SlTimeseriesDataStorageArrayMismatch'));
                    end
                end

                if isscalar(SampleSize)&&SampleSize==1
                    SampleSize=[1,1];
                end

                ValueArray.SampleSize=SampleSize;
                if~isempty(ValueArray.SampleSize)&&~isequal(ValueArray.SampleSize,SampleSize)
                    warning(message('Simulink:Logging:SlTimeseriesDataStorageRedimensioned'));
                end
                ValueArray.setArray(ValueArray.utReshape(NewValue,GridSize));
            else
                ValueArray.SampleSize=[];
                ValueArray.setArray([]);
            end
        else
            error(message('Simulink:Logging:SlTimeseriesDataStorageReadOnly'));
        end



        propout=[];



        if nargin<5||~varargin{1}

            tsin.fireDataChangeEvent(handle.EventData(tsin,'datachange'));
        end
    end
