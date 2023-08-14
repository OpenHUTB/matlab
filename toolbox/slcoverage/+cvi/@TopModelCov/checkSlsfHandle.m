




function res=checkSlsfHandle(cvId,handle)

    try

        if handle<0
            handle=cv('get',cvId,'.handle');
        end
        res=0;

        if handle==0
            res=1;
            return;
        end


        if~ishandle(handle)
            return;
        end

        slName=get_param(handle,'Name');

        if cv('get',cvId,'.isa')==cv('get','default','slsf.isa')
            cvName=cv('GetSlsfName',cvId);
        elseif cv('get',cvId,'.isa')==cv('get','default','modelcov.isa')
            cvName=SlCov.CoverageAPI.getModelcovName(cvId);
        else
            return;
        end

        if strcmp(slName,cvName)
            res=1;
        end

    catch MEx
        rethrow(MEx);
    end


