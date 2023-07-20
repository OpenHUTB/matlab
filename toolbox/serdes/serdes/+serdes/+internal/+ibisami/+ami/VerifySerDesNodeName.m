function verified=VerifySerDesNodeName(varargin)







    if nargin<1||isempty(varargin{1})||strtrim(string(varargin{1}))==""
        nodeName='<unnamed>';
    else
        nodeName=char(varargin{1});
    end


    verified=...
    isvarname(nodeName)&&...
    exist(nodeName,'builtin')~=5&&...
    ~serdes.internal.ibisami.ami.parameter.AmiParameter.isReservedParameterName(nodeName);
    if~verified&&(nargin<2||varargin{2})
        error(message('serdes:ibis:InvalidSerDesNode',nodeName))
    end
end

