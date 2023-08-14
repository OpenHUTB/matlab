function RTWName=getRTWName(obj)




    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>



    if obj.isSynthesized&&isa(obj,'Simulink.ModelReference')
        obj=get_param(obj.Parent,'Object');
    end

    if insideSiggen(obj.Handle)
        RTWName=obj.Name;
    else
        try
            RTWName=obj.getRTWName();
        catch ME %#ok
            RTWName='';
            if slcifeature('VirtualBusSupport')==1&&(obj.isSynthesized)


                RTWName=getOriginalBlockRTWName(obj);
            end
        end
    end
end

function out=getOriginalBlockRTWName(obj)


    assert(obj.isSynthesized,'Object is not synthesized');
    out='';
    aOriginalBlock=get_param(obj.getOriginalBlock,'Object');
    if strcmpi(aOriginalBlock.Type,'block')
        out=slci.internal.getRTWName(aOriginalBlock);
    end
end

function out=insideSiggen(blk)
    if strcmp(get_param(blk,'Type'),'block')
        if strcmp(get_param(blk,'IOType'),'siggen')
            out=true;
        else
            out=insideSiggen(get_param(blk,'Parent'));
        end
    else
        out=false;
    end
end
