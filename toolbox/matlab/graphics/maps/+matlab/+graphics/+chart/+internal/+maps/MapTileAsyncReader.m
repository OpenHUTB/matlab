


























classdef(ConstructOnLoad)MapTileAsyncReader<handle

    properties





        URL string=string.empty






        Filename string=string.empty








        Tempname string=string.empty






        TileQuadReference matlab.graphics.chart.internal.maps.TileQuadReference...
        =matlab.graphics.chart.internal.maps.TileQuadReference.empty





TileSetReader





        IsPrinting logical=false







        Action(1,1)string="download"
    end

    properties(Access=?matlab.graphics.chart.internal.maps.WebMercatorTileSetAsyncReader)

        TileQuadRequestManager matlab.graphics.chart.internal.maps.TileQuadRequestManager...
        =matlab.graphics.chart.internal.maps.TileQuadRequestManager.empty
    end

    properties(Dependent)




        SourceObject=[]
    end

    properties(GetAccess=public,SetAccess=private)




        AsyncReadCount=0
    end

    properties(Access=private,Dependent)

EnableDiagnostics


EnableErrorDiagnostics
    end

    properties(Access=private,Transient)





AsyncContentWriter





FileIsWrittenListener





DownloadErrorListener




        AsyncURL string=string.empty





        AsyncFilename string=string.empty





        AsyncTileQuadReference=[]





        EventIsRequestingTiles logical=false





SourceObjectListener


pSourceObject





        IsCancelled logical=false


TileSetReaderEnvironmentManager
    end

    properties(Access=private,Constant)




        MaxNumThreads=8




        MapTileSize=[256,256,3]
    end

    methods
        function reader=MapTileAsyncReader





            reader.TileSetReaderEnvironmentManager=...
            matlab.graphics.chart.internal.maps.TileSetReaderEnvironmentManager.instance();


            constructAsyncWriterAndListener(reader)
        end


        function tf=isActive(readers)





            tf=false(1,length(readers));
            for k=1:length(readers)
                reader=readers(k);
                if~isempty(reader)&&isvalid(reader)
                    writer=reader.AsyncContentWriter;
                    tf(k)=~isempty(writer)&&isvalid(writer)&&isOpen(writer);
                end
            end
        end


        function cancel(readers)




            for k=1:length(readers)
                reader=readers(k);
                reader.IsCancelled=true;
                writer=reader.AsyncContentWriter;
                if isvalid(writer)&&isOpen(writer)
                    removeRequest(reader.TileQuadRequestManager,writer.URL);
                    cancel(writer);
                end
            end
        end


        function fillTileQuads(reader)





            if~isempty(reader.URL)


                writer=reader.AsyncContentWriter;
                if isOpen(writer)
                    cancel(writer)
                    deleteAsyncWriterAndListener(reader)
                    constructAsyncWriterAndListener(reader)
                    writer=reader.AsyncContentWriter;
                end


                writer.Action=reader.Action;
                writer.URL=reader.URL;
                writer.Filename=reader.Tempname;
                numThreads=numel(reader.URL);
                writer.NumThreads=min(...
                [numThreads,reader.MaxNumThreads,writer.MaxNumThreads]);
                tileSetName=reader.TileSetReader.TileSetMetadata.TileSetName;
                writer.setLogRequestData('Basemap',tileSetName)




                reader.AsyncURL=reader.URL;
                reader.AsyncFilename=reader.Filename;
                reader.AsyncTileQuadReference=reader.TileQuadReference;
                reader.AsyncReadCount=0;

                if reader.IsPrinting














                    tileSetReader=reader.TileSetReader;
                    url=reader.AsyncURL;
                    if tileSetReader.ReaderIsOffline

                        for k=1:length(url)
                            fillTileQuadsWithMissingTile(tileSetReader,url(k))
                        end
                    else

                        try
                            writeContentToFilesAndBlock(writer)
                        catch

                            for k=1:length(url)
                                fillTileQuadsWithMissingTile(tileSetReader,url(k))
                            end
                        end
                    end

                elseif~isempty(reader.SourceObject)






                    reader.EventIsRequestingTiles=true;
                    reader.SourceObjectListener.Enabled=true;
                else






                    writeContentToFiles(writer)
                end
            end
        end

        function delete(readers)






            for k=1:length(readers)
                reader=readers(k);
                deleteAsyncWriterAndListener(reader)
                evlistener=reader.SourceObjectListener;
                if~isempty(evlistener)&&isvalid(evlistener)
                    delete(evlistener)
                end
            end
        end




        function set.SourceObject(reader,sourceObject)
            if~isequal(sourceObject,reader.SourceObject)
                delete(reader.SourceObjectListener)
                reader.SourceObjectListener=event.listener(sourceObject,'PostUpdate',...
                @(src,data)sourceObjectPostUpdateHandler(reader,src,data));
            end
            reader.pSourceObject=sourceObject;
        end

        function value=get.SourceObject(reader)
            value=reader.pSourceObject;
        end

        function set.EnableDiagnostics(reader,value)
            reader.TileSetReaderEnvironmentManager.EnableDiagnostics=value;
        end

        function tf=get.EnableDiagnostics(reader)
            if~isvalid(reader.TileSetReaderEnvironmentManager)
                reader.TileSetReaderEnvironmentManager=...
                matlab.graphics.chart.internal.maps.TileSetReaderEnvironmentManager.instance();
            end
            tf=reader.TileSetReaderEnvironmentManager.EnableDiagnostics;
        end

        function set.EnableErrorDiagnostics(reader,value)
            reader.TileSetReaderEnvironmentManager.EnableErrorDiagnostics=value;
        end

        function tf=get.EnableErrorDiagnostics(reader)
            if~isvalid(reader.TileSetReaderEnvironmentManager)
                reader.TileSetReaderEnvironmentManager=...
                matlab.graphics.chart.internal.maps.TileSetReaderEnvironmentManager.instance();
            end
            tf=reader.TileSetReaderEnvironmentManager.EnableDiagnostics;
        end
    end

    methods(Access=protected)

        function constructAsyncWriterAndListener(reader)







            writer=matlab.internal.asynchttpsave.AsyncHTTPContentFileWriter;
            writer.Options.Timeout=15;

            reader.FileIsWrittenListener=event.listener(writer,...
            'FileIsWritten',@(src,data)fileIsWrittenEventHandler(reader,src,data));

            reader.DownloadErrorListener=event.listener(writer,...
            'DownloadError',@(src,data)downloadErrorEventHandler(reader,src,data));

            reader.AsyncContentWriter=writer;
        end


        function deleteAsyncWriterAndListener(reader)






            writer=reader.AsyncContentWriter;
            deletefiles(writer)
            delete(reader.FileIsWrittenListener)
            delete(reader.DownloadErrorListener)
            delete(writer)
        end


        function sourceObjectPostUpdateHandler(reader,~,~)






            if reader.EventIsRequestingTiles
                listener=reader.SourceObjectListener;
                if isvalid(listener)&&~isempty(listener)&&listener.Enabled
                    writeContentToFiles(reader.AsyncContentWriter)
                    listener.Enabled=false;
                    reader.EventIsRequestingTiles=false;
                end
            end
        end


        function fileIsWrittenEventHandler(reader,~,evtdata)














            eventStatusData=evtdata.Status;
            urls=reader.AsyncURL;
            tileSetReader=reader.TileSetReader;
            readerIsEnabled=~reader.IsCancelled;

            for k=1:length(eventStatusData)
                status=eventStatusData(k);



                url=status.URL;
                index=contains(urls,url);
                filename=status.Filename;
                if isempty(index)||all(~index)
                    matlab.graphics.chart.internal.maps.deletefile(filename);
                else




                    cachenames=unique(reader.AsyncFilename(index));
                    cachename=char(cachenames(1));





                    copyFileAndFillQuad(reader,tileSetReader,url,...
                    filename,cachename,readerIsEnabled)
                    matlab.graphics.chart.internal.maps.deletefile(filename);
                end
            end
        end

        function copyFileAndFillQuad(reader,tileSetReader,url,...
            filename,cachename,readerIsEnabled)









            if reader.EnableDiagnostics
                fprintf('copy: %s\n',url)
            end

            try

                mapTile=readAndCopyMapTile(tileSetReader,...
                filename,cachename,tileSetReader.TileCacheIsEnabled);




                if isequal(size(mapTile),reader.MapTileSize)&&readerIsEnabled
                    reader.AsyncReadCount=reader.AsyncReadCount+1;
                    fillTileQuadsWithMapTile(tileSetReader,mapTile,url)
                end
            catch e

                if reader.EnableErrorDiagnostics
                    disp(e.identifier)
                    disp(e.message)
                end
            end
        end


        function downloadErrorEventHandler(reader,~,evtdata)













            if reader.EnableErrorDiagnostics
                disp(reader.AsyncContentWriter.ErrorID)
                disp(reader.AsyncContentWriter.ErrorMessage)
            end

            eventStatusData=evtdata.Status;
            urls=reader.AsyncURL;
            tileSetReader=reader.TileSetReader;
            readerIsEnabled=~reader.IsCancelled;



            for k=1:length(eventStatusData)
                status=eventStatusData(k);



                url=status.URL;
                index=contains(urls,url);
                if isempty(index)||all(~index)
                    filename=status.Filename;
                    matlab.graphics.chart.internal.maps.deletefile(filename);
                else


                    reader.AsyncReadCount=reader.AsyncReadCount+1;
                    if readerIsEnabled
                        if reader.EnableErrorDiagnostics
                            fprintf('downloaderror: %s\n',url)
                        end

                        try
                            fillTileQuadsWithMissingTile(tileSetReader,url)
                        catch


                        end
                    end
                end
            end
        end


        function reset(reader)




            reader.URL=string.empty;
            reader.Filename=string.empty;
            reader.Tempname=string.empty;
            reader.TileQuadReference=[];
        end
    end
end
