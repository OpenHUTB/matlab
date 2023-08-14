function newData=socmemlibForwarding(oldData)
    if contains(oldData.ForwardingTableEntry.('__slOldName__'),'Register Channel')
        newData=regChannelForwarding(oldData);
    end
    if contains(oldData.ForwardingTableEntry.('__slOldName__'),'Memory Controller')
        newData=memControllerForwarding(oldData);
    end
    if contains(oldData.ForwardingTableEntry.('__slOldName__'),'Memory Channel')
        newData=memChannelForwarding(oldData);
    end
    if contains(oldData.ForwardingTableEntry.('__slOldName__'),'Memory Traffic Generator')
        newData=memTGForwarding(oldData);
    end
end

function newData=regChannelForwarding(oldData)
    newData.NewBlockPath='';
    newData.NewInstanceData=[];


    newData.NewInstanceData=oldData.InstanceData;

    [~,idx]=intersect({newData.NewInstanceData.Name},'RegisterBankBaseAddress');
    if idx
        newData.NewInstanceData(idx)=[];
    end
    [~,idx]=intersect({newData.NewInstanceData.Name},'RegisterBankSize');
    if idx
        newData.NewInstanceData(idx)=[];
    end
    [~,idx]=intersect({newData.NewInstanceData.Name},'RegTableRW');
    if idx
        val=newData.NewInstanceData(idx).Value;

        param=evalin('base',val);
        for i=1:numel(param)
            if strcmpi(param{i},'r')
                param{i}='Read';
            elseif strcmpi(param{i},'w')
                param{i}='Write';
            end
        end
        newData.NewInstanceData(idx).Value=['{',sprintf('''%s'' ',param{:}),'}'];
    end
    [~,idx]=intersect({newData.NewInstanceData.Name},'RegTableOffsets');
    if idx
        newData.NewInstanceData(idx)=[];
    end
end

function newData=memControllerForwarding(oldData)
    newData.NewBlockPath='';
    newData.NewInstanceData=[];


    newData.NewInstanceData=oldData.InstanceData;

    [~,idx1]=intersect({newData.NewInstanceData.Name},'LastDiagnosticLevel');
    if idx1
        [~,idx2]=intersect({newData.NewInstanceData.Name},'DiagnosticLevel');
        if idx2
            newData.NewInstanceData(idx2).Value=oldData.InstanceData(idx1).Value;
        end
        newData.NewInstanceData(idx1)=[];
    end

    [~,idx]=intersect({newData.NewInstanceData.Name},'MemorySelection');
    if isempty(idx)

        hCS=getActiveConfigSet(bdroot(gcbh));
        isFPGACompat=codertarget.targethardware.isESBCompatible(hCS,2);

        if isFPGACompat
            fpgaDesign=codertarget.data.getParameterValue(hCS,'FPGADesign');

            if fpgaDesign.IncludeProcessingSystem
                newData.NewInstanceData(end+1).Name='MemorySelection';
                newData.NewInstanceData(end).Value='PS memory';
            else
                newData.NewInstanceData(end+1).Name='MemorySelection';
                newData.NewInstanceData(end).Value='PL memory';
            end
        end
    end
end

function newData=memChannelForwarding(oldData)
    newData.NewBlockPath='';
    newData.NewInstanceData=[];


    newData.NewInstanceData=oldData.InstanceData;

    [~,idx1]=intersect({newData.NewInstanceData.Name},'LastDiagnosticLevel');
    if idx1
        [~,idx2]=intersect({newData.NewInstanceData.Name},'DiagnosticLevel');
        if idx2
            newData.NewInstanceData(idx2).Value=oldData.InstanceData(idx1).Value;
        end
        newData.NewInstanceData(idx1)=[];
    end
    [~,idx]=intersect({newData.NewInstanceData.Name},'ChBitPackedWriterChIf');
    if isempty(idx)

        [~,idx]=intersect({newData.NewInstanceData.Name},'ChDimensionsWriterChIf');
        try
            chDims=evalin('base',newData.NewInstanceData(idx).Value);
        catch ME %#ok<NASGU>
            chDims=1;
        end

        MAX_COMPONENT_LENGTH=4;
        MAX_RADIO_CH_LENGTH=16;

        validRadioMIMO=(length(chDims)==2&&chDims(end)<=MAX_RADIO_CH_LENGTH);
        validVideoComp=(length(chDims)==2&&chDims(end)<=MAX_COMPONENT_LENGTH)||...
        (length(chDims)==3&&chDims(end)<=MAX_COMPONENT_LENGTH);

        if((chDims(end)>1)&&(validRadioMIMO||validVideoComp))
            newData.NewInstanceData(end+1).Name='ChBitPackedWriterChIf';
            newData.NewInstanceData(end).Value='on';
        else
            newData.NewInstanceData(end+1).Name='ChBitPackedWriterChIf';
            newData.NewInstanceData(end).Value='off';
        end
    end

    [~,idx]=intersect({newData.NewInstanceData.Name},'ChBitPackedReaderChIf');
    if isempty(idx)

        [~,idx]=intersect({newData.NewInstanceData.Name},'ChDimensionsReaderChIf');
        try
            chDims=evalin('base',newData.NewInstanceData(idx).Value);
        catch ME %#ok<NASGU>
            chDims=1;
        end

        MAX_COMPONENT_LENGTH=4;
        MAX_RADIO_CH_LENGTH=16;

        validRadioMIMO=(length(chDims)==2&&chDims(end)<=MAX_RADIO_CH_LENGTH);
        validVideoComp=(length(chDims)==2&&chDims(end)<=MAX_COMPONENT_LENGTH)||...
        (length(chDims)==3&&chDims(end)<=MAX_COMPONENT_LENGTH);

        if((chDims(end)>1)&&(validRadioMIMO||validVideoComp))
            newData.NewInstanceData(end+1).Name='ChBitPackedReaderChIf';
            newData.NewInstanceData(end).Value='on';
        else
            newData.NewInstanceData(end+1).Name='ChBitPackedReaderChIf';
            newData.NewInstanceData(end).Value='off';
        end
    end

    [~,idx]=intersect({newData.NewInstanceData.Name},'EnableMemSim');
    if isempty(idx)
        newData.NewInstanceData(end+1).Name='EnableMemSim';
        newData.NewInstanceData(end).Value='on';
    end
end

function newData=memTGForwarding(oldData)
    newData.NewBlockPath='';
    newData.NewInstanceData=[];


    newData.NewInstanceData=oldData.InstanceData;

    [~,idx1]=intersect({newData.NewInstanceData.Name},'ControllerDataWidth');
    if idx1
        newData.NewInstanceData(end+1).Name='ICDataWidth';
        newData.NewInstanceData(end).Value=newData.NewInstanceData(idx1).Value;
        newData.NewInstanceData(idx1)=[];
    end
end


