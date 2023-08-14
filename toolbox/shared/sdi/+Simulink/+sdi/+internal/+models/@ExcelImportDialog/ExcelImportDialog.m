classdef ExcelImportDialog<Simulink.sdi.internal.models.ImportDialog





    properties(Access='public')

        useExistingSheet;
    end

    methods

        function this=ExcelImportDialog(sdie)
            if~isa(sdie,'Simulink.sdi.internal.Engine')
                error(message('SDI:sdi:InvalidSDIEngine'));
            end

            this@Simulink.sdi.internal.models.ImportDialog(sdie);
            this.useExistingSheet=true;
        end
    end


    methods
        function set.useExistingSheet(this,val)
            if~islogical(val)
                error(message('SDI:sdi:invalidInput'));
            end
            this.useExistingSheet=val;
        end
    end

end