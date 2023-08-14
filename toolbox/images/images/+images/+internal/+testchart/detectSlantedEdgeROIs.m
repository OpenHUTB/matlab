function[refinedPoints,SlantedEdgeROIs]=detectSlantedEdgeROIs(chart,RefinePoints)




    if(~RefinePoints)
        X=chart.modelPoints(:,1);
        Y=chart.modelPoints(:,2);
        refinedPoints=chart.modelPoints;
    else
        [mag,~]=imgradient(imgaussfilt(chart.ImageGray,chart.sigma/3),'sobel');
        X=chart.modelPoints(:,1);
        Y=chart.modelPoints(:,2);
        slanted_sq_pts=[X(5:64),Y(5:64)];


        point_search_sz=round(abs(X(34)-X(33))/6);
        for i=1:size(slanted_sq_pts,1)

            if(i+4==14)||(i+4==56)
                continue;
            elseif(strcmp(chart.Style,'Enhanced')&&((i+4==6)||(i+4==21)||(i+4==47)||(i+4==64)))
                continue;
            else

                isValidROI=~isnan(slanted_sq_pts(i,1))&&~isnan(slanted_sq_pts(i,2))&&...
                (slanted_sq_pts(i,1)-point_search_sz>0)&&(slanted_sq_pts(i,2)-point_search_sz>0)&&...
                (slanted_sq_pts(i,1)+point_search_sz<chart.ImageCol)&&(slanted_sq_pts(i,2)+point_search_sz<chart.ImageRow);
                if(isValidROI)
                    ROI=mag(slanted_sq_pts(i,2)-point_search_sz:slanted_sq_pts(i,2)+point_search_sz,...
                    slanted_sq_pts(i,1)-point_search_sz:slanted_sq_pts(i,1)+point_search_sz);
                    corners_temp=images.internal.app.registration.model.harrismineigen('harris',...
                    ROI,'MinQuality',0.01);
                    [~,idx]=max(corners_temp.Metric);
                    corners.Location=corners_temp.Location(idx,:);

                    if(numel(corners.Location)==2)
                        X(i+4)=round(corners.Location(1)+slanted_sq_pts(i,1)-point_search_sz-1);
                        Y(i+4)=round(corners.Location(2)+slanted_sq_pts(i,2)-point_search_sz-1);
                    end
                end
            end
        end

        refinedPoints=[X,Y];
    end


    sl_edgeROI_height=round(abs((X(34)-X(33)))*chart.sl_edgeROI_height_ratio);
    sl_edgeROI_width=round(abs((X(34)-X(33)))*chart.sl_edgeROI_width_ratio);



    sl_edge_box=zeros(4*chart.numSquares,4);
    for i=1:chart.numSquares
        first=4*(i-1)+1;
        last=first+3;
        sl_edge_box(first:last,:)=images.internal.testchart.find_sl_edgeROI_boxes(chart.ImageGray,...
        [X(first+4:last+4),Y(first+4:last+4)],...
        [sl_edgeROI_height,sl_edgeROI_width]);
    end

    SlantedEdgeROIs=repmat(struct('ROI',zeros(1,4),'ROIIntensity',zeros(sl_edgeROI_height,sl_edgeROI_width,size(chart.Image,3))),4*chart.numSquares,1);

    if(strcmp(chart.Style,'Enhanced'))
        ignoreROIs=[1,19,41,59];
    elseif(strcmp(chart.Style,'WedgeEnhanced'))
        ignoreROIs=[1,2,4,18,19,20,41,42,44,58,59,60];
    else
        ignoreROIs=[];
    end

    for i=1:size(sl_edge_box,1)
        if(any(ignoreROIs==i))
            SlantedEdgeROIs(i).ROI=[nan,nan,nan,nan];
            SlantedEdgeROIs(i).ROIIntensity=[];
        else
            SlantedEdgeROIs(i).ROI=sl_edge_box(i,:);
            if(~isnan(sl_edge_box(i,:)))
                SlantedEdgeROIs(i).ROIIntensity=chart.Image(sl_edge_box(i,2):sl_edge_box(i,2)+sl_edge_box(i,4),sl_edge_box(i,1):sl_edge_box(i,1)+sl_edge_box(i,3),:);
            else
                SlantedEdgeROIs(i).ROIIntensity=[];
            end
        end
    end


end
