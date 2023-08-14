function varargout=privhdlfilterdainfo(filterobj,varargin)





    if~(builtin('license','checkout','Filter_Design_HDL_Coder'))
        error(message('hdlfilter:privhdlfilterdainfo:nolicenseavailable'));
    end



    supportedSystemObjs=dsp.internal.gethdlSysObj;
    if any(strcmp(class(filterobj),supportedSystemObjs))
        [filterobj,varargin]=getdfilt(filterobj,varargin{:});
    end


    if~isempty(varargin)&&length(varargin)~=2&&length(varargin)~=4


        error(message('hdlfilter:privhdlfilterdainfo:wrongargs'));
    end

    [cando,~,errObj]=ishdlable(filterobj);
    if~cando
        error(errObj);
    end

    hF=filterobj.createhdlfilter;

    if nargout>0
        [dlp,dr,lutsize,ff]=hF.getDALutPartition(varargin{:});
        varargout={dlp,dr,lutsize,ff};
    else
        hF.getDALutPartition(varargin{:});
    end


