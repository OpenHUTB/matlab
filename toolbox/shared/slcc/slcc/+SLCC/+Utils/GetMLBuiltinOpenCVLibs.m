
function openCVLibs=GetMLBuiltinOpenCVLibs()
    openCVLibs='';
    opencvLibNames={'calib3d','core','features2d','flann','imgproc','ml',...
    'objdetect','photo','stitching','video'};
    opencvLibNames=cellfun(@SLCC.Utils.GetMLBuiltinOpenCVLib,opencvLibNames,'UniformOutput',false);
    openCVLibs=sprintf('%s\n',opencvLibNames{:});
end

