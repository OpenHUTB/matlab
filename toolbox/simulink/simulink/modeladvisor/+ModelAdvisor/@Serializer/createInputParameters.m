function out=createInputParameters(this,checkObj)

    if isempty(checkObj.InputParameters)
        out=[];
        return;
    end

    out=[];

    for i=1:length(checkObj.InputParameters)
        inpElement=this.IPStruct;

        fields=fieldnames(inpElement);
        for j=1:numel(fields)
            if~isempty(inpElement.(fields{j}))&&isprop(checkObj.InputParameters{i},inpElement.(fields{j}))
                inpElement.(fields{j})=checkObj.InputParameters{i}.(inpElement.(fields{j}));
            end
        end


        inpElement.index=i;

        if~isempty(checkObj.InputParameters{i}.RowSpan)
            inpElement.rowspan1=checkObj.InputParameters{i}.RowSpan(1);
            inpElement.rowspan2=checkObj.InputParameters{i}.RowSpan(2);
        else
            inpElement.rowspan1=i;
            inpElement.rowspan2=i;
        end

        if~isempty(checkObj.InputParameters{i}.ColSpan)
            inpElement.colspan1=checkObj.InputParameters{i}.ColSpan(1);
            inpElement.colspan2=checkObj.InputParameters{i}.ColSpan(2);
        else
            inpElement.colspan1=1;
            inpElement.colspan2=1;
        end

        switch checkObj.InputParameters{i}.Type
        case 'BlockType'
            ValueElement=[];
            for j=1:length(checkObj.InputParameters{i}.Value)
                if isempty(checkObj.InputParameters{i}.Value{j})
                    continue;
                end
                ValueElement(j).name=checkObj.InputParameters{i}.Value{j,1};
                ValueElement(j).masktype=checkObj.InputParameters{i}.Value{j,2};
            end
            inpElement.entries=checkObj.InputParameters{i}.Entries;
            inpElement.value=ValueElement;
        case 'BlockTypeWithParameter'
            ValueElement=[];
            for j=1:length(checkObj.InputParameters{i}.Value)
                if isempty(checkObj.InputParameters{i}.Value{j})
                    continue;
                end
                ValueElement(j).name=checkObj.InputParameters{i}.Value{j,1};
                ValueElement(j).masktype=checkObj.InputParameters{i}.Value{j,2};
                ValueElement(j).blocktypeparameters=checkObj.InputParameters{i}.Value{j,3};
            end
            inpElement.entries=checkObj.InputParameters{i}.Entries;
            inpElement.value=ValueElement;
        case 'PushButton'
            inpElement.entries=[];
            inpElement.value=checkObj.InputParameters{i}.value;
        otherwise
            inpElement.entries=checkObj.InputParameters{i}.Entries;
            inpElement.value=checkObj.InputParameters{i}.value;
        end
        out=[out,inpElement];%#ok<AGROW> 
    end
end