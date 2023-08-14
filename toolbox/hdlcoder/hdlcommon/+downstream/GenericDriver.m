


classdef GenericDriver<handle



    properties

        GenericFileList={};

    end

    properties

        hDI=[];
        hClockModule=[];
        hConstraintEmitter=[];
    end

    methods
        function obj=GenericDriver(hDI)
            obj.hDI=hDI;
            obj.hConstraintEmitter=downstream.GenericConstraintEmitter(hDI);
            obj.hClockModule=hdlturnkey.ClockModuleGeneric(hDI);
        end
    end

end

