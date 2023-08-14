function generateImageRegistrationCode(alignmentData)





    codeGenerator=iptui.internal.CodeGenerator();

    addFunctionDeclaration(codeGenerator,alignmentData)
    codeGenerator.addReturn()
    codeGenerator.addHeader('registrationEstimator')

    if any(contains(alignmentData.alignmentType,{'SURF','FAST','BRISK','Harris','MinEigen','MSER','KAZE','ORB'}))
        codeGenerator.addComment('Feature-based techniques require license to Computer Vision Toolbox');
        codeGenerator.addLine('checkLicense()');
    end

    if alignmentData.isFixedNormalized
        addNormalizeCode(codeGenerator,'FIXED')
    end

    if alignmentData.isMovingNormalized
        addNormalizeCode(codeGenerator,'MOVING')
    end

    if alignmentData.isFixedRGB||alignmentData.isMovingRGB
        codeGenerator.addComment('Convert RGB images to grayscale');
    end

    if alignmentData.isFixedRGB
        codeGenerator.addLine('FIXED = im2gray(FIXED);');
    end

    if alignmentData.isMovingRGB
        codeGenerator.addLine('MOVINGRGB = MOVING;');
        codeGenerator.addLine('MOVING = im2gray(MOVING);');
    end

    if~strcmp(alignmentData.alignmentType,'Nonrigid')

        if~alignmentData.userLoadedFixedRefObj||~alignmentData.userLoadedMovingRefObj
            codeGenerator.addComment('Default spatial referencing objects');
        else
            codeGenerator.addComment('User-specified spatial referencing objects');
        end

        if~alignmentData.userLoadedFixedRefObj
            codeGenerator.addLine('fixedRefObj = imref2d(size(FIXED));');
        else
            codeGenerator.addLine(sprintf('fixedRefObj = imref2d([%d %d],[%f %f],[%f %f]);',...
            alignmentData.fixedReferencingObject.ImageSize(1),...
            alignmentData.fixedReferencingObject.ImageSize(2),...
            alignmentData.fixedReferencingObject.XWorldLimits,...
            alignmentData.fixedReferencingObject.YWorldLimits));
        end

        if~alignmentData.userLoadedMovingRefObj
            codeGenerator.addLine('movingRefObj = imref2d(size(MOVING));');
        else
            codeGenerator.addLine(sprintf('movingRefObj = imref2d([%d %d],[%f %f],[%f %f]);',...
            alignmentData.movingReferencingObject.ImageSize(1),...
            alignmentData.movingReferencingObject.ImageSize(2),...
            alignmentData.movingReferencingObject.XWorldLimits,...
            alignmentData.movingReferencingObject.YWorldLimits));
        end
    end


    if alignmentData.userLoadedTransform
        codeGenerator.addComment('Initial transformation');
        if alignmentData.isMovingRGB
            codeGenerator.addLine(sprintf('[MOVINGRGB, movingRefObj] = imwarp(MOVINGRGB, movingRefObj, initTform, ''SmoothEdges'', true);'));
            codeGenerator.addLine('MOVING = im2gray(MOVINGRGB);');
        else
            codeGenerator.addLine(sprintf('[MOVING, movingRefObj] = imwarp(MOVING, movingRefObj, initTform, ''SmoothEdges'', true);'));
        end
    end

    switch alignmentData.alignmentType
    case{'Monomodal','Multimodal'}
        addIntensityBasedCode(codeGenerator,alignmentData);
    case 'Phase Correlation'
        addCorrelationCode(codeGenerator,alignmentData);
    case{'SURF','FAST','BRISK','Harris','MinEigen','MSER','KAZE','ORB'}
        addFeatureBasedCode(codeGenerator,alignmentData);
    case 'Nonrigid'
        addNonrigidCode(codeGenerator,alignmentData,true);
    end


    if~strcmp(alignmentData.alignmentType,'Nonrigid')
        codeGenerator.addComment('Store spatial referencing object');
        codeGenerator.addLine('MOVINGREG.SpatialRefObj = fixedRefObj;');
    end

    codeGenerator.addReturn();
    codeGenerator.addLine('end');
    codeGenerator.addReturn();

    if any(contains(alignmentData.alignmentType,{'SURF','FAST','BRISK','Harris','MinEigen','MSER','KAZE','ORB'}))
        codeGenerator.addLine('function checkLicense()');
        codeGenerator.addComment('Check for license to Computer Vision Toolbox');
        codeGenerator.addLine('CVTStatus = license(''test'',''Video_and_Image_Blockset'');');
        codeGenerator.addLine('if ~CVTStatus');
        codeGenerator.addLine('    error(message(''images:imageRegistration:CVTRequired''));');
        codeGenerator.addLine('end');
        codeGenerator.addReturn();
        codeGenerator.addLine('end');
        codeGenerator.addReturn();

        if alignmentData.userLoadedTransform||alignmentData.userLoadedFixedRefObj||alignmentData.userLoadedMovingRefObj
            moveTransformationToWorldCoordinateSystemCode(codeGenerator,alignmentData);
        end
    end


    codeGenerator.addReturn();



    codeGenerator.putCodeInEditor();

end

function addFeatureBasedCode(generator,data)

    switch data.alignmentType
    case 'SURF'
        generator.addComment('Detect SURF features');
        generator.addLine(sprintf('fixedPoints = detectSURFFeatures(FIXED,''MetricThreshold'',%f,''NumOctaves'',%d,''NumScaleLevels'',%d);',data.MetricThreshold,data.NumOctaves,data.NumScaleLevels));
        generator.addLine(sprintf('movingPoints = detectSURFFeatures(MOVING,''MetricThreshold'',%f,''NumOctaves'',%d,''NumScaleLevels'',%d);',data.MetricThreshold,data.NumOctaves,data.NumScaleLevels));
    case 'FAST'
        generator.addComment('Detect corners using FAST algorithm');
        generator.addLine(sprintf('fixedPoints = detectFASTFeatures(FIXED,''MinContrast'',%f,''MinQuality'',%f);',data.MinContrast,data.MinQuality));
        generator.addLine(sprintf('movingPoints = detectFASTFeatures(MOVING,''MinContrast'',%f,''MinQuality'',%f);',data.MinContrast,data.MinQuality));
    case 'BRISK'
        generator.addComment('Detect BRISK features');
        generator.addLine(sprintf('fixedPoints = detectBRISKFeatures(FIXED,''MinContrast'',%f,''MinQuality'',%f,''NumOctaves'',%d);',data.MinContrast,data.MinQuality,data.NumOctaves));
        generator.addLine(sprintf('movingPoints = detectBRISKFeatures(MOVING,''MinContrast'',%f,''MinQuality'',%f,''NumOctaves'',%d);',data.MinContrast,data.MinQuality,data.NumOctaves));
    case 'Harris'
        generator.addComment('Detect corners using Harris-Stephens algorithm');
        generator.addLine(sprintf('fixedPoints = detectHarrisFeatures(FIXED,''FilterSize'',%d,''MinQuality'',%f);',data.FilterSize,data.MinQuality));
        generator.addLine(sprintf('movingPoints = detectHarrisFeatures(MOVING,''FilterSize'',%d,''MinQuality'',%f);',data.FilterSize,data.MinQuality));
    case 'MinEigen'
        generator.addComment('Detect corners using minimum eigenvalue algorithm');
        generator.addLine(sprintf('fixedPoints = detectMinEigenFeatures(FIXED,''FilterSize'',%d,''MinQuality'',%f);',data.FilterSize,data.MinQuality));
        generator.addLine(sprintf('movingPoints = detectMinEigenFeatures(MOVING,''FilterSize'',%d,''MinQuality'',%f);',data.FilterSize,data.MinQuality));
    case 'MSER'
        generator.addComment('Detect MSER features');
        generator.addLine(sprintf('fixedPoints = detectMSERFeatures(FIXED,''ThresholdDelta'',%f,''RegionAreaRange'',[%d %d],''MaxAreaVariation'',%f);',data.ThresholdDelta,data.RegionAreaRange(1),data.RegionAreaRange(2),data.MaxAreaVariation));
        generator.addLine(sprintf('movingPoints = detectMSERFeatures(MOVING,''ThresholdDelta'',%f,''RegionAreaRange'',[%d %d],''MaxAreaVariation'',%f);',data.ThresholdDelta,data.RegionAreaRange(1),data.RegionAreaRange(2),data.MaxAreaVariation));
    case 'KAZE'
        generator.addComment('Detect KAZE features');
        generator.addLine(sprintf('fixedPoints = detectKAZEFeatures(FIXED,''Diffusion'',''%s'',''Threshold'',%f,''NumOctaves'',%d,''NumScaleLevels'',%d);',data.Diffusion,data.Threshold,data.NumOctaves,data.NumScaleLevels));
        generator.addLine(sprintf('movingPoints = detectKAZEFeatures(MOVING,''Diffusion'',''%s'',''Threshold'',%f,''NumOctaves'',%d,''NumScaleLevels'',%d);',data.Diffusion,data.Threshold,data.NumOctaves,data.NumScaleLevels));
    case 'ORB'
        generator.addComment('Detect corners using ORB algorithm');
        generator.addLine(sprintf('fixedPoints = detectORBFeatures(FIXED,''ScaleFactor'',%f,''NumLevels'',%d);',data.ScaleFactor,data.NumLevels));
        generator.addLine(sprintf('movingPoints = detectORBFeatures(MOVING,''ScaleFactor'',%f,''NumLevels'',%d);',data.ScaleFactor,data.NumLevels));
    end

    generator.addComment('Extract features');
    if strcmp(data.alignmentType,'ORB')
        generator.addLine(sprintf('[fixedFeatures,fixedValidPoints] = extractFeatures(FIXED,fixedPoints);'));
        generator.addLine(sprintf('[movingFeatures,movingValidPoints] = extractFeatures(MOVING,movingPoints);'));
    else
        if data.Upright
            boolString='true';
        else
            boolString='false';
        end
        generator.addLine(sprintf('[fixedFeatures,fixedValidPoints] = extractFeatures(FIXED,fixedPoints,''Upright'',%s);',boolString));
        generator.addLine(sprintf('[movingFeatures,movingValidPoints] = extractFeatures(MOVING,movingPoints,''Upright'',%s);',boolString));
    end
    generator.addComment('Match features');
    generator.addLine(sprintf('indexPairs = matchFeatures(fixedFeatures,movingFeatures,''MatchThreshold'',%f,''MaxRatio'',%f);',data.MatchThreshold,data.MaxRatio));
    generator.addLine(sprintf('fixedMatchedPoints = fixedValidPoints(indexPairs(:,1));'));
    generator.addLine(sprintf('movingMatchedPoints = movingValidPoints(indexPairs(:,2));'));
    generator.addLine('MOVINGREG.FixedMatchedFeatures = fixedMatchedPoints;');
    generator.addLine('MOVINGREG.MovingMatchedFeatures = movingMatchedPoints;');
    generator.addComment('Apply transformation - Results may not be identical between runs because of the randomized nature of the algorithm');
    generator.addLine(sprintf('tform = estimateGeometricTransform2D(movingMatchedPoints,fixedMatchedPoints,''%s'');',data.Tform));
    if data.userLoadedTransform||data.userLoadedFixedRefObj||data.userLoadedMovingRefObj
        generator.addLine('tform = moveTransformationToWorldCoordinateSystem(tform,movingRefObj,fixedRefObj);');
    end
    generator.addLine('MOVINGREG.Transformation = tform;');

    if data.isMovingRGB
        generator.addLine(sprintf('MOVINGREG.RegisteredImage = imwarp(MOVINGRGB, movingRefObj, tform, ''OutputView'', fixedRefObj, ''SmoothEdges'', true);'));
    else
        generator.addLine(sprintf('MOVINGREG.RegisteredImage = imwarp(MOVING, movingRefObj, tform, ''OutputView'', fixedRefObj, ''SmoothEdges'', true);'));
    end

    if data.nonrigid.NonrigidSelected
        addNonrigidCode(generator,data,false);
    end

end

function addIntensityBasedCode(generator,data)

    if strcmp(data.alignmentType,'Monomodal')
        generator.addComment('Intensity-based registration');
        generator.addLine(sprintf('[optimizer, metric] = imregconfig(''monomodal'');'));
        generator.addLine(sprintf('optimizer.GradientMagnitudeTolerance = %0.5e;',data.GradMagTol));
        generator.addLine(sprintf('optimizer.MinimumStepLength = %0.5e;',data.MinStepLength));
        generator.addLine(sprintf('optimizer.MaximumStepLength = %0.5e;',data.MaxStepLength));
        generator.addLine(sprintf('optimizer.MaximumIterations = %d;',data.MaxIterations));
        generator.addLine(sprintf('optimizer.RelaxationFactor = %f;',data.RelaxFactor));
    else
        if data.UseAllPixels
            boolString='true';
        else
            boolString='false';
        end

        generator.addComment('Intensity-based registration');
        generator.addLine(sprintf('[optimizer, metric] = imregconfig(''multimodal'');'));
        generator.addLine(sprintf('metric.NumberOfSpatialSamples = %d;',data.NumSamples));
        generator.addLine(sprintf('metric.NumberOfHistogramBins = %d;',data.NumBins));
        generator.addLine(sprintf('metric.UseAllPixels = %s;',boolString));
        generator.addLine(sprintf('optimizer.GrowthFactor = %f;',data.GrowthFactor));
        generator.addLine(sprintf('optimizer.Epsilon = %0.5e;',data.Epsilon));
        generator.addLine(sprintf('optimizer.InitialRadius = %0.5e;',data.InitialRadius));
        generator.addLine(sprintf('optimizer.MaximumIterations = %d;',data.MaxIterations));
    end

    generator.addComment('Align centers');
    if strcmpi(data.AlignCenters,'center of mass')
        generator.addLine('[xFixed,yFixed] = meshgrid(1:size(FIXED,2),1:size(FIXED,1));');
        generator.addLine('[xMoving,yMoving] = meshgrid(1:size(MOVING,2),1:size(MOVING,1));');
        generator.addLine('sumFixedIntensity = sum(FIXED(:));');
        generator.addLine('sumMovingIntensity = sum(MOVING(:));');
        generator.addLine('fixedXCOM = (fixedRefObj.PixelExtentInWorldX .* (sum(xFixed(:).*double(FIXED(:))) ./ sumFixedIntensity)) + fixedRefObj.XWorldLimits(1);');
        generator.addLine('fixedYCOM = (fixedRefObj.PixelExtentInWorldY .* (sum(yFixed(:).*double(FIXED(:))) ./ sumFixedIntensity)) + fixedRefObj.YWorldLimits(1);');
        generator.addLine('movingXCOM = (movingRefObj.PixelExtentInWorldX .* (sum(xMoving(:).*double(MOVING(:))) ./ sumMovingIntensity)) + movingRefObj.XWorldLimits(1);');
        generator.addLine('movingYCOM = (movingRefObj.PixelExtentInWorldY .* (sum(yMoving(:).*double(MOVING(:))) ./ sumMovingIntensity)) + movingRefObj.YWorldLimits(1);');
        generator.addLine('translationX = fixedXCOM - movingXCOM;');
        generator.addLine('translationY = fixedYCOM - movingYCOM;');
    else
        generator.addLine('fixedCenterXWorld = mean(fixedRefObj.XWorldLimits);');
        generator.addLine('fixedCenterYWorld = mean(fixedRefObj.YWorldLimits);');
        generator.addLine('movingCenterXWorld = mean(movingRefObj.XWorldLimits);');
        generator.addLine('movingCenterYWorld = mean(movingRefObj.YWorldLimits);');
        generator.addLine('translationX = fixedCenterXWorld - movingCenterXWorld;');
        generator.addLine('translationY = fixedCenterYWorld - movingCenterYWorld;');
    end

    generator.addComment('Coarse alignment');
    generator.addLine('initTform = affine2d();');
    generator.addLine('initTform.T(3,1:2) = [translationX, translationY];');

    if data.ApplyBlur
        generator.addComment('Apply Gaussian blur');
        generator.addLine(sprintf('fixedInit = imgaussfilt(FIXED,%f);',2*data.BlurValue));
        generator.addLine(sprintf('movingInit = imgaussfilt(MOVING,%f);',2*data.BlurValue));
    end

    if data.Normalize
        generator.addComment('Normalize images');
        if data.ApplyBlur
            generator.addLine('movingInit = mat2gray(movingInit);');
            generator.addLine('fixedInit = mat2gray(fixedInit);');
        else
            generator.addLine('movingInit = mat2gray(MOVING);');
            generator.addLine('fixedInit = mat2gray(FIXED);');
        end
    end

    generator.addComment('Apply transformation');
    if data.ApplyBlur||data.Normalize
        generator.addLine(sprintf('tform = imregtform(movingInit,movingRefObj,fixedInit,fixedRefObj,''%s'',optimizer,metric,''PyramidLevels'',%d,''InitialTransformation'',initTform);',...
        data.Tform,data.PyramidLevels));
    else
        generator.addLine(sprintf('tform = imregtform(MOVING,movingRefObj,FIXED,fixedRefObj,''%s'',optimizer,metric,''PyramidLevels'',%d,''InitialTransformation'',initTform);',...
        data.Tform,data.PyramidLevels));
    end

    generator.addLine('MOVINGREG.Transformation = tform;');
    if data.isMovingRGB
        generator.addLine(sprintf('MOVINGREG.RegisteredImage = imwarp(MOVINGRGB, movingRefObj, tform, ''OutputView'', fixedRefObj, ''SmoothEdges'', true);'));
    else
        generator.addLine(sprintf('MOVINGREG.RegisteredImage = imwarp(MOVING, movingRefObj, tform, ''OutputView'', fixedRefObj, ''SmoothEdges'', true);'));
    end

    if data.nonrigid.NonrigidSelected
        addNonrigidCode(generator,data,false);
    end

end

function addCorrelationCode(generator,data)

    if data.Window
        boolString='true';
    else
        boolString='false';
    end

    generator.addComment('Phase correlation');
    generator.addLine(sprintf('tform = imregcorr(MOVING,movingRefObj,FIXED,fixedRefObj,''transformtype'',''%s'',''Window'',%s);',data.Tform,boolString));
    generator.addLine('MOVINGREG.Transformation = tform;');

    if data.isMovingRGB
        generator.addLine(sprintf('MOVINGREG.RegisteredImage = imwarp(MOVINGRGB, movingRefObj, tform, ''OutputView'', fixedRefObj, ''SmoothEdges'', true);'));
    else
        generator.addLine(sprintf('MOVINGREG.RegisteredImage = imwarp(MOVING, movingRefObj, tform, ''OutputView'', fixedRefObj, ''SmoothEdges'', true);'));
    end

    if data.nonrigid.NonrigidSelected
        addNonrigidCode(generator,data,false);
    end

end

function addNonrigidCode(generator,data,TF)

    generator.addComment('Nonrigid registration');
    if TF

        if data.isMovingRGB
            generator.addLine(sprintf('[MOVINGREG.DisplacementField,~] = imregdemons(MOVING,FIXED,%d,''AccumulatedFieldSmoothing'',%0.1f,''PyramidLevels'',%d);',...
            data.nonrigid.Iterations,data.nonrigid.Smoothing,data.nonrigid.PyramidLevels));
            generator.addLine(sprintf('MOVINGREG.RegisteredImage = imwarp(MOVINGRGB, MOVINGREG.DisplacementField, ''OutputView'', fixedRefObj, ''SmoothEdges'', true);'));
        else
            generator.addLine(sprintf('[MOVINGREG.DisplacementField,MOVINGREG.RegisteredImage] = imregdemons(MOVING,FIXED,%d,''AccumulatedFieldSmoothing'',%0.1f,''PyramidLevels'',%d);',...
            data.nonrigid.Iterations,data.nonrigid.Smoothing,data.nonrigid.PyramidLevels));
        end
    else

        if data.isMovingRGB
            generator.addLine(sprintf('[MOVINGREG.DisplacementField,~] = imregdemons(im2gray(MOVINGREG.RegisteredImage),FIXED,%d,''AccumulatedFieldSmoothing'',%0.1f,''PyramidLevels'',%d);',...
            data.nonrigid.Iterations,data.nonrigid.Smoothing,data.nonrigid.PyramidLevels));
            generator.addLine(sprintf('MOVINGREG.RegisteredImage = imwarp(MOVINGREG.RegisteredImage, MOVINGREG.DisplacementField, ''OutputView'', fixedRefObj, ''SmoothEdges'', true);'));
        else
            generator.addLine(sprintf('[MOVINGREG.DisplacementField,MOVINGREG.RegisteredImage] = imregdemons(MOVINGREG.RegisteredImage,FIXED,%d,''AccumulatedFieldSmoothing'',%0.1f,''PyramidLevels'',%d);',...
            data.nonrigid.Iterations,data.nonrigid.Smoothing,data.nonrigid.PyramidLevels));
        end
    end

end

function moveTransformationToWorldCoordinateSystemCode(generator,data)

    generator.addLine('function tform = moveTransformationToWorldCoordinateSystem(tform,Rmoving,Rfixed)');

    generator.addLine('Sx = Rmoving.PixelExtentInWorldX;');
    generator.addLine('Sy = Rmoving.PixelExtentInWorldY;');
    generator.addLine('Tx = Rmoving.XWorldLimits(1)-Rmoving.PixelExtentInWorldX*(Rmoving.XIntrinsicLimits(1));');
    generator.addLine('Ty = Rmoving.YWorldLimits(1)-Rmoving.PixelExtentInWorldY*(Rmoving.YIntrinsicLimits(1));');
    generator.addLine('tMovingIntrinsicToWorld = [Sx 0 0; 0 Sy 0; Tx Ty 1];');
    generator.addLine('tMovingWorldToIntrinsic = inv(tMovingIntrinsicToWorld);');

    generator.addLine('Sx = Rfixed.PixelExtentInWorldX;');
    generator.addLine('Sy = Rfixed.PixelExtentInWorldY;');
    generator.addLine('Tx = Rfixed.XWorldLimits(1)-Rfixed.PixelExtentInWorldX*(Rfixed.XIntrinsicLimits(1));');
    generator.addLine('Ty = Rfixed.YWorldLimits(1)-Rfixed.PixelExtentInWorldY*(Rfixed.YIntrinsicLimits(1));');
    generator.addLine('tFixedIntrinsicToWorld = [Sx 0 0; 0 Sy 0; Tx Ty 1];');

    generator.addLine('tMovingIntrinsicToFixedIntrinsic = tform.T;');
    generator.addLine('tComposite = tMovingWorldToIntrinsic * tMovingIntrinsicToFixedIntrinsic * tFixedIntrinsicToWorld; %#ok<MINV>');
    if strcmp(data.Tform,'projective')
        generator.addLine('tform.T = tComposite;');
    else
        generator.addLine('tform.T(1:3,1:2) = tComposite(1:3,1:2);');
    end

    generator.addLine('end')

end

function addNormalizeCode(generator,var)

    generator.addComment(sprintf('Normalize %s image',var));

    generator.addComment('Get linear indices to finite valued data')
    generator.addLine(sprintf('finiteIdx = isfinite(%s(:));',var))

    generator.addComment('Replace NaN values with 0');
    generator.addLine(sprintf('%s(isnan(%s)) = 0;',var,var));

    generator.addComment('Replace Inf values with 1');
    generator.addLine(sprintf('%s(%s==Inf) = 1;',var,var));

    generator.addComment('Replace -Inf values with 0');
    generator.addLine(sprintf('%s(%s==-Inf) = 0;',var,var));

    generator.addComment('Normalize input data to range in [0,1].')
    generator.addLine(sprintf('%smin = min(%s(:));',var,var))
    generator.addLine(sprintf('%smax = max(%s(:));',var,var))
    generator.addLine(sprintf('if isequal(%smax,%smin)',var,var))
    generator.addLine(sprintf('    %s = 0*%s;',var,var))
    generator.addLine('else')
    generator.addLine(sprintf('    %s(finiteIdx) = (%s(finiteIdx) - %smin) ./ (%smax - %smin);',var,var,var,var,var))
    generator.addLine('end')

end

function addFunctionDeclaration(generator,data)
    fcnName='registerImages';
    inputs={'MOVING','FIXED'};

    if data.userLoadedTransform
        inputs{end+1}='initTform';
    end

    outputs={'MOVINGREG'};

    h1Line=' Register grayscale images using auto-generated code from Registration Estimator app.';

    description=['Register grayscale images MOVING and FIXED using'...
    ,' auto-generated code from the Registration Estimator app. The'...
    ,' values for all registration parameters were set interactively in'...
    ,' the app and result in the registered image stored in the'...
    ,' structure array MOVINGREG.'];

    generator.addFunctionDeclaration(fcnName,inputs,outputs,h1Line);
    generator.addSyntaxHelp(fcnName,description,inputs,outputs);
end
