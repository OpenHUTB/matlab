classdef SFunMkCfgEmitter<legacycode.lct.gen.MkCfgEmitter



    methods
        function this=SFunMkCfgEmitter(lctObjs)
            this@legacycode.lct.gen.MkCfgEmitter(lctObjs);
        end



        function emit(this,~)

            narginchk(1,1);

            lctObjs=this.LctObjs;

            for i=1:length(lctObjs)


                this.EmittingLctObjs=lctObjs(i);


                this.EmittingFileName=sprintf('%s_%s.m',this.EmittingLctObjs.SFunctionName,'makecfg');
                outWriter=legacycode.lct.gen.BufferedFileWriter(this.EmittingFileName);

                emit@legacycode.lct.gen.MkCfgEmitter(this,outWriter);
            end
        end
    end

    methods(Access=protected)




        function emitBody(this,codeWriter)
            this.emitBuildInfoCalculation(codeWriter,'info','');
        end

        function emitBodyEnd(this,codeWriter)

            bodyTxt={...
            '',...
            '% Additional include directories',...
            'addIncludePaths(BuildInfo, correct_path_name(allIncPaths));',...
            '',...
            '% Additional source directories',...
            'addSourcePaths(BuildInfo,  correct_path_name(allSrcPaths));',...
''...
            };
            codeWriter.writeCellLines(bodyTxt);

            if this.EmittingObjsIsSingleCPPMexFile
                bodyTxt={...
                '% Additional sources ',...
                'addSourceFiles(BuildInfo,  info.SourceFiles);',...
''...
                };
                codeWriter.writeCellLines(bodyTxt);
            end

            if this.EmittingObjsHasLibs



                if~isempty(this.EmittingLctObjs.Options.LibGroup)
                    group_name='lib_group';
                    if numel(this.EmittingLctObjs.Options.LibGroup)>1
                        group_value=...
                        ['{',sprintf(' ''%s'' ',this.EmittingLctObjs.Options.LibGroup{:}),'}'];
                    else
                        group_value=sprintf('''%s''',this.EmittingLctObjs.Options.LibGroup{1});
                    end
                else
                    group_name='sfcn_group';
                    group_value='''Sfcn''';
                end

                bodyTxt={...
                'linkLibsObjs     = {};',...
                'sfcnLibMods      = {};',...
                'sfcnLibModsPaths = {};',...
                'numSfcnLibMods   = 0;',...
                sprintf('%s = %s;',group_name,group_value),...
                '',...
                'linkLibsObjs    = [ linkLibsObjs  correct_path_name(allLibs)];',...
                '',...
                'for i=1:length(linkLibsObjs)',...
                '    numSfcnLibMods = numSfcnLibMods + 1;',...
                '    [sfcnLibModsPaths{numSfcnLibMods},libName,libExt] = fileparts(linkLibsObjs{i});',...
                '',...
                '    sfcnLibMods{numSfcnLibMods} = [libName libExt];',...
                'end',...
                '',...
                'if ~isempty(sfcnLibMods)',...
                '    % add them to the BuildInfo object.  note that these are all considered not',...
                '    % precompiled and are link only',...
                '    addLibraries(BuildInfo, sfcnLibMods, sfcnLibModsPaths,...',...
                sprintf('                           [], false, true, %s);',group_name),...
                '',...
                'end',...
''...
                };
                codeWriter.writeCellLines(bodyTxt);
            end


        end





        function emitHeader(this,codeWriter)
            [~,functionName]=fileparts(this.EmittingFileName);

            headerText=[...
'function %s(BuildInfo)\n'...
            ,'%%%s adds include and source directories to the BuildInfo object.\n'...
            ];


            codeWriter.wLine(headerText,functionName,upper(functionName));


            slVer=legacycode.lct.spec.Common.SLVer;
            thisDate=datestr(now,0);

            codeWriter.wComment(sprintf('   Simulink version    : %s %s %s',slVer.Version,slVer.Release,slVer.Date));
            codeWriter.wComment(sprintf('   MATLAB file generated on : %s',thisDate));
        end

    end
end


