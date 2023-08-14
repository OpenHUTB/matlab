function cacheDialogParams(this)




    block=this.getBlock;
    paramFeatureOn=(slfeature('ForEachSubsystemParameterization')==1);
    inputOverlappingFeatureOn=(slfeature('ForEachSubsystemInputOverlapping')==1);

    if isempty(this.DialogData)
        lstParams=fieldnames(block.IntrinsicDialogParameters);

        for i=1:length(lstParams)
            this.DialogData.(lstParams{i})=block.(lstParams{i});
        end
        this.DialogData.InportBlockPtrsArray=get_param(block.Handle,'InportBlockPtrsArray');
        this.DialogData.OutportBlockPtrsArray=get_param(block.Handle,'OutportBlockPtrsArray');
        if paramFeatureOn
            this.DialogData.SubsysMaskParameterPtrsArray=get_param(block.Handle,'SubsysMaskParameterPtrsArray');
        end
        this.DialogData.OutputConcatenation=get_param(block.Handle,'OutputConcatenation');
        this.DialogData.StateReset=get_param(block.Handle,'StateReset');
        this.DialogData.NeedActiveIterationSignal=get_param(block.Handle,'NeedActiveIterationSignal');

        numInportBlocks=length(this.DialogData.InportBlockPtrsArray);
        if length(this.DialogData.InputPartition)<numInportBlocks
            for i=length(this.DialogData.InputPartition)+1:numInportBlocks
                this.DialogData.InputPartition{i}='on';
            end
        else
            this.DialogData.InputPartition=this.DialogData.InputPartition(1:numInportBlocks);
        end
        if length(this.DialogData.InputPartitionDimension)<numInportBlocks
            for i=length(this.DialogData.InputPartitionDimension)+1:numInportBlocks
                this.DialogData.InputPartitionDimension{i}='';
            end
        else
            this.DialogData.InputPartitionDimension=this.DialogData.InputPartitionDimension(1:numInportBlocks);
        end
        if length(this.DialogData.InputPartitionWidth)<numInportBlocks
            for i=length(this.DialogData.InputPartitionWidth)+1:numInportBlocks
                this.DialogData.InputPartitionWidth{i}='';
            end
        else
            this.DialogData.InputPartitionWidth=this.DialogData.InputPartitionWidth(1:numInportBlocks);
        end
        if inputOverlappingFeatureOn
            if length(this.DialogData.InputPartitionOffset)<numInportBlocks
                for i=length(this.DialogData.InputPartitionOffset)+1:numInportBlocks
                    this.DialogData.InputPartitionOffset{i}='';
                end
            else
                this.DialogData.InputPartitionOffset=this.DialogData.InputPartitionOffset(1:numInportBlocks);
            end
        end

        numOutportBlocks=length(this.DialogData.OutportBlockPtrsArray);
        if length(this.DialogData.OutputConcatenation)<numOutportBlocks
            for i=length(this.DialogData.OutputConcatenation)+1:numOutportBlocks
                this.DialogData.OutputConcatenation{i}='on';
            end
        else
            this.DialogData.OutputConcatenation=this.DialogData.OutputConcatenation(1:numOutportBlocks);
        end
        if length(this.DialogData.OutputConcatenationDimension)<numOutportBlocks
            for i=length(this.DialogData.OutputConcatenationDimension)+1:numOutportBlocks
                this.DialogData.OutputConcatenationDimension{i}='';
            end
        else
            this.DialogData.OutputConcatenationDimension=this.DialogData.OutputConcatenationDimension(1:numOutportBlocks);
        end

        if paramFeatureOn
            numSubsysMaskParameters=length(this.DialogData.SubsysMaskParameterPtrsArray);
            if length(this.DialogData.SubsysMaskParameterPartition)<numSubsysMaskParameters
                for i=length(this.DialogData.SubsysMaskParameterPartition)+1:numSubsysMaskParameters
                    this.DialogData.SubsysMaskParameterPartition{i}='on';
                end
            else
                this.DialogData.SubsysMaskParameterPartition=this.DialogData.SubsysMaskParameterPartition(1:numSubsysMaskParameters);
            end
            if length(this.DialogData.SubsysMaskParameterPartitionDimension)<numSubsysMaskParameters
                for i=length(this.DialogData.SubsysMaskParameterPartitionDimension)+1:numSubsysMaskParameters
                    this.DialogData.SubsysMaskParameterPartitionDimension{i}='';
                end
            else
                this.DialogData.SubsysMaskParameterPartitionDimension=this.DialogData.SubsysMaskParameterPartitionDimension(1:numSubsysMaskParameters);
            end
            if length(this.DialogData.SubsysMaskParameterPartitionWidth)<numSubsysMaskParameters
                for i=length(this.DialogData.SubsysMaskParameterPartitionWidth)+1:numSubsysMaskParameters
                    this.DialogData.SubsysMaskParameterPartitionWidth{i}='';
                end
            else
                this.DialogData.SubsysMaskParameterPartitionWidth=this.DialogData.SubsysMaskParameterPartitionWidth(1:numSubsysMaskParameters);
            end
        end

    else
        InportBlockPtrsArray=get_param(block.Handle,'InportBlockPtrsArray');
        if~isequal(InportBlockPtrsArray,this.DialogData.InportBlockPtrsArray)
            InputPartition=block.InputPartition;
            InputPartitionDimension=block.InputPartitionDimension;
            InputPartitionWidth=block.InputPartitionWidth;
            if inputOverlappingFeatureOn
                InputPartitionOffset=block.InputPartitionOffset;
            end
            for i=1:length(InportBlockPtrsArray)
                if InportBlockPtrsArray(i)~=-1
                    loc=find(this.DialogData.InportBlockPtrsArray==InportBlockPtrsArray(i));
                    if~isempty(loc)
                        InputPartition{i}=this.DialogData.InputPartition{loc};
                        InputPartitionDimension{i}=this.DialogData.InputPartitionDimension{loc};
                        InputPartitionWidth{i}=this.DialogData.InputPartitionWidth{loc};
                        if inputOverlappingFeatureOn
                            InputPartitionOffset{i}=this.DialogData.InputPartitionOffset{loc};
                        end
                    end
                end
            end
            this.DialogData.InportBlockPtrsArray=InportBlockPtrsArray;
            this.DialogData.InputPartition=InputPartition;
            this.DialogData.InputPartitionDimension=InputPartitionDimension;
            this.DialogData.InputPartitionWidth=InputPartitionWidth;
            if inputOverlappingFeatureOn
                this.DialogData.InputPartitionOffset=InputPartitionOffset;
            end
        end

        OutportBlockPtrsArray=get_param(block.Handle,'OutportBlockPtrsArray');
        if~isequal(OutportBlockPtrsArray,this.DialogData.OutportBlockPtrsArray)
            OutputConcatenation=block.OutputConcatenation;
            OutputConcatenationDimension=block.OutputConcatenationDimension;
            for i=1:length(OutportBlockPtrsArray)
                if OutportBlockPtrsArray(i)~=-1
                    loc=find(this.DialogData.OutportBlockPtrsArray==OutportBlockPtrsArray(i));
                    if~isempty(loc)
                        OutputConcatenation{i}=this.DialogData.OutputConcatenation{loc};
                        OutputConcatenationDimension{i}=this.DialogData.OutputConcatenationDimension{loc};
                    end
                end
            end
            this.DialogData.OutportBlockPtrsArray=OutportBlockPtrsArray;
            this.DialogData.OutputConcatenation=OutputConcatenation;
            this.DialogData.OutputConcatenationDimension=OutputConcatenationDimension;
        end

        if paramFeatureOn
            SubsysMaskParameterPtrsArray=get_param(block.Handle,'SubsysMaskParameterPtrsArray');
            if~isequal(SubsysMaskParameterPtrsArray,this.DialogData.SubsysMaskParameterPtrsArray)
                SubsysMaskParameterPartition=block.SubsysMaskParameterPartition;
                SubsysMaskParameterPartitionDimension=block.SubsysMaskParameterPartitionDimension;
                SubsysMaskParameterPartitionWidth=block.SubsysMaskParameterPartitionWidth;
                for i=1:length(SubsysMaskParameterPtrsArray)

                    loc=find(this.DialogData.SubsysMaskParameterPtrsArray==SubsysMaskParameterPtrsArray(i));
                    if~isempty(loc)
                        SubsysMaskParameterPartition{i}=this.DialogData.SubsysMaskParameterPartition{loc};
                        SubsysMaskParameterPartitionDimension{i}=this.DialogData.SubsysMaskParameterPartitionDimension{loc};
                        SubsysMaskParameterPartitionWidth{i}=this.DialogData.SubsysMaskParameterPartitionWidth{loc};
                    end

                end
                this.DialogData.SubsysMaskParameterPtrsArray=SubsysMaskParameterPtrsArray;
                this.DialogData.SubsysMaskParameterPartition=SubsysMaskParameterPartition;
                this.DialogData.SubsysMaskParameterPartitionDimension=SubsysMaskParameterPartitionDimension;
                this.DialogData.SubsysMaskParameterPartitionWidth=SubsysMaskParameterPartitionWidth;
            end
        end
    end

    this.DialogData.FeatureValue=slsvTestingHook('ImplicitIteratorSubsystem');
    this.DialogData.InportBlockNamesArray=get_param(block.Handle,'InportBlockNamesArray');
    this.DialogData.OutportBlockNamesArray=get_param(block.Handle,'OutportBlockNamesArray');
    if paramFeatureOn
        this.DialogData.SubsysMaskParameterNamesArray=get_param(block.Handle,'SubsysMaskParameterNamesArray');
        this.DialogData.SubsysMaskParameterIsPartitionableArray=get_param(block.Handle,'SubsysMaskParameterIsPartitionableArray');
    end

end
