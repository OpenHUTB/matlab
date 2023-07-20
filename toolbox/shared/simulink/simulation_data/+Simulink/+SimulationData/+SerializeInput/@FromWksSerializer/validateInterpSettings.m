function turnOffInterp=validateInterpSettings(this,data,interpolation,inputPath)




    turnOffInterp=false;
    if~interpolation
        return;
    end

    if iscellstr(data)||isenum(data)||isfi(data)%#ok<ISCLSTR>
        this.throwError(...
        false,...
        'Simulink:SimInput:FromWksCannotInterpFiEnumString',...
inputPath...
        );
    end
end


