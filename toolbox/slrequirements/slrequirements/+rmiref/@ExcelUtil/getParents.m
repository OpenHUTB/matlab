function parents=getParents(filename,arg)

    utilObj=rmiref.ExcelUtil.docUtilObj(filename);
    allSections=rmiref.ExcelUtil.getDocStructure(filename);
    matchLabel=true;
    if ischar(arg)

        [label,row]=getTextForAddress(utilObj,arg);
        if isempty(label)


            label=arg;
            try
                hName=utilObj.hDoc.Names.Item(label);
            catch
                hName=[];
            end
            if isempty(hName)

                row=findRow(utilObj.hDoc,label);
            else
                row=hName.RefersToRange.Row;
                matchLabel=false;
            end
        end
    else



        row=arg;
        label=strtok(utilObj.getLabel(row));
    end


    if matchLabel
        parentIdx=findParentByLabel(allSections(1:row-1,1),label);
    else
        parentIdx=[];
    end

    if isempty(parentIdx)


        myItem=allSections(row,:);
        parentRow=myItem{2};
        parents=cell(0,3);
        while parentRow>0
            parent=allSections(parentRow,:);
            parents=[{parentRow,parent{1},parent{3}};parents];%#ok<AGROW>
            parentRow=parent{2};
        end
    else
        parents={parentIdx,allSections{parentIdx}};
    end
end

function parentIdx=findParentByLabel(previousLabels,label)
    parentIdx=[];
    for i=length(previousLabels):-1:1
        oneLabel=strtok(previousLabels{i});
        if isempty(strfind(label,oneLabel))
            continue;
        else
            parentIdx=i;
            break;
        end
    end
end

function row=findRow(hDoc,label)
    hSheet=hDoc.Sheets.Item(1);
    hSheet.Activate;
    hAll=hSheet.Range('A1:IV20000');
    hRange=hAll.Find(label);
    row=hRange.Row;
end

function[label,row]=getTextForAddress(utilObj,arg)
    match=regexp(arg,'^\$[A-Z]+\$(\d+)$','tokens');
    if isempty(match)

        label='';
        row=-1;
    else
        row=str2num(match{1}{1});%#ok<ST2NM>
        myRange=utilObj.hDoc.Sheets.Item(1).Range(arg);
        label=myRange.Text;
    end
end