function[outputBlk,outputBlkPosition]=addSLBlockModel(this,hC,srcBlkPath,targetBlkPath,srcBlkParam)



    blkpath=[targetBlkPath,'/',hC.Name];

    if nargin==4
        srcBlkParam={};
    end

    load_system('simulink');
    blockHandle=add_block(srcBlkPath,blkpath,'MakeNameUnique','on',srcBlkParam{:});

    set_param(blockHandle,'Orientation','right');

    blockPosition=[160,75,245,115];
    set_param(blockHandle,'Position',blockPosition);

    hdlbuiltinimpl.EmlImplBase.addTunablePortsFromParams(blockHandle);

    for ii=1:length(hC.PirInputPorts)
        oport=sprintf('In%i/1',ii);
        if hC.PirInputPorts(ii).isSubsystemTrigger
            iport=sprintf('%s/Trigger',hC.Name);
        else
            iport=sprintf('%s/%i',hC.Name,ii);
        end
        add_line(targetBlkPath,oport,iport,'autorouting','on');
    end

    outputBlk=hC.Name;
    outputBlkPosition=[blockPosition(3),blockPosition(2)];

    if~isempty(srcBlkParam)
        [~,color]=this.getHiliteInfo(hC);
        set_param(blkpath,'BackgroundColor',color);
    end

    this.setBlockSampleTime(hC,blockHandle);

end
