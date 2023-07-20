function hoistedMaskCallback(in,varargin)




    currentBlock=gcb;
    topMask=Simulink.Mask.get(currentBlock);

    if ismember('hoistedMaskSrc',{topMask.Parameters.Name})
        underlyingBlkName=[currentBlock,'/',get_param(currentBlock,'hoistedMaskSrc')];
    else
        tmp=get_param(currentBlock,'Description');
        underlyingBlkName=regexp(tmp,'ESB wrapper for (.+)$','tokens');
        assert(~isempty(underlyingBlkName)&&~isempty(underlyingBlkName{1}));
        underlyingBlkName=underlyingBlkName{1}{1};
        underlyingBlkName=[currentBlock,'/',underlyingBlkName];
    end
    underlyingMask=Simulink.Mask.get(underlyingBlkName);
    switch(in)
    case 'adaptPorts'
        underlyingBlockPorts=get_param(underlyingBlkName,'PortHandles');
        topBlockPorts=get_param(currentBlock,'PortHandles');
        if numel(underlyingBlockPorts.Outport)>numel(topBlockPorts.Outport)
            for ii=1:numel(underlyingBlockPorts.Outport)
                hOut=get_param(underlyingBlockPorts.Outport(ii),'Line');
                if isequal(hOut,-1)
                    portName=['Out',num2str(get_param(underlyingBlockPorts.Outport(ii),'PortNumber'))];
                    variantName=[currentBlock,'/Variant Source',num2str(get_param(underlyingBlockPorts.Outport(ii),'PortNumber'))];
                    add_block('simulink/Signal Routing/Variant Source',variantName);
                    set_param(variantName,'VariantControlMode','sim codegen switching');
                    set_param(variantName,'VariantControls',{'(sim)','(codegen)'})
                    add_block('built-in/Outport',[currentBlock,'/',portName]);
                    OutPortHdls=get_param([currentBlock,'/',portName],'PortHandles');
                    VariantPortOut=get_param(variantName,'PortHandles');
                    add_line(currentBlock,underlyingBlockPorts.Outport(ii),VariantPortOut.Inport(2));
                    add_line(currentBlock,VariantPortOut.Outport(1),OutPortHdls.Inport(1));
                end
            end
        elseif numel(underlyingBlockPorts.Outport)<numel(topBlockPorts.Outport)
            for ii=numel(topBlockPorts.Outport):-1:1
                portName=[currentBlock,'/','Out',num2str(get_param(topBlockPorts.Outport(ii),'PortNumber'))];
                vidx=num2str(get_param(topBlockPorts.Outport(ii),'PortNumber'));
                if isequal(vidx,'1')
                    vidx='';
                end
                variantName=[currentBlock,'/Variant Source',vidx];
                ph=get_param(portName,'PortHandles');
                ph=ph.Inport;
                hOut=get_param(ph,'Line');
                ph=get_param(variantName,'PortHandles');
                hOut1=get_param(ph.Inport(2),'Line');
                if hOut1==-1
                    delete_line(hOut);
                    delete_block(portName);
                    delete_block(variantName);
                elseif isequal(get_param(hOut1,'Connected'),'off')
                    delete_line(hOut1);
                    delete_line(hOut);
                    delete_block(portName);
                    delete_block(variantName);
                end
            end
        end
        if numel(underlyingBlockPorts.Inport)>numel(topBlockPorts.Inport)
            for ii=1:numel(underlyingBlockPorts.Inport)
                hOut=get_param(underlyingBlockPorts.Inport(ii),'Line');
                if isequal(hOut,-1)
                    portName=['In',num2str(get_param(underlyingBlockPorts.Inport(ii),'PortNumber'))];
                    variantName=[currentBlock,'/Variant Sink',num2str(get_param(underlyingBlockPorts.Outport(ii),'PortNumber'))];
                    add_block('simulink/Signal Routing/Variant Sink',variantName);
                    set_param(variantName,'VariantControlMode','sim codegen switching');
                    set_param(variantName,'VariantControls',{'(sim)','(codegen)'})
                    add_block('built-in/Inport',[currentBlock,'/',portName]);
                    InPortHdls=get_param([currentBlock,'/',portName],'PortHandles');
                    VariantPortOut=get_param(variantName,'PortHandles');
                    add_line(currentBlock,InPortHdls.Outport(1),VariantPortOut.Inport(1));
                    add_line(currentBlock,VariantPortOut.Outport(2),underlyingBlockPorts.Inport(ii));
                end
            end
        elseif numel(underlyingBlockPorts.Inport)<numel(topBlockPorts.Inport)
            for ii=numel(topBlockPorts.Inport):-1:1
                portName=[currentBlock,'/','In',num2str(get_param(topBlockPorts.Inport(ii),'PortNumber'))];
                vidx=num2str(get_param(topBlockPorts.Outport(ii),'PortNumber'));
                if isequal(vidx,'1')
                    vidx='';
                end
                variantName=[currentBlock,'/Variant Sink',vidx];
                ph=get_param(portName,'PortHandles');
                ph=ph.Outport;
                hOut=get_param(ph,'Line');
                ph=get_param(variantName,'PortHandles');
                hOut1=get_param(ph.Outport(2),'Line');
                if hOut1==-1
                    delete_line(hOut);
                    delete_block(portName);
                    delete_block(variantName);
                elseif isequal(get_param(hOut1,'Connected'),'off')
                    delete_line(hOut1);
                    delete_line(hOut);
                    delete_block(portName);
                    delete_block(variantName);
                end
            end
        end
    case 'adaptMaskDisplay'


        if isequal(get_param(bdroot(currentBlock),'SimulationStatus'),'stopped')
            underlyingBlkMaskDipslay=get_param(underlyingBlkName,'MaskDisplay');
            if~isempty(varargin)
                appendmask=varargin{1};
                if ischar(appendmask)||isstring(appendmask)
                    underlyingBlkMaskDipslay=[underlyingBlkMaskDipslay,newline,convertStringsToChars(appendmask)];
                end
            end
            set_param(currentBlock,'MaskDisplay',underlyingBlkMaskDipslay);
        end
    case 'adaptMaskProperties'



        if isequal(get_param(bdroot(currentBlock),'SimulationStatus'),'stopped')
            preservedirtyflag=get_param(bdroot(currentBlock),'Dirty');
            hoistedMaskProperties={underlyingMask.Parameters.Name};
            topMaskProperties={topMask.Parameters.Name};
            for i=1:numel(hoistedMaskProperties)
                if ismember(hoistedMaskProperties{i},topMaskProperties)
                    soc.blocks.hoistedMaskCallback(hoistedMaskProperties{i});
                end
            end


            set_param(bdroot(currentBlock),'Dirty',preservedirtyflag);
        end
    otherwise
        idx=ismember({underlyingMask.Parameters.Name},in);
        if~isempty(idx)&&any(idx)
            topValue=get_param(currentBlock,in);
            if~isequal(topValue,underlyingMask.Parameters(idx).Value)
                set_param(underlyingBlkName,underlyingMask.Parameters(idx).Name,topValue);
            end
            if~isempty(underlyingMask.Parameters(idx).Callback)
                eval(underlyingMask.Parameters(idx).Callback);
            end
        end
    end
end


