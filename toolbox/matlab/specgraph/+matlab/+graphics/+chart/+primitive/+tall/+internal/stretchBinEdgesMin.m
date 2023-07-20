function[binedges,expandfactor]=stretchBinEdgesMin(chunkmin,...
    binedges,npixels,scale)
    firstbinedge=binedges(1);
    lastbinedge=binedges(end);
    expandfactor=1;


    if chunkmin<firstbinedge

        if strcmp(scale,'log')
            firstbinedgelog=log10(abs(firstbinedge));
            lastbinedgelog=log10(abs(lastbinedge));
            binrangelog=lastbinedgelog-firstbinedgelog;
            chunkminlog=log10(abs(chunkmin));
            expandfactor=ceil((lastbinedgelog-chunkminlog)/binrangelog);




            firstbinedgelog=max(min(lastbinedgelog-expandfactor*binrangelog,...
            chunkminlog),-realmax(class(firstbinedge)));
            binedges=sign(lastbinedge).*(10.^linspace(firstbinedgelog,lastbinedgelog,npixels+1));
        else
            binrange=lastbinedge-firstbinedge;
            expandfactor=ceil((lastbinedge-chunkmin)/binrange);




            firstbinedge=max(min(lastbinedge-expandfactor*binrange,...
            chunkmin),-realmax(class(firstbinedge)));
            binedges=linspace(firstbinedge,lastbinedge,npixels+1);
        end
    end
end