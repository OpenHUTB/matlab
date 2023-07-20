function[RegistrationPoints,modelPoints,Style]=register_esfrChart(chart,sensitivity,RegistrationPoints,Style)




    RegistrationPoints=double(RegistrationPoints);

    if isempty(RegistrationPoints)


        [mag,~]=imgradient(imgaussfilt(chart.ImageGray,chart.sigma),'sobel');


        st=zeros(11);
        st(6,:)=1;
        st(:,6)=1;
        st=strel(st);
        eroded_mag=imerode(mag,st);



        centerRow=round(chart.ImageRow/2);
        centerCol=round(chart.ImageCol/2);
        halfRowExtent=round(chart.ImageRow/3);
        halfColExtent=round(chart.ImageCol/3);
        ROI=eroded_mag(centerRow-halfRowExtent:centerRow+halfRowExtent,...
        centerCol-halfColExtent:centerCol+halfColExtent);
        corners=images.internal.app.registration.model.harrismineigen('harris',ROI,...
        'MinQuality',1-sensitivity);
        corners.Location=corners.Location+...
        [centerCol-halfColExtent-1...
        ,centerRow-halfRowExtent-1];

        if(size(corners.Location,1)<4)
            error(message('images:esfrChart:InsufficientRegistrationPoints'));
        end

        RegistrationPoints=images.internal.testchart.identifyRegPoints(corners);
    end





    D12=norm(RegistrationPoints(1,:)-RegistrationPoints(2,:))/chart.ImageCol;
    D34=norm(RegistrationPoints(3,:)-RegistrationPoints(4,:))/chart.ImageCol;
    D14=norm(RegistrationPoints(1,:)-RegistrationPoints(4,:))/chart.ImageCol;
    D23=norm(RegistrationPoints(2,:)-RegistrationPoints(3,:))/chart.ImageCol;
    D13=norm(RegistrationPoints(1,:)-RegistrationPoints(3,:))/chart.ImageCol;
    D24=norm(RegistrationPoints(2,:)-RegistrationPoints(4,:))/chart.ImageCol;

    measShape=(abs(D12-D34)+abs(D14-D23)+abs(D13-D24))/3;
    checkShape=(measShape>0.05)||(D12<0.1)||(D34<0.1)||(D14<0.1)||(D23<0.1);

    if checkShape
        error(message('images:esfrChart:UnalignedRegistrationPoints'));
    end


    if(isempty(Style))
        Style=images.internal.testchart.detectChartStyle(chart.ImageGray,RegistrationPoints);
    end



    if(strcmp(Style,'Extended'))
        eSFRModel=load(fullfile(toolboxdir('images'),'images','+images',...
        '+internal','+testchart','esfrChartModelPointsExtended.mat'));
    elseif(strcmp(Style,'Enhanced'))
        eSFRModel=load(fullfile(toolboxdir('images'),'images','+images',...
        '+internal','+testchart','esfrChartModelPointsEnhanced.mat'));
    elseif(strcmp(Style,'WedgeEnhanced'))
        eSFRModel=load(fullfile(toolboxdir('images'),'images','+images',...
        '+internal','+testchart','esfrChartModelPointsWedgeEnhanced.mat'));
    elseif(strcmp(Style,'WedgeExtended'))
        eSFRModel=load(fullfile(toolboxdir('images'),'images','+images',...
        '+internal','+testchart','esfrChartModelPointsExtended.mat'));
    end

    modelRegPoints=177:180;
    warningState=warning;
    warning('off');

    try

        tform=fitgeotrans(double([eSFRModel.model_col(modelRegPoints),eSFRModel.model_row(modelRegPoints)]),RegistrationPoints,'projective');
        warning(warningState);
    catch
        warning(warningState);
        error(message('images:esfrChart:fitgeotransErrorWrapper'));
    end

    [X,Y]=transformPointsForward(tform,double(eSFRModel.model_col),double(eSFRModel.model_row));
    X=round(X);
    Y=round(Y);


    Y(X>chart.ImageCol)=nan;X(X>chart.ImageCol)=nan;
    X(Y>chart.ImageRow)=nan;Y(Y>chart.ImageRow)=nan;
    Y(X<0)=nan;X(X<0)=nan;
    X(Y<0)=nan;Y(Y<0)=nan;

    modelPoints=[X,Y];

end
