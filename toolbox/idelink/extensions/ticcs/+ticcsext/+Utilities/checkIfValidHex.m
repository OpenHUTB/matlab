function checkIfValidHex(h,opt)






    narginchk(1,2);
    if nargin==1
        opt='address';
    end

    if ischar(h)
        CheckElement(h,opt);
    else
        for i=1:length(h)
            CheckElement(h{i},opt);
        end
    end


    function CheckElement(h,opt)
        h=upper(h);
        if any(any(~((h>='0'&h<='9')|(h>='A'&h<='F'))))
            if strcmp(opt,'address')

                error(message('TICCSEXT:util:InvalidHexAddress'));
            else
                error(message('TICCSEXT:util:IllegalHexCharacters'));
            end
        end


