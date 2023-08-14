

function dataUrl=getUserImageAsDataUrl()
    dataUrl='';

    filterDescription=message('simulink_ui:webblocks:resources:WebBlocksImageFileDescription').getString();
    filter={'*.gif;*.jpg;*.jpeg;*.jpe;*.jif;*.jfif;*.bmp;*.tiff;*.tif;*.png;*.svg',filterDescription};
    [file,path]=uigetfile(filter);
    if file

        [~,~,ext]=fileparts(file);
        switch ext
        case '.gif'
            mimeType='image/gif';
        case{'.jpg','.jpeg','.jpe','.jif','.jfif'}
            mimeType='image/jpeg';
        case '.bmp'
            mimeType='image/bmp';
        case{'.tiff','.tif'}
            mimeType='image/tiff';
        case '.png'
            mimeType='image/png';
        case '.svg'
            mimeType='image/svg+xml';
        otherwise
            error('Unsupported file extension');
        end
        prefix=['data:',mimeType,';base64,'];

        filePath=fullfile(path,file);
        fileId=fopen(filePath,'r');
        fileData=fread(fileId,'*uint8');
        fclose(fileId);
        b64Data=matlab.net.base64encode(fileData);

        dataUrl=[prefix,b64Data];
    end
end