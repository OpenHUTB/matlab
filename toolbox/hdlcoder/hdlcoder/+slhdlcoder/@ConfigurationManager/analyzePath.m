function[isValid,isGlobal,isHereOnly,isBlock,isCustomLibBlock,slPath]=...
    analyzePath(this,path)




























    isValid=1;
    isBlock=0;
    slPath=this.ModelName;
    isCustomLibBlock=0;
    isHereOnly=(path(end)=='?');
    isRealSL_block=false;


    if isHereOnly&&(length(path)>=2)
        slbk_path=[this.ModelName,path(2:end)];
        try
            slbh=get_param(slbk_path,'handle');
            if(~isempty(getfullname(slbh)))
                isHereOnly=true;
                isRealSL_block=true;
            end
        catch mEx %#ok<NASGU>

        end
    end

    if~isRealSL_block


        if isHereOnly
            path(end)='';
        end
    end


    path=this.relativePathToSLPath(path);

    if isempty(path)||strcmp(path,this.ModelName)
        isGlobal=1;
    else
        isGlobal=0;

        open_system(this.ModelName,'loadonly');
        if strncmp(this.ModelName,path,length(this.ModelName))
            try
                type=hdlgetblocklibpath(path);
                if~isempty(type)
                    isBlock=~strcmpi(type,'built-in/SubSystem');
                    isCustomLibBlock=~isempty(get_param(path,'ReferenceBlock'));
                    slPath=path;
                else
                    error(message('hdlcoder:engine:unexpectedobject',get_param(path,'Type')));
                end
            catch me %#ok<NASGU>
                isValid=0;
            end
        else


            isValid=1;
        end
    end
end


