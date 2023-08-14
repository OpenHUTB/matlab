function libpath=visionhdllibpath(blk)






    visionhdlblks=['Vision',char(10),'HDL Toolbox/'];


    visionhdlio='I/O Interfaces';
    visionhdlfilter='Filtering';
    visionhdlconversions='Conversions';
    visionhdlanalysis=['Analysis &',char(10),'Enhancement'];
    visionhdlmorphops=['Morphological',char(10),'Operations'];
    visionhdlgeotforms=['Geometric',char(10),'Transforms'];
    visionhdlstatistics='Statistics';
    visionhdlutilities='Utilities';

    if strncmpi(blk,'visionhdlio/',12)
        libpath=[visionhdlio,blk(12:end)];
    elseif strncmpi(blk,'visionhdlfilter/',16)
        libpath=[visionhdlfilter,blk(16:end)];
    elseif strncmpi(blk,'visionhdlconversions/',21)
        libpath=[visionhdlconversions,blk(21:end)];
    elseif strncmpi(blk,'visionhdlanalysis/',18)
        libpath=[visionhdlanalysis,blk(18:end)];
    elseif strncmpi(blk,'visionhdlmorphops/',18)
        libpath=[visionhdlmorphops,blk(18:end)];
    elseif strncmpi(blk,'visionhdlstatistics/',20)
        libpath=[visionhdlstatistics,blk(20:end)];
    elseif strncmpi(blk,'visionhdlutilities/',19)
        libpath=[visionhdlutilities,blk(19:end)];
    elseif strncmpi(blk,'visionhdlgeotforms/',19)
        libpath=[visionhdlgeotforms,blk(19:end)];
    else
        libpath='';
    end

    libpath=[visionhdlblks,libpath];

end

