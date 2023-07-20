



classdef SldvInstrumInfoWriter<handle
    properties
SettingsChecksum
CustomCodeSettings
    end

    methods(Access=public)
        function obj=SldvInstrumInfoWriter(settingsChecksum,customCodeSettings)
            obj.SettingsChecksum=settingsChecksum;
            obj.CustomCodeSettings=customCodeSettings;
        end

        function suffix=getInstrumSuffix(obj)
            suffix=obj.SettingsChecksum;
        end




        function updateTraceabilityDb(obj,dbFile,buildOptions,instrumentedFiles,workingDir)
            db=sldv.code.slcc.internal.TraceabilityDb(dbFile);
            numSources=numel(buildOptions.Sources);
            if numSources==numel(instrumentedFiles)
                db.beginTransaction();
                for ii=1:numSources
                    instrumentedFile=instrumentedFiles{ii};
                    srcFile=buildOptions.Sources{ii};
                    if~isempty(instrumentedFile)
                        fid=fopen(instrumentedFile,'r','n','utf-8');
                        if fid>=3
                            content=fread(fid,'*char');
                            fclose(fid);

                            db.setInstrumentedContent(srcFile,content);
                        end
                    end
                end

                obj.addWrapperFile(workingDir,db);

                db.commitTransaction();
            end
        end
    end

    methods(Access=private)
        function addWrapperFile(obj,workingDir,db)
            [wrapperContent,wrapperName]=obj.generateWrapperContent(workingDir);
            if~isempty(wrapperContent)
                f=db.insertFile(wrapperName,...
                internal.cxxfe.instrum.FileKind.SOURCE,...
                internal.cxxfe.instrum.FileStatus.INTERNAL);

                f.instrumentedContents=wrapperContent;
            end
        end

        function[wrapperContent,wrapperFile]=generateWrapperContent(obj,workingDir)

            wrapperText=sprintf(['#include "mex.h"\n',...
            '#include <string.h>\n',...
            '#include <stdlib.h>\n',...
            '#include <math.h>\n',...
            '#ifndef RTWTYPES_H\n',...
            '#define RTWTYPES_H\n',...
            '#include "tmwtypes.h"\n',...
            '#endif\n\n',...
            '%s\n\n'],obj.CustomCodeSettings.customCode);
            if obj.CustomCodeSettings.isCpp
                lang='C++';
                ext='.cpp';
            else
                lang='C';
                ext='.c';
            end
            feOptions=CGXE.CustomCode.getFrontEndOptions(lang,...
            obj.CustomCodeSettings.userIncludeDirs,...
            obj.CustomCodeSettings.customUserDefines);
            wrapperName=sprintf('wrapper_%s%s',obj.SettingsChecksum,ext);
            wrapperFile=fullfile(workingDir,wrapperName);
            feOptions.DoGenOutput=true;
            feOptions.GenOutput=wrapperFile;

            msgs=internal.cxxfe.FrontEnd.parseText(wrapperText,feOptions);%#ok;
            fid=fopen(wrapperFile,'r','n','utf-8');
            if fid<0










                errorMessages=evalc('internal.cxxfe.util.printFEMessages(msgs);');
                msg=message('sldv_sfcn:sldv_slcc:errorCompilingDesignVerifierInfo',errorMessages);
                warning('sldv_cc:errorCompilingDesignVerifierInfo',msg.getString());

                wrapperFile='';
                wrapperContent='';
            else
                wrapperContent=fread(fid,'*char');
                fclose(fid);
            end
        end
    end
end


