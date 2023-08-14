function res=updateModelName(modelcovId)
    try
        res=false;
        [oldName,newName]=matchModelName(modelcovId);

        if~isempty(oldName)&&~isempty(newName)
            fixTopSlsf(modelcovId,oldName,newName);
            fixChartFullPath(oldName,newName);
            res=true;
        end

    catch MEx
        rethrow(MEx);
    end

    function fixChartFullPath(oldName,newName)
        chIds=cv('find','all','slsf.refClass',sf('get','default','chart.isa'));
        for idx=1:numel(chIds)
            cvId=chIds(idx);
            origPath=cv('get',cvId,'.origPath');
            origPath=strrep(origPath,oldName,newName);
            cv('set',cvId,'.origPath',origPath);
        end


        function fixTopSlsf(modelId,oldName,newName)

            rootId=cv('get',modelId,'.rootTree.child');
            if rootId~=0
                topSlsfId=cv('get',rootId,'.topSlsf');
                topSlsfName=cv('GetSlsfName',topSlsfId);
                topSlsfName=strrep(topSlsfName,oldName,newName);
                cv('SetSlsfName',topSlsfId,topSlsfName);
            end

            function[oldName,newName]=matchModelName(id)
                oldName='';
                newName='';
                h=cv('get',id,'.handle');
                n=SlCov.CoverageAPI.getModelcovName(id);
                if(h~=0&&ishandle(h))
                    try
                        actName=get_param(h,'Name');
                    catch Mex %#ok<NASGU>
                        actName='';
                    end

                    if(~isempty(actName)&&~strcmp(n,actName))
                        SlCov.CoverageAPI.setModelcovName(id,actName);
                        oldName=n;
                        newName=actName;
                    end
                end

