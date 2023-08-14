function exclusionXMLGenerator(exclusionObjList,sysName,fileName)




    import matlab.io.xml.dom.*

    docNode=Document('rsccat');

    docRootNode=docNode.getDocumentElement;
    docRootNode.setAttribute('version','1.0');
    docRootNode.setAttribute('locale','en_US');
    sysListNode=docNode.createElement('SystemList');
    sysNode=docNode.createElement('System');
    sysNode.setAttribute('Name',sysName);
    ExclusionListNode=docNode.createElement('ExclusionList');

    for i=1:length(exclusionObjList)
        ExclusionNode=docNode.createElement('Exclusion');
        ExclusionNode.setAttribute('Name',exclusionObjList(i).Name);
        ruleListNode=docNode.createElement('RuleList');
        rule=exclusionObjList(i).Rule;
        for j=1:length(rule)
            ruleNode=docNode.createElement('Rule');
            ruleNode.setAttribute('Type',rule(j).Type);
            ruleNode.setAttribute('SID',rule(j).SID);
            ruleNode.setAttribute('RegExp',rule(j).RegExp);
            if strcmp(rule(j).Type,'BlockParameters')
                Name=rule(j).Name;
                Value=rule(j).Value;
                for k=1:length(Value)
                    paramValueNode=docNode.createElement('paramValue');
                    paramNameNode=docNode.createElement('paramName');
                    paramValueNode.appendChild(docNode.createTextNode(Value{k}));
                    paramNameNode.appendChild(docNode.createTextNode(Name{k}));
                    ruleNode.appendChild(paramNameNode);
                    ruleNode.appendChild(paramValueNode);
                end
            else
                Value=rule(j).Value;
                for k=1:length(Value)
                    paramValueNode=docNode.createElement('paramValue');
                    paramValueNode.appendChild(docNode.createTextNode(Value{k}));
                    ruleNode.appendChild(paramValueNode);
                end
            end
            ruleListNode.appendChild(ruleNode);
        end
        ExclusionNode.appendChild(ruleListNode);
        CheckID=exclusionObjList(i).CheckID;
        CheckIDListNode=docNode.createElement('CheckIDList');
        for j=1:length(CheckID)
            CheckIDNode=docNode.createElement('CheckID');
            CheckIDNode.appendChild(docNode.createTextNode(CheckID{k}));
            CheckIDListNode.appendChild(CheckIDNode);
        end
        ExclusionNode.appendChild(CheckIDListNode);
        ExclusionListNode.appendChild(ExclusionNode);
    end
    sysNode.appendChild(ExclusionListNode);
    sysListNode.appendChild(sysNode);
    docRootNode.appendChild(sysListNode);

    fileID=fopen(fileName,'w');
    if(fileID==-1)
        disp(DAStudio.message('ModelAdvisor:engine:ExclusionFileWritable'));
        return;
    end

    try
        docNode.xmlwrite(fileName);
    catch E
    end