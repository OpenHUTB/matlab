function dnnfpgaTblibRenderDDR(gcb,inType,outDimension)



    if(isempty(inType))
        return;
    end

    nDLUTPath=[gcb,'/Enabled Subsystem/Direct Lookup Table (n-D)'];
    set_param(nDLUTPath,'TableDataTypeStr',inType);
    lines=get_param([gcb,'/Enabled Subsystem/Sum'],'LineHandles');
    delete_line(lines.Outport);
    if(outDimension==1)
        set_param(nDLUTPath,'InputsSelectThisObjectFromTable','Element');
        set_param(nDLUTPath,'NumberOfTableDimensions','1');
    else
        assert(outDimension==2);
        set_param(nDLUTPath,'InputsSelectThisObjectFromTable','Vector');
        set_param(nDLUTPath,'NumberOfTableDimensions','2');
    end
    add_line([gcb,'/Enabled Subsystem'],'Sum/1','Direct Lookup Table (n-D)/1');
end
