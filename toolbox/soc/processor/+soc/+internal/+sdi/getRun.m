function run=getRun(name)




    narginchk(1,1);
    nargoutchk(0,1);
    run=[];
    repository=sdi.Repository(true);
    runIds=repository.getAllRunIDs;
    for i=1:numel(runIds)
        thisRun=Simulink.sdi.getRun(runIds(i));
        if isequal(thisRun.Name,name)
            run=thisRun;
            break;
        end
    end
end
