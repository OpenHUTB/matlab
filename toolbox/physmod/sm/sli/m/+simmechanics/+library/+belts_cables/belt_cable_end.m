function varargout=belt_cable_end(varargin)



    persistent BlockInfoCache
    mlock;

    if isempty(BlockInfoCache)
        BlockInfoCache=simmechanics.sli.internal.BlockInfo;
        mfname=mfilename('fullpath');
        BlockInfoCache.SourceFile=which(mfname);
        BlockInfoCache.InitialVersion='R2018a';

        msgFcn=@pm_message;

        BlockInfoCache.SLBlockProperties.Name=...
        msgFcn('sm:library:beltsCables:beltCableEnd:Name');
        BlockInfoCache.SLBlockProperties.Position=[10,10,50,50];
        BlockInfoCache.SLBlockProperties.MaskIconUnits='normalized';


        framePort=sm_ports_info('frame');
        frameName=msgFcn('sm:model:blockNames:beltCableEnd:ports:Frame');
        BlockInfoCache.addPorts(simmechanics.sli.internal.PortInfo(...
        framePort.PortType,frameName,'left',frameName));

        beltCablePort=sm_ports_info('beltcable');
        beltCableName=msgFcn('sm:model:blockNames:beltCableEnd:ports:BeltCable');
        BlockInfoCache.addPorts(simmechanics.sli.internal.PortInfo(...
        beltCablePort.PortType,beltCableName,'right',beltCableName));


        BlockInfoCache.IconFile=[mfname,'.svg'];


        maskParams(1)=simmechanics.library.helper.get_class_name_param(...
        pm_message('sm:model:blockNames:beltCableEnd:TypeId'));

        BlockInfoCache.addMaskParameters(maskParams);
    end

    if nargin==1
        varargout={simmechanics.library.helper.generate_outputs(BlockInfoCache,...
        varargin{1})};
    else
        varargout{1}=BlockInfoCache.copy;
    end

end

