function loadDefaultExclusions(this,fileName)




    import matlab.io.xml.dom.*
    tree=parseFile(Parser,fileName);
    xRoot=tree.getDocumentElement;
    sysNode=xRoot.getElementsByTagName('System');
    exclusionArray=[];
    if strcmp(class(this),'ModelAdvisor.ExclusionEditor')
        checkType='ModelAdvisor';
    else
        checkType='CloneDetection';
    end
    for j=0:sysNode.getLength-1
        exclusionArray=[exclusionArray,ModelAdvisor.constructExclusionObjArray(sysNode.item(j),checkType)];
        sys=sysNode.item(j).getAttributes;
        sys=char(sys.item(0).getNodeValue);
        for i=1:length(exclusionArray)
            prop=[];
            prop.propDesc='';
            prop.sys=sys;
            rules=exclusionArray(i).rules;
            if length(rules)>1
                prop.Type='custom';
                prop.value='....';
                prop.userdata=rules;
            else
                prop.Type=rules.Type;
                prop.value=rules.value{1};
            end
            prop.includeChildren=1;

            try
                prop.rationale=exclusionArray(i).Rationale;
            catch
                prop.Name=prop.value;
            end
            prop.checkIDs=exclusionArray(i).checkIDs;
            prop.Rationale='';
            if~isKey(this.defaultExclusionState,this.getPropKey(prop))
                this.defaultExclusionState(this.getPropKey(prop))=prop;
            else
                val=this.defaultExclusionState(this.getPropKey(prop));
                val.checkIDs=[val.checkIDs,prop.checkIDs];
                this.defaultExclusionState(this.getPropKey(prop))=val;
            end
        end
    end
end
