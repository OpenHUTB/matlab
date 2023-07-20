function hoistMask(h,srcBlk,varargin)
    p=inputParser;
    p.FunctionName='hostMask';
    addOptional(p,'DoNotAddNewParams',false,@(x)validateattributes(x,{'logical'},...
    {'nonempty'}))
    addOptional(p,'MaskUpdatesPorts',false,@(x)validateattributes(x,{'logical'},...
    {'nonempty'}))
    parse(p,varargin{:});
    addParam=~p.Results.DoNotAddNewParams;
    maskUpdatesPorts=p.Results.MaskUpdatesPorts;
    destMask=Simulink.Mask.get(h);
    if isempty(destMask)
        destMask=Simulink.Mask.create(h);
    end
    blkpath=[get_param(h,'Parent'),'/',get_param(h,'Name')];
    srcMask=Simulink.Mask.get([blkpath,'/',srcBlk]);
    destMask.copy(srcMask);

    for ii=1:numel(destMask.Parameters)
        destMask.Parameters(ii).Callback=['soc.blocks.hoistedMaskCallback(''',destMask.Parameters(ii).Name,''')'];
    end
    if addParam
        destMask.addParameter('Name','hoistedMaskSrc','Value',srcBlk,'Visible','off','Evaluate','off','Tunable','off');
    else
        set_param(h,'Description',['ESB wrapper for ',srcBlk]);
    end
    if maskUpdatesPorts
        destMask.Initialization=['soc.blocks.hoistedMaskCallback(''adaptPorts'');',10,destMask.Initialization];
    end
    destMask.SelfModifiable='on';
end