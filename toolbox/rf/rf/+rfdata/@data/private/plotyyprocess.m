function[out,usePLOT,loc_yformat]=plotyyprocess(h,varargin)





    new_varargin={};
    ninputs=numel(varargin);
    for ii=1:ninputs
        if~iscell(varargin{ii})
            new_varargin={new_varargin{:},varargin{ii}};
        else
            new_varargin={new_varargin{:},varargin{ii}{:}};
        end
    end
    varargin=new_varargin;
    out=new_varargin;
    usePLOT=false;


    [flag_yparam,flag_yformat]=getflag(h,varargin{:});
    loc_yparam=find(flag_yparam);
    loc_yformat=find(flag_yformat);
    loc_last_yparam=loc_yparam(end);
    allparams=varargin(loc_yparam);
    if isempty(loc_yparam)

        return
    end

    if(any(strncmpi(allparams,'am/am',5))||any(strncmpi(allparams,'am/pm',5)))...
        &&~all(strncmpi(varargin,'am/',3))
        error(message('rf:rfdata:data:plotyyprocess:CantPlotAMAMDatawithOthers'));
    end

    if~all(diff(loc_yparam)==1)
        if numel(loc_yformat)==1
            error(message('rf:rfdata:data:plotyyprocess:NotEnoughFormats',varargin{loc_yformat}));
        end
    elseif loc_last_yparam+2<=numel(varargin)&&...
        all(flag_yformat([loc_last_yparam+1,loc_last_yparam+2]))


        args_after_yformat=varargin(loc_last_yparam+3:end);
        yformat1=varargin{loc_last_yparam+1};
        yformat2=varargin{loc_last_yparam+2};
        out={allparams{:},yformat1,allparams{:},yformat2,args_after_yformat{:}};
    elseif loc_last_yparam<numel(varargin)&&...
        flag_yformat(loc_last_yparam+1)

        args_after_yformat=varargin(loc_last_yparam+2:end);
        yformat1=varargin{loc_last_yparam+1};
        out={allparams{:},yformat1,args_after_yformat{:}};
        usePLOT=true;
    else

        allparams=varargin(loc_yparam);


        predefined_primary_formats={'Magnitude (decibels)','dBm','dBc/Hz','Angle (degrees)','Kelvin','ns','None'};
        predefined_secondary_formats={'Angle (degrees)','W'};



        [out,loc_yformat]=searchtwoformats(h,predefined_primary_formats,predefined_secondary_formats,0,...
        allparams,varargin,loc_last_yparam);
        if isempty(out)


            [out,loc_yformat]=searchtwoformats(h,predefined_primary_formats,predefined_primary_formats,1,...
            allparams,varargin,loc_last_yparam);
        end
        if isempty(out)


            [out,loc_yformat]=searchtwoformats(h,predefined_secondary_formats,predefined_secondary_formats,1,...
            allparams,varargin,loc_last_yparam);
        end
        if isempty(out)


            [out,loc_yformat]=searchoneformat(h,predefined_primary_formats,allparams,varargin,loc_last_yparam);
            usePLOT=true;
        end
        if isempty(out)


            [out,loc_yformat]=searchoneformat(h,predefined_secondary_formats,allparams,varargin,loc_last_yparam);
            usePLOT=true;
        end

        if isempty(out)
            error(message('rf:rfdata:data:plotyyprocess:NoCommonFormat'));
        end
    end

    function[out,formatposition]=searchtwoformats(h,predefined_formats1,predefined_formats2,flag_2,allparams,varargin,loc_last_yparam)
        out={};
        formatposition=0;
        idx_1=0;idx_2=0;total_nparams=0;
        npredefined_formats1=numel(predefined_formats1);
        npredefined_formats2=numel(predefined_formats2);
        nallparams=numel(allparams);
        for ii=1:npredefined_formats1
            format1=predefined_formats1{ii};
            format1_flag=validformat(h,format1,allparams);
            if flag_2==0
                start_2=1;
            elseif flag_2==1
                start_2=ii+1;
            end
            for jj=start_2:npredefined_formats2
                format2=predefined_formats2{jj};
                if strcmp(format1,format2);continue;end;
                format2_flag=validformat(h,format2,allparams);
                if all(format1_flag|format2_flag)&&any(format1_flag==1)&&any(format2_flag==1)
                    nparams=sum(format1_flag)+sum(format2_flag);
                    if nparams>total_nparams
                        idx_1=ii;idx_2=jj;
                        total_nparams=nparams;
                    end
                    if total_nparams==2*nallparams;break;end;
                end
            end
            if total_nparams==2*nallparams;break;end;
        end
        if idx_1>0&&idx_2>0
            format1=predefined_formats1{idx_1};
            format1_flag=validformat(h,format1,allparams);
            format2=predefined_formats2{idx_2};
            format2_flag=validformat(h,format2,allparams);
            idx1=find(format1_flag==1);nidx1=numel(idx1);
            idx2=find(format2_flag==1);nidx2=numel(idx2);
            parameters1=cell(nidx1,1);
            for ij=1:nidx1
                parameters1{ij}=allparams{idx1(ij)};
            end
            parameters2=cell(nidx2,1);
            for ij=1:nidx2
                parameters2{ij}=allparams{idx2(ij)};
            end
            args_after_yparam=varargin(loc_last_yparam+1:end);
            if strcmp(format2,'Magnitude (decibels)')||strcmp(format1,'Angle (degrees)')
                out={parameters2{:},format2,parameters1{:},format1,args_after_yparam{:}};
                formatposition=numel(parameters2)+1;
            else
                out={parameters1{:},format1,parameters2{:},format2,args_after_yparam{:}};
                formatposition=numel(parameters1)+1;
            end
        end


        function[out,formatposition]=searchoneformat(h,predefined_formats1,allparams,varargin,loc_last_yparam)
            out={};
            formatposition=0;
            npredefined_formats1=numel(predefined_formats1);
            for ii=1:npredefined_formats1
                format1=predefined_formats1{ii};
                format1_flag=validformat(h,format1,allparams);
                if all(format1_flag)
                    args_after_yparam=varargin(loc_last_yparam+1:end);
                    out={allparams{:},format1,args_after_yparam{:}};
                    formatposition=numel(allparams)+1;
                    return;
                end
            end


            function validformatflag=validformat(h,format,allparams)

                nallparams=numel(allparams);
                validformatflag=zeros(nallparams,1);
                for ii=1:nallparams
                    param=allparams{ii};
                    validformatflag(ii)=any(strcmpi(listformat(h,param),format));
                end


                function[flag_param,flag_format]=getflag(h,varargin)

                    num_input=numel(varargin);
                    flag_param=false(1,num_input);
                    flag_format=false(1,num_input);
                    paramslist=listparam(h);
                    formatslist=listformat(h);
                    ninputs=numel(varargin);
                    for ii=1:ninputs
                        flag_param(ii)=any(strcmpi(varargin{ii},paramslist));
                        flag_format(ii)=any(strcmpi(varargin{ii},formatslist));
                    end