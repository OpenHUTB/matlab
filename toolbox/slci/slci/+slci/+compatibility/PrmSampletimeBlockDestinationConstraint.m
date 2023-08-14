

classdef PrmSampletimeBlockDestinationConstraint<slci.compatibility.Constraint

    methods(Access=private)

        function out=getPortSampleTime(~,dstPortHandle)
            portSampleTime=get_param(dstPortHandle,'CompiledSampleTime');
            if iscell(portSampleTime)


                out=portSampleTime{1};
            else
                out=portSampleTime;
            end
        end


        function out=isAutomaticRateTransition(aObj,dsts,tsTable)
            out=false;
            prevSampleTimeTid=[];

            numDsts=size(dsts,1);

            for i=1:numDsts
                dstPortHandle=dsts(i,1);
                parentBlkHandle=get_param(dstPortHandle,'ParentHandle');
                parentBlkType=get_param(parentBlkHandle,'BlockType');
                isRateTransitionBlock=strcmpi(parentBlkType,...
                'RateTransition');

                if~isRateTransitionBlock
                    dstSampleTime=get_param(parentBlkHandle,...
                    'CompiledSampleTime');


                    if iscell(dstSampleTime)
dstSampleTime...
                        =aObj.getPortSampleTime(dstPortHandle);
                    end


                    s=slci.internal.SampleTime(dstSampleTime);


                    if s.isParameter()
                        derivedSampleTime=...
                        slci.internal.deriveSampleTime(parentBlkHandle);
                        s=slci.internal.SampleTime(derivedSampleTime{1});
                    end



                    if~s.isDiscrete()
                        continue;
                    end



                    tid=slci.internal.tsToTid(s,tsTable);
                    if(tid>=0)
                        if isempty(prevSampleTimeTid)
                            prevSampleTimeTid=slci.internal.tsToTid(s,tsTable);
                        elseif(prevSampleTimeTid~=slci.internal.tsToTid(s,tsTable))

                            out=true;
                            break;
                        end
                    end
                end
            end
        end
    end

    methods

        function out=getDescription(aObj)%#ok
            out=['A block that is constant or has a parameter that can be '...
            ,'tuned should not automatically transition to multirate '...
            ,'destination blocks.'];
        end


        function obj=PrmSampletimeBlockDestinationConstraint()
            obj.setEnum('PrmSampletimeBlockDestination');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end


        function out=check(aObj)
            out=[];



            ports=aObj.ParentBlock().getParam('Porthandles');
            outports=ports.Outport;


            mdlH=Simulink.ID.getModel(Simulink.ID.getSID(...
            aObj.ParentBlock().getParam('Handle')));

            tsTable=slci.internal.getModelSampleTimes(mdlH);

            for pH=1:numel(outports)
                portSampleTime=get_param(outports(pH),...
                'CompiledSampleTime');
                if~iscell(portSampleTime)
                    s=slci.internal.SampleTime(portSampleTime);
                    if s.isParameter()
                        sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);
                        portObj=get_param(outports(pH),'Object');
                        dstPorts=portObj.getActualDst();
                        numDsts=size(dstPorts,1);


                        if(numDsts>1)&&...
                            aObj.isAutomaticRateTransition(dstPorts,tsTable)
                            out=slci.compatibility.Incompatibility(aObj,...
                            'PrmSampletimeBlockDestination',...
                            aObj.ParentBlock.getName());
                            return;
                        end
                        delete(sess);
                    end
                end
            end

        end

    end
end
