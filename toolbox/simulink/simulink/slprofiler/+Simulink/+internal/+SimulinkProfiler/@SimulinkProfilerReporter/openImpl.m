function result=openImpl(reporter,impl,varargin)
    if isempty(varargin)
        key=['E2C548z0ABVPjL9jqtmJW7GQsuI2f9ARbB4iUHEOnkVeq7UdcYB8YwP9d1HX'...
        ,'wUfYFjQRVAAmm2ArpQALzsMFeL/d43fGufaixAilRv/xlRzjE6AU7M9FWCBH'...
        ,'/Or0PyhsYP8tW9Vsi6x9keGaK7t3ew8+O7eC/Kx2Mec66nv/iqGID9DjyFaE'...
        ,'l2NWI76Q7y7C+zN8lWlhX6rupjWsK77R'];
    else
        key=varargin{1};
    end
    result=open(impl,key,reporter);
end