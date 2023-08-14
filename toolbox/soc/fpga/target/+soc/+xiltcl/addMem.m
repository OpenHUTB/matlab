function addMem(fid,hbuild)
    if~isempty(hbuild.MemPL)
        this_comp=hbuild.MemPL;

        fprintf(fid,this_comp.Instance);

        for j=1:numel(this_comp.Clk)
            clk_driver=this_comp.Clk(j).driver;
            soc.xiltcl.addConnections(fid,{hbuild.(clk_driver).source,this_comp.Clk(j).name});
        end

        for j=1:numel(this_comp.Rst)
            rst_driver=this_comp.Rst(j).driver;
            soc.xiltcl.addConnections(fid,{hbuild.(rst_driver).source,this_comp.Rst(j).name});
        end
    end
end