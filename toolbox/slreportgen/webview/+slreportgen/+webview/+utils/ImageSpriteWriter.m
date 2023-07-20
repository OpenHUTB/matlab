classdef ImageSpriteWriter<handle


































    properties(Dependent)
        Width;
        Height;
    end

    properties(Access=private)
        ImgFile string=string.empty()
        ImgURL string=string.empty()

        CSSFile string=string.empty()
        CSSList struct

AddedSpriteMap
        SpriteCount uint64
ImgSprite
AlphaSprite
        SpriteSize double=[16,16,3];

        IsOpened logical=false;
    end

    methods
        function this=ImageSpriteWriter(varargin)
            p=inputParser();
            addParameter(p,"Width",16);
            addParameter(p,"Height",16);
            parse(p,varargin{:});
            opts=p.Results;

            this.Width=opts.Width;
            this.Height=opts.Height;
        end

        function delete(this)
            if isOpen(this)
                close(this);
            end
        end

        function width=get.Width(this)
            width=this.SpriteSize(1);
        end
        function set.Width(this,width)
            assert(~isOpen(this),...
            message("slreportgen_webview:image_sprite_writer:UnableToSetWidth"));
            this.SpriteSize(1)=width;
        end

        function height=get.Height(this)
            height=this.SpriteSize(2);
        end
        function set.Height(this,height)
            assert(~isOpen(this),...
            message("slreportgen_webview:image_sprite_writer:UnableToSetHeight"));
            this.SpriteSize(2)=height;
        end

        function open(this,imgFile,cssFile)






            assert(~isOpen(this),...
            message("slreportgen_webview:image_sprite_writer:AlreadyOpened"));

            this.ImgFile=mlreportgen.utils.findFile(imgFile,...
            "FileMustExist",false);
            this.CSSFile=mlreportgen.utils.findFile(cssFile,...
            "FileMustExist",false);

            this.SpriteCount=0;
            this.AddedSpriteMap=containers.Map();
            this.ImgSprite=zeros([this.Height,this.Width*0,3]);
            this.AlphaSprite=255*ones([this.Height,this.Width*0],"uint8");

            this.CSSList=struct(...
            "className",{},...
            "offset",{});

            this.ImgURL=relative_path(imgFile,cssFile);
            if isempty(this.ImgURL)
                error(message("slreportgen_webview:image_sprite_writer:InvalidCSSFile"));
            end

            this.IsOpened=true;
        end

        function add(this,className,imgFilePath)





            if~isOpen(this)
                error(message("slreportgen_webview:image_sprite_writer:NotOpened"));
            end
            if startsWith(className,".")
                error(message("slreportgen_webview:image_sprite_writer:InvalidClassName"));
            end

            imgFilePath=string(imgFilePath);
            if isKey(this.AddedSpriteMap,className)
                addedImgFiles=this.AddedSpriteMap(className);
                if any(strcmp(addedImgFiles,imgFilePath))

                    return;
                else


                    if strcmp(mlreportgen.utils.internal.md5sum(addedImgFiles(1)),...
                        mlreportgen.utils.internal.md5sum(imgFilePath))
                        this.AddedSpriteMap(className)=[addedImgFiles,imgFilePath];

                        return;
                    else
                        error(message("slreportgen_webview:image_sprite_writer:ClassAlreadyExists",...
                        className,addedImgFiles(1),imgFilePath));
                    end
                end
            else
                this.AddedSpriteMap(className)=imgFilePath;
            end


            if~strcmp("\",filesep())
                imgFilePath=strrep(imgFilePath,"\",filesep());
            end
            if~strcmp("/",filesep())
                imgFilePath=strrep(imgFilePath,"/",filesep());
            end
            [imgData,mapData,alphaData]=imread(imgFilePath);
            if~isempty(mapData)

                imgData=ind2rgb(imgData,mapData);
            end
            if~isa(imgData,"double")
                imgData=im2double(imgData);
            end


            if any(size(imgData)~=this.SpriteSize)
                imgData=resizeImage(this,imgData);
                if~isempty(alphaData)
                    alphaData=resizeAlpha(this,alphaData);
                end
            end


            this.SpriteCount=this.SpriteCount+1;
            this.ImgSprite=[this.ImgSprite,imgData];


            if~isempty(alphaData)
                this.AlphaSprite=[this.AlphaSprite,alphaData];
            else
                this.AlphaSprite=[this.AlphaSprite,255*ones([this.Height,this.Width],"uint8")];
            end


            offset=(this.SpriteCount-1)*this.Width;
            this.CSSList(end+1)=struct(...
            "className",className,...
            "offset",offset);
        end

        function close(this)





            if isempty(this.ImgSprite)

                return
            end


            imgFile=this.ImgFile;
            imgFolder=fileparts(imgFile);
            if~isfolder(imgFolder)
                mkdir(imgFolder);
            end

            imwrite(this.ImgSprite,this.ImgFile,"png","Alpha",this.AlphaSprite);


            cssFile=this.CSSFile;
            cssFolder=fileparts(cssFile);
            if~isfolder(cssFolder)
                mkdir(cssFolder);
            end

            try
                fid=fopen(cssFile,"w","n","UTF-8");

                for i=1:this.SpriteCount-1
                    fprintf(fid,".%s,\n",this.CSSList(i).className);
                end
                fprintf(fid,...
                ".%s { background-image: url('%s'); width: %dpx; height: %dpx; }\n\n",...
                this.CSSList(end).className,...
                this.ImgURL,...
                this.Width,...
                this.Height);

                for i=1:this.SpriteCount
                    fprintf(fid,...
                    ".%s { background-position: -%dpx; }\n",...
                    this.CSSList(i).className,...
                    this.CSSList(i).offset);
                end
            catch ME
                this.IsOpened=false;
                fclose(fid);
                rethrow(ME)
            end
            this.IsOpened=false;
            fclose(fid);
        end

        function tf=isOpen(this)



            tf=this.IsOpened;
        end
    end

    methods(Access=private)
        function out=resizeImage(this,in)

            if islogical(in)
                out=false(this.SpriteSize);
            else
                out=zeros(this.SpriteSize,'like',in);
            end


            in=double(in);


            temp=zeros(this.SpriteSize(1),size(in,2),3);


            for k=1:3
                temp(:,:,k)=resize_columns(in(:,:,k),this.SpriteSize(1));
            end



            if islogical(out)
                for k=1:3

                    out(:,:,k)=resize_columns(temp(:,:,k)',this.SpriteSize(2))'>=0.5;
                end
            else
                for k=1:3
                    out(:,:,k)=resize_columns(temp(:,:,k)',this.SpriteSize(2))';
                end
            end
        end

        function out=resizeAlpha(this,in)

            if islogical(in)
                out=false(this.SpriteSize(1:2));
            else
                out=zeros(this.SpriteSize(1:2),'like',in);
            end


            in=double(in);


            temp=zeros(this.SpriteSize(1),size(in,2));


            temp(:,:)=resize_columns(in(:,:),this.SpriteSize(1));



            if islogical(out)

                out(:,:)=resize_columns(temp(:,:)',this.SpriteSize(2))'>=0.5;
            else
                out(:,:)=resize_columns(temp(:,:)',this.SpriteSize(2))';
            end
        end
    end
end

function out=resize_columns(in,Mout)






    scale=Mout/size(in,1);


    if(scale<1)
        filter_length=11;
        b=design_filter(11,scale)';





        pad_length=floor(filter_length/2);
        in=[in(ones(pad_length,1),:);in;in(end*ones(pad_length,1),:)];


        in=conv2(in,b,'valid');
    end


    yi=linspace(1,size(in,1),Mout)';
    out=interp1(in,yi);
end

function b=design_filter(N,Wn)



    odd=rem(N,2);
    vec=1:floor(N/2);
    vec2=pi*(vec-(1-odd)/2);

    wind=.54-.46*cos(2*pi*(vec-1)/(N-1));
    b=[fliplr(sin(Wn*vec2)./vec2).*wind,Wn];
    b=b([vec,floor(N/2)+(1:odd),fliplr(vec)]);
    b=b/abs(polyval(b,1));
end

function relpath=relative_path(filePath,basePath)


    fsep=filesep();
    pathParts=strsplit(filePath,fsep);
    baseParts=strsplit(basePath,fsep);

    minParts=min(numel(pathParts),numel(baseParts));
    idx=1;
    while(idx<=minParts)&&strcmp(pathParts(idx),baseParts(idx))
        idx=idx+1;
    end

    if(idx==1)
        relpath=string.empty();
    else
        pathParts=pathParts(idx:end);
        baseParts=baseParts(idx:end);

        relpath=strjoin(pathParts,fsep);

        n=numel(baseParts)-1;
        if n>0
            relpath=compose("%s%s",...
            repmat(['..',fsep],[1,n]),...
            relpath);
        end
    end
end
