function ret=haveMisplacedSignalsInput(sumBlock)

    ret=false;
    if isempty(sumBlock)
        return;
    end

    limDecimal=4;




    inportHandles=sumBlock.PortHandles.Inport;
    if isempty(inportHandles)
        return;
    end

    rotations=cell(1,length(inportHandles));

    for idx=1:numel(inportHandles)
        inportObj=get(inportHandles(idx));
        if isfield(inportObj,'Rotation')
            rotations{idx}=round(inportObj.Rotation,limDecimal);
        end
    end

    rotations=rotations(~cellfun('isempty',rotations));


    piBy2=round(pi/2,limDecimal);


    ret=any(cellfun(@(x)logical(mod(round(x,limDecimal),piBy2)),rotations));
end
