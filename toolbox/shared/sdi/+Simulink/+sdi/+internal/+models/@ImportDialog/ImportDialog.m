classdef ImportDialog<handle




    properties(GetAccess='public',SetAccess='private')
        varNames;
        varValues;
    end

    properties(Access='public')
        baseWSOrMAT;
        matFileName='';
        newOrExistRun;
        existRunID;
        PreferredImporter='';
    end

    methods
        function set.baseWSOrMAT(this,val)
            if~islogical(val)
                error(message('SDI:sdi:invalidInput'));
            end
            this.baseWSOrMAT=val;
        end

        function set.newOrExistRun(this,val)
            if~islogical(val)
                error(message('SDI:sdi:invalidInput'));
            end
            this.newOrExistRun=val;
        end

        function set.matFileName(this,val)
            if isempty(val)
                val='';
            end

            if~ischar(val)
                error(message('SDI:sdi:invalidInput'));
            end
            this.matFileName=val;
        end

        function set.existRunID(this,val)
            if isempty(val)||(isnumeric(val)&&isscalar(val)&&...
                Simulink.sdi.isValidRunID(val))
                this.existRunID=[];
            else
                error(message('SDI:sdi:InvalidRunID'));
            end
        end
    end

    methods(Access='public')

        function this=ImportDialog(sdie)
            if~isa(sdie,'Simulink.sdi.internal.Engine')
                error(message('SDI:sdi:InvalidSDIEngine'));
            end

            this.baseWSOrMAT=true;
            this.matFileName='';
            this.newOrExistRun=true;
            this.existRunID=[];
            this.PreferredImporter='';

            this.varNames={};
            this.varValues={};
        end

    end

end

