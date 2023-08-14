classdef CfgWriter<autosar.mm.mm2rte.RTEWriter




    methods(Access='public')
        function this=CfgWriter(cfgBuilder)
            this=this@autosar.mm.mm2rte.RTEWriter(cfgBuilder);

            rteFilesLocation=cfgBuilder.RTEGenerator.RTEFilesLocation;
            this.File_h_name=fullfile(rteFilesLocation,'Rte_Cfg.h');
            this.WriterHFile=rtw.connectivity.CodeWriter.create(...
            'callCBeautifier',true,...
            'filename',this.File_h_name,...
            'append',false);
        end

        function write(this)

            this.writeFileDescription(this.WriterHFile);

            autosar.mm.mm2rte.RTEWriter.writeFileGuardStart(...
            this.WriterHFile,this.File_h_name);



            this.WriterHFile.wLine('#include "rtwtypes.h"');
            this.WriterHFile.wLine('#include "Std_Types.h"');

            rteData=this.RTEBuilder.RTEData;
            rteDataItems=rteData.DataItems;
            vpps=rteDataItems(cellfun(@(x)isa(x,'autosar.mm.mm2rte.RTEDataItemVariationPoint'),rteDataItems));
            if~isempty(vpps)
                this.WriterHFile.wComment('Variation points');
                this.writeVariationPoints(vpps);
            end
            autosar.mm.mm2rte.RTEWriter.writeFileGuardEnd(this.WriterHFile);
            this.WriterHFile.close;
        end
    end

    methods(Access='private')

        function writeVariationPoints(this,dataItems)
            for i=1:length(dataItems)
                dataItems{i}.write(this.WriterHFile);
            end
        end
    end
end


