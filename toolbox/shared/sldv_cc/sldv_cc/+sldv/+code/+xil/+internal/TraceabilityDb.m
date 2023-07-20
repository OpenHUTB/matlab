



classdef TraceabilityDb<sldv.code.internal.TraceabilityDb

    methods



        function this=TraceabilityDb(varargin)
            this@sldv.code.internal.TraceabilityDb(varargin{:});
        end




        function feOpts=getFrontEndOptions(this)
            feOpts=[];
            files=this.getFilesInCurrentModule();
            for ii=1:numel(files)
                if files(ii).buildOptions.Size()~=0
                    feOpts2=files(ii).getFrontEndOptions();
                    if strcmp(feOpts2.Language.LanguageMode,'C++')||...
                        strcmp(feOpts2.Language.LanguageMode,'cxx')
                        feOpts=feOpts2;
                        break;
                    end
                    if isempty(feOpts)
                        feOpts=feOpts2;
                    end
                end
            end
            assert(~isempty(feOpts));
        end




        function instrumInfo=getInstrumInfo(this)

            try

                instrumInfo.instrFileExtPrefix=this.getConfigurationParameter('InstrFileExtPrefix');

                instrumInfo.InstrumentationSubFolder=this.getConfigurationParameter('InstrSubFolder');
                instrumInfo.hookChecksum=this.getConfigurationParameter('HookChecksum');
                instrumInfo.isSIL=sscanf(this.getConfigurationParameter('IsSilBuild'),'%d');
                instrumInfo.isTopXIL=sscanf(this.getConfigurationParameter('IsTopModelXil'),'%d');
                instrumInfo.instrVarRadix=this.getConfigurationParameter('InstrVarRadix');
                instrumInfo.instrFcnRadix=this.getConfigurationParameter('InstrFcnRadix');
            catch
                instrumInfo=[];
            end
        end




        function compilerInfo=getCompilerInfo(this,feOpts)
            if nargin<2
                feOpts=this.getFrontEndOptions();
            end
            compilerInfo=sldv.code.internal.getCompilerInfo(feOpts);
        end

    end
end


