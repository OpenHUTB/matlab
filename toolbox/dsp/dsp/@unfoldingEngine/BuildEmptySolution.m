function BuildEmptySolution(obj,bc)%#ok<INUSD>



    try
        clear([obj.data.mname,'_empty']);

        GenerateEmptyMexFile(obj);

        mex_line=['mex '...
        ,[fullfile(obj.data.workdirectory,[obj.data.tempname,'_empty_mex.c']),' ']...
        ,[fullfile(obj.data.workdirectory,'codegen',[obj.data.tempname,'original'],'interface',['_coder_',obj.data.fname,'_mex.c']),' ']...
        ,[fullfile(obj.data.workdirectory,'codegen',[obj.data.tempname,'original'],'interface',['_coder_',obj.data.fname,'_api.c']),' ']...
        ,'-l',obj.data.tempname,'original -lemlrt '...
        ,['-L"',fullfile(obj.data.workdirectory,'codegen',[obj.data.tempname,'original']),'" ']...
        ,['-I"',fullfile(obj.data.workdirectory,'codegen',[obj.data.tempname,'original']),'" ']...
        ,obj.data.includes...
        ,['-output ',fullfile(obj.data.workdirectory,[obj.data.tempname,'_empty ']),' ']...
        ];

        if(obj.Debugging)
            eval(mex_line);
        else
            evalc(mex_line);
        end

    catch err %#ok<NASGU>
        coder.internal.error('dsp:dspunfold:ErrorBuildEmpty');
    end





