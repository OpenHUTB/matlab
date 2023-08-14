function filename=getVerifyDataFile(this,app)







    filename=[];%#ok

    if~this.isConnected()
        this.connect();
    end

    validateattributes(app,{'char','string'},{'scalartext'});
    app=convertStringsToChars(app);

    [~,appName,~]=fileparts(app);
    fileOnTarget=strcat(this.appsDirOnTarget,"/",appName,"/verify/verify.dat");

    try


        dirOnHost=tempname;
        mkdir(dirOnHost);



        fileOnHost=fullfile(dirOnHost,"verify.dat");
        this.receiveFile(fileOnTarget,fileOnHost);

    catch ME
        this.throwError('slrealtime:target:getVerifyFileError',appName,this.TargetSettings.name,ME.message);
    end


    filename=fileOnHost;
end
