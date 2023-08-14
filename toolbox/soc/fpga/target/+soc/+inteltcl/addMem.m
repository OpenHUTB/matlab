function addMem(fid,hbuild)
    if~isempty(hbuild.MemPL)
        this_comp=hbuild.MemPL;

        fprintf(fid,'# Add DDR3/DDR4 EMIF\n');
        fprintf(fid,this_comp.Instance);
        if~soc.internal.isCustomHWBoard(hbuild.Board.Name)
            if~isa(this_comp,'soc.intelcomp.Arria10SoCDDR4')

                for j=1:numel(this_comp.Clk)
                    clk_driver=this_comp.Clk(j).driver;
                    fprintf(fid,'add_connection %s %s\n',hbuild.(clk_driver).interface,this_comp.Clk(j).name);
                end
            end
        end

        for j=1:numel(this_comp.Rst)
            rst_driver=this_comp.Rst(j).driver;
            fprintf(fid,'add_connection %s %s\n',hbuild.(rst_driver).interface,this_comp.Rst(j).name);
        end
        fprintf(fid,'\n');
    end
end