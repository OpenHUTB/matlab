classdef LibraryLayoutVisitor<pm.sli.LibAutoLayoutVisitor
































    methods
        function vis=LibraryLayoutVisitor(slHCont)
            vis@pm.sli.LibAutoLayoutVisitor(slHCont);
        end
    end

    methods(Access=protected)
        function visit_compoundnode_implementation(thisVisitor,aVisitableNode)
            libHandle=thisVisitor.SLHandle(aVisitableNode.NodeID);
            libInfo=aVisitableNode.Info;
            if ishandle(libHandle)

                if~isempty(libInfo.OrderofChildren)






                    chl=aVisitableNode.getChildren;
                    chlTokens={};
                    for cIdx=1:length(chl)
                        child=chl{cIdx};
                        if(strcmpi(child.Info.Hidden,'off'))
                            if isa(chl{cIdx},'pm.util.CompoundNode')


                                [~,name]=fileparts(...
                                fileparts(chl{cIdx}.Info.SourceFile));
                                chlTokens{end+1}=strrep(name,'+','');
                            else


                                [~,name]=fileparts(chl{cIdx}.Info.SourceFile);
                                chlTokens{end+1}=strrep(name,'+','');
                            end
                        end
                    end




                    libInfo.OrderofChildren=...
                    intersect(libInfo.OrderofChildren,chlTokens,'stable');




                    missing=setdiff(chlTokens,libInfo.OrderofChildren);
                    newOrder=[libInfo.OrderofChildren,missing];








                    numBlocks=length(newOrder);
                    baseNum=10^(ceil(log10(numBlocks)));
                    for nIdx=1:numBlocks
                        oIdx=strcmp(newOrder{nIdx},chlTokens);
                        blkHandle=thisVisitor.SLHandle(chl{oIdx}.NodeID);
                        set_param(blkHandle,'Name',['Block',num2str(baseNum+nIdx)]);
                    end


                    thisVisitor.LayoutFunction(libHandle);


                    for cIdx=1:length(chl)
                        blkHandle=thisVisitor.SLHandle(chl{cIdx}.NodeID);
                        set_param(blkHandle,'Name',chl{cIdx}.Info.SLBlockProperties.Name);
                    end
                else

                    thisVisitor.LayoutFunction(libHandle);
                end
            else
                pm_error('physmod:pm_sli:sli:sllibautolayoutvisitor:InvalidHandleReturned');
            end
        end
    end
end



