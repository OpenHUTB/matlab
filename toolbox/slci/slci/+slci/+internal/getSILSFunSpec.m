function def=getSILSFunSpec(name,varargin)




    if nargin==1
        def=[];
    else
        def='';
    end


    path=dir(['./xrel/',name,'.tlc']);
    file=[path.folder,'/',path.name];

    fid=fopen(file,'r');
    if(fid==0)
        return
    end

    line='0';
    inDef=false;
    while(line~=-1)
        line=fgets(fid);

        if inDef
            if contains(line,'%%%-MATLAB_Construction_Commands_End')...
                ||(~contains(line,'def =')&&~contains(line,'def.'))
                if nargin~=1
                    field=varargin{1};
                    def=def.(field);
                end
                break;
            end

        else
            if contains(line,'%%%-MATLAB_Construction_Commands_Start')
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



    if isa(def,'struct')
        [def.Options(:).stubSimBehavior]=true;
    end

end
