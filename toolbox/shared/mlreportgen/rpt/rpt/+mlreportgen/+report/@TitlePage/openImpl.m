function result=openImpl(reporter,impl,varargin)
    if isempty(varargin)
        key=['E2CxpMSUAQVTzNGaqxm3b+ygFBLlRQPuhG3BZ33AXLD1J7uUCvh+HH5ct6E7'...
        ,'lwVPBMqJdxxFzfxQb/mZnfmVR9RY6BDG+T4cjNWBFOVigXep8bQVuLIQKQZ4'...
        ,'wOrI9v9O6Oi0J+KAOWJdIqn03bTcOsr34BBSaOPShEV6jc+8nTt8ZxUhVx/W'...
        ,'3puuvIV8k8lXbq2jAdbNWj9PJvpL8g6GT7w85obp1FGnPyZQwitrFu1WVVzd'...
        ,'9ZThpegNXsEYsxo5NqrgtejMtgwfssBsVJ6mYAO2K4ucV0FU65JgeeHLF9w='];
    else
        key=varargin{1};
    end
    result=open(impl,key,reporter);
end