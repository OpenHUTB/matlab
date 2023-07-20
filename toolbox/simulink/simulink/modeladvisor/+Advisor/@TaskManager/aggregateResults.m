













function[compIds,results]=aggregateResults(this,varargin)


    nodeIdx=getNodesUnderRoot(this);

    if isempty(varargin)

        maObjs=this.getMAObjs();
    else
        compIds=varargin{1};
        maObjs=cell(size(compIds));

        for n=1:length(compIds)
            ma=this.getMAObjs(compIds{n});
            if~isempty(ma)
                maObjs(n)=ma;
            end
        end
    end

    compIds=cell(size(maObjs));
    results=cell(size(maObjs));
    isValidResult=true(size(maObjs));

    for n=1:length(maObjs)
        maObj=maObjs{n};

        if isa(maObj,'Simulink.ModelAdvisor')
            compIds{n}=maObj.ComponentId;
            taca=maObj.TaskAdvisorCellArray;
            issues=[0,0];

            taca=maObj.TaskAdvisorCellArray;

            for ni=1:length(nodeIdx)
                if nodeIdx(ni)>0;
                    node=taca{nodeIdx(ni)};


                    if isa(node,'ModelAdvisor.Task')&&(node.RunTime~=0)
                        if node.Check.Success==false&&node.Check.ErrorSeverity==0

                            issues(2)=issues(2)+1;

                        elseif node.Check.Success==false&&node.Check.ErrorSeverity>0
                            issues(1)=issues(1)+1;

                        else

                        end

                    else


                    end
                end
            end

            results{n}=issues;
        else
            isValidResult(n)=false;
        end
    end

    compIds=compIds(isValidResult);
    results=results(isValidResult);

end



