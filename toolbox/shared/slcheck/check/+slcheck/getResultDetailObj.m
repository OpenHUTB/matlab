function vObj=getResultDetailObj(varargin)
    vObj=ModelAdvisor.ResultDetail;
    ModelAdvisor.ResultDetail.setData(vObj,varargin{:});
end
