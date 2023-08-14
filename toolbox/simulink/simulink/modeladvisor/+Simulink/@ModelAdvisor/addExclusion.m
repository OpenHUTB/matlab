function addExclusion(this,exclusionObjArray,system)





    return
    for k=1:length(exclusionObjArray)
        exclusionObj=copy(exclusionObjArray(k));
        switch exclusionObj.Type
        case 'SubSystem'
            if strcmp(exclusionObj.Value(1),'*')
                exclusionObj.Value=[system,exclusionObj.Value(2:end)];
            end
            try
                exclusionObj.SID=Simulink.ID.getSID(exclusionObj.Value);
            catch E
                exclusionObj.SID='';
            end
            if~strcmp(get_param(get_param(exclusionObj.Value,'handle'),'BlockType'),'SubSystem')
                DAStudio.message('ModelAdvisor:engine:NotSubSystem');
            end
        case 'Block'
            if strcmp(exclusionObj.Value(1),'*')
                exclusionObj.Value=[system,exclusionObj.Value(2:end)];
            end
            try
                exclusionObj.SID=Simulink.ID.getSID(exclusionObj.Value);
            catch E
                exclusionObj.SID='';
            end

        case 'BlockType'
        case 'MaskType'

        end

        this.ExclusionCellArray{end+1}=exclusionObj;
        exclusionIndex=length(this.ExclusionCellArray);
        for i=1:length(exclusionObj.CheckIDs)
            if strcmp(exclusionObj.CheckIDs{i},'*')

                for j=1:length(this.CheckCellArray)

                    this.CheckCellArray{j}.ExclusionIndex{end+1}=exclusionIndex;

                end
            else
                checkObj=this.getCheckObj(exclusionObj.CheckIDs{i});
                if~isempty(checkObj)
                    checkObj.ExclusionIndex{end+1}=exclusionIndex;
                end
            end
        end

    end