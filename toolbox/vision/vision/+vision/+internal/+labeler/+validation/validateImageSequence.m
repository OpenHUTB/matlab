function validateImageSequence(images,hasTimeStamps)






    assert(iscellstr(images)||isstring(images)||isa(images,'matlab.io.datastore.ImageDatastore'),...
    'Unexpected input');

    if isa(images,'matlab.io.datastore.ImageDatastore')
        images=images.Files;
    end


    if nargin==2&&hasTimeStamps
        pathName=fileparts(images{1});


        for n=2:numel(images)
            if~strcmp(pathName,fileparts(images{n}))
                error(message('vision:groundTruthDataSource:expectedSameDir'))
            end
        end
    end
end
