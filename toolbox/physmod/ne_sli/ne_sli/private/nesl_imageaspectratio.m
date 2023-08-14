function[height,width]=nesl_imageaspectratio(imageFile)









    height=0;
    width=0;

    pm_assert(exist(imageFile,'file'),...
    sprintf('Can not find image file: %s',imageFile));

    [~,~,fileExt]=fileparts(imageFile);
    try
        if strcmp(fileExt,'.svg')

            height=40;
            width=40;


            s=readstruct(imageFile,'FileType','xml');
            extract=@(x)(regexp(char(x),'^\d+\.*\d*','match'));
            if isfield(s,'heightAttribute')&&isfield(s,'widthAttribute')
                height=s.heightAttribute;
                if~isnumeric(height)
                    height=extract(height);
                    height=str2double(height{1});
                end
                width=s.widthAttribute;
                if~isnumeric(width)
                    width=extract(width);
                    width=str2double(width{1});
                end
            elseif isfield(s,'viewBoxAttribute')
                viewBox=cellfun(@str2double,strsplit(...
                char(s.viewBoxAttribute)));
                if numel(viewBox)==4
                    height=viewBox(4);
                    width=viewBox(3);
                end
            end
        else
            imageInfo=imfinfo(imageFile);
            height=imageInfo.Height;
            width=imageInfo.Width;
        end
    catch



        pm_error('physmod:common:gl:sli:core_block:InvalidIconFile',imageFile);
    end

end