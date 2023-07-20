classdef MemoryInterconnectArbitration<matlab.DiscreteEventSystem




%#codegen
%#ok<*EMCA>

    properties(Nontunable)

        NumMasters=4

        Policy='Round robin'

        ArbDelay=1e-9
    end

    properties(Constant,Hidden)
        PolicySet=matlab.system.StringSet({'Round robin','Equiprobable','Time and priority'})
    end

    properties(Access=private)
IsMemBusy
Requests
Pos
    end

    methods
        function obj=MemoryInterconnectArbitration(varargin)
            coder.allowpcode('plain');
            obj@matlab.DiscreteEventSystem(varargin);
        end


        function[entity,events]=requestEntry(obj,storage,entity,source)

            events=obj.initEventArray;
            if storage<=obj.NumMasters

                entity.data.port=storage;
                obj.Requests(storage)=1;
                if(sum(obj.Requests)==1)&&(~obj.IsMemBusy)

                    obj.Pos=storage;
                    obj.IsMemBusy=true;


                    events=obj.eventForward('storage',obj.NumMasters+1,0);
                end
            elseif storage==obj.NumMasters+1
                events=obj.eventForward('output',1,0);
            end
        end

        function[entity,events]=rearbEntry(obj,storage,entity,source)
            events=obj.initEventArray;
            if storage==obj.NumMasters+2
                obj.IsMemBusy=false;
                events=[events,obj.eventForward('storage',obj.NumMasters+3,0)];
                switch obj.Policy
                case 'Round robin'
                    if sum(obj.Requests)>0
                        obj.Pos=mod(obj.Pos,obj.NumMasters)+1;
                        while obj.Requests(obj.Pos)==0
                            obj.Pos=mod(obj.Pos,obj.NumMasters)+1;
                        end

                        events=[events,obj.eventIterate(obj.Pos,'select',1)];
                    end
                otherwise

                    assert(false);
                end
            elseif storage==obj.NumMasters+3
                events=obj.eventDestroy();
            end
        end

        function events=requestExit(obj,storage,entity,destination)
            events=obj.initEventArray;
            if storage<=obj.NumMasters
                obj.Requests(storage)=0;
            elseif storage==obj.NumMasters+1

            end
        end

        function[entity,events,next]=requestIterate(obj,storage,entity,tag,status)
            obj.IsMemBusy=true;
            events=obj.eventForward('storage',obj.NumMasters+1,0);
            next=true;
        end

        function[entity,events,next]=rearbIterate(obj,storage,entity,tag,status)
            events=obj.initEventArray;
            next=false;
        end

        function events=rearbExit(obj,storage,entity,destination)
            events=obj.initEventArray;
        end
    end

    methods(Access=protected)
        function setupImpl(obj)
            obj.IsMemBusy=false;
            obj.Requests=zeros(1,obj.NumMasters);
            obj.Pos=1;
            if~strcmp(obj.Policy,'Round robin')
                msg=hsb.blkcb2.UtilsCodegenCb('getMessage','soc:msgs:InternalUnsupportedMICArbPolicy');
                error(msg);
            end
        end

        function entityTypes=getEntityTypesImpl(obj)
            entityTypes=[obj.entityType('request'),obj.entityType('rearb')];
        end

        function num=getNumInputsImpl(obj)
            num=obj.NumMasters+1;
        end

        function[inputTypes,outputTypes]=getEntityPortsImpl(obj)
            inputTypes=[repmat({'request'},1,obj.NumMasters),{'rearb'}];
            outputTypes={'request'};
        end

        function[storage,I,O]=getEntityStorageImpl(obj)
            portInReqs=(1:obj.NumMasters);
            portOutReq=obj.NumMasters+1;
            portRearb=obj.NumMasters+2;
            rearbTerminator=obj.NumMasters+3;


            storage(portInReqs)=repmat(obj.queueFIFO('request',1),1,obj.NumMasters);%#ok<*EMVDF>
            storage(portRearb)=obj.queueFIFO('rearb',1);


            storage(portOutReq)=obj.queueFIFO('request',1);


            storage(rearbTerminator)=obj.queueFIFO('rearb',1);


            I=[portInReqs,portRearb];

            O=portOutReq;
        end



        function s=saveObjectImpl(obj)
            s=saveObjectImpl@matlab.System(obj);
            s.IsMemBusy=obj.IsMemBusy;
            s.Requests=obj.Requests;
            s.Pos=obj.Pos;
        end

        function loadObjectImpl(obj,s,isInUse)
            obj.IsMemBusy=s.IsMemBusy;
            obj.Requests=s.Requests;
            obj.Pos=s.Pos;
            loadObjectImpl@matlab.System(obj,s,isInUse);
        end
    end
end
