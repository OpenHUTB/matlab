classdef(SupportExtensionMethods=true,Sealed)slCustomizer<handle



    properties(SetAccess=private,GetAccess=private)
        CustomizationManager={};
    end

    methods(Access=private)
        function obj=slCustomizer()
            obj.CustomizationManager=sl_customization_manager;
        end

        function delete(~)
        end
    end

    methods(Static)
        function ensureUniqueCustomizationMethods()
            disp('They''re unique!');
        end

        function staticRefresh()
            try

                builtin('_fevalWrapperDeferredCtrlc',@()slCustomizer.callRefresh());
            catch E
                if Diagnostic.Utils.isInterrupt(E)
                    fprintf('%s\n',DAStudio.message('Simulink:utility:CustomizationInterrupted'));
                end
                rethrow(E);
            end
        end

        function out=RecursionGuard(in)
            persistent Reentrant;
            if nargin,Reentrant=in;end
            out=Reentrant;
        end
    end

    methods(Static,Access=private)
        function callRefresh()
            slsvInternal('evalAndCatchInterrupt','customizer = slCustomizer();customizer.refresh();');
        end

    end

    methods(Access=private)

        function callAllMethods(obj,type)


            PerfTools.Tracer.logSLStartupData(type,true);

            phaseStr='methods(obj)';
            PerfTools.Tracer.logSLStartupData(phaseStr,true);
            m=methods(obj);
            PerfTools.Tracer.logSLStartupData(phaseStr,false);
            toDisable=slprivate('disableRunSpecificCustomization');
            for index=1:length(m)

                if isCustomizationFiltered(toDisable,m{index})
                    continue;
                end

                if strncmp(m{index},type,length(type))
                    try
                        PerfTools.Tracer.logSLStartupData(m{index},true);
                        performance.productStats.logEventBeginTime('SLStartup',m{index});
                        feval(m{index},obj);
                        performance.productStats.logEventEndTime('SLStartup',m{index});
                        PerfTools.Tracer.logSLStartupData(m{index},false);
                    catch ME
                        warning(ME.identifier,'%s',getMessageWithTrimmedStack(ME,'callAllMethods'));
                    end
                end
            end
            PerfTools.Tracer.logSLStartupData(type,false);
        end

        function callAll(obj,fileName)
            cm=obj.CustomizationManager;

            phaseStr=['which(''-all'', ',fileName,')'];
            PerfTools.Tracer.logSLStartupData(phaseStr,true);
            customizations=which('-all',fileName);
            PerfTools.Tracer.logSLStartupData(phaseStr,false);

            PerfTools.Tracer.logSLStartupData(fileName,true);

            preCallStr=[fileName,'_pre_call'];
            PerfTools.Tracer.logSLStartupData(preCallStr,true);
            if length(customizations)==0 %#ok

                PerfTools.Tracer.logSLStartupData(preCallStr,false);
                PerfTools.Tracer.logSLStartupData(fileName,false);
                return
            end

            phaseStr=[fileName,'_fileparts_loop'];
            PerfTools.Tracer.logSLStartupData(phaseStr,true);
            for i=1:length(customizations)
                paths{i}=fileparts(customizations{i});%#ok
            end
            PerfTools.Tracer.logSLStartupData(phaseStr,false);

            phaseStr=[fileName,'_unique'];
            PerfTools.Tracer.logSLStartupData(phaseStr,true);
            [paths,indexFromCustomizations,~]=unique(paths);
            PerfTools.Tracer.logSLStartupData(phaseStr,false);

            phaseStr=[fileName,'_GetFunctionHandleForFullpath_loop'];
            PerfTools.Tracer.logSLStartupData(phaseStr,true);
            for i=1:length(paths)
                funcs{i}=builtin('_GetFunctionHandleForFullpath',customizations{indexFromCustomizations(i)});%#ok
            end
            PerfTools.Tracer.logSLStartupData(phaseStr,false);

            PerfTools.Tracer.logSLStartupData(preCallStr,false);

            toDisable=slprivate('disableRunSpecificCustomization');



            for i=1:length(funcs)
                try
                    if strcmp(fileName,'sl_customization')&&...
                        exist('rtw.codegenObjectives.ObjectiveCustomizer','class')>0
                        try
                            cm.ObjectiveCustomizer.currentCustomizationFile=paths{i};
                        catch ME %#ok<NASGU>
                        end
                    end
                    customizationString=fullfile(paths{i},fileName);

                    if isCustomizationFiltered(toDisable,customizationString)
                        continue;
                    end

                    PerfTools.Tracer.logSLStartupData(customizationString,true);
                    performance.productStats.logEventBeginTime('SLStartup',customizationString);
                    feval(funcs{i},cm);
                    performance.productStats.logEventEndTime('SLStartup',customizationString);
                    PerfTools.Tracer.logSLStartupData(customizationString,false);
                catch me
                    warning(me.identifier,'%s',getMessageWithTrimmedStack(me,'callAll'));
                end
            end

            PerfTools.Tracer.logSLStartupData(fileName,false);
        end
    end
end

function str=getMessageWithTrimmedStack(ME,func)
    str=ME.getReport;
    ind=strfind(str,func);
    if~isempty(ind)

        str=str(1:ind(1));
        ind=find(str==newline);
        if~isempty(ind)
            str=str(1:ind(end)-1);
        end
    end
end




function ret=isCustomizationFiltered(toDisable,customization)
    ret=0;
    if~isempty(toDisable)
        if find(strcmp(toDisable,customization))
            disp(['Skipping customizer: ',customization]);
            ret=1;
        end
    end
end


