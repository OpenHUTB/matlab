classdef Task_CodeReport<simulinkcoder.internal.codeperspectivetask.BaseTask




    properties(Constant)
        ID='CodeReport'
    end

    methods
        function obj=Task_CodeReport
        end
    end
    methods
        function result=turnOn(obj,input,minimize)


            if nargin<3
                minimize=false;
            end

            cp=simulinkcoder.internal.CodePerspective.getInstance;
            src=simulinkcoder.internal.util.getSource(input);
            studio=src.studio;
            mdl=studio.App.blockDiagramHandle;
            cps=cp.getFlag(mdl,studio);
            if isempty(cps.cv)
                cps.cv=simulinkcoder.internal.CodeView_C(studio);
            end
            cv=cps.cv;
            cv.open([],~minimize);

            result=true;
        end

        function turnOff(~,input)


            cp=simulinkcoder.internal.CodePerspective.getInstance;
            src=simulinkcoder.internal.util.getSource(input);
            studio=src.studio;
            mdl=studio.App.blockDiagramHandle;
            cps=cp.getFlag(mdl,studio);
            if~isempty(cps)
                cv=cps.cv;
                if~isempty(cv)
                    cv.close;
                end
            end
        end

        function bool=isAvailable(obj,type)
            if strcmp(type,'grt')||strcmp(type,'grt_cpp')||strcmp(type,'none')
                bool=false;
            else
                bool=true;
            end
        end

        function bool=isAutoOn(obj,input)


            bool=true;

            if~isAutoOn@simulinkcoder.internal.codeperspectivetask.BaseTask(obj,input)
                bool=false;
                return;
            elseif~dig.isProductInstalled('Embedded Coder')

                bool=false;
                return;
            end
        end
    end
end



