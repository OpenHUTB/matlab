




















































classdef AsyncHTTPContentFileWriter<handle
    properties





        URL string{mustStartWithHTTP}=string.empty








        Filename string=string.empty






        Options weboptions=weboptions






        NumThreads double=1







        PauseInSeconds double=.001







        Action(1,1)string="download"
    end

    properties(Constant)





        MaxNumThreads=maxNumCompThreads*2;
    end

    properties(Dependent)




FilesAreAvailable





ErrorID





ErrorMessage
    end

    properties(SetAccess=private)










        Data struct=struct.empty
    end

    properties(SetAccess=private,Hidden)





        UseAsyncDownloader(1,1)logical=true
    end

    properties(Constant,Access=private)




        InstallFolder=fullfile(toolboxdir('matlab'),'maps','asynchttpsave','bin',lower(computer('arch')));








        FilesAvailableTimeoutInSeconds double=60
    end

    properties(Access=private,Dependent)




DeviceLibrary





ConverterLibrary
    end

    properties(Access=private)





        DataCount double=0







        TimeCount double=0




AsyncChannel





ErrorListener






ThreadIsFinishedListener





        Params=struct(...
        'URLs','',...
        'Filenames','',...
        'NumThreads','',...
        'TimeoutInMilliseconds',5000,...
        'UserAgent','',...
        'CertificateFilename','',...
        'Action','download',...
        'LogKeyName','DataSource',...
        'LogKeyValue','other_clients');
    end

    events




FileIsWritten






DownloadError





ThreadError
    end

    methods
        function writer=AsyncHTTPContentFileWriter





        end


        function writeContentToFiles(writer)







            assert(numel(writer.URL)==numel(writer.Filename),...
            'MATLAB:graphics:maps:InternalAsyncError',...
            'Internal error: Expect number of URLs to match number of filenames.')

            if isempty(writer.URL)||isempty(writer.Filename)
                writer.Data=struct.empty;
            else

                if isempty(writer.AsyncChannel)
                    init(writer)
                end


                writer.Params.URLs=cellstr(writer.URL);
                writer.Params.Filenames=cellstr(writer.Filename);
                writer.Params.NumThreads=uint32(writer.NumThreads);
                writer.Params.Action=char(writer.Action);
                writer.Params.LoggingIsEnabled=...
                contains(feature('diagnosticSpec'),'matlab::maps::basemaps');
                if~isempty(writer.URL)&&startsWith(writer.URL(1),connector.getBaseUrl)

                    filename=connector.getCertificateLocation;
                    writer.Params.CertificateFilename=filename;
                    writer.Options.CertificateFilename=filename;
                else

                    writer.Params.CertificateFilename='';
                end

                timeoutInMilliseconds=secondsToMilliseconds(writer.Options.Timeout);
                writer.Params.TimeoutInMilliseconds=timeoutInMilliseconds;
                writer.Params.UserAgent=writer.Options.UserAgent;


                asyncChannel=writer.AsyncChannel;
                if asyncChannel.isOpen()
                    cancelAndCloseChannel(writer);
                end


                writer.ErrorListener.Enabled=false;
                writer.ThreadIsFinishedListener.Enabled=false;
                asyncChannel.ThreadError=0;
                asyncChannel.ThreadIsFinished=0;
                asyncChannel.ThreadErrorID='';
                asyncChannel.ThreadErrorMessage='';
                writer.ErrorListener.Enabled=true;
                writer.ThreadIsFinishedListener.Enabled=true;


                writer.TimeCount=0;
                writer.DataCount=0;
                writer.Data=struct.empty;


                try
                    asyncChannel.open(writer.Params);
                    writer.UseAsyncDownloader=true;
                catch


                    writeContentToFilesSynchronously(writer)
                    writer.UseAsyncDownloader=false;
                end
            end
        end


        function writeContentToFilesAndBlock(writer,varargin)












            writeContentToFiles(writer)
            if writer.UseAsyncDownloader
                waitUntilFilesAreAvailable(writer,varargin{:})
            end
            assert(writer)
        end


        function writeContentToFilesSynchronously(writer)








            urls=writer.Params.URLs;
            filenames=writer.Params.Filenames;
            data=struct('Filename','','URL','','DataIsWritten','');
            data(length(urls))=data;
            options=writer.Options;

            for k=1:length(urls)
                data(k).Filename=filenames{k};
                data(k).URL=urls{k};
                try


                    connection=matlab.internal.webservices.HTTPConnector(data(k).URL,options);
                    copyContentToFile(connection,data(k).Filename)
                    data(k).DataIsWritten='1';
                catch e
                    data(k).DataIsWritten='0';
                    writer.AsyncChannel.ThreadErrorID='MATLAB:graphics:asyncio:HTTPException';
                    writer.AsyncChannel.ThreadErrorMessage=e.message;
                    handleErrorEvent(writer)
                end
            end
            setDataAndNotifyClients(writer,data)
        end


        function waitUntilFilesAreAvailable(writer,timeoutInSeconds)






            if nargin<2
                timeoutInSeconds=writer.FilesAvailableTimeoutInSeconds;
            end

            tf=false;
            while~tf
tic
                tf=writer.FilesAreAvailable;
                numSeconds=toc;
                writer.TimeCount=writer.TimeCount+numSeconds;
                if writer.TimeCount>timeoutInSeconds
                    cancelAndCloseChannel(writer)
                    errorID='MATLAB:graphics:asyncio:TimeoutReached';
                    errorMsg='Maximum number of seconds reached waiting to finish download of data from server.';
                    e=MException(errorID,errorMsg);
                    throwAsCaller(e)
                end
            end
        end


        function delete(writer)





            cancelAndCloseChannel(writer)
            try
                deletelisteners(writer)
                close(writer)
                delete(writer.AsyncChannel)
            catch
            end
        end


        function cleanup(writer)






            cancelAndCloseChannel(writer)
            deletefiles(writer)
        end


        function deletefiles(writer)







            filenames=writer.Filename;
            for k=1:length(filenames)
                matlab.graphics.chart.internal.maps.deletefile(filenames(k));
            end
        end


        function close(writer)




            asyncChannel=writer.AsyncChannel;
            if~isempty(asyncChannel)&&asyncChannel.isOpen()
                asyncChannel.close();
            end
        end


        function cancel(writer)





            asyncChannel=writer.AsyncChannel;
            if~isempty(asyncChannel)&&asyncChannel.isOpen()
                asyncChannel.execute('CANCEL','');
            end
        end


        function cancelAndCloseChannel(writer)





            asyncChannel=writer.AsyncChannel;
            if~isempty(asyncChannel)&&asyncChannel.isOpen()
                writer.ErrorListener.Enabled=false;
                writer.ThreadIsFinishedListener.Enabled=false;
                asyncChannel.InputStream.flush()
                asyncChannel.execute('CANCEL','');
                asyncChannel.close();
            end
        end


        function tf=isOpen(writer)





            asyncChannel=writer.AsyncChannel;
            tf=~isempty(asyncChannel)&&isOpen(asyncChannel);
        end


        function assert(writer)
















            downloadError=~isempty(writer.Data)&&~all([writer.Data.DataIsWritten]);
            threadError=~isempty(writer.AsyncChannel)&&...
            (~isempty(writer.ErrorMessage)||~isempty(writer.ErrorID)...
            ||writer.AsyncChannel.ThreadError);

            if downloadError||threadError
                errorMsgSet=~isempty(writer.AsyncChannel)&&...
                ~isempty(writer.ErrorMessage)&&~isempty(writer.ErrorID);
                cleanup(writer)
                if errorMsgSet
                    e=MException(writer.ErrorID,'%s',writer.ErrorMessage);
                else
                    id='MATLAB:graphics:asyncio:HTTPException';
                    msg='Internal thread error: Download failed.';
                    e=MException(id,msg);
                end
                throwAsCaller(e)
            end
        end


        function setLogRequestData(writer,keyName,keyValue)






            writer.Params.LogKeyName=char(keyName);
            writer.Params.LogKeyValue=char(keyValue);
        end



        function set.NumThreads(writer,numThreads)

            maxNumThreads=writer.MaxNumThreads;
            try
                validateattributes(numThreads,{'numeric'},...
                {'nonempty','integer','positive','<=',maxNumThreads},...
                'graphics:asyncio','NumThreads')
            catch e
                throwAsCaller(e)
            end
            writer.NumThreads=min(numThreads,maxNumThreads);
        end

        function tf=get.FilesAreAvailable(writer)
            if~isempty(writer.AsyncChannel)
                count=writer.AsyncChannel.InputStream.DataAvailable();
                numOperations=numel(writer.URL);
                tf=(count==numOperations)||(writer.DataCount==numOperations);
                if~tf










                    t=tic;
                    while toc(t)<writer.PauseInSeconds
                    end
                    handleThreadIsFinishedEvent(writer)
                    tf=~isempty(writer.ErrorID)||writer.AsyncChannel.ThreadError;
                end
            else
                tf=false;
            end
        end

        function id=get.ErrorID(writer)
            id=writer.AsyncChannel.ThreadErrorID;
        end

        function msg=get.ErrorMessage(writer)
            msg=writer.AsyncChannel.ThreadErrorMessage;
        end

        function folder=get.DeviceLibrary(writer)
            folder=fullfile(writer.InstallFolder,'httpsavedevice');
        end

        function folder=get.ConverterLibrary(writer)
            folder=fullfile(writer.InstallFolder,'dataconverter');
        end
    end

    methods(Access=private)

        function init(writer)





            writer.AsyncChannel=matlabshared.asyncio.internal.Channel(...
            writer.DeviceLibrary,writer.ConverterLibrary);

            addlisteners(writer);
        end


        function addlisteners(writer)





            writer.ErrorListener=addlistener(writer.AsyncChannel,'ThreadError',...
            'PostSet',@(source,eventData)handleErrorEvent(writer,source,eventData));

            writer.ThreadIsFinishedListener=addlistener(writer.AsyncChannel,'ThreadIsFinished',...
            'PostSet',@(source,eventData)handleThreadIsFinishedEvent(writer,source,eventData));
        end


        function deletelisteners(writer)





            delete(writer.ErrorListener)
            delete(writer.ThreadIsFinishedListener)
        end


        function handleErrorEvent(writer,~,~)





            notify(writer,'ThreadError')
        end


        function handleThreadIsFinishedEvent(writer,~,~)





            asyncChannel=writer.AsyncChannel;
            if asyncChannel.isOpen()
                dataCount=asyncChannel.InputStream.DataAvailable();
                if dataCount>0
                    data=asyncChannel.InputStream.read();
                    if isempty(data)
                        asyncChannel.close();
                    else
                        setDataAndNotifyClients(writer,data);
                    end
                end
            end
        end


        function setDataAndNotifyClients(writer,data)












            dataIsWritten=string({data.DataIsWritten});
            dataIsWritten=str2double(dataIsWritten);
            for k=1:length(data)
                data(k).DataIsWritten=dataIsWritten(k);
            end





            fileIsWrittenEventData=data(logical(dataIsWritten));
            if~isempty(fileIsWrittenEventData)
                evtdata=matlab.internal.asynchttpsave.AsyncHTTPContentEventData(fileIsWrittenEventData);
                notify(writer,'FileIsWritten',evtdata)
            end

            downloadErrorEventData=data(logical(~dataIsWritten));
            if~isempty(downloadErrorEventData)
                evtdata=matlab.internal.asynchttpsave.AsyncHTTPContentEventData(downloadErrorEventData);
                notify(writer,'DownloadError',evtdata)
            end


            if isempty(writer.Data)
                writer.Data=data;
            else
                data=data(:);
                writer.Data=[writer.Data;data];
            end

            writer.DataCount=writer.DataCount+length(data);
            if numel(writer.Data)==numel(writer.Filename)
                close(writer)
            end
        end
    end
end



function milliseconds=secondsToMilliseconds(seconds)







    if~isempty(seconds)


        secondsToMilliseconds=1000;
        milliseconds=round(ceil(seconds*secondsToMilliseconds));



        microToMillisecond=1/1000;
        maxValueInMilliseconds=fix(double(intmax*microToMillisecond)-1);
        milliseconds=min(maxValueInMilliseconds,milliseconds);
    else

        milliseconds=1;
    end
end

function mustStartWithHTTP(url)





    index=startsWith(url,"http");
    if~all(index)
        error(message('MATLAB:webservices:MalformedURL',url(find(~index,1))))
    end
end
