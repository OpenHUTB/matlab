function uniquename=hdluniquename(Name,initialize)






    if nargin==1
        initialize=0;
    end

    if initialize
        getIncPostfix('',initialize);
        uniquename='';
    else
        uniquename=sprintf('%s%d',Name,getIncPostfix(Name,initialize));
    end




    function incr=getIncPostfix(Name,initialize)

        mlock;

        persistent hdlDataBase;

        if isempty(hdlDataBase)
            hdlDataBase=[];
        end

        if initialize
            hdlDataBase=[];
            incr=0;
        else
            if isempty(hdlDataBase)
                hdlDataBase(1).Name=Name;
                hdlDataBase(1).Incr=0;
                incr=0;
            else
                nameFound=false;
                for loop=1:length(hdlDataBase)
                    if strcmp(hdlDataBase(loop).Name,Name)
                        incr=hdlDataBase(loop).Incr+1;
                        hdlDataBase(loop).Incr=incr;
                        nameFound=true;
                        break;
                    end
                end

                if~nameFound
                    hdlDataBase(length(hdlDataBase)+1).Name=Name;
                    hdlDataBase(length(hdlDataBase)).Incr=0;
                    incr=0;
                end
            end
        end




