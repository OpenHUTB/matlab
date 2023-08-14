classdef FILLoadBitstreamDialogT<handle















    properties(SetObservable,GetObservable)

        FileName{matlab.internal.validation.mustBeASCIICharRowVector(FileName,'FileName')}='';

        BoardName{matlab.internal.validation.mustBeASCIICharRowVector(BoardName,'BoardName')}='';

        DeviceName{matlab.internal.validation.mustBeASCIICharRowVector(DeviceName,'DeviceName')}='';

        Status{matlab.internal.validation.mustBeCharRowVector(Status,'Status')}='';
    end


    methods
        function this=FILLoadBitstreamDialogT(varargin)




            assert(license('test','EDA_Simulator_Link')==1,...
            'EDALink:FILLoadBitstreamDialogT:NoLicense',...
            'HDL Verifier license is not available.');

        end

    end



    methods(Hidden)
        dStruct=getDialogSchema(this,~)
        updateInfo(this,fn,bn,dn)
        updateStatus(this,status)
    end

    methods
        function set.Status(obj,value)
            obj.Status=matlab.internal.validation.makeCharRowVector(value);
        end
    end
    methods
        function set.DeviceName(obj,value)
            obj.DeviceName=matlab.internal.validation.makeCharRowVector(value);
        end
    end
    methods
        function set.BoardName(obj,value)
            obj.BoardName=matlab.internal.validation.makeCharRowVector(value);
        end
    end
    methods
        function set.FileName(obj,value)
            obj.FileName=matlab.internal.validation.makeCharRowVector(value);
        end
    end
end

