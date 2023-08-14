classdef Publish<handle




    properties(Access=protected)

        ImagesFoldername="_PublishedImages"
        ImageFilename="Slice_";
        Screenshot3DFilename="3DScreenshot"

    end

    events
ErrorThrown
    end

    methods


        function publishImages(self,data,labelData,labelColormap,labelAlphamap,path,rangeStart,rangeEnd,screenshot3D,sliceDir)

            try
                dataName=strtok(data.DataName,'.');
                foldername=strcat(dataName,self.ImagesFoldername);
                foldername=medical.internal.app.labeler.utils.getUniqueFolderName(path,foldername);
                folderpath=fullfile(path,foldername);
                mkdir(folderpath)

            catch
                folderpath=path;
            end

            [img,pixelSize]=data.getSlice(1,sliceDir);

            hFig=figure('Visible','off');
            c=onCleanup(@()delete(hFig));

            hIM=image(img);
            hIM.Parent.DataAspectRatio=[1/pixelSize(2),1/pixelSize(1),1];
            drawnow;

            for idx=rangeStart:rangeEnd

                try

                    imgFilename=strcat(self.ImageFilename,num2str(idx),'.png');
                    imgFilename=fullfile(folderpath,imgFilename);


                    slice=data.getSlice(idx,sliceDir);
                    label=labelData.getSlice(idx,sliceDir);
                    img=medical.internal.app.labeler.utils.getOverlayImage(slice,label,labelColormap,labelAlphamap,data.DataDisplayLimits);


                    hIM.CData=img;
                    frame=getframe(hIM.Parent);
                    img=frame.cdata;


                    imwrite(img,imgFilename);

                catch ME
                    evt=medical.internal.app.labeler.events.ErrorEventData(ME.message);
                    self.notify('ErrorThrown',evt);
                end


            end

            if~isempty(screenshot3D)

                try
                    imgFilename=strcat(self.Screenshot3DFilename,'.png');
                    imgFilename=fullfile(folderpath,imgFilename);

                    imwrite(screenshot3D,imgFilename);

                catch ME

                    evt=medical.internal.app.labeler.events.ErrorEventData(ME.message);
                    self.notify('ErrorThrown',evt);

                end

            end

        end


        function publishPDF(self,data,labelData,labelColormap,labelAlphamap,filename,rangeStart,rangeEnd,screenshot3D,sliceDir)

            tempFolder='';

            try


                rpt=mlreportgen.report.Report(filename,'pdf');
                open(rpt);



                tempFolder=tempname(tempdir);
                mkdir(tempFolder);

                imgTitle=strcat("Slice ");

                if isa(data,'medical.internal.app.labeler.model.data.Volume')&&~data.IsOblique
                    imgTitle=strcat("Slice (",string(sliceDir),") ");
                end

                [img,pixelSize]=data.getSlice(1,sliceDir);

                hFig=figure('Visible','off');
                c=onCleanup(@()delete(hFig));

                hIM=image(img);
                hIM.Parent.DataAspectRatio=[1/pixelSize(2),1/pixelSize(1),1];
                drawnow;

                for idx=rangeStart:rangeEnd

                    imgFilename=strcat(self.ImageFilename,num2str(idx),'.png');
                    imgFilename=fullfile(tempFolder,imgFilename);


                    slice=data.getSlice(idx,sliceDir);
                    label=labelData.getSlice(idx,sliceDir);
                    img=medical.internal.app.labeler.utils.getOverlayImage(slice,label,labelColormap,labelAlphamap,data.DataDisplayLimits);


                    hIM.CData=img;
                    frame=getframe(hIM.Parent);
                    img=frame.cdata;


                    imwrite(img,imgFilename);


                    title=strcat(imgTitle,num2str(idx));
                    headingObj=mlreportgen.dom.Heading1(title);
                    imgObj=mlreportgen.dom.Image(imgFilename);


                    rpt.add(headingObj);
                    rpt.add(imgObj);

                end

                if~isempty(screenshot3D)

                    imgFilename=strcat(self.Screenshot3DFilename,'.png');
                    imgFilename=fullfile(tempFolder,imgFilename);
                    imwrite(screenshot3D,imgFilename);


                    headingObj=mlreportgen.dom.Heading1('3D Volume');
                    imgObj=mlreportgen.dom.Image(imgFilename);


                    rpt.add(headingObj);
                    rpt.add(imgObj);

                end

            catch ME


                if isvalid(rpt)
                    close(rpt);
                end


                if isfolder(tempFolder)
                    rmdir(tempFolder,'s');
                end

                evt=medical.internal.app.labeler.events.ErrorEventData(ME.message);
                self.notify('ErrorThrown',evt);
                return

            end


            if isvalid(rpt)
                close(rpt);
            end


            if isfolder(tempFolder)
                rmdir(tempFolder,'s');
            end

        end

    end

end