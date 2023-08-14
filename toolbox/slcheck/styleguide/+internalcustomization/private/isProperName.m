

function errStr=isProperName(name,varargin)



    errStr={};
    oknumchars='0123456789';
    okchars=[oknumchars,'ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz'];
    blockNameCheck=false;



    if~isempty(varargin)
        blockNameCheck=varargin{1};
    end

    if~isempty(name)

        if~isempty(strfind(oknumchars,name(1)))
            errStr='isProperNameFailStartsWithNumber';
        elseif blockNameCheck


            cr=sprintf('\n');
            lf=sprintf('\r');
            okcharsBlock=[okchars,' ',cr,lf];

            if name(1)==' '
                errStr='isProperNameFailStartsWithSpace';

            elseif~isempty(setdiff(name,okcharsBlock))
                errStr='isProperNameFailIllegalChars';
            end
        else



            if~isempty(strfind(name,'__'))
                errStr='isProperNameFailMultipleUnderscores';




            elseif~isempty(setdiff(name,okchars))
                errStr='isProperNameFailIllegalChars';

            else

                if name(1)=='_'
                    errStr='isProperNameFailStartsWithUnderscore';


                elseif name(end)=='_'
                    errStr='isProperNameFailEndsWithUnderscore';

                end
            end
        end
    end