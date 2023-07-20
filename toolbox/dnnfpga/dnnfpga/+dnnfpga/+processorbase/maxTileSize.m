


function[inputTileImageSize,outputTileImageSize,inputMemSizeLimit,inputTileW,outputTileW]=maxTileSize(inputMemDepthLimit,resultMemDepthLimit,threadNumLimit,...
    inputFeatureNum,outputFeatureNum,opSize)




    inputMemSizeLimit=prod(inputMemDepthLimit)*threadNumLimit;
    resultMemSizeLimit=prod(resultMemDepthLimit)*threadNumLimit;



    outputFeatureDepth=ceil(outputFeatureNum/threadNumLimit)*threadNumLimit;
    inputFeatureDepth=ceil(inputFeatureNum/threadNumLimit)*threadNumLimit;



    inputTileW=floor(sqrt(inputMemSizeLimit/inputFeatureDepth));
    outputTileW=floor(sqrt(resultMemSizeLimit/outputFeatureDepth));





    inputTileImageSize=[inputTileW,inputTileW].*opSize(1:2)';
    outputTileImageSize=[outputTileW,outputTileW].*opSize(1:2)';

end

