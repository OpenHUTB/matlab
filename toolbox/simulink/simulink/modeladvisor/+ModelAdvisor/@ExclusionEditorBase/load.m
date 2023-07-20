function status=load(this)



    import matlab.io.xml.dom.*

    status=true;
    if this.storeInSLX
        Simulink.slx.extractFileForPart(this.fModelName,this.getSlxPartName);
    end

    if isempty(this.fileName)||exist(this.fileName,'file')==0
        return;
    end

    try
        tree=parseFile(Parser,this.fileName);
        xRoot=tree.getDocumentElement;
        sysNode=xRoot.getElementsByTagName('System');
        exclusionArray=[];
        if strcmp(class(this),'ModelAdvisor.ExclusionEditor')
            checkType='ModelAdvisor';
        else
            checkType='CloneDetection';
        end
        for i=0:sysNode.getLength-1
            exclusionArray=[exclusionArray,ModelAdvisor.constructExclusionObjArray(sysNode.item(i),checkType)];%#ok<AGROW>
        end
    catch E
        status=false;
        return;
    end

    this.setExclusions(exclusionArray);

    for i=1:length(exclusionArray)
        prop=[];
        prop.propDesc='';

        prop.idx=i;
        Rules=exclusionArray(i).Rules;
        prop.sid=Rules.SID;
        if length(Rules)>1
            prop.Type='hybrid';
        else
            prop.Type=Rules.Type;
        end
        prop.includeChildren=1;
        if strcmpi(prop.Type,'Subsystem')||strcmpi(prop.Type,'Block')
            if strcmpi(Rules.SID,'off')
                prop.value=[this.fModelName,'/',Rules.Value{1}];
            else
                prop.value=[this.fModelName,':',Rules.Value{1}];
            end
        else
            prop.value=Rules.Value{1};
        end
        try
            prop.rationale=exclusionArray(i).Rationale;
            prop.Name=get_param(prop.value,'Name');
        catch
            prop.Name=prop.value;
        end
        prop.checkIDs=exclusionArray(i).CheckIDs;
        prop.Rationale='';
        prop.checkType=exclusionArray(i).CheckType;
        if~isKey(this.exclusionState,this.getPropKey(prop))
            this.exclusionState(this.getPropKey(prop))=prop;
        else
            val=this.exclusionState(this.getPropKey(prop));
            val.checkIDs=[val.checkIDs,prop.checkIDs];
            this.exclusionState(this.getPropKey(prop))=val;
        end
    end
end
