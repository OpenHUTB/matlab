function content=getAuxiliaryMakefileContent(lConfigSet)




    assemblyFlags=i_getAssemblyFlagsContent(lConfigSet);
    targetTokens=i_getTargetTokensContent(lConfigSet);
    stackSize=i_getStackSizeContent(lConfigSet);

    content=sprintf('%s%s%s',...
    assemblyFlags,targetTokens,stackSize);


    function content=i_getAssemblyFlagsContent(hCS)

        attribInfo=codertarget.attributes.getTargetHardwareAttributes(hCS);
        toolchain=get_param(hCS,'Toolchain');
        os=codertarget.targethardware.getTargetRTOS(hCS);
        assemblyFlags=attribInfo.getAssemblyFlags('toolchain',toolchain,'os',os);
        content=sprintf('ASFLAGS_ADDITIONAL = %s\n',assemblyFlags);


        function content=i_getTargetTokensContent(hCS)
            attribInfo=codertarget.attributes.getTargetHardwareAttributes(hCS);
            hwInfo=codertarget.targethardware.getHardwareConfiguration(hCS);
            targetFolder=codertarget.target.getTargetFolder(hCS);
            toolsInfoFileName=codertarget.target.getThirdPartyToolsRegistrationFileName(targetFolder);
            content='';
            if exist(toolsInfoFileName,'file')
                thirdPartyToolsInfo=codertarget.thirdpartytools.ThirdPartyToolInfo(toolsInfoFileName);
                thirdPartyTools=thirdPartyToolsInfo.getThirdPartyTools;
                for i=1:numel(thirdPartyTools)
                    if ispc




                        folder=coder.make.internal.transformPaths(thirdPartyTools{i}{:}.RootFolder,...
                        'pathType','alternate','ignoreErrors',true);
                        folder=strrep(folder,'\','/');
                    else
                        folder=thirdPartyTools{i}{:}.RootFolder;
                    end
                    content=sprintf('%s%s = %s\n',content,...
                    thirdPartyTools{i}{:}.TokenName,folder);
                end
            end
            content=sprintf('%sTARGET_LOAD_CMD = %s\n',...
            content,...
            i_getLoadCmdForSelectedToolChain(hCS,attribInfo,hwInfo));
            content=sprintf('%sTARGET_LOAD_CMD_ARGS = %s\n',...
            content,...
            i_getLoadCmdArgsForSelectedToolChain(hCS,attribInfo,hwInfo));
            if ispc
                pkgInstallDir=coder.make.internal.transformPaths(targetFolder,'pathType','alternate');
                pkgInstallDir=strrep(pkgInstallDir,'\','/');
            else
                pkgInstallDir=targetFolder;
            end
            content=sprintf('%sTARGET_PKG_INSTALLDIR = %s\n',...
            content,pkgInstallDir);



            function content=i_getStackSizeContent(hCS)
                stackSize=get_param(hCS,'MaxStackSize');
                content=sprintf('STACK_SIZE = %s\n',stackSize);



                function cmd=i_getLoadCmdForSelectedToolChain(hCS,attribInfo,hwInfo)
                    cmd='';
                    data=codertarget.data.getData(hCS);
                    selectedToolchain=get_param(hCS,'Toolchain');
                    idx=ismember({hwInfo.ToolChainInfo(:).Name},selectedToolchain);
                    if~isempty(idx)&&any(idx)
                        tcLoadCmd=codertarget.utils.replaceTokens(hCS,...
                        hwInfo.ToolChainInfo(idx).LoadCommand,attribInfo.Tokens);
                        if isfield(data,'Runtime')&&~strcmpi(tcLoadCmd,'dummy')...
                            &&~hwInfo.ToolChainInfo(idx).IsLoadCommandMATLABFcn
                            cmd=['"',tcLoadCmd,'"'];
                        end
                    end



                    function cmd=i_getLoadCmdArgsForSelectedToolChain(hCS,attribInfo,hwInfo)
                        data=codertarget.data.getData(hCS);
                        selectedToolchain=get_param(hCS,'Toolchain');
                        idx=ismember({hwInfo.ToolChainInfo(:).Name},selectedToolchain);
                        if~isempty(idx)&&any(idx)&&...
                            ~hwInfo.ToolChainInfo(idx).IsLoadCommandMATLABFcn
                            cmd=codertarget.utils.replaceTokens(...
                            hCS,hwInfo.ToolChainInfo(idx).LoadCommandArgs,attribInfo.Tokens);
                            if isfield(data,'Runtime')&&isfield(data.Runtime,'LoadCommandArg')
                                data=codertarget.data.getParameterValue(hCS,'Runtime.LoadCommandArg');
                                cmdEnd=codertarget.utils.replaceTokens(hCS,data,attribInfo.Tokens);
                                if ispc
                                    cmd=coder.make.internal.transformPaths(cmd,'pathType','alternate');
                                    cmdEnd=coder.make.internal.transformPaths(cmdEnd,'pathType','alternate');
                                end
                                cmd=[cmd,' ',cmdEnd];
                            end
                        else
                            cmd='';
                        end
