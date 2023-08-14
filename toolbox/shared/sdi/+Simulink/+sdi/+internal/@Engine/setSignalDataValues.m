function setSignalDataValues(this,id,value,keepDimensions)

    if(isa(value,'timeseries')&&value.length>0)||...
        (isstruct(value)&&isfield(value,'Data')&&~isempty(value.Data))
        len=length(value.Data);
        value1.Data=reshape(value.Data,len,1);
        value1.Time=reshape(value.Time,len,1);
        if nargin<4
            keepDimensions=false;
        end
        this.sigRepository.setSignalDataValues(id,value1,keepDimensions);
    else
        error(message('SDI:sdi:INPUT_MISMATCH_WITH_STRUCT','timeseries','structure'));
    end
    this.dirty=true;
end