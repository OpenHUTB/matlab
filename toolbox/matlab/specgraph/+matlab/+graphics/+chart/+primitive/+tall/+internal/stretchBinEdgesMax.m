function[binedges,expandfactor]=stretchBinEdgesMax(chunkmax,...
    binedges,npixels,scale)
    firstbinedge=binedges(1);
    lastbinedge=binedges(end);
    expandfactor=1;


    if chunkmax>lastbinedge

        if strcmp(scale,'log')
            firstbinedgelog=log10(abs(firstbinedge));
            lastbinedgelog=log10(abs(lastbinedge));
            binrangelog=lastbinedgelog-firstbinedgelog;
            chunkmaxlog=log10(abs(chunkmax));
            expandfactor=ceil((chunkmaxlog-firstbinedgelog)/binrangelog);



            lastbinedgelog=min(max(firstbinedgelog+expandfactor*binrangelog,...
            chunkmaxlog),realmax(class(lastbinedge)));
            binedges=sign(firstbinedge).*(10.^linspace(firstbinedgelog,lastbinedgelog,npixels+1));
        else
            binrange=lastbinedge-firstbinedge;
            expandfactor=ceil((chunkmax-firstbinedge)/binrange);



            lastbinedge=min(max(firstbinedge+expandfactor*binrange,...
            chunkmax),realmax(class(lastbinedge)));
            binedges=linspace(firstbinedge,lastbinedge,npixels+1);
        end
    end
end