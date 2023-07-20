function exclusionObjArray=constructExclusionObjArray(sysNode,checkTypeValue)




    if nargin<2
        checkTypeValue='ModelAdvisor';
    end
    exclusionObjArray=[];

    exListNode=sysNode.getElementsByTagName('ExclusionList');
    if exListNode.getLength==0
        return;
    end
    ExclusionNode=exListNode.item(0).getElementsByTagName('Exclusion');
    for i=0:ExclusionNode.getLength-1
        checkType=getCheckType(ExclusionNode.item(i));
        if(strcmp(checkType,checkTypeValue))
            exclusionObjArray=[exclusionObjArray,constructExclusionObj(ExclusionNode.item(i),checkTypeValue)];
        end
    end

    function exclusionObj=constructExclusionObj(ExclusionNode,checkTypeValue)
        exclusionObj=ModelAdvisor.Exclusion;
        ruleObjList=getRuleObjList(ExclusionNode);
        checkIDList=getCheckIDList(ExclusionNode);
        Rationale=getExclusionDetails(ExclusionNode);
        exclusionObj.CheckType=checkTypeValue;
        exclusionObj.Rationale=Rationale;
        exclusionObj.Rules=ruleObjList;
        exclusionObj.CheckIDs=checkIDList;


        function Rationale=getExclusionDetails(ExclusionNode)
            Rationale='';
            exclusionAttributes=ExclusionNode.getAttributes;
            for i=0:exclusionAttributes.getLength-1
                if strcmpi(exclusionAttributes.item(i).getNodeName,'Rationale')
                    Rationale=char(exclusionAttributes.item(i).getNodeValue);
                end
            end

            function checkIDList=getCheckIDList(ExclusionNode)
                CheckIDListNode=ExclusionNode.getElementsByTagName('CheckIDList');
                CheckIDNode=CheckIDListNode.item(0).getElementsByTagName('CheckID');
                checkIDList={};
                for i=0:CheckIDNode.getLength-1
                    checkIDList{end+1}=char(CheckIDNode.item(i).item(0).getNodeValue);
                end

                function checkType=getCheckType(ExclusionNode)
                    checkType='ModelAdvisor';
                    CheckTypeParent=ExclusionNode.getElementsByTagName('CheckTypeList');
                    if~isempty(CheckTypeParent.item(0))
                        CheckType=CheckTypeParent.item(0).getElementsByTagName('CheckType');
                        checkType=CheckType.item(0).item(0).getNodeValue;
                    end


                    function ruleObjList=getRuleObjList(ExclusionNode)
                        ruleObjList=[];
                        RuleListNode=ExclusionNode.getElementsByTagName('RuleList');
                        RuleNode=RuleListNode.item(0).getElementsByTagName('Rule');
                        for i=0:RuleNode.getLength-1
                            RuleObj=ModelAdvisor.Rule;
                            RuleAttributes=RuleNode.item(i).getAttributes;
                            for k=0:RuleAttributes.getLength-1
                                if strcmp(RuleAttributes.item(k).getNodeName,'Type')
                                    RuleObj.Type=char(RuleAttributes.item(k).getNodeValue);
                                elseif strcmp(RuleAttributes.item(k).getNodeName,'RegExp')
                                    RuleObj.RegExp=char(RuleAttributes.item(k).getNodeValue);
                                elseif strcmp(RuleAttributes.item(k).getNodeName,'SID')
                                    RuleObj.SID=char(RuleAttributes.item(k).getNodeValue);
                                end
                            end

                            if strcmp(RuleObj.Type,'BlockParameters')
                                paramNameNode=RuleNode.item(i).getElementsByTagName('paramName');
                                paramValueNode=RuleNode.item(i).getElementsByTagName('paramValue');
                                pName={};
                                pValue={};
                                for j=0:paramValueNode.getLength-1
                                    pName{end+1}=char(paramNameNode.item(j).item(0).getNodeValue);
                                    pValue{end+1}=char(paramValueNode.item(j).item(0).getNodeValue);
                                end
                                RuleObj.Name=pName;
                                RuleObj.Value=pValue;
                            else
                                paramValueNode=RuleNode.item(i).getElementsByTagName('paramValue');
                                pValue={};
                                for j=0:paramValueNode.getLength-1
                                    pValue{end+1}=char(paramValueNode.item(j).item(0).getNodeValue);
                                end
                                RuleObj.Value=pValue;
                            end
                            if isempty(ruleObjList)
                                ruleObjList=RuleObj;
                            else
                                ruleObjList(end+1)=RuleObj;
                            end
                        end