classdef Report2CP
    methods(Static,Access=private)


        function[criticalPath,debugStrings]=constructCriticalPath(rootPIR,gmPrefixOpt,reportPath)
            import BA.New.Util;
            import BA.New.CP.Report2CP;
            import BA.New.CP.CriticalPath;
            import BA.New.CP.CriticalComponent;
            import BA.New.Optional;
            debugStrings={};

            componentPaths=reportPath.getComponents();
            delays=reportPath.getDelays();



            componentPaths=Util.uniq(@strcmp,componentPaths);

            topNetworkPath=rootPIR.getTopNetwork.FullPath;
            reachableNICs=Util.reachableNICs(rootPIR);
            reachableNICsPaths=Util.map(@Util.componentPath,reachableNICs);
            reachableNICsPaths=Util.map(@(p)p(length(topNetworkPath)+2:end),reachableNICsPaths);

            lineHandles=cell(1,length(componentPaths));
            drivers=cell(1,length(componentPaths));
            validDriversIndices=true(1,length(componentPaths));
            for i=1:length(componentPaths)
                componentPath=componentPaths{i};
                parentNICBasename=Util.grep(componentPath,'^.+/');
                if isempty(reachableNICsPaths)||isempty(parentNICBasename)
                    compNetwork=rootPIR.getTopNetwork;
                else
                    distances=cell2mat(Util.map(@(fp)Util.editDistance(fp,parentNICBasename,containers.Map()),reachableNICsPaths));
                    [~,idx]=sort(distances);
                    sortedPaths=reachableNICsPaths(idx);
                    bestNetworkRelPath=sortedPaths{1};
                    compNetworks=Util.filter(@(n)strcmp(Util.componentPath(n),[topNetworkPath,'/',bestNetworkRelPath]),reachableNICs);
                    assert(length(compNetworks)==1);
                    compNetwork=compNetworks{1};
                    compNetwork=compNetwork.ReferenceNetwork;
                end

                signals=compNetwork.Signals;
                [matchingDriver,lineHandle,ds]=Util.findMatchingDriver(gmPrefixOpt.isSome(),signals,componentPath);

                debugStrings=horzcat(debugStrings,ds);
                drivers{i}=matchingDriver;
                lineHandles{i}=lineHandle;
                if matchingDriver==-1
                    validDriversIndices(i)=false;
                end
            end

            if~any(validDriversIndices)
                criticalPath=Optional.none();
                return;
            end


            componentPaths=componentPaths(validDriversIndices);
            delays=delays(validDriversIndices);
            drivers=drivers(validDriversIndices);
            handles=Util.map(@(d)d.getGMHandle,drivers);

            lineHandles=lineHandles(validDriversIndices);

            criticalComponents=arrayfun(...
            @(i)CriticalComponent(...
            gmPrefixOpt,...
            componentPaths{i},...
            delays(i),...
            drivers{i},...
            handles{i},...
            lineHandles{i}...
            ),...
            (1:length(componentPaths))...
            );



            uniqByTVRName=Util.uniqAccumulate(...
            @(a,b)strcmp(a.getTVRName(),b.getTVRName()),...
            @(a,b)CriticalComponent(...
            gmPrefixOpt,...
            a.getTVRName(),...
            a.delay+b.delay,...
            a.component,...
            a.getGMHandle,...
            a.getLineHandle...
            ),...
criticalComponents...
            );


            metadata=reportPath.getMetadata();

            criticalPath=Optional.some(CriticalPath(uniqByTVRName,metadata));
        end

        function comps=getComponents(this)
            comps=this.abstractComponents(:);
        end


        function prettyPrint(this,indentWidth,indentLevel)

            structuredDataPath=criticalComponents;
        end










        function value=getValue(field,timingLine,isNumerical)
            import BA.New.Util;
            assert(startsWith(timingLine,field));


            value=timingLine(length(field)+1:end);
            if isNumerical

                value=Util.ifElse(isempty(value),@()0,@()str2double(value));
            end
        end
    end

    methods(Static)










        function[criticalPaths,debugStrings]=parse(rootPIR,gmPrefixOpt,report)
            import BA.New.ReportParser.XilinxVivadoTvrParser;
            import BA.New.Util;
            import BA.New.CP.Report2CP;
            import BA.New.Optional;

            paths=report.getPaths();

            criticalPaths=cell(1,length(paths));
            debugStrings={};
            for i=1:length(paths)
                path=paths{i};
                [criticalPath,ds]=Report2CP.constructCriticalPath(rootPIR,gmPrefixOpt,path);
                if criticalPath.isSome()
                    criticalPaths{i}=criticalPath.unwrap();
                end

                debugStrings=horzcat(debugStrings,ds);
            end
            criticalPaths=[criticalPaths{:}];
        end
    end
end
