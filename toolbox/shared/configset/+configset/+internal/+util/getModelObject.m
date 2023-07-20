function model=getModelObject(model)











    if ischar(model)||isStringScalar(model)||isnumeric(model)

        model=get_param(model,'Object');
    end
    if~isa(model,'Simulink.BlockDiagram')&&~isa(model,'Simulink.Root')
        throw(MSLException([],message(...
        'Simulink:ConfigSet:FirstInpArgMustBeValidModel')));
    end


