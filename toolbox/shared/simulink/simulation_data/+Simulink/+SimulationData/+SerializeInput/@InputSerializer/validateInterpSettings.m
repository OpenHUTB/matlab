function turnOffInterp=validateInterpSettings(this,data,interpolation,inputPath)




    turnOffInterp=false;
    if~interpolation
        return;
    end

    if(isenum(data)||isfi(data)||iscellstr(data))&&...
        isequal(get_param(this.currBlock,'IsBusElementPort'),'on')
        if isequal(this.slFeatures.busElPortAutoInterp,0)



            this.throwError(...
            false,...
'Simulink:SimInput:BusElementPortNonSupportedInterpData'...
            );
        else



            turnOffInterp=true;
        end
    else
        if iscellstr(data)%#ok<*ISCLSTR>
            this.throwError(...
            true,...
            'Simulink:SimInput:LoadingStrInterp',...
inputPath...
            );
        elseif isenum(data)


            this.throwError(...
            false,...
'Simulink:SimInput:LoadingCannotInterpFiOrEnum'...
            );
        elseif isfi(data)&&...
            this.slFeatures.rootInportInterpolation<2

            this.throwError(...
            false,...
'Simulink:SimInput:LoadingCannotInterpFiOrEnum'...
            );
        end
    end
end
