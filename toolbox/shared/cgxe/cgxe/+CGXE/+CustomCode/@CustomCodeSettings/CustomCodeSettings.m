



classdef CustomCodeSettings<handle
    properties(Access=public)
        customCode=''
        customSourceCode=''
        userIncludeDirs=''
        userSources=''
        userLibraries=''
        reservedNames=''
        customInitializer=''
        dataInitializer=''
        customTerminator=''
        customUserDefines=''
        customCompilerFlags=''
        customLinkerFlags=''
        parseCC=false
        analyzeCC=false
        debugExecuteCC=false
        sameCustomCodeForSimAndCode=false
        isCpp=false
        defaultFunctionArrayLayout=''
        functionNameToArrayLayout=[]
        customCodeUndefinedFunction=''
        customCodeGlobalsAsFunctionIO=''
        defaultCustomCodeDeterministicFcns=''
        customCodeDeterministicByFcn=''
        prebuiltCCDependency=struct('interfaceHeader',{},'simExe',{})
    end

    methods
        function dst=copy(src)
            dst=CGXE.CustomCode.CustomCodeSettings;
            propNames=properties(src);
            for ii=1:numel(propNames)
                propName=propNames{ii};
                dst.(propName)=src.(propName);
            end
        end



        function result=hasSettings(obj,forSLCC)
            if(nargin<2)
                forSLCC=false;
            end

            if forSLCC&&~obj.parseCC



                result=false;
                return;
            end

            result=~(isempty(obj.customCode)&&...
            isempty(obj.customSourceCode)&&...
            isempty(obj.userIncludeDirs)&&...
            isempty(obj.userSources)&&...
            isempty(obj.userLibraries)&&...
            isempty(obj.reservedNames)&&...
            isempty(obj.customInitializer)&&...
            isempty(obj.customTerminator)&&...
            isempty(obj.customUserDefines)&&...
            isempty(obj.customCompilerFlags)&&...
            isempty(obj.customLinkerFlags));
        end











        function[hasDll,hasCustomSource,hasCustomHeaders]=hasCustomCode(obj)
            hasCustomSource=~(isempty(strtrim(obj.customInitializer))&&...
            isempty(strtrim(obj.customSourceCode))&&...
            isempty(strtrim(obj.customTerminator)));

            hasCustomHeaders=hasCustomSource||...
            ~isempty(strtrim(obj.customCode));

            hasDll=hasCustomSource||hasCustomHeaders||...
            ~(isempty(strtrim(obj.userIncludeDirs))&&...
            isempty(strtrim(obj.userSources))&&...
            isempty(strtrim(obj.userLibraries)));
        end


        function setUserIncludeDirs(obj,userIncludes)
            userIncludes=CGXE.CustomCode.CustomCodeSettings.pathListToConfigSetString(userIncludes);
            obj.userIncludeDirs=userIncludes;
        end


        function setUserSources(obj,userSources)
            userSources=CGXE.CustomCode.CustomCodeSettings.pathListToConfigSetString(userSources);
            obj.userSources=userSources;
        end


        function setUserLibraries(obj,userLibraries)
            userLibraries=CGXE.CustomCode.CustomCodeSettings.pathListToConfigSetString(userLibraries);
            obj.userLibraries=userLibraries;
        end


        function chkSum=fieldChecksum(obj,chkSum)
            if nargin==1
                chkSum='';
            end
            ccProps={obj.customCode...
            ,obj.customSourceCode...
            ,obj.userIncludeDirs...
            ,obj.userSources...
            ,obj.userLibraries...
            ,obj.reservedNames...
            ,obj.customInitializer...
            ,obj.customTerminator...
            ,obj.customUserDefines...
            ,obj.customCompilerFlags...
            ,obj.customLinkerFlags...
            ,obj.defaultFunctionArrayLayout...
            ,obj.functionNameToArrayLayout...
            ,obj.customCodeUndefinedFunction...
            ,obj.customCodeGlobalsAsFunctionIO...
            ,obj.analyzeCC...
            ,obj.debugExecuteCC...
            ,obj.defaultCustomCodeDeterministicFcns...
            ,obj.customCodeDeterministicByFcn...
            ,obj.isCpp};

            for i=1:length(ccProps)


                chkSum=CGXE.Utils.md5(chkSum,i,ccProps{i});
            end

            if obj.analyzeCC



                chkSum=CGXE.Utils.md5(chkSum,'2');
            end
        end


        function setFromStruct(obj,stru)
            structFields={'customCode','customSourceCode','userIncludeDirs',...
            'userSources','userLibraries','reservedNames',...
            'customInitializer','dataInitializer','customTerminator',...
            'customUserDefines','customCompilerFlags','customLinkerFlags'};
            for ii=1:numel(fields)
                field=structFields{ii};
                if isfield(stru,field)
                    obj.(field)=stru.(field);
                end
            end
        end


        function setFromConfigSet(obj,cs,isRTW,isLib)
            if nargin<4
                isLib=false;
            end

            useRTWPanel=strcmp(get_param(cs,'RTWUseSimCustomCode'),'off');

            obj.sameCustomCodeForSimAndCode=~useRTWPanel;
            obj.analyzeCC=false;
            obj.defaultFunctionArrayLayout=get_param(cs,'DefaultCustomCodeFunctionArrayLayout');
            obj.functionNameToArrayLayout=get_param(cs,'CustomCodeFunctionArrayLayout');
            obj.customCodeUndefinedFunction=get_param(cs,'CustomCodeUndefinedFunction');
            obj.defaultCustomCodeDeterministicFcns=get_param(cs,'DefaultCustomCodeDeterministicFunctions');
            if strcmpi(obj.defaultCustomCodeDeterministicFcns,'ByFunction')
                obj.customCodeDeterministicByFcn=get_param(cs,'CustomCodeDeterministicFunctions');
            else
                obj.customCodeDeterministicByFcn='';
            end
            customCodeGlobalsAsFunctionIOStr=get_param(cs,'CustomCodeGlobalsAsFunctionIO');
            if(strcmp(customCodeGlobalsAsFunctionIOStr,"on"))
                obj.customCodeGlobalsAsFunctionIO=true;
            else
                obj.customCodeGlobalsAsFunctionIO=false;
            end

            if isRTW&&useRTWPanel
                if isLib&&strcmp(get_param(cs,'RTWUseLocalCustomCode'),'off')
                    return;
                end
                obj.customCode=get_param(cs,'CustomHeaderCode');
                obj.customSourceCode=get_param(cs,'CustomSourceCode');
                obj.userIncludeDirs=get_param(cs,'CustomInclude');
                obj.userSources=get_param(cs,'CustomSource');
                obj.userLibraries=get_param(cs,'CustomLibrary');
                obj.reservedNames=get_param(cs,'ReservedNameArray');
                obj.customInitializer=get_param(cs,'CustomInitializer');
                obj.customTerminator=get_param(cs,'CustomTerminator');
                obj.customUserDefines=get_param(cs,'CustomDefine');
            else
                if isLib&&strcmp(get_param(cs,'SimUseLocalCustomCode'),'off')
                    return;
                end

                prebuiltSimExe='';
                isSim=~isRTW;
                if isSim
                    [prebuiltSimExe,interfaceHeader]=SLCC.OOP.getPreBuiltCCDependency(cs.getModel);

                    obj.isCpp=strcmp(get_param(cs,'SimTargetLang'),'C++');
                end
                if~isempty(prebuiltSimExe)

                    assert(~isempty(interfaceHeader),'Generated interface header must exist.');
                    obj.prebuiltCCDependency=struct('interfaceHeader',interfaceHeader,'simExe',prebuiltSimExe);
                    obj.customCode=['#include "',interfaceHeader,'"'];
                    obj.customSourceCode='';
                    obj.userIncludeDirs='';
                    obj.userSources='';
                    obj.userLibraries='';
                    obj.reservedNames='';
                    obj.customCompilerFlags='';
                    obj.customLinkerFlags='';
                    obj.customInitializer='';
                    obj.customTerminator='';
                    obj.customUserDefines='';

                    obj.customCodeUndefinedFunction='DoNotDetect';
                    obj.parseCC=true;
                    obj.debugExecuteCC=true;
                    obj.analyzeCC=false;
                else
                    obj.customCode=get_param(cs,'SimCustomHeaderCode');
                    obj.customSourceCode=get_param(cs,'SimCustomSourceCode');
                    obj.userIncludeDirs=get_param(cs,'SimUserIncludeDirs');
                    obj.userSources=get_param(cs,'SimUserSources');
                    obj.userLibraries=get_param(cs,'SimUserLibraries');
                    obj.reservedNames=get_param(cs,'SimReservedNameArray');
                    obj.customCompilerFlags=get_param(cs,'SimCustomCompilerFlags');
                    obj.customLinkerFlags=get_param(cs,'SimCustomLinkerFlags');
                    obj.customInitializer=get_param(cs,'SimCustomInitializer');
                    obj.customTerminator=get_param(cs,'SimCustomTerminator');
                    obj.customUserDefines=get_param(cs,'SimUserDefines');
                    if isSim
                        obj.parseCC=strcmp(get_param(cs,'SimParseCustomCode'),'on');

                        if cgxe('Feature','ForceOptOutSLCC')
                            obj.parseCC=false;
                        end



                        obj.debugExecuteCC=obj.parseCC&&(slfeature('OutOfProcessExecution')==2)&&strcmpi(get_param(cs,'SimDebugExecutionForCustomCode'),'on');




                        obj.analyzeCC=~obj.debugExecuteCC&&strcmpi(get_param(cs,'SimAnalyzeCustomCode'),'on');
                    end
                end
            end
        end

        function saveToConfigSet(obj,cs,rtwSettings)
            if nargin<3
                rtwSettings=false;
            end

            if rtwSettings
                set_param(cs,'CustomHeaderCode',obj.customCode);
                set_param(cs,'CustomSourceCode',obj.customSourceCode);
                set_param(cs,'CustomInclude',obj.userIncludeDirs);
                set_param(cs,'CustomSource',obj.userSources);
                set_param(cs,'CustomLibrary',obj.userLibraries);
                set_param(cs,'ReservedNameArray',obj.reservedNames);
                set_param(cs,'CustomInitializer',obj.customInitializer);
                set_param(cs,'CustomTerminator',obj.customTerminator);
                set_param(cs,'CustomDefine',obj.customUserDefines);
            else
                set_param(cs,'SimCustomHeaderCode',obj.customCode);
                set_param(cs,'SimCustomSourceCode',obj.customSourceCode);
                set_param(cs,'SimUserIncludeDirs',obj.userIncludeDirs);
                set_param(cs,'SimUserSources',obj.userSources);
                set_param(cs,'SimUserLibraries',obj.userLibraries);
                set_param(cs,'SimReservedNameArray',obj.reservedNames);
                set_param(cs,'SimCustomCompilerFlags',obj.customCompilerFlags);
                set_param(cs,'SimCustomLinkerFlags',obj.customLinkerFlags);
                set_param(cs,'SimCustomInitializer',obj.customInitializer);
                set_param(cs,'SimCustomTerminator',obj.customTerminator);
                set_param(cs,'SimUserDefines',obj.customUserDefines);
            end
        end



        function[userIncludes,userSources,userLibraries]=getTokenizedPathsAndFiles(obj,modelName,projRootDir,targetDir)
            if nargin<4
                targetDir=pwd;
            end

            if nargin<3
                projRootDir=cgxeprivate('get_cgxe_proj_root');
            end


            [userIncludes,userSources,userLibraries]=...
            cgxeprivate('getTokenizedPathsAndFiles',modelName,projRootDir,obj,targetDir);
        end


        function saved=saveToModel(obj,modelName,saveToRtw)
            if nargin<3
                saveToRtw=false;
            end

            saved=false;
            try
                cs=getActiveConfigSet(modelName);
            catch
                return
            end

            isCSResolved=~isempty(cs)&&(isa(cs,'Simulink.ConfigSet')||strcmp(cs.SourceResolved,'on'));
            if~isCSResolved
                return;
            end

            obj.saveToConfigSet(cs,saveToRtw);
            saved=true;
        end
    end

    methods(Static=true)

        function customCodeSettings=createFromModel(modelName,useRTW)
            if nargin<2
                useRTW=false;
            end

            customCodeSettings=CGXE.CustomCode.CustomCodeSettings();







            try
                cs=getActiveConfigSet(modelName);
                if strcmp(get_param(modelName,'Description'),'Temporary wrapper for PIL simulation')

                    cs=[];
                end
            catch
                cs=[];
            end

            isCSResolved=~isempty(cs)&&(isa(cs,'Simulink.ConfigSet')||strcmp(cs.SourceResolved,'on'));
            if~isCSResolved
                return;
            end

            isLib=strcmpi(get_param(modelName,'BlockDiagramType'),'library');
            customCodeSettings.setFromConfigSet(cs,useRTW,isLib);

        end
    end

    methods(Static=true,Access=private)





        function configSetString=pathListToConfigSetString(pathList)
            pathList=convertStringsToChars(pathList);

            if iscell(pathList)

                for ii=1:numel(pathList)
                    if~isempty(strfind(pathList{ii},' '))
                        pathList{ii}=sprintf('"%s"',pathList{ii});
                    end
                end


                configSetString=strjoin(pathList,newline);
            else
                configSetString=pathList;
            end
        end
    end
end


