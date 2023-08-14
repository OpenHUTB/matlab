function setNetworkName(obj,varargin)




%#codegen
    coder.inline('always');
    coder.allowpcode('plain');

    coder.extrinsic('fileparts');
    if nargin>1&&~isempty(varargin{1})
        netName=varargin{1};
        coder.internal.assert((coder.internal.isCharOrScalarString(netName)&&...
        coder.internal.isConst(netName)),...
        'dlcoder_spkg:cnncodegen:invalid_networkname');
    else
        [~,netName,~]=coder.const(@fileparts,obj.MatFile);
    end

    obj.NetworkName=netName;

end
