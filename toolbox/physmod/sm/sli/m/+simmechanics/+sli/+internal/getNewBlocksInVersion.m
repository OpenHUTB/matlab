function newBlks=getNewBlocksInVersion(smver)


    library=simmechanics.sli.internal.getLibraryTree;

    persistent NewBlocks;
    if isempty(NewBlocks)
        NewBlocks=visit_sub_library(library,library.Info.LibFileName,...
        NewBlocks);
    end

    newBlks={};
    if isfield(NewBlocks,smver)
        newBlks=NewBlocks.(smver);
    end

    function newBlocks=visit_sub_library(lib,path,newBlocks)

        blks=lib.getChildren;
        for i=1:length(blks)
            c=blks{i};
            if isa(c,'pm.util.CompoundNode')
                npath=[path,'/',c.Info.SLBlockProperties.Name];
                newBlocks=visit_sub_library(c,npath,newBlocks);
            else
                verstr=c.Info.InitialVersion;
                bpath=[path,'/',c.Info.SLBlockProperties.Name];
                if isfield(newBlocks,verstr)
                    newBlocks.(verstr)=[newBlocks.(verstr),{bpath}];
                else
                    newBlocks.(verstr)={bpath};
                end


                ftEntries=c.Info.ForwardingTableEntries;
                for j=1:length(ftEntries)
                    if~isempty(ftEntries(j).OldPath)
                        opath=sprintf(ftEntries(j).OldPath);
                        newBlocks.(verstr)=[newBlocks.(verstr),{opath}];
                    end
                end
            end
        end


