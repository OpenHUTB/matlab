classdef PartitionsCheck<handle






    properties(SetAccess=private,GetAccess=private)




InvalidSubsystems
InvalidChildren

Params
    end

    properties(Constant)
        FindOptions=Simulink.ModelReference.Conversion.PartitionsCheck.getFindOptions();
    end

    methods(Static,Access=public)
        function args=getFindOptions()
            args=horzcat(Simulink.ModelReference.Conversion.Utilities.BasicFindOptions,...
            {'MatchFilter',@Simulink.match.allVariants});
        end

        function check(subsys,params)

            assert(all(ishandle(subsys)),'Input must be an array of handles');






            if(strcmp(get_param(bdroot(subsys(1)),'IsExportFunctionModel'),'on'))
                return
            end


            this=Simulink.ModelReference.Conversion.PartitionsCheck(params);
            arrayfun(@(ss)this.exec(ss),subsys);


            this.createExceptions;
        end
    end

    methods
        function exec(this,subsysHandle)




            if sltp.BlockAccess(subsysHandle).isBlockCreatingPartitions
                this.InvalidSubsystems(end+1)=subsysHandle;
                this.InvalidChildren(end+1)=subsysHandle;
            else
                partitionSubsystems=find_system(...
                subsysHandle,...
                this.FindOptions{:},...
                'RegExp','on',...
                'BlockType','SubSystem',...
                'ScheduleAs','partition');
                this.pushInvalidChildrenIntoLists(subsysHandle,partitionSubsystems);

                partitionModels=find_system(...
                subsysHandle,...
                this.FindOptions{:},...
                'BlockType','ModelReference',...
                'ScheduleRates','on',...
                'ScheduleRatesWith','Schedule Editor');
                this.pushInvalidChildrenIntoLists(subsysHandle,partitionModels);

            end

        end

        function pushInvalidChildrenIntoLists(this,subsysHandle,invalidChildren)


            for i=1:length(invalidChildren)
                this.InvalidSubsystems(end+1)=subsysHandle;
                this.InvalidChildren(end+1)=invalidChildren(i);
            end
        end

        function createExceptions(this)


            assert(length(this.InvalidSubsystems)==...
            length(this.InvalidChildren),...
            'Invalid subsystem handles are not the same size');


            if isempty(this.InvalidSubsystems)
                return;
            end

            msgs=cell(size(this.InvalidSubsystems));
            subsysNames=arrayfun(@(subsys)this.Params.beautifySubsystemName(subsys),...
            this.InvalidSubsystems,'UniformOutput',false);

            for i=1:length(this.InvalidSubsystems)
                invalidSS=this.InvalidSubsystems(i);
                invalidChild=this.InvalidChildren(i);

                if invalidSS==invalidChild
                    msgs{i}=message(...
                    'Simulink:modelReferenceAdvisor:InvalidPartitionedSubsystem',...
                    subsysNames{i});
                else
                    childName=Simulink.ModelReference.Conversion.MessageBeautifier.beautifyBlockName(...
                    getfullname(invalidChild),invalidChild);
                    msgs{i}=message(...
                    'Simulink:modelReferenceAdvisor:InvalidSubsystemContainsPartition',...
                    subsysNames{i},childName);
                end
            end

            assert(~isempty(msgs),'No failures to report');
            if this.Params.ConversionParameters.Force
                cellfun(@(msg)this.Params.Logger.addWarning(msg),msgs);
            else
                nameString=Simulink.ModelReference.Conversion.Utilities.cellstr2str(unique(subsysNames),'','');
                me=MException(message('Simulink:modelReferenceAdvisor:CannotConvertSubsystem',nameString));
                N=numel(msgs);
                for idx=1:N
                    me=me.addCause(MException(msgs{idx}));
                end
                throw(me);
            end
        end

        function this=PartitionsCheck(params)
            this.Params=params;
            this.InvalidSubsystems=[];
            this.InvalidChildren=[];
        end
    end
end

