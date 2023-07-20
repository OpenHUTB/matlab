function vars=ec_get_usedWSParams(modelName,theseParamsOnly)










    vars={};

    assert(iscellstr(theseParamsOnly)||isstring(theseParamsOnly));
    allUsedParams=isempty(theseParamsOnly);



    vlist=get_param(modelName,'ReferencedWSVars');


    blkList=containers.Map('KeyType','double','ValueType','any');

    for k=1:length(vlist)
        name=vlist(k).Name;
        blks=vlist(k).ReferencedBy;
        skip=false;
        if~allUsedParams
            skip=~ismember(name,theseParamsOnly);
        else
            obj=evalin('base',name);
            if~isa(obj,'Simulink.Parameter')
                skip=true;
            end
        end
        if skip
            continue;
        end

        for j=1:length(blks)
            thisBlk=blks(j);
            if~blkList.isKey(thisBlk)
                blkList(thisBlk)={name};
            else
                blkList(thisBlk)=[blkList(thisBlk),name];
            end
        end
    end


    blks=blkList.keys;
    for j=1:length(blks)
        thisBlk=blks{j};
        if loc_isBlockOfThisModel(thisBlk,modelName)

            names=unique(blkList(thisBlk));
            blkType=get_param(thisBlk,'BlockType');
            if~strcmp(blkType,'ModelReference')

                vars=horzcat(vars,names);%#ok
            else


                mdlParamVals=get_param(thisBlk,'ParameterArgumentValues');
                mdlParamNames=fields(mdlParamVals);
                for i=1:length(mdlParamNames)
                    mdlParamName=mdlParamNames{i};
                    mdlParamVal=mdlParamVals.(mdlParamName);
                    mdlParams=loc_getModelArguementValueParameters(mdlParamVal);
                    if~isempty(mdlParams)
                        namesOfUsedParameters=intersect(names,mdlParams);

                        vars=horzcat(vars,namesOfUsedParameters);%#ok
                    end
                end
            end
        end

    end

    vars=unique(vars);



    function mdlParam=loc_getModelArguementValueParameters(argValueStr)
        mdlParam={};
        t=mtree(argValueStr);
        if isempty(t)||t.isnull
            return;
        end

        paramnames=t.find('Kind','ID').strings;
        assert(iscellstr(paramnames));
        mdlParam=unique(paramnames);




        function r=loc_isBlockOfThisModel(thisBlk,modelName)

            while(1)
                parent=get_param(thisBlk,'Parent');
                assert(~isempty(parent),'block parent shall not be empty');

                if strcmp(get_param(parent,'Type'),'block_diagram')
                    if~strcmp(get_param(parent,'Name'),modelName)

                        r=false;
                    else

                        r=true;
                    end
                    break;
                end

                if strcmp(get_param(parent,'BlockType'),'ModelReference')

                    r=false;
                    break;
                end

                thisBlk=parent;
            end


