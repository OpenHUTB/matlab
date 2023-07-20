function spider_plot(P,varargin)












































































































































































































































































































    [num_data_groups,num_data_points]=size(P);


    numvarargs=length(varargin);


    if mod(numvarargs,2)==1
        error('Error: Please check name-value pair arguments');
    end


    axes_labels=cell(1,num_data_points);


    for ii=1:num_data_points

        axes_labels{ii}=sprintf('Label %i',ii);
    end


    axes_interval=3;
    axes_precision=1;
    axes_display='all';
    axes_limits=[];
    fill_option='off';
    fill_transparency=0.2;
    colors=lines(num_data_groups);
    line_style='-';
    line_width=2;
    line_transparency=1;
    marker_type='o';
    marker_size=36;
    marker_transparency=1;
    axes_font='Helvetica';
    label_font='Helvetica';
    axes_font_size=10;
    axes_font_color=[0,0,0];
    label_font_size=10;
    direction='clockwise';
    axes_direction='normal';
    axes_labels_offset=0.1;
    axes_scaling='linear';
    axes_color=[0.6,0.6,0.6];
    axes_labels_edge='k';
    axes_offset=1;
    axes_zoom=0.7;
    axes_horz_align='center';
    axes_vert_align='middle';


    if numvarargs>1

        name_arguments=varargin(1:2:end);
        value_arguments=varargin(2:2:end);


        for ii=1:length(name_arguments)

            switch lower(name_arguments{ii})
            case 'axeslabels'
                axes_labels=value_arguments{ii};
            case 'axesinterval'
                axes_interval=value_arguments{ii};
            case 'axesprecision'
                axes_precision=value_arguments{ii};
            case 'axesdisplay'
                axes_display=value_arguments{ii};
            case 'axeslimits'
                axes_limits=value_arguments{ii};
            case 'filloption'
                fill_option=value_arguments{ii};
            case 'filltransparency'
                fill_transparency=value_arguments{ii};
            case 'color'
                colors=value_arguments{ii};
            case 'linestyle'
                line_style=value_arguments{ii};
            case 'linewidth'
                line_width=value_arguments{ii};
            case 'linetransparency'
                line_transparency=value_arguments{ii};
            case 'marker'
                marker_type=value_arguments{ii};
            case 'markersize'
                marker_size=value_arguments{ii};
            case 'markertransparency'
                marker_transparency=value_arguments{ii};
            case 'axesfont'
                axes_font=value_arguments{ii};
            case 'labelfont'
                label_font=value_arguments{ii};
            case 'axesfontsize'
                axes_font_size=value_arguments{ii};
            case 'axesfontcolor'
                axes_font_color=value_arguments{ii};
            case 'labelfontsize'
                label_font_size=value_arguments{ii};
            case 'direction'
                direction=value_arguments{ii};
            case 'axesdirection'
                axes_direction=value_arguments{ii};
            case 'axeslabelsoffset'
                axes_labels_offset=value_arguments{ii};
            case 'axesscaling'
                axes_scaling=value_arguments{ii};
            case 'axescolor'
                axes_color=value_arguments{ii};
            case 'axeslabelsedge'
                axes_labels_edge=value_arguments{ii};
            case 'axesoffset'
                axes_offset=value_arguments{ii};
            case 'axeszoom'
                axes_zoom=value_arguments{ii};
            case 'axeshorzalign'
                axes_horz_align=value_arguments{ii};
            case 'axesvertalign'
                axes_vert_align=value_arguments{ii};
            otherwise
                error('Error: Please enter in a valid name-value pair.');
            end
        end

    end



    if iscell(axes_labels)

        if length(axes_labels)~=num_data_points
            error('Error: Please make sure the number of labels is the same as the number of points.');
        end
    else

        if~contains(axes_labels,'none')
            error('Error: Please enter in valid labels or "none" to remove labels.');
        end
    end


    if~isempty(axes_limits)

        if size(axes_limits,1)~=2||size(axes_limits,2)~=num_data_points
            error('Error: Please make sure the min and max axes limits match the number of data points.');
        end


        lower_limits=axes_limits(1,:);
        upper_limits=axes_limits(2,:);


        diff_limits=upper_limits-lower_limits;


        if any(diff_limits<0)
            error('Error: Please make sure max axes limits are greater than the min axes limits.');
        end


        if any(diff_limits==0)
            error('Error: Please make sure the min and max axes limits are different.');
        end
    end


    if isnumeric(axes_precision)

        if length(axes_precision)==1

            axes_precision=repmat(axes_precision,num_data_points,1);
        elseif length(axes_precision)~=num_data_points
            error('Error: Please specify the same number of axes precision as number of data points.');
        end
    else
        error('Error: Please make sure the axes precision is a numeric value.');
    end


    if floor(axes_interval)~=axes_interval||any(floor(axes_precision)~=axes_precision)
        error('Error: Please enter in an integer for the axes properties.');
    end


    if axes_interval<1||any(axes_precision<0)
        error('Error: Please enter a positive value for the axes properties.');
    end


    if~ismember(axes_display,{'all','none','one','data'})
        error('Error: Invalid axes display entry. Please enter in "all", "none", or "one" to set axes text.');
    end


    if any(~ismember(fill_option,{'off','on'}))
        error('Error: Please enter either "off" or "on" for fill option.');
    end


    if any(fill_transparency<0)||any(fill_transparency>1)
        error('Error: Please enter a transparency value between [0, 1].');
    end


    if any(line_transparency<0)||any(line_transparency>1)
        error('Error: Please enter a transparency value between [0, 1].');
    end


    if any(marker_transparency<0)||any(marker_transparency>1)
        error('Error: Please enter a transparency value between [0, 1].');
    end


    if axes_font_size<=0||label_font_size<=0
        error('Error: Please enter a font size greater than zero.');
    end


    if~ismember(direction,{'counterclockwise','clockwise'})
        error('Error: Invalid direction entry. Please enter in "counterclockwise" or "clockwise" to set direction of rotation.');
    end


    if~ismember(axes_direction,{'normal','reverse'})
        error('Error: Invalid axes direction entry. Please enter in "normal" or "reverse" to set axes direction.');
    end


    if axes_labels_offset<0
        error('Error: Please enter a positive for the axes labels offset.');
    end


    if any(~ismember(axes_scaling,{'linear','log'}))
        error('Error: Invalid axes scaling entry. Please enter in "linear" or "log" to set axes scaling.');
    end


    if floor(axes_offset)~=axes_offset||axes_offset<0||axes_offset>axes_interval
        error('Error: Invalid axes offset entry. Please enter in an integer value that is between [0, axes_interval].');
    end


    if~isnumeric(axes_zoom)||length(axes_zoom)~=1||axes_zoom<0||axes_zoom>1
        error('Error: Please enter an axes zoom value between [0, 1].');
    end


    if any(~ismember(axes_horz_align,{'center','left','right','quadrant'}))
        error('Error: Invalid axes horizontal alignment entry.');
    end


    if any(~ismember(axes_vert_align,{'middle','top','cap','bottom','baseline','quadrant'}))
        error('Error: Invalid axes vertical alignment entry.');
    end


    if iscell(axes_scaling)

        if length(axes_scaling)==1

            axes_scaling=repmat(axes_scaling,num_data_points,1);
        elseif length(axes_scaling)~=num_data_points
            error('Error: Please specify the same number of axes scaling as number of data points.');
        end
    else

        axes_scaling=repmat({axes_scaling},num_data_points,1);
    end


    if ischar(line_style)

        line_style=cellstr(line_style);


        line_style=repmat(line_style,num_data_groups,1);
    elseif iscellstr(line_style)

        if length(line_style)==1

            line_style=repmat(line_style,num_data_groups,1);
        elseif length(line_style)~=num_data_groups
            error('Error: Please specify the same number of line styles as number of data groups.');
        end
    else
        error('Error: Please make sure the line style is a char or a cell array of char.');
    end


    if isnumeric(line_width)

        if length(line_width)==1

            line_width=repmat(line_width,num_data_groups,1);
        elseif length(line_width)~=num_data_groups
            error('Error: Please specify the same number of line width as number of data groups.');
        end
    else
        error('Error: Please make sure the line width is a numeric value.');
    end


    if ischar(marker_type)

        marker_type=cellstr(marker_type);


        marker_type=repmat(marker_type,num_data_groups,1);
    elseif iscellstr(marker_type)

        if length(marker_type)==1

            marker_type=repmat(marker_type,num_data_groups,1);
        elseif length(marker_type)~=num_data_groups
            error('Error: Please specify the same number of line styles as number of data groups.');
        end
    else
        error('Error: Please make sure the line style is a char or a cell array of char.');
    end


    if isnumeric(marker_size)
        if length(marker_size)==1

            marker_size=repmat(marker_size,num_data_groups,1);
        elseif length(marker_size)~=num_data_groups
            error('Error: Please specify the same number of line width as number of data groups.');
        end
    else
        error('Error: Please make sure the line width is numeric.');
    end


    if iscell(axes_direction)

        if length(axes_direction)==1

            axes_direction=repmat(axes_direction,num_data_points,1);
        elseif length(axes_direction)~=num_data_points
            error('Error: Please specify the same number of axes direction as number of data points.');
        end
    else

        axes_direction=repmat({axes_direction},num_data_points,1);
    end


    if iscell(fill_option)

        if length(fill_option)==1

            fill_option=repmat(fill_option,num_data_groups,1);
        elseif length(fill_option)~=num_data_groups
            error('Error: Please specify the same number of fill option as number of data groups.');
        end
    else

        fill_option=repmat({fill_option},num_data_groups,1);
    end


    if isnumeric(fill_transparency)

        if length(fill_transparency)==1

            fill_transparency=repmat(fill_transparency,num_data_groups,1);
        elseif length(fill_transparency)~=num_data_groups
            error('Error: Please specify the same number of fill transparency as number of data groups.');
        end
    else
        error('Error: Please make sure the transparency is a numeric value.');
    end


    if isnumeric(line_transparency)

        if length(line_transparency)==1

            line_transparency=repmat(line_transparency,num_data_groups,1);
        elseif length(line_transparency)~=num_data_groups
            error('Error: Please specify the same number of line transparency as number of data groups.');
        end
    else
        error('Error: Please make sure the transparency is a numeric value.');
    end


    if isnumeric(marker_transparency)

        if length(marker_transparency)==1

            marker_transparency=repmat(marker_transparency,num_data_groups,1);
        elseif length(marker_transparency)~=num_data_groups
            error('Error: Please specify the same number of marker transparency as number of data groups.');
        end
    else
        error('Error: Please make sure the transparency is a numeric value.');
    end


    if strcmp(axes_display,'data')
        if size(axes_font_color,1)~=num_data_groups

            if size(axes_font_color,1)==1&&size(axes_font_color,2)==3
                axes_font_color=repmat(axes_font_color,num_data_groups,1);
            else
                error('Error: Please specify axes font color as a RGB triplet normalized to 1.');
            end
        end
    end




    P_selected=P;


    log_index=strcmp(axes_scaling,'log');


    if any(log_index)

        P_log=P_selected(:,log_index);


        P_log=sign(P_log).*log10(abs(P_log));


        min_limit=min(min(fix(P_log)));
        max_limit=max(max(ceil(P_log)));
        recommended_axes_interval=max_limit-min_limit;


        warning('For the log scale values, recommended axes limit is [%i, %i] with an axes interval of %i.',...
        10^min_limit,10^max_limit,recommended_axes_interval);


        P_selected(:,log_index)=P_log;
    end



    fig=gcf;


    fig.Color='white';


    cla reset;


    ax=gca;


    hold on;
    axis square;
    axis([-1,1,-1,1]*1.3);


    ax.XTickLabel=[];
    ax.YTickLabel=[];
    ax.XColor='none';
    ax.YColor='none';


    theta_increment=2*pi/num_data_points;
    full_interval=axes_interval+1;
    rho_offset=axes_offset/full_interval;



    P_scaled=zeros(size(P_selected));
    axes_range=zeros(3,num_data_points);


    axes_direction_index=strcmp(axes_direction,'reverse');


    for ii=1:num_data_points

        if num_data_groups==1&&isempty(axes_limits)

            group_points=P_selected(:,:);
        else

            group_points=P_selected(:,ii);
        end


        if log_index(ii)

            min_value=min(fix(group_points));
            max_value=max(ceil(group_points));
        else

            min_value=min(group_points);
            max_value=max(group_points);
        end


        range=max_value-min_value;


        if~isempty(axes_limits)

            if log_index(ii)

                axes_limits(:,ii)=sign(axes_limits(:,ii)).*log10(abs(axes_limits(:,ii)));%#ok<AGROW>
            end


            min_value=axes_limits(1,ii);
            max_value=axes_limits(2,ii);
            range=max_value-min_value;


            if min_value>min(group_points)||max_value<max(group_points)
                error('Error: Please make the manually specified axes limits are within range of the data points.');
            end
        end


        if range==0

            range=1;
        end


        P_scaled(:,ii)=((P_selected(:,ii)-min_value)/range);


        if axes_direction_index(ii)

            axes_range(:,ii)=[max_value;min_value;range];
            P_scaled(:,ii)=-(P_scaled(:,ii)-1);
        else

            axes_range(:,ii)=[min_value;max_value;range];
        end


        P_scaled(:,ii)=P_scaled(:,ii)*(1-rho_offset)+rho_offset;
    end



    rho_increment=1/full_interval;
    rho=0:rho_increment:1;


    switch direction
    case 'counterclockwise'

        theta=(0:theta_increment:2*pi)+(pi/2);
    case 'clockwise'

        theta=(0:-theta_increment:-2*pi)+(pi/2);
    end


    theta=mod(theta,2*pi);


    for ii=1:length(theta)-1

        [x_axes,y_axes]=pol2cart(theta(ii),rho);


        h=plot(x_axes,y_axes,...
        'LineWidth',1.5,...
        'Color',axes_color);


        h.Annotation.LegendInformation.IconDisplayStyle='off';
    end


    for ii=2:length(rho)

        [x_axes,y_axes]=pol2cart(theta,rho(ii));


        h=plot(x_axes,y_axes,...
        'Color',axes_color);


        h.Annotation.LegendInformation.IconDisplayStyle='off';
    end


    switch axes_display
    case 'all'
        theta_end_index=length(theta)-1;
    case 'one'
        theta_end_index=1;
    case 'none'
        theta_end_index=0;
    case 'data'
        theta_end_index=0;
    end


    rho_start_index=axes_offset+1;
    offset_interval=full_interval-axes_offset;


    horz_align=axes_horz_align;
    vert_align=axes_vert_align;


    for ii=1:theta_end_index

        [x_axes,y_axes]=pol2cart(theta(ii),rho);


        if strcmp(axes_horz_align,'quadrant')

            [horz_align,~,~,~]=quadrant_position(axes_labels_offset,theta(ii));
        end


        if strcmp(axes_vert_align,'quadrant')

            [~,vert_align,~,~]=quadrant_position(axes_labels_offset,theta(ii));
        end


        for jj=rho_start_index:length(rho)

            min_value=axes_range(1,ii);
            range=axes_range(3,ii);


            if axes_direction_index(ii)

                axes_value=min_value-(range/offset_interval)*(jj-rho_start_index);
            else

                axes_value=min_value+(range/offset_interval)*(jj-rho_start_index);
            end


            if log_index(ii)

                axes_value=10^axes_value;
            end


            text_str=sprintf(sprintf('%%.%if',axes_precision(ii)),axes_value);
            text(x_axes(jj),y_axes(jj),text_str,...
            'Units','Data',...
            'Color',axes_font_color,...
            'FontName',axes_font,...
            'FontSize',axes_font_size,...
            'HorizontalAlignment',horz_align,...
            'VerticalAlignment',vert_align);
        end
    end



    fill_option_index=strcmp(fill_option,'on');


    for ii=1:num_data_groups

        [x_points,y_points]=pol2cart(theta(1:end-1),P_scaled(ii,:));


        x_circular=[x_points,x_points(1)];
        y_circular=[y_points,y_points(1)];


        h=plot(x_circular,y_circular,...
        'LineStyle',line_style{ii},...
        'Color',colors(ii,:),...
        'LineWidth',line_width(ii));
        h.Color(4)=line_transparency(ii);

        h=scatter(x_circular,y_circular,...
        'Marker',marker_type{ii},...
        'SizeData',marker_size(ii),...
        'MarkerFaceColor',colors(ii,:),...
        'MarkerEdgeColor',colors(ii,:),...
        'MarkerFaceAlpha',marker_transparency(ii),...
        'MarkerEdgeAlpha',marker_transparency(ii));


        h.Annotation.LegendInformation.IconDisplayStyle='off';


        if strcmp(axes_display,'data')
            for jj=1:num_data_points

                [horz_align,vert_align,x_pos,y_pos]=quadrant_position(axes_labels_offset,theta(jj));
                x_pos=x_pos*0.1;
                y_pos=y_pos*0.1;


                data_value=P(ii,jj);
                text_str=sprintf(sprintf('%%.%if',axes_precision(jj)),data_value);
                text(x_points(jj)+x_pos,y_points(jj)+y_pos,text_str,...
                'Units','Data',...
                'Color',axes_font_color(ii,:),...
                'FontName',axes_font,...
                'FontSize',axes_font_size,...
                'HorizontalAlignment',horz_align,...
                'VerticalAlignment',vert_align);
            end
        end


        if fill_option_index(ii)

            h=patch(x_circular,y_circular,colors(ii,:),...
            'EdgeColor','none',...
            'FaceAlpha',fill_transparency(ii));


            h.Annotation.LegendInformation.IconDisplayStyle='off';
        end
    end


    text_handles=findobj(ax.Children,...
    'Type','Text');
    patch_handles=findobj(ax.Children,...
    'Type','Patch');
    isocurve_handles=findobj(ax.Children,...
    'Color',axes_color,...
    '-and','Type','Line');
    plot_handles=findobj(ax.Children,'-not',...
    'Color',axes_color,...
    '-and','Type','Line');


    uistack(plot_handles,'bottom');
    uistack(patch_handles,'bottom');
    uistack(isocurve_handles,'bottom');
    uistack(text_handles,'top');



    if~strcmp(axes_labels,'none')

        [x_axes,y_axes]=pol2cart(theta,rho(end));


        for ii=1:length(axes_labels)

            [horz_align,vert_align,x_pos,y_pos]=quadrant_position(axes_labels_offset,theta(ii));


            text(x_axes(ii)+x_pos,y_axes(ii)+y_pos,axes_labels{ii},...
            'Units','Data',...
            'HorizontalAlignment',horz_align,...
            'VerticalAlignment',vert_align,...
            'EdgeColor',axes_labels_edge,...
            'BackgroundColor','w',...
            'FontName',label_font,...
            'FontSize',label_font_size);
        end
    end

    function[horz_align,vert_align,x_pos,y_pos]=quadrant_position(axes_labels_offset,theta_point)

        if theta_point==0
            quadrant=0;
        elseif theta_point==pi/2
            quadrant=1.5;
        elseif theta_point==pi
            quadrant=2.5;
        elseif theta_point==3*pi/2
            quadrant=3.5;
        elseif theta_point==2*pi
            quadrant=0;
        elseif theta_point>0&&theta_point<pi/2
            quadrant=1;
        elseif theta_point>pi/2&&theta_point<pi
            quadrant=2;
        elseif theta_point>pi&&theta_point<3*pi/2
            quadrant=3;
        elseif theta_point>3*pi/2&&theta_point<2*pi
            quadrant=4;
        end


        switch quadrant
        case 0
            horz_align='left';
            vert_align='middle';
            x_pos=axes_labels_offset;
            y_pos=0;
        case 1
            horz_align='left';
            vert_align='bottom';
            x_pos=axes_labels_offset;
            y_pos=axes_labels_offset;
        case 1.5
            horz_align='center';
            vert_align='bottom';
            x_pos=0;
            y_pos=axes_labels_offset;
        case 2
            horz_align='right';
            vert_align='bottom';
            x_pos=-axes_labels_offset;
            y_pos=axes_labels_offset;
        case 2.5
            horz_align='right';
            vert_align='middle';
            x_pos=-axes_labels_offset;
            y_pos=0;
        case 3
            horz_align='right';
            vert_align='top';
            x_pos=-axes_labels_offset;
            y_pos=-axes_labels_offset;
        case 3.5
            horz_align='center';
            vert_align='top';
            x_pos=0;
            y_pos=-axes_labels_offset;
        case 4
            horz_align='left';
            vert_align='top';
            x_pos=axes_labels_offset;
            y_pos=-axes_labels_offset;
        end
    end
end