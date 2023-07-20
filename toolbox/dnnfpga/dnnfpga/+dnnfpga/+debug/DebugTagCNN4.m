


classdef DebugTagCNN4<handle


    properties(Access=protected)

        DebugNametoTagMap=[];
        DebugNametoIDMap=[];
        DebugIDtoNameMap=[];
    end

    methods
        function obj=DebugTagCNN4()

            obj.DebugNametoTagMap=containers.Map();
            obj.DebugNametoIDMap=containers.Map();
            obj.DebugIDtoNameMap=containers.Map('KeyType','double','ValueType','any');

            obj.buildDebugTagList;
        end


        function buildDebugTagList(obj)











            obj.addDebugTag('input','CONV_DEBUGOUTTAG_0');
            obj.addDebugTag('result','CONV_DEBUGOUTTAG_1');
            obj.addDebugTag('syncIP0','CONV_DEBUGOUTTAG_2');
            obj.addDebugTag('syncIP1','CONV_DEBUGOUTTAG_3');
            obj.addDebugTag('syncOP0','CONV_DEBUGOUTTAG_4');
            obj.addDebugTag('syncCONV','CONV_DEBUGOUTTAG_5');
            obj.addDebugTag('lcIP0','CONV_DEBUGOUTTAG_6');
            obj.addDebugTag('lcIP1','CONV_DEBUGOUTTAG_7');
            obj.addDebugTag('lcOP0','CONV_DEBUGOUTTAG_8');
            obj.addDebugTag('lcCONV','CONV_DEBUGOUTTAG_9');



            obj.addDebugTag('bitstreamChecksum','TOP_DEBUGOUTTAG_1');
            obj.addDebugTag('networkChecksum','TOP_DEBUGOUTTAG_2');


            obj.addDebugTag('profilerTSmem','TOP_PROFILETAG_1');
            obj.addDebugTag('profilerMSGmem','TOP_PROFILETAG_2');
            obj.addDebugTag('profilerTScounter','TOP_PROFILETAG_3');
            obj.addDebugTag('profilerMSGcounter','TOP_PROFILETAG_4');
            obj.addDebugTag('profilerControl','TOP_PROFILETAG_5');
            obj.addDebugTag('profilerTimeCounter','TOP_PROFILETAG_6');


            obj.addDebugTag('FCinput','FC_DEBUGOUTTAG_0');
            obj.addDebugTag('FCresult','FC_DEBUGOUTTAG_1');












        end


        function addDebugTag(obj,debugName,debugTag)
            obj.DebugNametoTagMap(debugName)=debugTag;



            newID=length(obj.DebugNametoTagMap)-1;
            obj.DebugNametoIDMap(debugName)=newID;
            obj.DebugIDtoNameMap(newID)=debugName;
        end

        function debugTag=getDebugTag(obj,debugName)
            debugTag=obj.DebugNametoTagMap(debugName);
        end

        function debugID=getDebugID(obj,debugName)
            debugID=obj.DebugNametoIDMap(debugName);
        end

        function debugName=getDebugName(obj,debugID)
            debugName=obj.DebugIDtoNameMap(debugID);
        end

        function map=getDebugNametoIDMap(obj)
            map=obj.DebugNametoIDMap;
        end


        function debugCCParams=emitCCDebugParameters(obj)








            debugCCParams.DebugParams={};

            debugIDList=obj.DebugIDtoNameMap.keys;
            for ii=1:length(debugIDList)
                debugID=debugIDList{ii};
                debugName=obj.getDebugName(debugID);
                debugParam.debugblock=debugName;
                debugParam.debugTag=obj.getDebugTag(debugName);
                debugParam.debugID=obj.getDebugID(debugName);

                debugCCParams.DebugParams{end+1}=debugParam;
            end
        end
    end
end


