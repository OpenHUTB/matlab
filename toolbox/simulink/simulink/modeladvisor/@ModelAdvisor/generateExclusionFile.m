function[status,msg]=generateExclusionFile(exclusionObjList,sysName,fileName,checkType)





    import matlab.io.xml.dom.*
    status=true;
    msg='';
    if~Advisor.Utils.license('test','SL_Verification_Validation')
        DAStudio.error('ModelAdvisor:engine:ExclusionLicenseFailed');
    end

    exclusionArray=readExclusions(fileName,checkType);


    import matlab.io.xml.dom.*

    docNode=Document('rsccat');
    docRootNode=docNode.getDocumentElement;
    docRootNode.setAttribute('version','1.0');
    docRootNode.setAttribute('locale','en_US');
    sysListNode=docNode.createElement('SystemList');
    sysNode=docNode.createElement('System');
    sysNode.setAttribute('Name',sysName);
    ExclusionListNode=docNode.createElement('ExclusionList');

    if iscell(exclusionObjList)
        t=[];
        if~isempty(exclusionObjList)
            t=exclusionObjList{1};
        end
        for i=2:length(exclusionObjList)
            t(end+1)=exclusionObjList{i};%#ok<AGROW>
        end
        exclusionObjList=t;
        for i=1:length(exclusionObjList)
            if iscell(exclusionObjList(i).Rules)
                t=exclusionObjList(i).Rules{1};
                for j=2:length(exclusionObjList(i).Rules)
                    t(end+1)=exclusionObjList(i).Rules{j};%#ok<AGROW>
                end
                exclusionObjList(i).Rules=t;
            end
        end
    end

    for i=1:length(exclusionObjList)
        ExclusionNode=docNode.createElement('Exclusion');
        ruleListNode=docNode.createElement('RuleList');
        ExclusionNode.setAttribute('Rationale',exclusionObjList(i).Rationale);
        rule=exclusionObjList(i).Rules;
        for j=1:length(rule)
            ruleNode=docNode.createElement('Rule');
            ruleNode.setAttribute('Type',rule(j).Type);
            ruleNode.setAttribute('SID',rule(j).SID);
            ruleNode.setAttribute('RegExp',rule(j).RegExp);
            if strcmp(rule(j).Type,'BlockParameters')
                Name=rule(j).Name;
                Value=rule(j).Value;
                if~iscell(Value)
                    Value={Value};
                end
                if~iscell(Name)
                    Value={Name};
                end
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
                if~iscell(Value)
                    Value={Value};
                end
                for k=1:length(Value)
                    paramValueNode=docNode.createElement('paramValue');
                    paramValueNode.appendChild(docNode.createTextNode(Value{k}));
                    ruleNode.appendChild(paramValueNode);
                end
            end
            ruleListNode.appendChild(ruleNode);
        end
        ExclusionNode.appendChild(ruleListNode);
        CheckID=exclusionObjList(i).CheckIDs;
        CheckIDListNode=docNode.createElement('CheckIDList');
        for j=1:length(CheckID)
            CheckIDNode=docNode.createElement('CheckID');
            CheckIDNode.appendChild(docNode.createTextNode(CheckID{j}));
            CheckIDListNode.appendChild(CheckIDNode);
        end
        ExclusionNode.appendChild(CheckIDListNode);
        if strcmp(exclusionObjList(i).CheckType,'CloneDetection')
            CheckTypeParent=docNode.createElement('CheckTypeList');
            CheckType=docNode.createElement('CheckType');
            CheckType.appendChild(docNode.createTextNode(exclusionObjList(i).CheckType));
            CheckTypeParent.appendChild(CheckType);
            ExclusionNode.appendChild(CheckTypeParent);
        end






        ExclusionListNode.appendChild(ExclusionNode);
    end

    appendExclusionArray(exclusionArray,docNode,ExclusionListNode);
    sysNode.appendChild(ExclusionListNode);
    sysListNode.appendChild(sysNode);
    docRootNode.appendChild(sysListNode);

    fileID=fopen(fileName,'w');
    if(fileID==-1)
        status=false;
        msg=DAStudio.message('ModelAdvisor:engine:ExclusionFileWritable');
        return;
    else
        fclose(fileID);
    end

    try
        docNode.xmlwrite(fileName);
    catch E
        status=false;
        msg=E.message;
    end



    function exclusionArray=readExclusions(fileName,checkType)
        exclusionArray=[];
        if isempty(fileName)||exist(fileName,'file')==0
            return;
        end
        try
            tree=parseFile(Parser,fileName);
            xRoot=tree.getDocumentElement;
            sysNode=xRoot.getElementsByTagName('System');

            if strcmp(checkType,'ModelAdvisor')
                checkTypeChange='CloneDetection';
            else
                checkTypeChange='ModelAdvisor';
            end
            for i=0:sysNode.getLength-1
                exclusionArray=[exclusionArray,ModelAdvisor.constructExclusionObjArray(sysNode.item(i),checkTypeChange)];%#ok<AGROW>
            end
        catch E
            return;
        end


        function appendExclusionArray(exclusionObjList,docNode,ExclusionListNode)
            for i=1:length(exclusionObjList)
                ExclusionNode=docNode.createElement('Exclusion');
                ruleListNode=docNode.createElement('RuleList');
                ExclusionNode.setAttribute('Rationale',exclusionObjList(i).Rationale);
                rule=exclusionObjList(i).Rules;
                for j=1:length(rule)
                    ruleNode=docNode.createElement('Rule');
                    ruleNode.setAttribute('Type',rule(j).Type);
                    ruleNode.setAttribute('SID',rule(j).SID);
                    ruleNode.setAttribute('RegExp',rule(j).RegExp);
                    if strcmp(rule(j).Type,'BlockParameters')
                        Name=rule(j).Name;
                        Value=rule(j).Value;
                        if~iscell(Value)
                            Value={Value};
                        end
                        if~iscell(Name)
                            Value={Name};
                        end
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
                        if~iscell(Value)
                            Value={Value};
                        end
                        for k=1:length(Value)
                            paramValueNode=docNode.createElement('paramValue');
                            paramValueNode.appendChild(docNode.createTextNode(Value{k}));
                            ruleNode.appendChild(paramValueNode);
                        end
                    end
                    ruleListNode.appendChild(ruleNode);
                end
                ExclusionNode.appendChild(ruleListNode);
                CheckID=exclusionObjList(i).CheckIDs;
                CheckIDListNode=docNode.createElement('CheckIDList');
                for j=1:length(CheckID)
                    CheckIDNode=docNode.createElement('CheckID');
                    CheckIDNode.appendChild(docNode.createTextNode(CheckID{j}));
                    CheckIDListNode.appendChild(CheckIDNode);
                end
                ExclusionNode.appendChild(CheckIDListNode);
                if strcmp(exclusionObjList(i).CheckType,'CloneDetection')
                    CheckTypeParent=docNode.createElement('CheckTypeList');
                    CheckType=docNode.createElement('CheckType');
                    CheckType.appendChild(docNode.createTextNode(exclusionObjList(i).CheckType));
                    CheckTypeParent.appendChild(CheckType);
                    ExclusionNode.appendChild(CheckTypeParent);
                end
                ExclusionListNode.appendChild(ExclusionNode);
            end
