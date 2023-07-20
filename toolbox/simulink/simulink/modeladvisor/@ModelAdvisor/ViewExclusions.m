
function ViewExclusions(system)



    if nargin==1
        exclusions=ModelAdvisor.ExclusionManager('get',system);
    else
        exclusions=ModelAdvisor.ExclusionManager('get','.*');
    end

    newline=sprintf('\n');
    str='';
    if nargin==0

        for i=1:length(exclusions)
            exclusionObjs=exclusions(i);
            str=[str,'===============',newline,'Model: .*',newline,'===============',newline];
            for j=1:length(exclusionObjs)
                str=[str,exclusionObjs(j).view,newline];
            end
        end
    else
        str=['===============',newline,'Model: ',system,newline,'===============',newline];
        for j=1:length(exclusionObjs)
            str=[str,exclusionObjs(j).view,newline];
        end
    end
    disp(str);