classdef HierarchyNumber<handle




































































    properties(SetAccess=private)


Source
    end

    properties(Access=private)

HierachyNumberMap
    end

    methods

        function this=HierarchyNumber(source)
            if nargin>0
                this.Source=source;
                initSystemPathToNumberMap(this);
            else
                error(message("slreportgen:utils:error:sourceNotSpecified"));
            end

        end

        function out=subsystemPaths(this)


            out=string(keys(this.HierachyNumberMap));

        end

        function hierarchyNumber=generateHierarchyNumber(this,diagram)











            diagramPath=slreportgen.utils.getDiagramPath(diagram);
            hierarchyNumber=[];
            if isKey(this.HierachyNumberMap,diagramPath)
                hierarchyNumber=string(this.HierachyNumberMap(diagramPath));
            end

        end

        function set.Source(this,source)





            mustBeNonempty(source);

            if(isStringScalar(source)&&source=="")
                error(message("slreportgen:utils:error:sourceNotEmpty"));
            end

            if ischar(source)
                source=string(source);
            end

            if isscalar(source)
                if slreportgen.utils.isModel(source)
                    this.Source=source;
                else
                    error(message("slreportgen:utils:error:invalidSource",source));
                end
            else

                nPath=length(source);
                for i=1:nPath
                    if iscell(source)
                        currSrc=source{i};
                    else
                        currSrc=source(i);
                    end

                    if~isempty(currSrc)
                        dhid=slreportgen.utils.HierarchyService.getDiagramHID(currSrc);
                        if~slreportgen.utils.HierarchyService.isDiagram(dhid)
                            error(message("slreportgen:utils:error:invalidSource",currSrc));
                        end
                    end

                end
                this.Source=source;
            end
        end

    end

    methods(Access=private)

        function initSystemPathToNumberMap(this)









            this.HierachyNumberMap=containers.Map('KeyType','char','ValueType','Any');


            if slreportgen.utils.isModel(this.Source)
                finder=slreportgen.finder.DiagramFinder(this.Source);
                r=finder.find();
                list=[r.Path];
            else
                list=this.Source;
            end

            hier=[];
            current_Level=0;

            n=numel(list);
            for i=1:n
                sysPath=slreportgen.utils.getDiagramPath(list{i});
                if~isempty(sysPath)
                    depth_level=numel(slreportgen.utils.pathSplit(sysPath));

                    if(depth_level>current_Level)
                        while((depth_level-current_Level)>0)
                            hier(end+1)=1;%#ok

                            current_Level=current_Level+1;
                        end
                    else
                        while((current_Level-depth_level)>0)
                            hier(end)=[];
                            current_Level=current_Level-1;
                        end
                        hier(end)=hier(end)+1;
                    end



                    this.HierachyNumberMap(sysPath)=strjoin(string(hier),".");
                end

            end

        end

    end
end