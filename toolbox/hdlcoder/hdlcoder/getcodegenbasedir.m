function codegendir=getcodegenbasedir(mdlName,snn,targetdir,targetsubdir)



    if(ischar(targetsubdir))
        if(strcmpi(targetsubdir,'none'))
            targetsubdir=1;
        elseif(strcmpi(targetsubdir,'model'))
            targetsubdir=2;
        elseif(strcmpi(targetsubdir,'model_dut'))
            targetsubdir=3;
        else
            assert(0);
        end
    end

    switch targetsubdir
    case 1
        codegendir=targetdir;
    case 2
        codegendir=fullfile(targetdir,mdlName);
    otherwise
        if strcmp(mdlName,snn)
            model_dut=mdlName;
        else
            [~,dutName]=getmodelnodename(mdlName,snn);
            model_dut=sprintf('%s_%s',mdlName,dutName);
        end
        codegendir=fullfile(targetdir,model_dut);
    end
end
