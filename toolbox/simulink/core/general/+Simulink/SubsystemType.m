




classdef SubsystemType<handle
    properties(Transient,SetAccess=private,GetAccess=private)
System
        PortBlocks={}
    end


    methods(Access=public)
        function this=SubsystemType(currentSubsystem)
            if ishandle(currentSubsystem)
                this.System=currentSubsystem;
            else
                this.System=get_param(currentSubsystem,'Handle');
            end
        end


        function status=isSubsystem(this)
            status=slInternal('isSubsystem',this.System);
        end


        function status=isAtomicSubsystem(this)
            status=slInternal('isAtomicSubsystem',this.System);
        end


        function status=isVirtualSubsystem(this)
            status=slInternal('isVirtualSubsystem',this.System);
        end


        function status=isFunctionCallSubsystem(this)
            status=slInternal('isFunctionCallSubsystem',this.System);
        end


        function status=isSimulinkFunction(this)
            status=slInternal('isSimulinkFunction',this.System);
        end

        function status=isInitTermOrResetSubsystem(this)
            status=slInternal('isInitTermOrResetSubsystem',this.System);
        end


        function status=isEnabledSubsystem(this)
            status=slInternal('isEnabledSubsystem',this.System);
        end


        function status=isEnabledAndTriggeredSubsystem(this)
            status=slInternal('isEnabledAndTriggeredSubsystem',this.System);
        end


        function status=isTriggeredSubsystem(this)
            status=slInternal('isTriggeredSubsystem',this.System);
        end

        function status=isResettableSubsystem(this)
            status=slInternal('isResettableSubsystem',this.System);
        end

        function status=isVariantSubsystem(this)
            status=slInternal('isVariantSubsystem',this.System);
        end


        function status=isActionSubsystem(this)
            status=slInternal('isActionSubsystem',this.System);
        end


        function status=isIteratorSubsystem(this)
            status=slInternal('isIteratorSubsystem',this.System);
        end


        function status=isForIteratorSubsystem(this)
            status=slInternal('isForIteratorSubsystem',this.System);
        end


        function status=isWhileIteratorSubsystem(this)
            status=slInternal('isWhileIteratorSubsystem',this.System);
        end


        function status=isForEachSubsystem(this)
            status=slInternal('isForEachSubsystem',this.System);
        end


        function status=isMessageTriggeredFunction(this)
            status=slInternal('isMessageTriggeredFunction',this.System);
        end


        function status=isMessageTriggeredSampleTime(this)
            status=slInternal('isMessageTriggeredSampleTime',this.System);
        end


        function status=isStateflowSubsystem(this)
            status=slprivate('is_stateflow_based_block',this.System);
        end


        function status=isPhysmodSubsystem(this)
            this.getPortBlocks();
            status=~isempty(this.PortBlocks.LConn)||~isempty(this.PortBlocks.RConn);
        end


        function status=isSubsystemBD(this)
            status=bdIsSubsystem(bdroot(this.System));
        end

        function ssType=getType(this)
            if this.isSimulinkFunction
                ssType='Simulink Function';
            elseif this.isInitTermOrResetSubsystem
                ssType='IRT';
            elseif this.isVariantSubsystem
                ssType='variant';
            elseif this.isStateflowSubsystem
                ssType='stateflow';
            elseif this.isPhysmodSubsystem
                ssType='physmod';
            else
                ssType=slInternal('getSubsystemType',this.System);
                if strcmp(ssType,'iterator')
                    if this.isForIteratorSubsystem
                        ssType='for';
                    elseif this.isWhileIteratorSubsystem
                        ssType='while';
                    elseif this.isForEachSubsystem
                        ssType='for-each';
                    end
                end
            end
        end
    end


    methods(Static,Access=public)
        function results=isModelBlock(blkH)
            results=strcmp(get_param(blkH,'BlockType'),'ModelReference');
        end


        function results=isBlockDiagram(blkH)
            results=strcmp(get_param(blkH,'Type'),'block_diagram');
        end

        function status=hasLinkToADirtyLibrary(blkh)
            obj=get_param(blkh,'Object');
            status=obj.hasLinkToADirtyLibrary;
        end
    end


    methods(Access=private)
        function getPortBlocks(this)
            this.PortBlocks=get_param(this.System,'PortHandles');
        end
    end
end
