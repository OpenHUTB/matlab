classdef ProfileLogsAdder<handle










    properties
AdderLogsMap
NetworkEvents
Layers
LayerEvent
Verbose
    end

    methods


        function obj=ProfileLogsAdder(cnnLogs,NetworkEvents,layers,verbose)
            switch verbose
            case{1,2,3}
                obj.AdderLogsMap=cnnLogs;
                obj.NetworkEvents=NetworkEvents;
                obj.Layers=layers;
                obj.Verbose=verbose;
            otherwise

                error('Doesn''t supported yet!');
            end
        end


        function adderLogsMap=populateAdderLayer(obj)
            switch obj.Verbose
            case{1,2}

                obj.populateAdderLayersVerbose_1_2;
            case 3

                obj.populateAdderLayersVerbose_3;
            otherwise

                error('Doesn''t supported yet!');
            end
            adderLogsMap=obj.AdderLogsMap;
        end


        function processorCycle=getProcessorCycle(obj)





            processorCycle=obj.getProcessorLayersCyclesVerbose_1_2.layerLatency;
        end


        function processorLayersCycles=getLayersCycles(obj)
            switch obj.Verbose
            case{1,2}
                processorLayersCycles=obj.getProcessorLayersCyclesVerbose_1_2;
            case 3
                processorLayersCycles=obj.getProcessorLayersCyclesVerbose_3;
            otherwise

                error('Doesn''t supported yet!');
            end
            processorLayersCycles={processorLayersCycles};
        end

    end

    methods(Hidden,Access=protected)


        function populateAdderLayersVerbose_1_2(obj)



            [adderStart,obj.AdderLogsMap('adder_start')]=obj.populateEvents('adder_start');
            [adderDone,obj.AdderLogsMap('adder_done')]=obj.populateEvents('adder_done');

            layerEvent.AdderStart=adderStart;
            layerEvent.AdderDone=adderDone;
            obj.LayerEvent=layerEvent;
        end

        function processorCycle=getProcessorLayersCyclesVerbose_1_2(obj)

            processorCycle.layerLatency=obj.LayerEvent.AdderDone-obj.LayerEvent.AdderStart;
        end



        function populateAdderLayersVerbose_3(obj)



            [adderStart,obj.AdderLogsMap('adder_start')]=obj.populateEvents('adder_start');
            [adderDone,obj.AdderLogsMap('adder_done')]=obj.populateEvents('adder_done');




            [adderIPStart,obj.AdderLogsMap('adder_ip_start')]=obj.populateEvents('adder_ip_start');
            [adderIPDone,obj.AdderLogsMap('adder_ip_done')]=obj.populateEvents('adder_ip_done');
            [adderOPStart,obj.AdderLogsMap('adder_op_start')]=obj.populateEvents('adder_op_start');
            [adderOPDone,obj.AdderLogsMap('adder_op_done')]=obj.populateEvents('adder_op_done');

            layerEvent.AdderStart=adderStart;
            layerEvent.AdderDone=adderDone;
            layerEvent.AdderIPStart=adderIPStart;
            layerEvent.AdderIPDone=adderIPDone;
            layerEvent.AdderOPStart=adderOPStart;
            layerEvent.AdderOPDone=adderOPDone;
            obj.LayerEvent=layerEvent;
        end

        function processorCycle=getProcessorLayersCyclesVerbose_3(obj)

            processorCycle.layerLatency=obj.LayerEvent.AdderDone-obj.LayerEvent.AdderStart;
            processorCycle.IPTotalLatency=obj.LayerEvent.AdderIPDone(end)-obj.LayerEvent.AdderIPStart(1);
            processorCycle.OPTotalLatency=obj.LayerEvent.AdderOPDone(end)-obj.LayerEvent.AdderOPStart(1);
        end


        function[pEvent,events]=populateEvents(obj,eventName)






            events=obj.AdderLogsMap(eventName);
            [pEvent,events]=deal(events{1},events(2:end));
        end

    end

end

