




function ftList=iterateMLBlocks(system,objectID)

    ftList={};%#ok<NASGU>


    modelObj=getSLCIModelObj();
    objs=modelObj.getBlockType('MatlabFunction');


    [result,constraintMap,failureMap]=runChecks(objs);


    ftList=formatResults(constraintMap,failureMap,objectID,objs);

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(result);

end





function[result,constraintMap,failureMap]=runChecks(objs)


    failureMap=containers.Map;
    constraintMap=containers.Map;
    result=true;

    for i=1:numel(objs)

        obj=objs{i};


        blkConstraints=obj.getConstraints;
        [blkResult,constraintMap,failureMap]=...
        runConstraints(blkConstraints,constraintMap,failureMap);
        result=result&&blkResult;


        chart=obj.getEMChart();
        chartConstraints=chart.getConstraints();
        [chartResult,constraintMap,failureMap]=...
        runConstraints(chartConstraints,constraintMap,failureMap);
        result=result&&chartResult;

    end

end


function[result,constraintMap,failureMap]=runConstraints(constraints,...
    constraintMap,...
    failureMap)

    [result,failureMap]=runMLConstraints(constraints,failureMap);
    for j=1:numel(constraints)
        constraint=constraints{j};
        ckey=constraint.getID;
        if~isKey(constraintMap,ckey)
            constraintMap(ckey)=constraint;
        end
    end
end


function ftList=formatResults(constraintMap,failureMap,objectID,objs)

    ftList={};

    cKeys=constraintMap.keys;
    if isempty(objs)


        ft=ModelAdvisor.FormatTemplate('ListTemplate');
        ft.setSubResultStatusText(...
        DAStudio.message('Slci:compatibility:NoMLObjects',...
        DAStudio.message(['Slci:compatibility:',objectID])));
        ftList{1}=ft;

    elseif isempty(cKeys)


        ft=ModelAdvisor.FormatTemplate('ListTemplate');
        ft.setSubResultStatusText(...
        DAStudio.message('Slci:compatibility:AllMLObjectsCompatible',...
        DAStudio.message(['Slci:compatibility:',objectID])));
        ftList{1}=ft;
    else


        for i=1:numel(cKeys)

            constraintKey=cKeys{i};
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
                        StatusText=[DAStudio.message('Slci:compatibility:PrereqConstraintsWarn')...
                        ,StatusText];%#ok<AGROW>                        
                    end

                    ft=ModelAdvisor.FormatTemplate('ListTemplate');
                    ft.setSubTitle(SubTitle);
                    ft.setInformation(Information);
                    ft.setSubResultStatus('Warn');
                    ft.setSubResultStatusText(StatusText);
                    ft.setRecAction(RecAction);


                    handle=cell(1,numel(incomp));
                    for j=1:numel(incomp)
                        handle{j}=incomp(j).getConstraint().getOwner().getSID();
                    end
                    ft.setListObj(handle);


                    ft=setFailUserData(ft,constraint,handle);

                    ftList{end+1}=ft;%#ok<AGROW>
                end
            end

        end
    end

    if~isempty(ftList)
        ftList{end}.setSubBar(true);
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
