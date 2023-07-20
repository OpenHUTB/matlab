



function extraOpts=compilerWorkArounds(outDir,options,isCxx)
    extraOpts={};
    ver=iCompilerVersion(options);


    needMacroWorkarounds=ismac||(ispc&&ver.visual>=1700)||ver.mingw>0||ver.gnu>0;

    if needMacroWorkarounds
        txtFile=[fullfile(outDir,'__tmw_ignored_macros'),'.txt'];
        fid=fopen(txtFile,'wt');
        if fid<0
            return
        end
        clrObj=onCleanup(@()fclose(fid));











        fprintf(fid,'isnan    def_otf:isnan(x)=__builtin_mw_isnan(x)       system\n');
        fprintf(fid,'isinf    def_otf:isinf(x)=__builtin_mw_isinf(x)       system\n');
        fprintf(fid,'isfinite def_otf:isfinite(x)=__builtin_mw_isfinite(x) system\n');
        fprintf(fid,'isnormal def_otf:isnormal(x)=__builtin_mw_isnormal(x) system\n');
        fprintf(fid,'signbit  def_otf:signbit(x)=__builtin_mw_signbit(x)   system\n');
        fprintf(fid,'log2     def_otf:log2(x)=__builtin_mw_log2(x)         system\n');
        fprintf(fid,'log1p    def_otf:log1p(x)=__builtin_mw_log1p(x)       system\n');
        fprintf(fid,'logb     def_otf:logb(x)=__builtin_mw_logb(x)         system\n');
        fprintf(fid,'expm1    def_otf:expm1(x)=__builtin_mw_expm1(x)       system\n');

        if~isCxx






















            fprintf(fid,'acosl      def_otf:acosl(x)=__builtin_mw_acosl(x)              system\n');
            fprintf(fid,'asinl      def_otf:asinl(x)=__builtin_mw_asinl(x)              system\n');
            fprintf(fid,'atanl      def_otf:atanl(x)=__builtin_mw_atanl(x)              system\n');
            fprintf(fid,'atan2l     def_otf:atan2l(x,y)=__builtin_mw_atan2l(x,y)        system\n');
            fprintf(fid,'ceill      def_otf:ceill(x)=__builtin_mw_ceill(x)              system\n');
            fprintf(fid,'cosl       def_otf:cosl(x)=__builtin_mw_cosl(x)                system\n');
            fprintf(fid,'coshl      def_otf:coshl(x)=__builtin_mw_coshl(x)              system\n');
            fprintf(fid,'expl       def_otf:expl(x)=__builtin_mw_expl(x)                system\n');
            fprintf(fid,'fabsl      def_otf:fabsl(x)=__builtin_mw_fabsl(x)              system\n');
            fprintf(fid,'floorl     def_otf:floorl(x)=__builtin_mw_floorl(x)            system\n');
            fprintf(fid,'fmodl      def_otf:fmodl(x,y)=__builtin_mw_fmodl(x,y)          system\n');
            fprintf(fid,'logl       def_otf:logl(x)=__builtin_mw_logl(x)                system\n');
            fprintf(fid,'log10l     def_otf:log10l(x)=__builtin_mw_log10l(x)            system\n');
            fprintf(fid,'modfl      def_otf:modfl(x,y)=__builtin_mw_modfl(x,y)          system\n');
            fprintf(fid,'powl       def_otf:powl(x,y)=__builtin_mw_powl(x,y)            system\n');
            fprintf(fid,'sinl       def_otf:sinl(x)=__builtin_mw_sinl(x)                system\n');
            fprintf(fid,'sinhl      def_otf:sinhl(x)=__builtin_mw_sinhl(x)              system\n');
            fprintf(fid,'sqrtl      def_otf:sqrtl(x)=__builtin_mw_sqrtl(x)              system\n');
            fprintf(fid,'tanl       def_otf:tanl(x)=__builtin_mw_tanl(x)                system\n');
            fprintf(fid,'tanhl      def_otf:tanhl(x)=__builtin_mw_tanhl(x)              system\n');
            fprintf(fid,'_chgsignl  def_otf:_chgsignl(x)=__builtin_mw_chgsignl(x)       system\n');
            fprintf(fid,'_copysignl def_otf:_copysignl(x,y)=__builtin_mw_copysignl(x,y) system\n');

            fprintf(fid,'acosf      def_otf:acosf(x)=__builtin_mw_acosf(x)              system\n');
            fprintf(fid,'asinf      def_otf:asinf(x)=__builtin_mw_asinf(x)              system\n');
            fprintf(fid,'atanf      def_otf:atanf(x)=__builtin_mw_atanf(x)              system\n');
            fprintf(fid,'atan2f     def_otf:atan2f(x,y)=__builtin_mw_atan2f(x,y)        system\n');
            fprintf(fid,'ceilf      def_otf:ceilf(x)=__builtin_mw_ceilf(x)              system\n');
            fprintf(fid,'cosf       def_otf:cosf(x)=__builtin_mw_cosf(x)                system\n');
            fprintf(fid,'coshf      def_otf:coshf(x)=__builtin_mw_coshf(x)              system\n');
            fprintf(fid,'expf       def_otf:expf(x)=__builtin_mw_expf(x)                system\n');
            fprintf(fid,'fabsf      def_otf:fabsf(x)=__builtin_mw_fabsf(x)              system\n');
            fprintf(fid,'floorf     def_otf:floorf(x)=__builtin_mw_floorf(x)            system\n');
            fprintf(fid,'fmodf      def_otf:fmodf(x,y)=__builtin_mw_fmodf(x,y)          system\n');
            fprintf(fid,'logf       def_otf:logf(x)=__builtin_mw_logf(x)                system\n');
            fprintf(fid,'log10f     def_otf:log10f(x)=__builtin_mw_log10f(x)            system\n');
            fprintf(fid,'modff      def_otf:modff(x,y)=__builtin_mw_modff(x,y)          system\n');
            fprintf(fid,'powf       def_otf:powf(x,y)=__builtin_mw_powf(x,y)            system\n');
            fprintf(fid,'sinf       def_otf:sinf(x)=__builtin_mw_sinf(x)                system\n');
            fprintf(fid,'sinhf      def_otf:sinhf(x)=__builtin_mw_sinhf(x)              system\n');
            fprintf(fid,'sqrtf      def_otf:sqrtf(x)=__builtin_mw_sqrtf(x)              system\n');
            fprintf(fid,'tanf       def_otf:tanf(x)=__builtin_mw_tanf(x)                system\n');
            fprintf(fid,'tanhf      def_otf:tanhf(x)=__builtin_mw_tanhf(x)              system\n');




            fprintf(fid,'acoshl     def_otf:acoshl(x)=__builtin_mw_acoshl(x)            system\n');
            fprintf(fid,'asinhl     def_otf:asinhl(x)=__builtin_mw_asinhl(x)            system\n');
            fprintf(fid,'atanhl     def_otf:atanhl(x)=__builtin_mw_atanhl(x)            system\n');
            fprintf(fid,'acoshf     def_otf:acoshf(x)=__builtin_mw_acoshf(x)            system\n');
            fprintf(fid,'asinhf     def_otf:asinhf(x)=__builtin_mw_asinhf(x)            system\n');
            fprintf(fid,'atanhf     def_otf:atanhf(x)=__builtin_mw_atanhf(x)            system\n');

            fprintf(fid,'log2l      def_otf:log2l(x)=__builtin_mw_log2l(x)              system\n');
            fprintf(fid,'log2f      def_otf:log2f(x)=__builtin_mw_log2f(x)              system\n');
            fprintf(fid,'log1pl     def_otf:log1pl(x)=__builtin_mw_log1pl(x)            system\n');
            fprintf(fid,'log1pf     def_otf:log1pf(x)=__builtin_mw_log1pf(x)            system\n');
            fprintf(fid,'logbl      def_otf:logbl(x)=__builtin_mw_logbl(x)              system\n');
            fprintf(fid,'logbf      def_otf:logbf(x)=__builtin_mw_logbf(x)              system\n');
            fprintf(fid,'expm1l     def_otf:expm1l(x)=__builtin_mw_expm1l(x)            system\n');
            fprintf(fid,'expm1f     def_otf:expm1f(x)=__builtin_mw_expm1f(x)            system\n');

            fprintf(fid,'isnanl     def_otf:isnanl(x)=__builtin_mw_isnanl(x)            system\n');
            fprintf(fid,'isnanf     def_otf:isnanf(x)=__builtin_mw_isnanf(x)            system\n');
            fprintf(fid,'isinfl     def_otf:isinfl(x)=__builtin_mw_isinfl(x)            system\n');
            fprintf(fid,'isinff     def_otf:isinff(x)=__builtin_mw_isinff(x)            system\n');
            fprintf(fid,'isfinitel  def_otf:isfinitel(x)=__builtin_mw_isfinitel(x)      system\n');
            fprintf(fid,'isfinitef  def_otf:isfinitef(x)=__builtin_mw_isfinitef(x)      system\n');



            fprintf(fid,'fabs       def_otf:fabs(x)=__builtin_mw_fabs(x)                system\n');























        end


        extraOpts{end+1}='--sldv_code_analysis';
        extraOpts{end+1}='--set_flag=preload_builtin_functions';
        extraOpts{end+1}='--sldv_code_macro=__MW_INTERNAL_SLDV_PS_ANALYSIS__';
        extraOpts{end+1}=['--ignore_macro_definition_file=',txtFile];



        funcBehavFile=fullfile(matlabroot,'polyspace','verifier','cxx',...
        'polyspace_stubs','sldv_math_properties.xml');
        extraOpts{end+1}=['--lib_properties_specifications=',funcBehavFile];

        if ver.intel>=1700






            extraOpts{end+1}='--define_macro=__PURE_INTEL_C99_HEADERS__';
        end
    end
end


function ret=iCompilerVersion(options)
    ret.gnu=-1;
    ret.clang=-1;
    ret.visual=-1;
    ret.mingw=-1;
    ret.intel=-1;
    if~isempty(options)&&isa(options,'internal.cxxfe.FrontEndOptions')
        edgOpts=[options.Language.LanguageExtra;options.ExtraOptions];
        verOpts={'--gnu_version','--microsoft_version','--clang_version'};
        verValue=[];
        for ii=1:numel(verOpts)
            verOpt=verOpts{ii};

            ver=strcmp(edgOpts,verOpt);
            if any(ver)
                idx=find(ver,1,'last');
                if~isempty(idx)
                    verValue=str2double(edgOpts{idx+1});
                end
            else

                ver=regexp(edgOpts,sprintf('(?<=%s=).*',verOpt),'match');
                idx=cellfun(@(x)~isempty(x),ver);
                if any(idx)
                    idx=find(idx,1,'last');
                    if~isempty(idx)
                        verValue=str2double(ver{idx}{1});
                    end
                end
            end



            if~isempty(verValue)
                switch ii
                case 1
                    if ispc
                        ret.mingw=verValue;
                    else
                        ret.gnu=verValue;
                    end
                case 2
                    ret.visual=verValue;
                case 3
                    ret.clang=verValue;
                end
                break
            end
        end

        if ret.visual>0


            edgDefs=options.Preprocessor.Defines;
            ver=regexp(edgDefs,'__INTEL_COMPILER=(.*)','tokens');
            idx=cellfun(@(x)~isempty(x),ver);
            if any(idx)
                verValue=str2double(ver{idx}{1});
                ret.intel=verValue;
            end
        end
    else

    end
end
