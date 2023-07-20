classdef ModelHierarchyFilter<handle















    properties(Dependent)
        IncludeMaskedSubsystems;
        IncludeReferencedModels;
        IncludeSimulinkLibraryLinks;
        IncludeUserLibraryLinks;
    end

    properties
        FilterCallback=[];
    end

    properties(Hidden,Dependent)
        IncludeMaskSubSystems;
        IncludeMathworksLinks;
        IncludeUserLinks;
        IncludeReferenceModel;
    end

    properties(Access=private)
        m_filter;
    end

    methods
        function h=ModelHierarchyFilter()
            h.m_filter=SLM3I.SLTreeFilter();
            h.IncludeMaskedSubsystems=false;
            h.IncludeReferencedModels=false;
            h.IncludeSimulinkLibraryLinks=false;
            h.IncludeUserLibraryLinks=false;
        end

        function set.IncludeMaskedSubsystems(h,tf)
            h.m_filter.ShowSystemsWithMaskedParameters=tf;
        end

        function tf=get.IncludeMaskedSubsystems(h)
            tf=h.m_filter.ShowSystemsWithMaskedParameters;
        end

        function set.IncludeSimulinkLibraryLinks(h,tf)
            h.m_filter.ShowMathworksLinks=tf;
        end

        function tf=get.IncludeSimulinkLibraryLinks(h)
            tf=h.m_filter.ShowMathworksLinks;
        end

        function set.IncludeUserLibraryLinks(h,tf)
            h.m_filter.ShowUserLinks=tf;
        end

        function tf=get.IncludeUserLibraryLinks(h)
            tf=h.m_filter.ShowUserLinks;
        end
        function set.IncludeReferencedModels(h,tf)
            h.m_filter.ShowReferencedModels=tf;
        end

        function tf=get.IncludeReferencedModels(h)
            tf=h.m_filter.ShowReferencedModels;
        end





        function out=filter(h,hids)

            filterImp=h.m_filter;

            hs=slreportgen.utils.HierarchyService;

            nHIDs=numel(hids);
            keep=true(1,nHIDs);







            unsupportedSFClasses={'Stateflow.StateTransitionTableChart',...
            'Stateflow.TruthTableChart',...
            'Stateflow.TruthTable'};

            for j=1:nHIDs
                hid=hids(j);
                keep(j)=filterImp.keepHid(hid);

                if keep(j)
                    dhid=hs.getDiagramHID(hid);
                    domain=hs.getDomain(dhid);
                    keep(j)=(strcmp(domain,'Simulink')||strcmp(domain,'Stateflow'));
                    if keep(j)
                        sysHandle=slreportgen.utils.getSlSfHandle(dhid);

                        if~isempty(h.FilterCallback)
                            sysPath=hs.getPath(dhid);
                            keep(j)=feval(h.FilterCallback,sysPath,sysHandle);
                        end

                        if isa(sysHandle,'Stateflow.Chart')&&Stateflow.ReqTable.internal.isRequirementsTable(sfprivate('getChartOf',sysHandle.Id))
                            keep(j)=false;
                        end

                        if keep(j)&&isa(sysHandle,'Stateflow.Object')&&...
                            ismember(class(sysHandle),unsupportedSFClasses)
                            keep(j)=false;
                        end
                    end
                end
            end
            out=hids(keep);
        end
    end


    methods
        function set.IncludeMaskSubSystems(h,tf)
            h.IncludeMaskedSubsystems=tf;
        end

        function tf=get.IncludeMaskSubSystems(h)
            tf=h.IncludeMaskedSubsystems;
        end

        function set.IncludeMathworksLinks(h,tf)
            h.IncludeSimulinkLibraryLinks=tf;
        end

        function tf=get.IncludeMathworksLinks(h)
            tf=h.IncludeSimulinkLibraryLinks;
        end

        function set.IncludeUserLinks(h,tf)
            h.IncludeUserLibraryLinks=tf;
        end

        function tf=get.IncludeUserLinks(h)
            tf=h.IncludeUserLibraryLinks;
        end
        function set.IncludeReferenceModel(h,tf)
            h.IncludeReferencedModels=tf;
        end

        function tf=get.IncludeReferenceModel(h)
            tf=h.IncludeReferencedModels;
        end
    end
end
