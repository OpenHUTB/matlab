function constrStruct=getConstraintStruct(zeroSize)
    constrStruct=struct(...
    'Name','',...
    'Condition','true',...
    'Description','');
    if nargin==1&&zeroSize
        constrStruct(end)=[];
    end
end
