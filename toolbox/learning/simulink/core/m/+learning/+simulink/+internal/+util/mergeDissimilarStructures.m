function structArray=mergeDissimilarStructures(structures,defaultempty)








    if nargin<2
        defaultempty=[];
    end

    fieldunion=cellfun(@fieldnames,structures,'UniformOutput',false);
    fieldunion=unique(vertcat(fieldunion{:}));
    structArray=repmat({defaultempty},numel(structures),numel(fieldunion));
    for sidx=1:numel(structures)
        [~,destcol]=ismember(fieldnames(structures{sidx}),fieldunion);
        structArray(sidx,destcol)=struct2cell(structures{sidx});
    end
    structArray=reshape(cell2struct(structArray,fieldunion,2),size(structures));
end
