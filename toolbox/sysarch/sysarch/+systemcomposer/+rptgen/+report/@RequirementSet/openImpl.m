function result=openImpl(reporter,impl,varargin)
    if isempty(varargin)
        key=['E2CxpMS0BgVPzNGaF6zwy0bsO7fAPCOoaMb7bV/qNzbC4540sv7t8jgmMDMe'...
        ,'JkA9uIGTt22IrJyfqmQ2Ye2O4M8aSji2HilMv8tvAC0HIT5FCKkd4B2Us2SY'...
        ,'1P5XlZ2XSuG3kAw6Iz1Wn7oWrCguwqBo9Yv/QZFtwL5WbGIjgqs8LzYWcxqL'...
        ,'hHRxZwcJoAiQHNnoncnt6ISQo/uDHtULVZ+GKTKy/NYv40WzjCd6/+sqGun6'...
        ,'sY1ys8YR+Nm/SQeSCupbJ7X4gzu+wK1TfCD+wEZWtkB7lPoXMyERPfJRKGLM'...
        ,'vJpvjKFJtix6LaattjpC'];
    else
        key=varargin{1};
    end
    result=open(impl,key,reporter);
end