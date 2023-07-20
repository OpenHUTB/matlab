function checksum=md5(varargin)



    raw=lower(dec2hex(CGXE.Utils.md5(varargin{:}),8));
    checksum=reshape(raw(:,[7:8,5:6,3:4,1:2])',1,[]);
end