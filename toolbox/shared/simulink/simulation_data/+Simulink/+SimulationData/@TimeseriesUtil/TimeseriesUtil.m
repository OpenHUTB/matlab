



classdef TimeseriesUtil

    methods(Static=true)


        function sampleDims=getSampleDimensions(ts)





            narginchk(1,1);
            if~isa(ts,'timeseries')&&~isa(ts,'Simulink.Timeseries')
                Simulink.SimulationData.utError('GetSampleDimsArgType');
            elseif builtin('length',ts)~=1
                Simulink.SimulationData.utError('GetSampleDimsArgArray');
            end


            dataDims=size(ts.Data);
            numDims=length(dataDims);
            numSteps=ts.TimeInfo.Length;

            if numDims==2&&numSteps==1&&dataDims(1)==1





                if ts.IsTimeFirst
                    sampleDims=dataDims(end);
                else
                    sampleDims=dataDims;
                end

            elseif numSteps==1&&~ts.IsTimeFirst




                sampleDims=dataDims;

            elseif ts.IsTimeFirst


                sampleDims=dataDims(2:end);

            else


                sampleDims=dataDims(1:end-1);

            end

        end


        function ts=utcreatewithoutcheck(data,time,...
            interpretSingleRowDataAs3D,duptimes,units,varargin)
            ts=timeseries.utcreatewithoutcheck(data,time,...
            interpretSingleRowDataAs3D,duptimes,varargin{1});
            if isempty(units)
                ts.DataInfo.Units='';
            else
                ts.DataInfo.Units=Simulink.SimulationData.Unit(units);
            end
        end



        function ts=utcreateuniformwithoutcheck(data,len,starttime,...
            increment,interpretSingleRowDataAs3D,units,varargin)
            ts=timeseries.utcreateuniformwithoutcheck(data,len,starttime,...
            increment,interpretSingleRowDataAs3D,varargin{1});
            if isempty(units)
                ts.DataInfo.Units='';
            else
                ts.DataInfo.Units=Simulink.SimulationData.Unit(units);
            end
        end

        function[ts,tt_prop]=convertSingleColumnTimeTableToTimeSeries(tt)






            if isempty(tt)
                ts=timeseries;
                return
            end

            tt_prop=tt.Properties;

            var_name=tt.Properties.VariableNames;
            if(numel(var_name)>1)
                Simulink.SimulationData.utError('UnsupportedTTNumCols');
            end
            tt_data=tt.(var_name{1});
            data_size=size(tt_data);
            ts_data=permute(tt_data,circshift((1:length(data_size)),-1));



            if isa(tt.Time,'datetime')

                if any(isnat(tt.Time))||~all(diff(tt.Time)>=0)
                    Simulink.SimulationData.utError('UnsupportedConversionTTtoTS');
                end
            elseif isa(tt.Time,'duration')

                if any(isnan(tt.Time))||~all(diff(tt.Time)>=0)
                    Simulink.SimulationData.utError('UnsupportedConversionTTtoTS');
                end
            else
                assert(false,'time must be a datetime or duration vector');
            end

            tt_time=seconds(tt.Time);
            ts=timeseries(ts_data,tt_time,'Name',var_name{1});
            ts.TimeInfo.Units='seconds';
            tt_units=tt.Properties.VariableUnits;
            if~isempty(tt_units)
                ts.DataInfo.Units=tt_units{1};
            end
        end

        function[tt,ts_prop]=convertTimeSeriesToTimeTable(ts)




            if numel(ts)>1

                ttCell=cell(size(ts));
                ts_propCell=cell(size(ts));
                for idx=1:numel(ts)
                    [ttCell{idx},ts_propCell{idx}]=...
                    Simulink.SimulationData.TimeseriesUtil.locConvertTimeSeriesToTimeTable(ts(idx));
                end
                tt=ttCell;
                ts_prop=ts_propCell;
            else
                [tt,ts_prop]=...
                Simulink.SimulationData.TimeseriesUtil.locConvertTimeSeriesToTimeTable(ts);
            end
        end

        function[tt,ts_prop]=locConvertTimeSeriesToTimeTable(ts)

            if isempty(ts)
                tt={};
                ts_prop=[];
                return
            end


            ts_prop.TimeInfo=ts.TimeInfo;
            ts_prop.DataInfo=ts.DataInfo;

            data_size=size(ts.Data);
            isWide=false;
            tt_time=seconds(ts.Time);
            if~ts.isTimeFirst

                if length(ts.Time)>1


                    if isa(ts.Data,'half')



                        tt_data=half(permute(single(ts.Data),circshift((1:length(data_size)),1)));
                    else
                        tt_data=permute(ts.Data,circshift((1:length(data_size)),1));
                    end
                else










                    tt_data=reshape(ts.Data,[1,data_size]);
                end
            else


                tt_data=ts.Data;

                if data_size(2)>1
                    isWide=true;
                end
            end

            if isempty(ts.Data)


                tt=timetable;
            else
                tt=timetable(tt_time,tt_data,'VariableNames',{'Data'});
                tt.Properties.DimensionNames{1}='Time';

                if isequal(ts_prop.DataInfo.Interpolation.Name,'linear')
                    tt.Properties.VariableContinuity={'continuous'};
                else
                    tt.Properties.VariableContinuity={'step'};
                end

                if isWide
                    tt.Properties.UserData.AppData.IsSimulinkWideSignal=true;
                end
            end
        end
    end

end


