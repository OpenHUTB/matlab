function addHPS(fid,hbuild)
    if~isempty(hbuild.HPS)

        fprintf(fid,'#add HPS\n');
        fprintf(fid,hbuild.HPS.Instance);

        for j=1:numel(hbuild.HPS.Clk)
            clk_driver=hbuild.HPS.Clk(j).driver;
            fprintf(fid,'add_connection %s %s\n',hbuild.(clk_driver).source,hbuild.HPS.Clk(j).name);
        end

        for j=1:numel(hbuild.HPS.Rst)
            rst_driver=hbuild.HPS.Rst(j).driver;
            fprintf(fid,'add_connection %s %s\n',hbuild.(rst_driver).source,hbuild.HPS.Rst(j).name);
        end
    end
end