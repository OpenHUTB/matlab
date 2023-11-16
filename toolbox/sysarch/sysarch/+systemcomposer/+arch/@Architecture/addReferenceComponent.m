function comp=addReferenceComponent(this,compName,varargin)
    this.validateAPISupportForAUTOSAR('addReferenceComponent');

    compPos=[];
    for k=1:2:numel(varargin)
        if strcmpi(varargin{k},"Position")
            compPos=varargin{k+1};
        else
            error('systemcomposer:API:APIInvalidOption',message(...
            'SystemArchitecture:API:APIInvalidOption',varargin{k}).getString);
        end
    end

    compName=string(compName);


    if~isempty(compPos)
        [posM,posN]=size(compPos);
        if length(varCompNames)~=posM||posN~=4
            error('systemcomposer:API:ComponentPositionsInvalid',message(...
            'SystemArchitecture:API:ComponentPositionsInvalid').getString);
        end
    end

    t=this.MFModel.beginTransaction;
    mdlH=this.SimulinkModelHandle;
    blkPath=string(this.getQualifiedName).append("/").append(compName);
    try
        bh=add_block('simulink/Ports & Subsystems/Model',blkPath);
    catch

        systemcomposer.internal.arch.internal.processBatchedPluginEvents(mdlH);
        t.commit;
        error('systemcomposer:API:ComponentExists',message(...
        'SystemArchitecture:API:ComponentExists',compName).getString);
    end

    systemcomposer.internal.arch.internal.processBatchedPluginEvents(mdlH);
    if~isempty(compPos)
        set_param(bh,'Position',compPos(idx,:));
    end
    t.commit;

    compImpl=systemcomposer.utils.getArchitecturePeer(bh);
    comp=systemcomposer.internal.getWrapperForImpl(compImpl,'systemcomposer.arch.Component');


end