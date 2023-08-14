function ret=updateBuildInfo(ModelName,IsrName)




    if nargin<2
        IsrName=[];
    end
    ret=true;
    buildInfo=codertarget.interrupts.internal.getModelBuildInfo(ModelName);
    if~isempty(buildInfo)
        try
            hCS=getActiveConfigSet(ModelName);
            intdef=codertarget.interrupts.internal.getHardwareBoardInterruptInfo(ModelName);
            if isempty(IsrName)
                bcs=getBuildConfigurationInfo(intdef,'toolchain',get_param(ModelName,'Toolchain'));
            else
                irqgrp=getInterruptGroupBasedOnInterruptName(intdef,IsrName);
                bcs=getBuildConfigurationInfo(irqgrp,'toolchain',get_param(ModelName,'Toolchain'));
            end

            GROUP='SkipForSil';

            for k=1:numel(bcs)
                bc=bcs(k);
                info=codertarget.attributes.getTargetHardwareAttributes(hCS);
                tokens=info.Tokens;

                if~isempty(bc.CompileFlags)
                    CFlags=codertarget.utils.replaceTokens(hCS,bc.CompileFlags,tokens);
                    addCompileFlags(buildInfo,CFlags,GROUP);
                end

                if~isempty(bc.CPPCompileFlags)
                    CPPFlags=codertarget.utils.replaceTokens(hCS,bc.CPPCompileFlags,tokens);
                    addCompileFlags(buildInfo,CPPFlags,GROUP);
                end

                if~isempty(bc.LinkFlags)
                    LFlags=codertarget.utils.replaceTokens(hCS,bc.LinkFlags,tokens);
                    addLinkFlags(buildInfo,LFlags,GROUP);
                end
                if~isempty(bc.CPPLinkFlags)
                    LFlags=codertarget.utils.replaceTokens(hCS,bc.CPPLinkFlags,tokens);
                    addLinkFlags(buildInfo,LFlags,GROUP);
                end

                if~isempty(bc.LinkObjects)
                    for j=1:length(bc.LinkObjects)
                        if isstruct(bc.LinkObjects{j})
                            name=codertarget.utils.replaceTokens(hCS,bc.LinkObjects{j}.Name,tokens);
                            name=codertarget.utils.replacePathSep(name);
                            path=codertarget.utils.replaceTokens(hCS,bc.LinkObjects{j}.Path,tokens);
                            path=codertarget.utils.replacePathSep(path);
                        else
                            linkObj=codertarget.utils.replaceTokens(hCS,bc.LinkObjects{j},tokens);
                            linkObj=codertarget.utils.replacePathSep(linkObj);
                            [path,name,ext]=fileparts(linkObj);
                            name=[name,ext];%#ok<AGROW>
                        end
                        addLinkObjects(buildInfo,name,path,1000,true,true,GROUP);
                    end
                end

                if~isempty(bc.Defines)
                    addDefines(buildInfo,bc.Defines,GROUP);
                end

                if~isempty(bc.IncludePaths)
                    IPaths=codertarget.utils.replaceTokens(hCS,bc.IncludePaths,tokens);
                    IPaths=codertarget.utils.replacePathSep(IPaths);
                    for j=1:length(IPaths)
                        addIncludePaths(buildInfo,IPaths{j},GROUP);
                    end
                end

                for j=1:length(bc.SourceFiles)
                    [pathstr,name,ext]=fileparts(bc.SourceFiles{j});
                    pathstr=codertarget.utils.replaceTokens(hCS,pathstr,tokens);
                    pathstr=codertarget.utils.replacePathSep(pathstr);
                    addSourceFiles(buildInfo,[name,ext],pathstr,'SkipForInTheLoop');
                end
            end
        catch
            ret=false;
        end
    end

end


