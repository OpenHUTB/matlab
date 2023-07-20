


classdef InternalSignalManager<handle





























































    properties(Access=private)


        IntSigMap=[];

        GotoSigMap=[];

        GotoTagMap=[];

        FromTagMap=[];
    end

    methods

        function obj=InternalSignalManager()

        end

        function initialSignalMap(obj)

            obj.IntSigMap=containers.Map();
            obj.GotoSigMap=containers.Map();
            obj.GotoTagMap=containers.Map();
            obj.FromTagMap=containers.Map();
        end

        function isa=isInternalSignalDefined(obj,id)
            isa=obj.IntSigMap.isKey(id);
        end

        function setInternalSignal(obj,id,hIntSig)



            if obj.isInternalSignalDefined(id)
                error(message('hdlcommon:workflow:IntSigDefined',id));
            end

            obj.IntSigMap(id)=hIntSig;
            obj.GotoTagMap(id)='';
            obj.FromTagMap(id)='';
        end

        function hIntSig=getInternalSignal(obj,id)



            if~obj.isInternalSignalDefined(id)
                error(message('hdlcommon:workflow:IntSigNotDefined',id));
            end

            hIntSig=obj.IntSigMap(id);
        end

        function connectSignalFrom(obj,id,hFromSig)





            hIntSig=getInternalSignal(obj,id);
            hIntNet=hIntSig.Owner;
            hIntType=hIntSig.Type;





            if isempty(obj.GotoTagMap(id))




                tag=id;
                if~isGotoCompAdded(obj,hIntSig,tag)


                    tag=obj.getUniqueTagName(id);
                    pirelab.getGotoComp(hIntNet,hIntSig,tag);
                end


                obj.GotoTagMap(id)=tag;
            end

            hFromNet=hFromSig.Owner;
            hFromType=hFromSig.Type;
            if~hFromType.isEqual(hIntType)
                error(message('hdlcommon:workflow:SigTypeMismatch',id));
            end



            tag=obj.GotoTagMap(id);
            pirelab.getFromComp(hFromNet,hFromSig,tag);
        end

        function connectSignalTo(obj,id,hGotoSig)





            hIntSig=getInternalSignal(obj,id);
            hIntNet=hIntSig.Owner;
            hIntType=hIntSig.Type;





            if isempty(obj.FromTagMap(id))




                tag=id;
                if~isFromCompAdded(obj,hIntSig,tag)


                    tag=obj.getUniqueTagName(id);
                    pirelab.getFromComp(hIntNet,hIntSig,tag);
                end


                obj.FromTagMap(id)=tag;
            end

            hGotoNet=hGotoSig.Owner;
            hGotoType=hGotoSig.Type;
            if~hGotoType.isEqual(hIntType)
                error(message('hdlcommon:workflow:SigTypeMismatch',id));
            end

            if obj.GotoSigMap.isKey(id)

                error(message('hdlcommon:workflow:GotoCompExist',id));
            else





                tag=obj.FromTagMap(id);
                pirelab.getGotoComp(hGotoNet,hGotoSig,tag);


                obj.GotoSigMap(id)=hGotoSig;

            end

        end
    end

    methods(Access=private)
        function isa=isGotoCompAdded(~,hIntSig,tagName)


            isa=false;
            if hIntSig.NumberOfReceivers>0
                receivers=hIntSig.getReceivers;
                for ii=1:length(receivers)
                    receiver=receivers(ii);
                    portBufferName=receiver.Owner.Name;
                    gotoCompName=sprintf('%s_goto',tagName);
                    if strcmp(portBufferName,gotoCompName)
                        isa=true;
                        return;
                    end
                end
            end
        end

        function isa=isFromCompAdded(~,hIntSig,tagName)


            isa=false;
            if hIntSig.NumberOfDrivers>0
                portBufferName=hIntSig.getDrivers.Owner.Name;
                fromCompName=sprintf('%s_from',tagName);
                if strcmp(portBufferName,fromCompName)
                    isa=true;
                    return;
                end
            end
        end

        function tag=getUniqueTagName(obj,id)






            if isempty(obj.GotoTagMap(id))&&isempty(obj.FromTagMap(id))
                tag=id;
            else
                tag=append(id,'1');
            end
        end
    end

end

