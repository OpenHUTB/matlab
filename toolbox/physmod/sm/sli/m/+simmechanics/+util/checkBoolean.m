function propValue=checkBoolean(propName,propValue,varargin)









    retBool=false;
    if nargin==3
        retBool=varargin{1};
    end

    switch(lower(propValue))
    case 'on'
        propValue=true;
    case 'off'
        propValue=false;
    case 1
        propValue=true;
    case 0
        propValue=false;
    otherwise
        pm_error('sm:util:checkboolean:InvalidBooleanValue',propName,'''on'',''off'',1,0,true,false');
    end

    if~retBool
        if propValue
            propValue='on';
        else
            propValue='off';
        end
    end

end


