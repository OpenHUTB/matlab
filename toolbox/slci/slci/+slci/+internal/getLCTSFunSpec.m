function def=getLCTSFunSpec(name,varargin)


    if nargin==1
        def=[];
    else
        def='';
    end

    file=which([name,'.c']);
    if(isempty(file))
        file=which([name,'.cpp']);
        if(isempty(file))
            return
        end
    end

    fid=fopen(file,'r');
    if(fid==0)
        return
    end

    line='0';
    inDef=false;
    while(line~=-1)
        line=fgets(fid);

        if inDef
            index1=strfind(line,'%%%-MATLAB_Construction_Commands_End');
            index2=strfind(line,'def =');
            index3=strfind(line,'def.');
            if~isempty(index1)||(isempty(index2)&&isempty(index3))
                if nargin==1
                    fclose(fid);
                    return
                else
                    field=varargin{1};
                    def=def.(field);
                    fclose(fid);
                    return
                end
            end

        else
            index=strfind(line,'%%%-MATLAB_Construction_Commands_Start');
            if~isempty(index)
                inDef=true;
            end
            continue
        end

        if inDef
            try
                eval(line)
            catch ME %#ok
                break
            end
        end
    end

    fclose(fid);

end
