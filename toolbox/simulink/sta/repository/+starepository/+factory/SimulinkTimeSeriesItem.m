classdef SimulinkTimeSeriesItem<starepository.factory.Item





    properties

TimeSeries


Name


MATLABTimeSeriesFactory
    end

    methods
        function obj=SimulinkTimeSeriesItem(Name,TimeSeries)

            if isStringScalar(Name)
                Name=char(Name);
            end

            obj=obj@starepository.factory.Item;
            obj.TimeSeries=TimeSeries;
            obj.Name=Name;
            obj.MATLABTimeSeriesFactory=starepository.factory.TimeSeriesItem(obj.Name,obj.TimeSeries);
        end

        function SignalItem=createSignalItemWithoutProperties(obj)

            SignalItem=obj.MATLABTimeSeriesFactory.createSignalItemWithoutProperties();
            SignalItem.isSLTimeseries=true;
            SignalItem.TSName=obj.TimeSeries.Name;
            SignalItem.BlockPath=obj.TimeSeries.BlockPath;
            SignalItem.PortIndex=obj.TimeSeries.PortIndex;
            SignalItem.SignalName=obj.TimeSeries.SignalName;
            SignalItem.SLParentName=obj.TimeSeries.ParentName;
        end

        function SignalItem=createSignalItemWithoutChildren(obj)
            SignalItem=createSignalItemWithoutProperties(obj);
        end

        function signalproperty=buildProperties(obj)

            signalproperty=obj.MATLABTimeSeriesFactory.buildProperties();



        end
    end



    methods(Static)


        function bool=isSupported(dataValue)

            bool=false;

            if isa(dataValue,'Simulink.Timeseries')
                bool=true;
            end
        end

    end

end

