



function i_closeModel(modelName,skipCloseFcnCallback)

    if nargin==1
        skipCloseFcnCallback=false;
    end
    try


        close_system(modelName,0,'SkipCloseFcn',skipCloseFcnCallback);
    catch
    end

end


