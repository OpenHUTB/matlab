function percent_of_range_str=percentOfRangeStr(ratio_of_range,out_of_range_colors,full_range_colors)



    if nargin<2,out_of_range_colors={};end
    if nargin<3,full_range_colors={};end
    if isempty(out_of_range_colors)
        out_of_range_colors={'red',...
        'white'};
    end
    if isempty(full_range_colors)
        full_range_colors={'yellow',...
        'black'};
    end

    if isempty(ratio_of_range)

        percent_of_range_str='';
        return
    end
    if iscell(ratio_of_range)

        allEmpty=true;
        for i=1:length(ratio_of_range)
            if~isempty(ratio_of_range{i})
                allEmpty=false;
                break
            end
        end
        if allEmpty
            percent_of_range_str='';
            return
        end
    end
    if length(ratio_of_range)==1
        if iscell(ratio_of_range)
            val=ratio_of_range{1};
        else
            val=ratio_of_range;
        end
        percent_of_range_str=formatFunction(val);
    else
        if iscell(ratio_of_range)
            val=ratio_of_range{1};
        else
            val=ratio_of_range(1);
        end
        percent_of_range_str=formatFunction(val);
        for i=2:length(ratio_of_range)
            if iscell(ratio_of_range)
                val=ratio_of_range{i};
            else
                val=ratio_of_range(i);
            end
            percent_of_range_str=[percent_of_range_str,'<br />',formatFunction(val)];%#ok<AGROW>
        end
    end
    function str=formatFunction(valVector)
        strVector=cell(size(valVector));
        for n=1:length(valVector)
            strVector{n}=formatElement(valVector(n));
        end
        str=[strVector{:}];
    end
    function str=formatElement(val)
        if isempty(val)
            str='-';
        else
            percent_of_range=ceil(val*100);
            str=int2str(percent_of_range);
            color_format='<span style="background-color: %s"><span style="color: %s"><b>%s</b></span></span>';

            if percent_of_range>100

                str=sprintf(color_format,out_of_range_colors{1},out_of_range_colors{2},str);
            elseif percent_of_range==100

                str=sprintf(color_format,full_range_colors{1},full_range_colors{2},str);
            elseif val<0.01&&val~=0

                str='< 1';
            end
        end
    end
end
