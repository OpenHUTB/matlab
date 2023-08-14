classdef PbCfgWriter<autosar.mm.mm2rte.RTEWriter




    properties(Constant,Access='public')
        RTETypeFileNameH='Rte_PBcfg.h';
        RTETypeFileNameC='Rte_PBcfg.c';
    end

    methods(Access='public')
        function this=PbCfgWriter(cfgBuilder)
            this=this@autosar.mm.mm2rte.RTEWriter(cfgBuilder);

            rteFilesLocation=cfgBuilder.RTEGenerator.RTEFilesLocation;

            this.File_h_name=fullfile(rteFilesLocation,autosar.mm.mm2rte.PbCfgWriter.RTETypeFileNameH);
            this.WriterHFile=rtw.connectivity.CodeWriter.create(...
            'callCBeautifier',true,...
            'filename',this.File_h_name,...
            'append',false);

            this.File_c_name=fullfile(rteFilesLocation,autosar.mm.mm2rte.PbCfgWriter.RTETypeFileNameC);
            this.WriterCFile=rtw.connectivity.CodeWriter.create(...
            'callCBeautifier',true,...
            'filename',this.File_c_name,...
            'append',false);
        end

        function write(this)
            this.writeHFile();
            this.writeCFile();
        end

        function fileNames=getWrittenFiles(this)
            fileNames=getWrittenFiles@autosar.mm.mm2rte.RTEWriter(this);
            fileNames{end+1}=this.File_c_name;
        end
    end

    methods(Access='private')

        function writeCFile(this)
            this.writeFileDescription(this.WriterCFile);

            autosar.mm.mm2rte.RTEWriter.writeFileGuardStart(...
            this.WriterCFile,this.File_c_name);

            this.WriterCFile.wLine(['#include "',this.RTETypeFileNameH,'"']);

            rteData=this.RTEBuilder.RTEData;
            rteDataItems=rteData.DataItems;
            vpps=rteDataItems(cellfun(@(x)isa(x,'autosar.mm.mm2rte.RTEDataItemVariationPoint'),rteDataItems));
            if~isempty(vpps)
                this.WriterCFile.wComment('PostBuild Variation Points');
                this.writeVariationPointDefinitions(vpps);
            end
            autosar.mm.mm2rte.RTEWriter.writeFileGuardEnd(this.WriterCFile);
            this.WriterCFile.close;
        end

        function writeHFile(this)
            this.writeFileDescription(this.WriterHFile);

            autosar.mm.mm2rte.RTEWriter.writeFileGuardStart(...
            this.WriterHFile,this.File_h_name);



            this.WriterHFile.wLine('#include "rtwtypes.h"');
            this.WriterHFile.wLine('#include "Std_Types.h"');

            rteData=this.RTEBuilder.RTEData;
            rteDataItems=rteData.DataItems;
            vpps=rteDataItems(cellfun(@(x)isa(x,'autosar.mm.mm2rte.RTEDataItemVariationPoint'),rteDataItems));
            if~isempty(vpps)
                this.WriterHFile.wComment('PostBuild Variation Points');
                this.WriterHFile.wComment('Note: Based on the AUTOSAR standard, the variables should be declared as static const');
                this.writeVariationPointDeclarations(vpps);
            end
            autosar.mm.mm2rte.RTEWriter.writeFileGuardEnd(this.WriterHFile);
            this.WriterHFile.close;
        end

        function writeVariationPointDeclarations(this,dataItems)
            for i=1:length(dataItems)
                dataItems{i}.write(this.WriterHFile);
            end
        end

        function writeVariationPointDefinitions(this,dataItems)
            for i=1:length(dataItems)
                dataItems{i}.writeValue(this.WriterCFile);
            end
        end
    end
end


