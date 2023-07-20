classdef BuildHooksImpl<handle





    methods(Static)



        function postCodeGen(modelName,buildInfo,buildDirectory)


            if~dds.internal.isInstalledAndLicensed()
                return;
            end



            [~,~,vendorKey,~]=dds.internal.simulink.Util.getCurrentMapSetting(modelName);

            codeDescriptor=coder.getCodeDescriptor(buildDirectory);

            outputFcns=codeDescriptor.getFunctionInterfaces('Output');
            [~,aperiodicIndexes,~,~]=dds.internal.coder.InputEventServiceInfo.findOutputFunctionIndex(outputFcns);
            aperiodicFunctions=outputFcns(aperiodicIndexes);
            modelUsesInputEvents=dds.internal.coder.InputEventServiceInfo.modelInputEventsForDDSServiceGen(aperiodicFunctions);

            includedHeaderFiles={};


            if modelUsesInputEvents
                mainUtilsFile='MainUtilsDataEvents.hpp';
            else
                mainUtilsFile='MainUtils.hpp';
            end
            utilsPath=fullfile(matlabroot,'toolbox','dds','src','mainUtils');
            buildInfo.addIncludeFiles(mainUtilsFile,utilsPath);
            includedHeaderFiles{end+1}=fullfile(utilsPath,mainUtilsFile);


            SimulinkMsgStatusFile='SimulinkMessageStatus.hpp';
            statusFilePath=fullfile(matlabroot,'toolbox','dds','src');
            buildInfo.addIncludeFiles(SimulinkMsgStatusFile,statusFilePath);
            includedHeaderFiles{end+1}=fullfile(statusFilePath,SimulinkMsgStatusFile);


            reg=dds.internal.vendor.DDSRegistry;
            entry=reg.getEntryFor(vendorKey);


            buildInfo.addSourceFiles(fullfile(buildDirectory,'main.cpp'));


            xmlFiles=entry.GenerateIDLAndXMLFiles(modelName,buildInfo);


            legacyFiles=buildInfo.getFiles('source',false,false,{'Legacy'});
            buildInfo.removeSourceFiles(legacyFiles);


            reportInfo=rtw.report.ReportInfo.instance(modelName);


            serviceGenInfo=dds.internal.coder.getDataForServicegen(codeDescriptor,...
            buildDirectory,buildInfo,xmlFiles);
            save(fullfile(buildDirectory,'serviceGenInfo.mat'),'serviceGenInfo');

            filesPathsGenOrAdded=entry.GenerateServices(serviceGenInfo);
            for idx=1:numel(filesPathsGenOrAdded)
                [folder,name,ext]=fileparts(filesPathsGenOrAdded{idx});
                if startsWith(ext,'.h','IgnoreCase',true)
                    buildInfo.addIncludeFiles(filesPathsGenOrAdded{idx});
                    reportInfo.addFileInfo([name,ext],'Other','header',folder);
                elseif startsWith(ext,'.c','IgnoreCase',true)
                    buildInfo.addSourceFiles(filesPathsGenOrAdded{idx});
                    reportInfo.addFileInfo([name,ext],'Other','source',folder);
                elseif startsWith(ext,'.inl','IgnoreCase',true)
                    reportInfo.addFileInfo([name,ext],'Other','header',folder);
                end
            end


            for headerFile=includedHeaderFiles
                [p,f,e]=fileparts(headerFile);
                reportInfo.addFileInfo([f,e],'Other','header',p);
            end



            if strcmp(get_param(modelName,'GenerateReport'),'on')

...
...
...
...
...
...
...
...
...
...
                reportInfo.convertCode2HTML();
                rtw.report.generate(reportInfo.ModelName);
                if strcmp(get_param(modelName,'LaunchReport'),'on')
                    reportInfo.show;
                end
            end
        end
    end
end


