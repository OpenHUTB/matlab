function ret=connectRuntimeSignalAccess(arg,varargin)


































    ret=[];

    try

        p=inputParser;
        p.addParameter('BlockType','ToAsyncQueueBlock',@(x)locValidateStr(x));
        p.addParameter('Register',true,@(x)locValidateLogical(x));
        p.addParameter('id',uint64(0),@(x)locValidateID(x));
        p.addParameter('Params',struct.empty());
        p.addParameter('DisableRecording',false,@(x)locValidateLogical(x));
        p.addParameter('IsFrame',false,@(x)locValidateLogical(x));
        p.addParameter('OutputPortIndex',1,@(x)locValidatePort(x));
        p.parse(varargin{:});
        params=p.Results;


        [hPort,mdlRefPath]=locGetPort(arg,params);
        bMdlRef=~isempty(mdlRefPath);


        if params.Register
            if bMdlRef
                ret=Simulink.registerRuntimeSignalAccessMdlRef(...
                mdlRefPath,...
                params.OutputPortIndex,...
                char(params.BlockType),...
                params.Params,...
                logical(params.DisableRecording),...
                logical(params.IsFrame));
            else
                ret=Simulink.registerRuntimeSignalAccess(...
                hPort,...
                char(params.BlockType),...
                params.Params,...
                logical(params.DisableRecording),...
                logical(params.IsFrame));
            end
        else
            if bMdlRef
                Simulink.unregisterRuntimeSignalAccessMdlRef(...
                mdlRefPath,...
                params.id);
            else
                Simulink.unregisterRuntimeSignalAccess(hPort,params.id);
            end
        end
    catch me
        throwAsCaller(me);
    end
end


function ret=locValidateStr(x)
    ret=ischar(x)||(isstring(x)&&isscalar(x));
end


function ret=locValidateLogical(x)
    ret=isscalar(x);
    if ret&&~islogical(x)
        ret=isnumeric(x)&&isreal(x);
    end
end


function ret=locValidateID(x)
    ret=isscalar(x)&&isa(x,'uint64');
end


function ret=locValidatePort(x)
    ret=isscalar(x)&&isnumeric(x)&&x>0&&int32(x)==x;
end


function[hPort,mdlRefPath]=locGetPort(arg,params)
    mdlRefPath={};
    hPort=0;


    if isa(arg,'Simulink.SimulationData.BlockPath')
        if arg.getLength()==1
            bp=arg.getBlock(1);
            ph=get_param(bp,'PortHandles');
            arg=ph.Outport(params.OutputPortIndex);
        else
            mdlRefPath=arg.convertToCell();
            locValidateMdlRefPath(mdlRefPath);
            return
        end
    end


    if isa(arg,'Simulink.Port')
        hPort=arg.Handle;
    elseif isa(arg,'Simulink.Segment')
        hPort=arg.SrcPortHandle;
    else
        hPort=arg;
    end


    obj=get_param(hPort,'Object');
    if isa(obj,'Simulink.Segment')
        hPort=obj.SrcPortHandle;
    end
end



function locValidateMdlRefPath(fullPath)

    fullPath(end)=[];
    for idx=1:numel(fullPath)
        mode=get_param(fullPath{idx},'SimulationMode');
        if~strcmpi(mode,'normal')
            error(message('SimulinkBlock:Foundation:RuntimeAccessInvalidMdlRefMode',fullPath{idx}));
        end
    end
end

