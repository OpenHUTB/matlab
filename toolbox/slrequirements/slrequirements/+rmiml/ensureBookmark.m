function[fPath,id,isNew]=ensureBookmark(varargin)





    isNew=false;

    if~isempty(varargin)&&ischar(varargin{2})



        idString=strtrim(varargin{2});


        if~isempty(regexp(idString,'^\d+\.[\d\.]+$','once'))

            fPath=varargin{1};
            id=idString;
        elseif~isempty(regexp(idString,'^\d+\-\d+$','once'))

            range=sscanf(idString,'%d-%d',2);
            [fPath,id,isNew]=rmiml.locationToId(true,varargin{1},range');
        else
            fPath=varargin{1};
            fullText=rmiml.getText(fPath);
            pos=strfind(fullText,idString);
            if~isempty(pos)
                posString=sprintf('%d-%d',pos(1),pos(1)+length(idString)-1);
                [fPath,id,isNew]=rmiml.ensureBookmark(fPath,posString);
            else
                id=idString;
            end
        end
    else
        [fPath,id,isNew]=rmiml.locationToId(true,varargin{:});
    end
end
