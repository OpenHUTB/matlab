function createVendorArtifacts(IDLFiles,buildInfo,bDir)









    if~isempty(IDLFiles)
        javaPath=fullfile((matlabroot),'sys','java','jre',...
        computer('arch'),'jre','bin','java');
        FastDDSDir=fullfile(matlabroot,'sys','FastDDS',computer('arch'));

        typeFiles={};
        for i=1:numel(IDLFiles)
            [~,~,ext]=fileparts(IDLFiles{i});
            if~strcmp(ext,'.idl')
                continue;
            end


            [status,result]=runcommand(['"',javaPath,'" -jar "'...
            ,fullfile(FastDDSDir,'share','fastddsgen','java','fastddsgen.jar'),'" -replace -ppDisable -d "'...
            ,bDir,'" "',fullfile(bDir,IDLFiles{i}),'"']);


            if status~=0
                error(message('dds:cgen:ErrorCreatingPackage',result));
            end
            [~,fileName,~]=fileparts(IDLFiles{i});
            typeFiles{end+1}=[fileName,'.h'];
            typeFiles{end+1}=[fileName,'PubSubTypes.h'];
            typeFiles{end+1}=[fileName,'.cxx'];
            typeFiles{end+1}=[fileName,'PubSubTypes.cxx'];




            slrealtime.internal.dds.eprosima.utils.customizeIDLGeneratedFiles(bDir,typeFiles);


            if isfile(fullfile(bDir,[fileName,'PubSubTypes.cpp']))...
                &&isfile(fullfile(bDir,[fileName,'.cpp']))

                buildInfo.addSourceFiles(fullfile(bDir,[fileName,'.cpp']));
                buildInfo.addSourceFiles(fullfile(bDir,[fileName,'PubSubTypes.cpp']));
            end
        end

    end
end


function[status,result]=runcommand(cmdline)
    [status,result]=system(cmdline);
end
