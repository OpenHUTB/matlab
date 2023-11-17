function FW=setMappedCoefficientLTData(FW,datcomStruct,coeffMap,statesMap,component)

    coeffTemplate=Simulink.LookupTable;
    coeffs=cell(size(coeffMap,1),1);

    bpOrder=cell(size(statesMap,1),1);
    for i=1:size(statesMap,1)
        if numel(datcomStruct.(statesMap(i,1)))<2
            coeffTemplate.Breakpoints(i).Value=[0,0];
            bpOrder{i}=1;
            continue
        end

        if statesMap(i,1)=="deltal"
            coeffTemplate.Breakpoints(i).Value=datcomStruct.deltal-datcomStruct.deltar;
        elseif statesMap(i,1)=="grndht"

            coeffTemplate.Breakpoints(i).Value=[0,datcomStruct.(statesMap(i,1))];
        else
            coeffTemplate.Breakpoints(i).Value=datcomStruct.(statesMap(i,1));
        end
        coeffTemplate.Breakpoints(i).FieldName=statesMap(i,2);
        [coeffTemplate.Breakpoints(i).Value,bpOrder{i}]=sort(coeffTemplate.Breakpoints(i).Value);
    end

    for i=1:size(coeffMap,1)

        if~isfield(datcomStruct,coeffMap(i,1))
            continue
        end


        tmpLT=copy(coeffTemplate);
        tmpLT.Table.Value=extractDATCOMdata(datcomStruct,coeffMap(i,1),statesMap(:,1));


        idxDelta=contains(statesMap(:,1),"delta");
        sLT=size(tmpLT.Table.Value,1:numel(idxDelta));
        if(datcomStruct.ndelta>0)&&isempty(datcomStruct.delta)&&isempty(datcomStruct.deltal)...
            &&any(idxDelta)&&(sLT(idxDelta)~=1)
            warning(message("aero_aircraft:datcomToFixedWing:UnmappedCoefficient",coeffMap(i,1)))
            continue
        end


        idx=size(tmpLT.Table.Value,1:numel(tmpLT.Breakpoints))~=1;
        tmpLT.Breakpoints=tmpLT.Breakpoints(idx);



        if numel(size(tmpLT.Table.Value))~=numel(bpOrder)
            bpOrder=bpOrder(idx);
        end

        tmpLT.Table.Value=squeeze(tmpLT.Table.Value(bpOrder{:}));


        coeffs{i}=tmpLT;
    end


    idx=cellfun(@isempty,coeffs);
    coeffs(idx)=[];
    coeffMap(idx,:)=[];


    FW=FW.setCoefficient(coeffMap(:,2),coeffMap(:,3),coeffs,"Component",component,"AddVariable",true);
end