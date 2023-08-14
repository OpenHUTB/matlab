function Udata=collectresponse(h,Udata,plottype,yparam,yformat,...
    xname,xformat,plotz0,tag)







    for ii=1:numel(yformat)
        yformat{ii}=modifyformat(h,yformat{ii});
    end


    idx=strcmp(strtrim(yparam),'');
    if any(idx)
        yparam=yparam(~idx);
        yformat=yformat(~idx);
    end
    if(numel(unique(Udata.PlotFormat))~=numel(unique(yformat)))||...
        (numel(unique(Udata.PlotFormat))==1&&...
        ~strcmp(Udata.PlotFormat{1},yformat{1}))
        parameters=yparam;
        formats=yformat;
    else
        parameters={Udata.Parameters{:},yparam{:}};
        formats={Udata.PlotFormat{:},yformat{:}};
    end
    XAxisName=Udata.XAxisName;
    XFormat=Udata.XFormat;


    if donewplot(h,Udata,plottype,formats,xname,xformat,plotz0,tag)
        XAxisName=xname;
        XFormat=xformat;
        parameters=yparam;
        formats=yformat;
        if numel(unique(formats))==1
            [parameters,idx]=myunique(parameters);
            formats=formats(idx);
        end
    else

        unique_formats=myunique(formats);
        if numel(unique_formats)==1
            [parameters,idx]=myunique(parameters);
            formats=formats(idx);
        else
            first_format=unique_formats{1};
            idx=strcmp(first_format,formats);
            tempParam1=parameters(idx);
            tempParam2=parameters(~idx);
            tempFormat1=formats(idx);
            tempFormat2=formats(~idx);

            [tempParam1,new_idx]=myunique(tempParam1);
            tempFormat1=tempFormat1(new_idx);
            [tempParam2,new_idx]=myunique(tempParam2);
            tempFormat2=tempFormat2(new_idx);
            parameters={tempParam1{:},tempParam2{:}};
            formats={tempFormat1{:},tempFormat2{:}};
        end
    end


    Udata.Parameters=parameters;
    Udata.NumParameters=numel(parameters);
    Udata.PlotFormat=formats;
    Udata.PlotType=plottype;
    Udata.XAxisName=XAxisName;
    Udata.XFormat=XFormat;
    Udata.PlotZ0=plotz0;


    function result=donewplot(h,Udata,plottype,formats,xname,...
        xformat,plotz0,tag)

        result=false;
        fig=findobj('Type','Figure','Tag',tag);
        if isempty(fig)
            result=true;
            return
        end
        if~strcmp(plottype,Udata.PlotType)
            result=true;
            return
        end
        if~strcmp(xname,Udata.XAxisName)
            result=true;
            return
        end
        if~strcmp(xformat,Udata.XFormat)
            result=true;
            return
        end
        if isfield(Udata,'PlotZ0')&&~isequal(plotz0,Udata.PlotZ0)
            result=true;
            return
        end
        unique_formats=unique(formats);
        if strcmp(plottype,'X-Y plane')
            if numel(unique_formats)>2
                result=true;
                return
            end
        end
        paramslist=listparam(h,Udata.PlotType);
        parameters=Udata.Parameters;
        nparameters=numel(parameters);
        for ii=1:nparameters
            if~any(strcmpi(parameters{ii},paramslist))
                result=true;
                return
            end
        end


        function[out,idx]=myunique(in)
            [temp,idx]=unique(in,'first');
            idx=sort(idx);
            out=in(idx);
