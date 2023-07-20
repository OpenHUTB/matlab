function pathConv=getBlockPathMapsForVersion(smver)

    mlock;
    library=simmechanics.sli.internal.getLibraryTree;

    persistent PathConversions;
    if isempty(PathConversions)
        PathConversions=visit_sub_library(library,library.Info.LibFileName,...
        PathConversions);
    end

    pathConv=[];
    if isfield(PathConversions,smver)
        pathConv=PathConversions.(smver);
    end

    function PathConversions=visit_sub_library(lib,path,PathConversions)

        blks=lib.getChildren;
        for i=1:length(blks)
            c=blks{i};
            if isa(c,'pm.util.CompoundNode')
                npath=[path,'/',c.Info.SLBlockProperties.Name];
                PathConversions=visit_sub_library(c,npath,PathConversions);
            else
                currpath=[path,'/',c.Info.SLBlockProperties.Name];


                ftEntries=c.Info.ForwardingTableEntries;
                if~isempty(ftEntries)
                    bpc.NewPath=currpath;
                    bpc.OldPath={};
                    for j=1:length(ftEntries)
                        if~isempty(ftEntries(j).OldPath)
                            verstr=ftEntries(j).PathChangeVersion;
                            opath=ftEntries(j).OldPath;
                            bpc.OldPath=opath;
                            if isfield(PathConversions,verstr)
                                PathConversions.(verstr)=[PathConversions.(verstr),bpc];
                            else
                                PathConversions.(verstr)=bpc;
                            end
                        end
                    end
                else


                    ftEntries=c.Parent.Info.ForwardingTableEntries;
                    if~isempty(ftEntries)
                        bpc.NewPath=currpath;
                        bpc.OldPath={};
                        for idx=1:length(ftEntries)
                            ftEntry=ftEntries(idx).copy;
                            verstr=ftEntry.PathChangeVersion;
                            opath=[ftEntry.OldPath,'/'...
                            ,c.Info.SLBlockProperties.Name];
                            bpc.OldPath=opath;
                            if isfield(PathConversions,verstr)
                                PathConversions.(verstr)=[PathConversions.(verstr),bpc];
                            else
                                PathConversions.(verstr)=bpc;
                            end
                        end
                    end
                end
            end
        end


