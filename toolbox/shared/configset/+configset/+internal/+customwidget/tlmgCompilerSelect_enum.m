function[out,dscr]=tlmgCompilerSelect_enum(cs,~)


    dscr='';
    l_tlmgCompilerSelectDetected=cs.get_param('tlmgCompilerSelectDetected');
    out=struct('str',l_tlmgCompilerSelectDetected,...
    'disp',l_tlmgCompilerSelectDetected);
