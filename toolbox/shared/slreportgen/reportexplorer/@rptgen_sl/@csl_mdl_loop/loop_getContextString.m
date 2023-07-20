function mdlNames=loop_getContextString(c)






    mdlNames='';

    for i=1:length(c.LoopList)
        if c.LoopList(i).Active
            if~isempty(mdlNames)
                mdlNames=[mdlNames,', '];
            end
            thisMdl=c.LoopList(i).MdlName;
            if strcmp(thisMdl,'$current')
                thisMdl=getString(message('RptgenSL:rsl_csl_mdl_loop:currentModelLabel'));
            elseif strcmp(thisMdl,'$all')
                thisMdl=getString(message('RptgenSL:rsl_csl_mdl_loop:allModelsLabel'));
            elseif strcmp(thisMdl,'$pwd')
                thisMdl=getString(message('RptgenSL:rsl_csl_mdl_loop:currentDirectoryLabel'));
            end
            mdlNames=[mdlNames,thisMdl];
        end
    end
