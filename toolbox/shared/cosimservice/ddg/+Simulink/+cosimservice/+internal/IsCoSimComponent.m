function flag=IsCoSimComponent(bh)
    bType=get_param(bh,'BlockType');



    flag=any(strcmp({'SubSystem','S-Function','FMU','ModelReference',...
    'MATLABSystem','CoSimServiceBlock'},...
    bType));
end