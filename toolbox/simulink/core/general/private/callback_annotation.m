function cba=callback_annotation(varargin)



    persistent callbackAnnotation;
    if(nargin>0)
        cba=callbackAnnotation;
        callbackAnnotation=varargin{1};
    else
        cba=callbackAnnotation;
    end
