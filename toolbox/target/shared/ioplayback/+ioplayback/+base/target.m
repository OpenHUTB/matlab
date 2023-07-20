function y=target()



















%#codegen

    coder.allowpcode('plain');

    if coder.target('MATLAB')

        y=true;
    else

        y=false;
    end
