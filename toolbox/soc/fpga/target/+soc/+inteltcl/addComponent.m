function addComponent(fid,hbuild)
    comp_list=hbuild.ComponentList;

    isPerfMon=cellfun(@(x)isa(x,'soc.intelcomp.APM'),comp_list);
    if any(isPerfMon)
        perfIdx=find(isPerfMon);
        temp=comp_list{perfIdx};
        for nn=perfIdx:numel(comp_list)
            if nn<numel(comp_list)
                comp_list{nn}=comp_list{nn+1};
            else
                comp_list{nn}=temp;
            end
        end
    end
    hbuild.ComponentList=comp_list;

    for i=1:numel(comp_list)
        this_comp=comp_list{i};

        if~isempty(this_comp.Instance)
            fprintf(fid,this_comp.Instance);

            for j=1:numel(this_comp.Clk)
                clk_driver=this_comp.Clk(j).driver;
                fprintf(fid,'add_connection %s %s\n',hbuild.(clk_driver).source,this_comp.Clk(j).name);
            end

            for j=1:numel(this_comp.Rst)
                rst_driver=this_comp.Rst(j).driver;
                fprintf(fid,'add_connection %s %s\n',hbuild.(rst_driver).source,this_comp.Rst(j).name);
            end
            fprintf(fid,'\n');
        end
    end
end