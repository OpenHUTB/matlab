




function ftList=iterateMLObjects(system,objectID)

    ftList={};%#ok<NASGU>


    modelObj=getSLCIModelObj();
    objs=getMLObjects(modelObj,objectID);


    [result,constraintMap,failureMap]=runChecks(objs);


    ftList=formatResults(constraintMap,...
    failureMap,...
    objectID,...
    objs);

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(result);

end





function[result,constraintMap,failureMap]=runChecks(objs)


    result=true;
    failureMap=containers.Map;
    constraintMap=containers.Map;


    for i=1:numel(objs)

        obj=objs{i};
        constraints=obj.getConstraints;
        [thisResult,failureMap]=runMLConstraints(constraints,failureMap);
        result=result&&thisResult;

        for j=1:numel(constraints)
            constraint=constraints{j};
            ckey=constraint.getID;
            if~isKey(constraintMap,ckey)
                constraintMap(ckey)=constraint;
            end
        end
    end

end


function ftList=formatResults(constraintMap,failureMap,objectID,objs)

    ftList={};

    ckeys=constraintMap.keys;
    if isempty(objs)


        ft=ModelAdvisor.FormatTemplate('ListTemplate');
        ft.setSubResultStatusText(...
        DAStudio.message('Slci:compatibility:NoMLObjects',...
        DAStudio.message(['Slci:compatibility:',objectID])));
        ftList{1}=ft;
    elseif isempty(ckeys)


        ft=ModelAdvisor.FormatTemplate('ListTemplate');
        ft.setSubResultStatusText(...
        DAStudio.message('Slci:compatibility:AllMLObjectsCompatible',...
        DAStudio.message(['Slci:compatibility:',objectID])));
        ftList{1}=ft;
    else


        for i=1:numel(ckeys)

            constraintKey=ckeys{i};
            constraint=constraintMap(constraintKey);

            incompMap=failureMap(constraintKey);
            if isempty(incompMap)


                [SubTitle,Information,StatusText,~]=...
                constraint.getSpecificMAStrings(true);


                ft=ModelAdvisor.FormatTemplate('ListTemplate');
                ft.setSubTitle(SubTitle);
                ft.setInformation(Information);
                ft.setSubResultStatus('Pass');
                ft.setSubResultStatusText(StatusText);

                ft=setPassUserData(ft,constraint,objs);
                ftList{end+1}=ft;%#ok<AGROW>
            else


                incomps=incompMap.keys;
                for k=1:numel(incomps)

                    incompKey=incomps{k};
                    incomp=incompMap(incompKey);


                    [SubTitle,Information,~,~]=...
                    constraint.getSpecificMAStrings(true);
                    [~,~,StatusText,RecAction]=incomp(1).getMAStrings();
                    if incomp(1).getpreReqFailureFlag
                        StatusText=...
                        [DAStudio.message('Slci:compatibility:PrereqConstraintsWarn')...
                        ,StatusText];%#ok<AGROW> 
                    end
                    ft=ModelAdvisor.FormatTemplate('TableTemplate');
                    ft.setSubTitle(SubTitle);
                    ft.setInformation(Information);
                    ft.setSubResultStatus('Warn');
                    ft.setSubResultStatusText(StatusText);
                    ft.setRecAction(RecAction);


                    ft=formatHandles(ft,objectID,incomp);


                    ftList{end+1}=ft;%#ok<AGROW>
                end
            end

        end
    end

    if~isempty(ftList)
        ftList{end}.setSubBar(true);
    end
end


function ft=formatHandles(ft,objectID,incomp)

    blkMap=containers.Map;
    for j=1:numel(incomp)
        obj=incomp(j).getConstraint().getOwner();
        handle=incomp(j).getConstraint().getOwner().getSID();
        key=obj.ParentBlock().getSID();
        if~isKey(blkMap,key)
            blkMap(key)={handle};
        else
            blkMap(key)=[blkMap(key),handle];
        end
    end

    ft=formatTable(ft,objectID,blkMap);


    ft=setFailUserData(ft,incomp(1).getConstraint,values(blkMap));
end


function ft=formatTable(ft,objectID,blkMap)

    colTitles={...
    DAStudio.message(['Slci:compatibility:MATLABFunction',objectID,'UsageTableCol1']),...
    DAStudio.message(['Slci:compatibility:MATLABFunction',objectID,'UsageTableCol2'])};
    ft.setColTitles(colTitles);

    blks=keys(blkMap);
    numBlks=numel(blks);
    for indx=1:numBlks

        col1Data=blks{indx};

        objs=blkMap(blks{indx});
        numCols=1;
        numRows=numel(objs);
        col2Data=ModelAdvisor.Table(numRows,numCols);
        for indx1=1:numRows
            col2Data.setEntry(indx1,1,objs{indx1});
        end

        ft.addRow({col1Data,col2Data});
    end

end


function ft=setPassUserData(ft,constraint,objs)
    ft.UserData.ID=constraint.getID;
    ft.UserData.Sid=cellfun(@getSID,objs,'UniformOutput',false);
end


function ft=setFailUserData(ft,constraint,sids)
    ft.UserData.ID=constraint.getID;
    ft.UserData.Sid=sids;
    ft.UserData.Constraint=constraint;
end
