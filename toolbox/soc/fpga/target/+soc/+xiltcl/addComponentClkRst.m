function addComponentClkRst(fid,hbuild)






    comp_list=hbuild.ComponentList;
    if~isempty(hbuild.PS7)
        comp_list=[comp_list,{hbuild.PS7}];
    end

    if~isempty(hbuild.FMCIO)
        for nn=1:numel(hbuild.FMCIO)
            comp_list=[comp_list,{hbuild.FMCIO{nn}}];
        end
    end
    if~isempty(hbuild.CustomIP)
        for nn=1:numel(hbuild.CustomIP)
            comp_list=[comp_list,{hbuild.CustomIP{nn}}];
        end
    end



    for i=1:numel(comp_list)
        this_comp=comp_list{i};

        for j=1:numel(this_comp.Clk)
            clk_driver=this_comp.Clk(j).driver;
            soc.xiltcl.addConnections(fid,{hbuild.(clk_driver).source,this_comp.Clk(j).name});
        end

        for j=1:numel(this_comp.Rst)
            rst_driver=this_comp.Rst(j).driver;
            soc.xiltcl.addConnections(fid,{hbuild.(rst_driver).source,this_comp.Rst(j).name});
        end
    end
