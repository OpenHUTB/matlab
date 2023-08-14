classdef Helper




    methods(Static=true)




        function[minStr,maxStr]=getMinMaxStr(minVal,maxVal)
            minStr='min';
            maxStr='max';
            if~isempty(minVal)&&~isinf(minVal)&&~isnan(minVal)
                minStr=num2str(minVal);
            end
            if~isempty(maxVal)&&~isinf(maxVal)&&~isnan(maxVal)
                maxStr=num2str(maxVal);
            end

        end





        function str=makeStrList(cellOfStr)
            sep='';
            str='';
            for jj=1:numel(cellOfStr)
                if~isempty(cellOfStr{jj})
                    str=sprintf('%s%s%s',str,sep,cellOfStr{jj});
                    sep=',';
                end
            end
        end




        function sysDirInfo=getConfigDirInfo(arg1,coderID,codeGenFolder,pslinkOptions)
            if nargin<4
                pslinkOptions=[];
            end

            validateattributes(arg1,{'char'},{'row'},'getConfigDirInfo','arg1',1);
            if strcmpi(arg1,'-codegenfolder')
                if isempty(coderID)
                    coderID=pslink.verifier.codegen.Coder.CODER_ID;
                end
                validateattributes(codeGenFolder,{'char'},{'row'},'getConfigDirInfo','codeGenFolder',3);


                codegenID=pslink.verifier.codegen.Coder.getCodegenID(codeGenFolder);

            else

                modelName=get_param(bdroot(arg1),'Name');
                systemName=getfullname(arg1);


                if nargin<2||isempty(coderID)
                    coderID=pssharedprivate('getCoderID',systemName);
                    if isempty(coderID)


                        coderID=pslink.verifier.slcc.Coder.CODER_ID;
                    end
                end

            end

            isForEC=strcmpi(coderID,pslink.verifier.ec.Coder.CODER_ID);
            isForTL=strcmpi(coderID,pslink.verifier.tl.Coder.CODER_ID);
            isForCodegen=strcmpi(coderID,pslink.verifier.codegen.Coder.CODER_ID);
            isForSFcn=strcmpi(coderID,pslink.verifier.sfcn.Coder.CODER_ID);
            isForSlcc=strcmpi(coderID,pslink.verifier.slcc.Coder.CODER_ID);

            sysDirInfo=struct(...
            'CoderID',coderID,...
            'CodeGenFolder','',...
            'SystemCodeGenDir','',...
            'SystemCodeGenName','',...
            'ModelRefCodeGenDir','',...
            'SharedUtilsDir','',...
            'SystemConfigFileDir','',...
            'SystemConfigFileName','',...
            'SystemCxxeConfigFileName','',...
            'SystemCxxConfigFileName','',...
            'SystemConfigFileNameRadix','',...
            'SystemRelativeInfoDir','',...
            'SystemResultDirKey','',...
            'SystemResultFileDir','',...
            'SystemResultFileName','',...
            'AllSystemCodeGenInfo',[]...
            );

            resultRadix=[];
            if isForCodegen

                sysDirInfo.CodeGenFolder=pwd;
                sysDirInfo.SystemConfigFileNameRadix=codegenID;
            elseif isForSFcn
                if isempty(pslinkOptions)
                    pslinkOptions=pslink.Options(systemName);
                end
                resultRadix=pslink.verifier.sfcn.getSFcnId(pslinkOptions,systemName);

                sysDirInfo.SystemConfigFileNameRadix=modelName;
                sysDirInfo.CodeGenFolder=pwd;
            else
                if isForSlcc
                    if isempty(pslinkOptions)
                        pslinkOptions=pslink.Options(systemName);
                    end
                    slccId=pslink.verifier.slcc.getSlccId(pslinkOptions,systemName);
                    resultRadix=slccId;
                end


                mdlDirInfo=RTW.getBuildDir(modelName);
                if~isfield(mdlDirInfo,'CodeGenFolder')
                    if isfield(mdlDirInfo,'BuildDirectory')
                        codeGenFolder=fileparts(mdlDirInfo.BuildDirectory);
                    else
                        codeGenFolder=pwd;
                    end
                    sysDirInfo.CodeGenFolder=codeGenFolder;
                else
                    sysDirInfo.CodeGenFolder=mdlDirInfo.CodeGenFolder;
                end
                sysDirInfo.SystemConfigFileNameRadix=modelName;
                sysDirInfo.SharedUtilsDir=fullfile(sysDirInfo.CodeGenFolder,mdlDirInfo.SharedUtilsTgtDir);
            end


            sysDirInfo.SystemRelativeInfoDir='pslink_config';


            sysDirInfo.SystemConfigFileDir=fullfile(sysDirInfo.CodeGenFolder,sysDirInfo.SystemRelativeInfoDir);
            sysDirInfo.SystemConfigFileName=[sysDirInfo.SystemConfigFileNameRadix,'_config',pslink.util.Helper.getConfigFileExtension()];
            sysDirInfo.SystemCxxeConfigFileName=[sysDirInfo.SystemConfigFileNameRadix,'_cxxe_config',pslink.util.Helper.getConfigFileExtension()];
            sysDirInfo.SystemCxxConfigFileName=[sysDirInfo.SystemConfigFileNameRadix,'_cxx_config',pslink.util.Helper.getConfigFileExtension()];
            sysDirInfo.SystemResultFileDir=sysDirInfo.SystemConfigFileDir;
            if isempty(resultRadix)
                resultRadix=sysDirInfo.SystemConfigFileNameRadix;
            end
            sysDirInfo.SystemResultFileName=[resultRadix,'_results.mat'];

            codeGenDir='';
            codeGenName='';

            if isForEC
                if strcmp(systemName,modelName)
                    sysDirInfo.SystemResultDirKey=matlab.lang.makeValidName(mdlDirInfo.RelativeBuildDir);
                    sysDirInfo.AllSystemCodeGenInfo={mdlDirInfo.BuildDirectory,modelName};
                    sysDirInfo.SystemCodeGenDir=mdlDirInfo.BuildDirectory;
                    sysDirInfo.SystemCodeGenName=modelName;
                    sysDirInfo.ModelRefCodeGenDir=fullfile(sysDirInfo.CodeGenFolder,mdlDirInfo.ModelRefRelativeBuildDir);
                else

                    sysDirInfo.AllSystemCodeGenInfo=pslink.verifier.ec.Coder.getCodeGenerationDir(systemName);
                    if~isempty(sysDirInfo.AllSystemCodeGenInfo)
                        codeGenDir=sysDirInfo.AllSystemCodeGenInfo{1,1};
                        codeGenName=sysDirInfo.AllSystemCodeGenInfo{1,2};
                    end
                    sysDirInfo.SystemCodeGenDir=codeGenDir;
                    sysDirInfo.SystemCodeGenName=codeGenName;
                    sysDirInfo.SystemResultDirKey=[codeGenName,mdlDirInfo.BuildDirSuffix];
                    sysDirInfo.ModelRefCodeGenDir=fullfile(sysDirInfo.CodeGenFolder,...
                    strrep(mdlDirInfo.ModelRefRelativeBuildDir,modelName,codeGenName));
                end

            elseif isForTL
                if~strcmp(systemName,modelName)
                    sysDirInfo.AllSystemCodeGenInfo=pslink.verifier.tl.Coder.getCodeGenerationDir(systemName);
                    if~isempty(sysDirInfo.AllSystemCodeGenInfo)
                        codeGenDir=sysDirInfo.AllSystemCodeGenInfo{1,1};
                        codeGenName=sysDirInfo.AllSystemCodeGenInfo{1,2};
                    end
                    sysDirInfo.SystemCodeGenDir=codeGenDir;
                    sysDirInfo.SystemCodeGenName=codeGenName;
                    sysDirInfo.SystemResultDirKey=codeGenName;
                end

            elseif isForCodegen
                sysDirInfo.SystemCodeGenDir=codeGenFolder;
                sysDirInfo.SystemCodeGenName=codegenID;
                sysDirInfo.SystemResultDirKey=codegenID;
            elseif isForSFcn
                sfcnName=get_param(systemName,'FunctionName');

                sysDirInfo.SystemCodeGenName=sfcnName;
                sysDirInfo.SystemResultDirKey=sfcnName;
                sysDirInfo.SystemCodeGenDir='';
            elseif isForSlcc
                sysDirInfo.SystemCodeGenName=slccId;
                sysDirInfo.SystemResultDirKey=slccId;
                sysDirInfo.SystemCodeGenDir='';
            else
                return
            end
        end




        function ret=isLinux()
            persistent lnxOS;
            if isempty(lnxOS)
                lnxOS=~isempty(strfind(computer('arch'),'glnx'));
            end
            ret=lnxOS;
        end




        function ret=isWindows()
            persistent winOS;
            if isempty(winOS)
                winOS=~isempty(strfind(computer('arch'),'win'));
            end
            ret=winOS;
        end




        function ret=isProverAvailable()
            persistent proverLicence;
            if isempty(proverLicence)
                proverLicence=pssharedprivate('isPslinkAvailable')...
                &&(pslinkprivate('checkProducts','PolySpace_Server_C_CPP')...
                ||pslinkprivate('checkProducts','Distrib_Computing_Toolbox'));
            end
            ret=proverLicence;
        end




        function preferenceValue=getPvePreference(prefStr)
            preferenceValue=polyspace.Utils.getPvePreference(prefStr);
        end




        function modelLang=getModelLang(systemName)
            modelName=get_param(bdroot(systemName),'Name');
            confSet=getActiveConfigSet(modelName);
            modelLang=confSet.getProp('TargetLang');



            if confSet.hasProp('CodeInterfacePackaging')
                codeInterface=confSet.getProp('CodeInterfacePackaging');
                if strcmpi(modelLang,'C++')&&strcmpi(codeInterface,'C++ class')
                    modelLang='C++ (Encapsulated)';
                end
            end
        end




        function configExt=getConfigFileExtension()
            configExt='.psprj';
        end

    end

end



