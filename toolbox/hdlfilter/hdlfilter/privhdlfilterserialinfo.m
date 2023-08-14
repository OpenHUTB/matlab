function varargout=privhdlfilterserialinfo(filterobj,varargin)





    if~(builtin('license','checkout','Filter_Design_HDL_Coder'))
        error(message('hdlfilter:privhdlfilterserialinfo:nolicenseavailable'));
    end


    if~isempty(varargin)&&length(varargin)~=2&&length(varargin)~=4


        error(message('hdlfilter:privhdlfilterserialinfo:wrongargs'));
    end

    idxMults=find(strcmp(varargin,'Multipliers'),1);
    if~isempty(idxMults)
        if~isValidMultOrFoldFactValue(varargin{idxMults+1})
            error(message('hdlfilter:privhdlfilterserialinfo:invalidMultipliers'));
        end
    end

    idxFldFc=find(strcmp(varargin,'FoldingFactor'),1);
    if~isempty(idxFldFc)
        if~isValidMultOrFoldFactValue(varargin{idxFldFc+1})
            error(message('hdlfilter:privhdlfilterserialinfo:invalidFoldingFactor'));
        end
    end



    supportedSystemObjs=dsp.internal.gethdlSysObj;
    if any(strcmp(class(filterobj),supportedSystemObjs))
        [filterobj,varargin]=getdfilt(filterobj,varargin{:});
    end

    [cando,~,errObj]=ishdlable(filterobj);
    if~cando
        error(errObj);
    end

    hF=filterobj.createhdlfilter;

    if nargout>0
        [sp,ff,mul]=hF.getSerialPartition(varargin{:});
        varargout={sp,ff,mul};
    else
        hF.getSerialPartition(varargin{:});
    end

end


function retVal=isValidMultOrFoldFactValue(argVal)

    retVal=~isempty(argVal)&&isscalar(argVal)&&isnumeric(argVal)&&...
    isreal(argVal)&&(argVal>0)&&(argVal==floor(argVal));
end
