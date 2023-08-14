function raw_data=LTspice2Matlab(filename,varargin)














































































































    raw_data=[];

    if nargin==0,
        error('LTspice2Matlab takes 1, 2, or 3 input parameters.  Type "help LTspice2Matlab" for details');
    elseif nargin==1,
        selected_vars='all';
        downsamp_N=1;
    elseif nargin==2,
        selected_vars=varargin{1};
        if ischar(selected_vars),selected_vars=lower(selected_vars);end
        downsamp_N=1;
    elseif nargin==3,
        selected_vars=varargin{1};
        if ischar(selected_vars),selected_vars=lower(selected_vars);end
        downsamp_N=varargin{2};
    else
        error('LTspice2Matlab takes only 1, 2, or 3 input parameters.  Type "help LTspice2Matlab" for details');
    end


    if length(downsamp_N)~=1|~isnumeric(downsamp_N)|isnan(downsamp_N)|mod(downsamp_N,1)~=0.0|downsamp_N<=0,
        error('Optional parameter DOWNSAMP_N must be a positive integer >= 1');
    end


    filename=fliplr(deblank(fliplr(deblank(filename))));
    fid=fopen(filename,'rb','n','UTF16LE');
    if length(fid)==1&isnumeric(fid)&fid==-1,

        fid=fopen(sprintf('%s.raw',filename),'rb','n','UTF16LE');
        if length(fid)==1&isnumeric(fid)&fid==-1,
            pm_error('physmod:ee:SPICE2sscvalidation:RawFileError');

        end
    end


    [filename,the_permision,machineformat]=fopen(fid);


    variable_name_list={};variable_type_list={};
    variable_flag=0;
    file_format='';
    while 1,
        the_line=fgetl(fid);
        if length(the_line)==1&isnumeric(the_line)&double(the_line)==-1,
            try fclose(fid);catchend

            pm_error('physmod:ee:SPICE2sscvalidation:LTspiceFileFormatError1');
        end

        the_line=char(the_line);

        if length(strfind(the_line,'Binary:'))~=0,file_format='binary';break;end
        if length(strfind(the_line,'Values:'))~=0,file_format='ascii';break;end

        if variable_flag==0,
            if length(the_line)==0,colon_index=[];
            else,colon_index=find(the_line==':');end
            if length(colon_index)==0,
                try fclose(fid);catchend

                pm_error('physmod:ee:SPICE2sscvalidation:LTspiceFileFormatError2');
            end
            var_name=the_line(1:(colon_index(1)-1));
            var_value=fliplr(deblank(fliplr(deblank(the_line((colon_index(1)+1):end)))));

            vn_keep_index=find(var_name~=' '&var_name~='.'&var_name~=char(9)&var_name~=char(10)&var_name~=char(13));
            var_name=lower(var_name(vn_keep_index));
            var_name=var_name(~isspace(var_name));
            if length(var_name)==0|(var_name(1)>='0'&var_name(1)<='9'),
                try fclose(fid);catchend

                pm_error('physmod:ee:SPICE2sscvalidation:LTspiceFileFormatError3');
            end

            if strcmpi(var_name,'variables')|strcmpi(var_name,'variable'),variable_flag=1;continue;end
            value_try=str2num(var_value);
            try
                if length(value_try)==0,raw_data=setfield(raw_data,var_name,var_value);
                else raw_data=setfield(raw_data,var_name,value_try);end
            catch
                try fclose(fid);catchend

                pm_error('physmod:ee:SPICE2sscvalidation:LTspiceFileFormatError3');
            end

        else
            leading_ch_index=find((the_line(1:end-1)==' '|the_line(1:end-1)==char(9))&(the_line(2:end)~=' '&the_line(2:end)~=char(9)));
            if length(leading_ch_index)~=3,
                try fclose(fid);catchend

                pm_error('physmod:ee:SPICE2sscvalidation:LTspiceFileFormatError4');
            end

            part1=fliplr(deblank(fliplr(deblank(the_line((leading_ch_index(1)+1):leading_ch_index(2))))));
            part2=fliplr(deblank(fliplr(deblank(the_line((leading_ch_index(2)+1):leading_ch_index(3))))));
            part3=fliplr(deblank(fliplr(deblank(the_line((leading_ch_index(3)+1):end)))));

            if str2num(part1)~=length(variable_name_list),
                try fclose(fid);catchend

                pm_error('physmod:ee:SPICE2sscvalidation:LTspiceFileFormatError5');
            end
            variable_name_list{end+1}=part2;
            variable_type_list{end+1}=part3;
        end
    end


    expected_tags={'title','date','plotname','flags','novariables','nopoints'};
    expected_tags_full={'Title','Date','Plotname','Flags','No. Variables','No. Points'};
    for q=1:length(expected_tags),
        if~isfield(raw_data,lower(expected_tags{q})),
            try fclose(fid);catchend

            pm_error('physmod:ee:SPICE2sscvalidation:LTspiceFileFormatError6');
        end
    end

    raw_data.conversion_notes='';
    raw_data.num_data_pnts=raw_data.nopoints;raw_data=rmfield(raw_data,'nopoints');
    raw_data.num_variables=raw_data.novariables-1;raw_data=rmfield(raw_data,'novariables');


    if isfield(raw_data,'command'),raw_data=rmfield(raw_data,'command');end
    if isfield(raw_data,'backannotation'),raw_data=rmfield(raw_data,'backannotation');end
    if isfield(raw_data,'offset'),
        general_offset=raw_data.offset;
        raw_data=rmfield(raw_data,'offset');
    else
        general_offset=0.0;
    end


    raw_data.variable_name_list={variable_name_list{2:end}};
    raw_data.variable_type_list={variable_type_list{2:end}};

    simulation_type='';
    if length(strfind(lower(raw_data.plotname),'transient analysis'))~=0,simulation_type='.tran';
    elseif length(strfind(lower(raw_data.plotname),'ac analysis'))~=0,simulation_type='.ac';
    elseif length(strfind(lower(raw_data.plotname),'dc transfer characteristic'))~=0,simulation_type='.dc';
    elseif length(strfind(lower(raw_data.plotname),'operating point'))~=0,simulation_type='.op';
    end

    if length(simulation_type)==0|~(strcmpi(simulation_type,'.tran')|strcmpi(simulation_type,'.ac')),
        try fclose(fid);catchend
        error('Currently LTspice2Matlab is only able to import results from Transient Analysis (.tran) and AC Analysis (.ac) simulations.');
    end

    if length(strfind(lower(raw_data.flags),'fastaccess'))~=0,
        try fclose(fid);catchend
        error('LTspice2Matlab cannot convert files saved in the "Fast Access" format.');
    end
    if strcmpi(simulation_type,'.tran')&length(strfind(lower(raw_data.flags),'real'))==0,
        try fclose(fid);catchend
        error('Expected to find "real" flag for a Transient Analysis (.tran) simulation.  Unsure how to convert the data');
    end
    if strcmpi(simulation_type,'.tran')&length(strfind(lower(raw_data.flags),'forward'))==0,
        try fclose(fid);catchend
        error('Expected to find "forward" flag for a Transient Analysis (.tran) simulation.  Unsure how to convert the data');
    end

    if strcmpi(simulation_type,'.ac')&length(strfind(lower(raw_data.flags),'complex'))==0,
        try fclose(fid);catchend
        error('Expected to find "complex" flag for an AC Analysis (.ac) simulation.  Unsure how to convert the data');
    end
    if strcmpi(simulation_type,'.ac')&length(strfind(lower(raw_data.flags),'forward'))==0,
        try fclose(fid);catchend
        error('Expected to find "forward" flag for an AC Analysis (.ac) simulation.  Unsure how to convert the data');
    end
    if isfield(raw_data,'flags'),raw_data=rmfield(raw_data,'flags');end


    if ischar(selected_vars),
        if strcmpi(selected_vars,'all')|strcmpi(selected_vars,'everything')|strcmpi(selected_vars,'complete')|strcmpi(selected_vars,'all variables')|...
            strcmpi(selected_vars,'all vars')|strcmpi(selected_vars,'every thing')|strcmpi(selected_vars,'every'),
            selected_vars=1:raw_data.num_variables;
        else
            try fclose(fid);catchend
            error('Bad value for optional input parameter SELECTED_VARS');
        end
    end


    if size(selected_vars,1)==0|size(selected_vars,2)==0,
        raw_data.selected_vars=[];
        raw_data.variable_mat=[];
        raw_data.time_vect=[];
        try fclose(fid);catchend
        return;
    end
    if size(selected_vars,1)>1&size(selected_vars,2)>1,
        try fclose(fid);catchend
        error('SELECTED_VARS must be a row or column vector, not a matrix');
    end
    if length(find(selected_vars==0))~=0,
        try fclose(fid);catchend
        error('The time vector (index 0) is returned separately.  \n   Values in input parameter SELECTED_VARS must be positive integers >= 1 and <= NUM_VARIABLES');
    end
    non_integer_index=find(isnan(selected_vars)|~isnumeric(selected_vars)|mod(selected_vars,1)~=0.0);
    if length(non_integer_index)~=0,
        try fclose(fid);catchend
        error('Values in input parameter SELECTED_VARS must be positive integers >= 1 and <= NUM_VARIABLES');
    end
    missing_index=find(~ismember(selected_vars,1:raw_data.num_variables));
    if length(missing_index)~=0,
        try fclose(fid);catchend
        error('Error in input parameter SELECTED_VARS ... Out of range value(s) found');
    end

    selected_vars=unique(selected_vars);
    raw_data.selected_vars=selected_vars;


    NumPnts=raw_data.num_data_pnts;
    NumPnts_DS=floor(NumPnts/downsamp_N);
    raw_data.num_data_pnts=NumPnts_DS;
    NumVars=raw_data.num_variables+1;



    if strcmpi(file_format,'binary'),
        binary_start=ftell(fid);

        if strcmpi(simulation_type,'.tran'),




            if length(selected_vars)>1,
                g_border=find([2,diff(selected_vars),2]~=1);
                block_list={};
                for k=1:length(g_border)-1,block_list{k}=g_border(k):(g_border(k+1)-1);end
            else
                block_list={1:length(selected_vars)};
            end

            raw_data.variable_mat=zeros(length(selected_vars),NumPnts_DS);
            for k=1:length(block_list),
                target_var_index=selected_vars(block_list{k});
                fseek(fid,binary_start+(target_var_index(1)+1)*4,'bof');
                TVIL=length(target_var_index);
                bytes_skip=(NumVars+1-TVIL)*4+(downsamp_N-1)*(NumVars+1)*4;
                precision_str=sprintf('%.0f*float',TVIL);
                raw_data.variable_mat(block_list{k},:)=reshape(fread(fid,NumPnts_DS*TVIL,precision_str,bytes_skip,machineformat),TVIL,NumPnts_DS);
            end

            fseek(fid,binary_start,'bof');
            raw_data.time_vect=fread(fid,NumPnts_DS,'double',(NumVars-1)*4+(downsamp_N-1)*(NumVars+1)*4,machineformat).';
            if downsamp_N==1,raw_data.conversion_notes='Converted from Binary format';
            else raw_data.conversion_notes=sprintf('Converted from Binary format.  Downsampled from %.0f to %.0f points',NumPnts,NumPnts_DS);end

        elseif strcmpi(simulation_type,'.ac'),




            if length(selected_vars)>1,
                g_border=find([2,diff(selected_vars),2]~=1);
                block_list={};
                for k=1:length(g_border)-1,block_list{k}=g_border(k):(g_border(k+1)-1);end
            else
                block_list={1:length(selected_vars)};
            end

            raw_data.variable_mat=zeros(length(selected_vars),NumPnts_DS);
            if prod(size(raw_data.variable_mat))~=0,raw_data.variable_mat(1,1)=0.0+j*0.0;end
            for k=1:length(block_list),
                target_var_index=selected_vars(block_list{k});
                fseek(fid,binary_start+target_var_index(1)*16,'bof');
                TVIL=length(target_var_index);
                bytes_skip=(NumVars-TVIL)*16+(downsamp_N-1)*NumVars*16;
                precision_str=sprintf('%.0f*double',TVIL*2);
                temp_buff=reshape(fread(fid,NumPnts_DS*TVIL*2,precision_str,bytes_skip,machineformat),TVIL*2,NumPnts_DS);
                raw_data.variable_mat(block_list{k},:)=temp_buff(1:2:end-1,:)+j*temp_buff(2:2:end,:);
                clear temp_buff;
            end

            fseek(fid,binary_start,'bof');
            raw_data.freq_vect=fread(fid,NumPnts_DS,'double',(NumVars-1)*16+8+(downsamp_N-1)*NumVars*16,machineformat).';

        else
            try fclose(fid);catchend
            error(sprintf('Simulation type (%s) not currently supported',simulation_type));
        end


    elseif strcmpi(file_format,'ascii'),

        if strcmpi(simulation_type,'.tran'),

            raw_data.variable_mat=fscanf(fid,'%g',[raw_data.num_variables+2,raw_data.num_data_pnts]);
            if(size(raw_data.variable_mat,1)~=raw_data.num_variables+2)|(size(raw_data.variable_mat,2)~=raw_data.num_data_pnts),
                error(sprintf('Format error in ASCII Transient Analysis LTspice file "%s" ... Incorrect number of data values read',filename));
            end
            raw_data.time_vect=raw_data.variable_mat(2,1:downsamp_N:end);
            raw_data.variable_mat=raw_data.variable_mat(2+selected_vars,1:downsamp_N:end);

        elseif strcmpi(simulation_type,'.ac'),

            all_data=fread(fid,inf,'uchar');
            all_data(find(all_data==','))=sprintf('\t');
            raw_data.variable_mat=sscanf(char(all_data),'%g',[3+2*raw_data.num_variables,raw_data.num_data_pnts]);
            clear all_data;


            if(size(raw_data.variable_mat,1)~=(3+2*raw_data.num_variables))|(size(raw_data.variable_mat,2)~=raw_data.num_data_pnts),
                error(sprintf('Format error in ASCII AC Analysis LTspice file "%s" ... Incorrect number of data values read',filename));
            end
            raw_data.freq_vect=raw_data.variable_mat(2,1:downsamp_N:end);
            raw_data.variable_mat=raw_data.variable_mat(3+selected_vars*2-1,1:downsamp_N:end)+j*raw_data.variable_mat(3+selected_vars*2,1:downsamp_N:end);

        else
            try fclose(fid);catchend
            error(sprintf('Simulation type (%s) not currently supported',simulation_type));
        end

        if downsamp_N==1,raw_data.conversion_notes='Converted from ASCII format';
        else raw_data.conversion_notes=sprintf('Converted from ASCII format.  Downsampled from %.0f to %.0f points',NumPnts,NumPnts_DS);end

    else
        try fclose(fid);catchend

        pm_error('physmod:ee:SPICE2sscvalidation:LTspiceFileFormatError7');
    end

    try fclose(fid);catchend




    if strcmpi(simulation_type,'.tran')&(min(diff(raw_data.time_vect))<0.0),

        if downsamp_N~=1,
            raw_data.time_vect=abs(raw_data.time_vect);

        else


            t_vect=raw_data.time_vect;
            neg_pnt_index=find(t_vect<0.0&[0,ones(1,length(t_vect)-1)]);
            t_vect=abs(t_vect);

            x1=t_vect(neg_pnt_index-1);x2=t_vect(neg_pnt_index);x3=t_vect(neg_pnt_index+1);
            x_new=[(2*x1+x2)/3;(x1+2*x2)/3;(2*x2+x3)/3;(x2+2*x3)/3];

            t_vect_big=NaN*zeros(6,length(t_vect));
            t_vect_big(1,:)=t_vect;
            t_vect_big(4,neg_pnt_index)=t_vect(neg_pnt_index);
            t_vect_big(1,neg_pnt_index)=NaN;
            t_vect_big([2,3,5,6],neg_pnt_index)=x_new;

            full_index=find(~isnan(t_vect_big));
            time_vect_new=t_vect_big(full_index).';
            t_vect_big([1,4],:)=NaN;
            nan_vect=isnan(t_vect_big(full_index));
            new_index=find(~nan_vect);
            old_index=find(nan_vect);
            clear t_vect t_vect_big full_index nan_vect;

            x1sqr=repmat(x1.^2,[4,1]);x2sqr=repmat(x2.^2,[4,1]);x3sqr=repmat(x3.^2,[4,1]);
            x1=repmat(x1,[4,1]);x2=repmat(x2,[4,1]);x3=repmat(x3,[4,1]);
            denom=(x1sqr-x2sqr).*(x2-x3)-(x2sqr-x3sqr).*(x1-x2);
            r1=(x_new.^2-x1sqr)./denom;
            r2=(x_new-x1)./denom;
            p1=(x2-x3).*r1-(x2sqr-x3sqr).*r2;
            p3=(x1-x2).*r1-(x1sqr-x2sqr).*r2;
            p2=-p1-p3;
            p1=p1+1;
            clear x_new x1sqr x2sqr x3sqr x1 x2 x3 denom r1 r2;

            raw_data.variable_mat(:,end+1:length(time_vect_new))=0.0;
            for k=1:size(raw_data.variable_mat,1),
                y_vect=raw_data.variable_mat(k,1:length(raw_data.time_vect));
                raw_data.variable_mat(k,old_index)=y_vect;
                y_new=repmat(y_vect(neg_pnt_index-1),[4,1]).*p1+repmat(y_vect(neg_pnt_index),[4,1]).*p2+repmat(y_vect(neg_pnt_index+1),[4,1]).*p3;
                raw_data.variable_mat(k,new_index)=y_new(:).';
            end
            raw_data.time_vect=time_vect_new;
            clear time_vect_new y_vect y_new new_index old_index neg_pnt_index p1 p2 p3;

            raw_data.conversion_notes=sprintf('Converted from Binary format with 2nd Order compression.  Upsampled waveforms from %.0f to %.0f points',...
            raw_data.num_data_pnts,length(raw_data.time_vect));
            raw_data.num_data_pnts=length(raw_data.time_vect);
        end

    end

    if isfield(raw_data,'time_vect'),raw_data.time_vect=raw_data.time_vect+general_offset;
    elseif isfield(raw_data,'freq_vect'),raw_data.freq_vect=raw_data.freq_vect+general_offset;
    end
