classdef(Hidden)TiledDiagramSnapshot<handle













































    properties(Dependent)






        Source;






        Theme;







        BackgroundColor;










        Format;
    end

    properties

        TileSize(1,2)double{mustBeNonnegative(TileSize)}=[500,500];




        Zoom(1,1)double{mustBeNonnegative(Zoom)}=100;


        Filename(1,1)string="untitled";
    end

    properties(Access=private)
Snapshot
TileFileStem
TileFileExt
    end

    methods
        function this=TiledDiagramSnapshot(varargin)
            this.Snapshot=slreportgen.utils.internal.DiagramSnapshot();
            this.Format="PNG";
            if~isempty(varargin)
                this.Source=varargin{1};
                n=numel(varargin);
                for i=2:2:n
                    this.(varargin{i})=varargin{i+1};
                end
            end
        end

        function set.Source(this,source)
            this.Snapshot.Source=source;
        end

        function source=get.Source(this)
            source=this.Snapshot.Source;
        end

        function set.Theme(this,theme)
            this.Snapshot.Theme=theme;
        end

        function theme=get.Theme(this)
            theme=this.Snapshot.Theme;
        end

        function set.BackgroundColor(this,backgroundColoring)
            this.Snapshot.BackgroundColor=backgroundColoring;
        end

        function backgroundColoring=get.BackgroundColor(this)
            backgroundColoring=this.Snapshot.backgroundColoring;
        end

        function set.Format(this,format)
            this.Snapshot.Format=format;
        end

        function format=get.Format(this)
            format=this.Snapshot.Format;
        end

        function set.Filename(this,filename)
            this.Filename=filename;
            reset(this);
        end

        function filenames=snap(this)





            switch(this.Format)
            case{"SVG","PDF","EMF","TIFF"}
                filenames=implRenderTiles(this);
            otherwise
                filenames=implSplitImage(this);
            end
        end

        function[bounds,filenames]=getSnapshotBounds(this,obj)






            tileSize=this.TileSize;

            snapshot=this.Snapshot;
            snapshot.View="Full";
            snapshot.Scaling="Zoom";
            snapshot.Zoom=this.Zoom;
            snapshot.MaxSize=[inf,inf];
            objUntiledBounds=getSnapshotBounds(snapshot,obj);

            objTopLeft=objUntiledBounds(1:2);
            objBottomRight=objUntiledBounds(1:2)+objUntiledBounds(3:4);

            objTopLeftRow=floor(objTopLeft(2)/tileSize(2))+1;
            objTopLeftCol=floor(objTopLeft(1)/tileSize(1))+1;

            objBottomRightRow=floor(objBottomRight(2)/tileSize(2))+1;
            objBottomRightCol=floor(objBottomRight(1)/tileSize(1))+1;

            nRows=objBottomRightRow-objTopLeftRow+1;
            nCols=objBottomRightCol-objTopLeftCol+1;

            bounds=cell(nRows,nCols);
            filenames=string.empty();

            rowCount=0;
            for row=objTopLeftRow:objBottomRightRow
                rowCount=rowCount+1;

                if(row==objTopLeftRow)
                    y1=objTopLeft(2)-(row-1)*tileSize(2);
                else
                    y1=0;
                end
                if(row==objBottomRightRow)
                    y2=objBottomRight(2)-(row-1)*tileSize(2);
                else
                    y2=tileSize(2);
                end

                colCount=0;
                for col=objTopLeftCol:objBottomRightCol
                    colCount=colCount+1;

                    if(col==objTopLeftCol)
                        x1=objTopLeft(1)-(col-1)*tileSize(1);
                    else
                        x1=0;
                    end
                    if(col==objBottomRightCol)
                        x2=objBottomRight(1)-(col-1)*tileSize(1);
                    else
                        x2=tileSize(1);
                    end

                    filenames(rowCount,colCount)=getTileFilename(this,row,col);
                    bounds{rowCount,colCount}=[
                    x1,...
                    y1,...
                    x2-x1,...
                    y2-y1];
                end
            end
        end
    end

    methods(Access=private)
        function reset(this)
            this.TileFileExt=[];
            this.TileFileStem=[];
        end

        function filenames=implRenderTiles(this)

            reset(this);

            snapshot=this.Snapshot;
            snapshot.View="Custom";
            snapshot.Scaling="Custom";
            snapshot.Format=this.Format;
            snapshot.Size=this.TileSize;

            sourceBounds=getSourceBounds(snapshot);
            tileViewSize=this.TileSize/(this.Zoom/100);



            bias=0.01;
            nCols=ceil(sourceBounds(3)/tileViewSize(1)-bias);
            nRows=ceil(sourceBounds(4)/tileViewSize(2)-bias);

            filenames=string.empty();
            for row=1:nRows
                for col=1:nCols
                    snapshot.ViewRect=[...
                    sourceBounds(1)+(col-1)*tileViewSize(1)...
                    ,sourceBounds(2)+(row-1)*tileViewSize(2)...
                    ,tileViewSize(1)...
                    ,tileViewSize(2)...
                    ];
                    snapshot.Filename=getTileFilename(this,row,col);

                    filenames(row,col)=snap(snapshot);
                end
            end
        end

        function filenames=implSplitImage(this)

            reset(this);

            snapshot=this.Snapshot;
            snapshot.View="Full";
            snapshot.Scaling="Zoom";
            snapshot.Zoom=this.Zoom;
            snapshot.MaxSize=[inf,inf];
            snapshot.Filename=getTileFilename(this,[],[]);
            untiledImageFile=snap(snapshot);

            [img,~,alpha]=imread(untiledImageFile);
            scopeDeleteFile=onCleanup(@()delete(untiledImageFile));

            imgDims=size(img);
            tileSize=this.TileSize;
            nCols=ceil(imgDims(2)/tileSize(1)-0.01);
            nRows=ceil(imgDims(1)/tileSize(2)-0.01);

            filenames=string.empty();
            for row=1:nRows
                for col=1:nCols
                    tileImg=uint8(255*ones(tileSize(2),tileSize(1),3));

                    rStart=ceil((row-1)*tileSize(2)+1);
                    rEnd=ceil(rStart+tileSize(2)-1);

                    cStart=ceil((col-1)*tileSize(1)+1);
                    cEnd=ceil(cStart+tileSize(1)-1);

                    if(rEnd>=imgDims(1))
                        rEnd=imgDims(1);
                    end
                    tRows=rEnd-rStart+1;

                    if(cEnd>=imgDims(2))
                        cEnd=imgDims(2);
                    end
                    tCols=cEnd-cStart+1;

                    outFile=getTileFilename(this,row,col);
                    tileImg(1:tRows,1:tCols,:)=img(rStart:rEnd,cStart:cEnd,:);

                    if~isempty(alpha)
                        tileAlpha(1:tRows,1:tCols)=alpha(rStart:rEnd,cStart:cEnd);
                        imwrite(tileImg,outFile,"Alpha",tileAlpha);
                    else
                        imwrite(tileImg,outFile);
                    end

                    filenames(row,col)=outFile;
                end
            end
        end

        function filename=getTileFilename(this,row,col)
            if isempty(this.TileFileStem)
                [fdir,fname,fext]=fileparts(this.Filename);
                if(strlength(fext)==0)
                    fext=fileExtension(this.Format);
                end
                fpath=fullfile(fdir,strcat(fname,fext));
                fpath=string(mlreportgen.utils.internal.canonicalPath(fpath));
                [fdir,fname,fext]=fileparts(fpath);

                this.TileFileStem=fullfile(fdir,fname);
                this.TileFileExt=fext;
            end

            if(~isempty(row)&&~isempty(col))
                filename=compose("%s_%i_%i%s",...
                this.TileFileStem,...
                row,...
                col,...
                this.TileFileExt);
            else
                filename=compose("%s%s",...
                this.TileFileStem,...
                this.TileFileExt);
            end
        end
    end
end