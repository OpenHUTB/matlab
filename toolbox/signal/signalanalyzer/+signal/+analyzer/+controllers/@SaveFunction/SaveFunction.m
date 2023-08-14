classdef SaveFunction<handle





    properties(Hidden)
        Dispatcher;
    end

    properties(Constant)
        ControllerID='SaveFunction';
    end

    methods(Static)

        function ret=getController()

            persistent ctrlObj;
            mlock;
            if isempty(ctrlObj)||~isvalid(ctrlObj)
                dispatcherObj=Simulink.sdi.internal.controllers.SDIDispatcher.getDispatcher();
                ctrlObj=signal.analyzer.controllers.SaveFunction(dispatcherObj);
            end


            ret=ctrlObj;
        end
    end

    methods(Hidden)

        function this=SaveFunction(dispatcherObj)

            this.Dispatcher=dispatcherObj;


            import signal.analyzer.controllers.SaveFunction;
            this.Dispatcher.subscribe(...
            [SaveFunction.ControllerID,'/','savecustomfunction'],...
            @(arg)cb_SaveFunction(this,arg));
        end


        function cb_SaveFunction(this,arg)




            this.saveFunction(arg);
        end
    end

    methods(Access=protected)

        function saveFunction(this,arg)
            if isfield(arg.data,'functionName')
                functionName=arg.data.functionName;
                functionDesc=arg.data.functionDesc;
                createFunctionTemplate(this,functionName,functionDesc,true);

                prefStruct=struct('name',functionName,'description',functionDesc);
                setpref('SACustomFunctionList',functionName,prefStruct);

                functionToAdd={prefStruct};
                signal.sigappsshared.Utilities.publishCustomPreprocessAddCompleted(functionToAdd);
            end
        end

        function str=getString(~,key)

            str=getString(message(['SDI:sigAnalyzer:',key]));
        end

        function codeBufferCell=createFunctionTemplate(this,fileName,functionDesc,bOpenInEditor)
            codeBufferCell={};
            codeBuffer=StringWriter;
            this.addHeader(codeBuffer,fileName,functionDesc);
            codeBuffer.indentCode('matlab');
            codeBufferCell{end+1}=codeBuffer;
            fullFile=fullfile(pwd,[fileName,'.m']);
            codeBuffer.write(fullFile);
            if bOpenInEditor
                matlab.desktop.editor.openDocument(fullFile);
            end
        end


        function addHeader(this,codeBuffer,functionName,functionDesc)
            fcnHeader1=['function [y,tOut] = ',functionName,'(x,tIn,varargin)'];
            fcnTemplateHeader=getString(this,'PreprocessTemplateMsg');
            fncBodyStr=getString(this,'PreprocessTmpGenWriteAlgorithm');
            commentStr=getString(this,'PreprocessTmpGenWithArg');
            codeBuffer.addcr('%s',fcnHeader1);
            if~isempty(functionDesc)
                splitFunctionDesc=splitlines(functionDesc);
                for idx=1:numel(splitFunctionDesc)
                    codeBuffer.addcr('%s%s','% ',splitFunctionDesc{idx});
                end
                codeBuffer.addcr('%s','');
            end
            codeBuffer.addcr('%s%s','% ',fcnTemplateHeader);
            codeBuffer.addcr('%s%s','%  ',commentStr);
            codeBuffer.addcr('\n%s',fncBodyStr);
            codeBuffer.addcr('%s','');
        end

    end
end