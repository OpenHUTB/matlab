classdef SlicerModelHierarchyFilter<slreportgen.webview.ModelHierarchyFilter


    properties
        IncludeSystems;
        IncludeVariants;
    end

    methods
        function h=SlicerModelHierarchyFilter()
            h@slreportgen.webview.ModelHierarchyFilter;
            h.IncludeMaskSubSystems=true;
            h.IncludeMathworksLinks=true;
            h.IncludeUserLinks=true;
            h.IncludeReferenceModel=true;
            h.IncludeVariants=true;
        end
    end

    methods
        function out=filter(h,hids)



            hids=filter@slreportgen.webview.ModelHierarchyFilter(h,hids);
            nHids=numel(hids);
            keep=true(1,nHids);

            for j=1:nHids
                thisHandle=slreportgen.utils.getSlSfHandle(hids(j));
                if~isempty(thisHandle)
                    try
                        bObj=get(thisHandle,'Object');
                        if isa(bObj,'Simulink.SubSystem')||isa(bObj,'Simulink.ModelReference')

                            if~ismember(thisHandle,h.IncludeSystems)
                                keep(j)=false;
                            end

                            if~h.IncludeVariants&&keep(j)...
                                &&isa(bObj.getParent,'Simulink.SubSystem')
                                activeVariant=get_param(bObj.getParent.Handle,'ActiveVariantBlock');
                                if~isempty(activeVariant)
                                    activeVariantH=get_param(activeVariant,'Handle');
                                    if isequal(activeVariantH,thisHandle)
                                        keep(j)=false;
                                    end
                                end
                            end
                        end
                    catch mex %#ok<NASGU>

                        keep(j)=true;
                    end
                end
            end
            out=hids(keep);
        end
    end
end
