classdef MemMapWriter<autosar.mm.mm2rte.RTEWriter




    methods(Access='public')
        function this=MemMapWriter(memMapBuilder)
            this=this@autosar.mm.mm2rte.RTEWriter(memMapBuilder);

            rteFilesLocation=memMapBuilder.RTEGenerator.RTEFilesLocation;
            this.File_h_name=fullfile(rteFilesLocation,[this.RTEBuilder.ASWCName,'_MemMap.h']);
            this.WriterHFile=rtw.connectivity.CodeWriter.create(...
            'callCBeautifier',true,...
            'filename',this.File_h_name,...
            'append',false);
        end

        function write(this)

            this.writeFileDescription(this.WriterHFile);

            rteData=this.RTEBuilder.RTEData;
            rteDataItems=rteData.DataItems;
            swAddrMethods=rteDataItems(cellfun(@(x)isa(x,'autosar.mm.mm2rte.RTEDataItemSwAddrMethod'),rteDataItems));
            if~isempty(swAddrMethods)
                numSwAddressMethods=length(swAddrMethods);

                this.WriterHFile.wLine('#define MEMMAP_ERROR');

                this.WriterHFile.wComment('START_SEC Symbols');
                this.WriterHFile.wNewLine;

                for inx=1:numSwAddressMethods
                    swAddrMethod=swAddrMethods{inx};
                    swAddrMethodName=swAddrMethod.SwAddrMethodName;
                    if inx==1
                        defSym='#ifdef';
                        closeParen='';
                    else
                        defSym='#elif defined(';
                        closeParen=')';
                    end
                    swAddrMethodStartMacro=[this.RTEBuilder.ASWCName,'_START_SEC_',swAddrMethodName];
                    this.WriterHFile.wLine([defSym,' ',swAddrMethodStartMacro,closeParen]);
                    this.WriterHFile.wLine(['#undef ',swAddrMethodStartMacro]);
                    this.WriterHFile.wLine('#undef MEMMAP_ERROR');
                end

                this.WriterHFile.wLine('#endif');

                this.WriterHFile.wNewLine;
                this.WriterHFile.wComment('STOP_SEC symbols');

                for inx=1:numSwAddressMethods
                    swAddrMethod=swAddrMethods{inx};
                    swAddrMethodName=swAddrMethod.SwAddrMethodName;
                    if inx==1
                        defSym='#ifdef';
                        closeParen='';
                    else
                        defSym='#elif defined(';
                        closeParen=')';
                    end
                    swAddrMethodMacro=[this.RTEBuilder.ASWCName,'_STOP_SEC_',swAddrMethodName];
                    this.WriterHFile.wLine([defSym,' ',swAddrMethodMacro,closeParen]);
                    this.WriterHFile.wLine(['#undef ',swAddrMethodMacro]);
                    this.WriterHFile.wLine('#undef MEMMAP_ERROR');
                end

                this.WriterHFile.wComment('Error out if none of the expected Memory Section keywords are defined');
                this.WriterHFile.wLine('#ifdef MEMMAP_ERROR');
                [~,fileName,fileExt]=fileparts(this.File_h_name);
                this.WriterHFile.wLine('#error "%s wrong pragma command"',[fileName,fileExt]);
                this.WriterHFile.wLine('#endif');
                this.WriterHFile.wLine('#endif');
            end

            this.WriterHFile.close;
        end
    end
end


