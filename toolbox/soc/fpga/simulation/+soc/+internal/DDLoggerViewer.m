classdef DDLoggerViewer<handle
    methods
        function obj=DDLoggerViewer(blkH,ddBlks,ddFilter)
            obj.modelName=getfullname(bdroot(blkH));
            obj.clientId=mat2str(bdroot(blkH));
            obj.ddBlks=ddBlks;
            obj.ddFilter=ddFilter;
        end
        function turnOnLogging(obj)%#ok<*MANU>

            [success,la,wasAlreadyOpen]=obj.launchLAAndWaitForOpenComplete();
            if success
                startIdx=obj.getTraceCount();
                obj.setLoggingState('on');
                obj.formatWaveforms(startIdx);
            else
                obj.setLoggingState('on');
            end

            if~wasAlreadyOpen
                close(la);
            end

        end
        function turnOffLogging(obj)
            obj.setLoggingState('off');
        end

    end



    properties(Access=private)
modelName
clientId
ddBlks
ddFilter
    end
    properties(Constant)
        colors={'green','blue','red','yellow'};
    end
    methods(Access=private)
        function formatWaveforms(obj,startLAIdx)
            if(startLAIdx==-1),return;end
            oph=obj.getPortHandles();
            allBlkIdx=1:length(oph);
            waveIdx=startLAIdx+allBlkIdx;
            idxPerBlk=length(allBlkIdx)/length(obj.ddBlks);

            colorVals=arrayfun(@(x)(obj.colors{rem(floor((x-1)/idxPerBlk),length(obj.colors))+1}),...
            allBlkIdx,'UniformOutput',false);
            arrayfun(@(x,y)(setWaveProperty(obj,x,'color',colorVals(y))),...
            waveIdx,allBlkIdx,'UniformOutput',false);
            arrayfun(@(x,y)(setWaveProperty(obj,x,'format','digital')),...
            waveIdx,allBlkIdx,'UniformOutput',false);

            obj.sendMessage(struct(...
            'path',{{}},...
            'method','requestGraphicalSettings'));
        end
        function[success,la,wasAlreadyOpen]=launchLAAndWaitForOpenComplete(obj)
            if~slfeature('slLogicAnalyzerApp')
                success=false;la=[];wasAlreadyOpen=false;
                return;
            end






            try
                la=Simulink.scopes.LAScope.getLogicAnalyzer(obj.modelName);
                wasAlreadyOpen=isvalid(la.WebWindow);
                if wasAlreadyOpen
                    success=true;
                    return;
                end



                p=soc.internal.LARequestResponse('/logicanalyzer','openComplete',obj.clientId);

                la.openLogicAnalyzer(obj.modelName);





                drawnow;
                for indx=1:100
                    if p.isComplete
                        pause(0.1);
                        drawnow;
                        break;
                    end
                    pause(0.1);
                    drawnow;
                end



                if~p.isComplete
                    msg=message('soc:msgs:LAOpenError');
                    disp(msg.getString());
                    success=false;
                else
                    success=isvalid(la.WebWindow);
                end

            catch ME %#ok<NASGU>
                success=false;
            end
        end

        function oph=getPortHandles(obj)
            ph=get_param(obj.ddBlks,'PortHandles');
            portSubsetIdx=obj.ddFilter;
            if portSubsetIdx==-1
                ophc=cellfun(@(x)(x.Outport),ph,'UniformOutput',false);
            else
                ophc=cellfun(@(x)(x.Outport(portSubsetIdx)),ph,'UniformOutput',false);
            end
            oph=[ophc{:}];
        end
        function setLoggingState(obj,state)
            oph=obj.getPortHandles();
            arrayfun(@(x)(set_param(x,'DataLogging',state)),oph);
        end

        function addDivider(obj,index,name)
            obj.sendMessage(struct(...
            'path',{{'logicAnalyzer','panels'}},...
            'method','addDividerAtIndex',...
            'arguments',{index-1}));

            if nargin>2
                obj.sendMessage(struct(...
                'path',{{'logicAnalyzer','panels','traces',index-1}},...
                'property','name',...
                'value',name));
            end

            obj.sendMessage(struct(...
            'path',{{'logicAnalyzer'}},...
            'method','paint'));
        end
        function setWaveProperty(obj,index,propName,propValue)
            obj.sendMessage(struct(...
            'path',{{'logicAnalyzer','panels','traces',index-1}},...
            'property',propName,...
            'value',propValue));
        end
        function paintLogicAnalyzer(clientId)
            obj.sendMessage(struct(...
            'path',{{'logicAnalyzer'}},...
            'method','paint'));
        end
        function count=getTraceCount(obj)
            p=soc.internal.LARequestResponse('/logicanalyzer','testRequestResponse',obj.clientId);
            obj.sendMessage(struct(...
            'path',{{'logicAnalyzer','panels','traces'}},...
            'property','length'));





            drawnow;
            for indx=1:50
                if p.isComplete
                    pause(0.1);
                    drawnow;
                    break;
                end
                pause(0.1);
                drawnow;
            end

            if p.isComplete

                hadErr=isempty(p.Data)||(p.Data.success==0)||~isfield(p.Data,'outputs');
                if hadErr
                    msg=message('soc:msgs:LADBQueryError','with an error');
                    disp(msg.getString());
                    count=-1;
                else
                    count=p.Data.outputs;
                end
            else
                msg=message('soc:msgs:LADBQueryError','with a timeout');
                disp(msg.getString());
                count=-1;
            end
        end
    end
    methods(Access=private)
        function sendMessage(obj,params)
            msg.action=['testRequest',obj.clientId];
            msg.params=params;
            message.publish('/logicanalyzer',msg);
        end
    end
end

