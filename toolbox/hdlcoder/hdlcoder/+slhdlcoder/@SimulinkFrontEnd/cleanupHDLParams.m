function cleanupHDLParams(this,slbh,~)%#ok<INUSL>



    if strcmp(get(slbh,'Type'),'block_diagram')

        return;
    end

    chd=[];
    set_param(slbh,'CompiledHDLData',chd);
end
