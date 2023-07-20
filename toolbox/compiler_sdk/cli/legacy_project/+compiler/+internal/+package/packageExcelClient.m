function packageExcelClient(prjStruct,buildOutput)

    options=compiler.package.ExcelClientForProductionServerOptions(buildOutput);


    options.OutputDir=fullfile(prjStruct.param_output,"client");
    options.MaxResponseSize=str2double(prjStruct.param_max_size);
    options.ServerTimeOut=str2double(prjStruct.param_time_out);

    options.ServerURL=prjStruct.param_mads_server_configuration;


    options.InstallerName=prjStruct.param_appname+"ClientInstl";

    options.SSLCertificate=prjStruct.param_certificate_file;
    options.Version=prjStruct.param_version;

    if prjStruct.param_icon.strlength>0

        options.InstallerIcon=prjStruct.param_icons.file(1);
    end
    filesOnlyFolder=prjStruct.param_files_only;


    if~exist(filesOnlyFolder,'dir')
        mkdir(filesOnlyFolder);
    end

    serverFilesOnlyFolder=fullfile(filesOnlyFolder,"server");
    compiler.internal.package.writeFilesOnlyFolder({buildOutput.Options.ServerArchive},...
    fullfile(prjStruct.param_intermediate,"server"),...
    serverFilesOnlyFolder);

    clientFilesOnlyFolder=fullfile(filesOnlyFolder,"client");
    compiler.internal.package.writeFilesOnlyFolder(buildOutput.Files,...
    fullfile(prjStruct.param_intermediate,"client"),...
    clientFilesOnlyFolder);



    serverDLL=fullfile(matlabroot,'toolbox','matlabxl',...
    'bin','win64','v4.0','ServerConfig.dll');
    [success,~,msgID]=copyfile(serverDLL,fullfile(clientFilesOnlyFolder));
    if~success
        error(msgID);
    end


    compiler.package.excelClientForProductionServer(buildOutput,...
    'Options',options);



    serverRedisFolder=fullfile(prjStruct.param_output,"server");
    if exist(serverRedisFolder,'dir')~=7
        mkdir(serverRedisFolder);
    end
    zip(fullfile(serverRedisFolder,prjStruct.param_appname+"ServerArchive.zip"),fullfile(serverFilesOnlyFolder,"*"));

end