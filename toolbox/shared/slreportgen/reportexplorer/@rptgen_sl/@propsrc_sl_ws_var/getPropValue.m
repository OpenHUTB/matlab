function[pValue,propName]=getPropValue(~,objList,propName)





    switch propName
    case 'Name'
        pValue={objList(:).Name};

    case 'DataType'
        pValue=locGetDataType(objList);

    case 'UsedByBlocks'
        pValue=locGetUsedByBlocks(objList);

    case 'Workspace'
        pValue={objList(:).Source};

    case 'WorkspaceType'
        pValue={objList(:).SourceType};

    case 'Value'
        pValue=locGetValue(objList);

    otherwise
        pValue='';
    end



    function pValue=locGetDataType(objList)

        numberOfObjects=length(objList);
        pValue=cell(1,numberOfObjects);

        for i=1:numberOfObjects
            [resolvedVariable,variableExists]=slResolve(objList(i).Name,...
            objList(i).UsedByBlocks{1});
            if variableExists
                pValue{i}=class(resolvedVariable);
            else
                pValue{i}='undefined';
            end
        end


        function pValue=locGetValue(objList)

            numberOfObjects=length(objList);
            pValue=cell(numberOfObjects,1);

            for i=1:numberOfObjects
                pValue{i}=objList(i).Value;
            end


            function pValue=locGetUsedByBlocks(objList)

                numberOfObjects=length(objList);
                pValue=cell(numberOfObjects,1);
                ps=rptgen_sl.propsrc_sl;
                d=get(rptgen.appdata_rg,'CurrentDocument');
                for i=1:numberOfObjects
                    usedByBlocks=objList(i).UsedByBlocks;
                    for j=1:length(usedByBlocks)
                        linkID=ps.getObjectID(usedByBlocks{j});
                        pValue{i}{j}=d.makeLink(linkID,usedByBlocks{j},'link');
                    end
                end





