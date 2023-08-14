classdef SaveLabelerFunction<handle





    properties(Hidden)
        Dispatcher;
    end

    properties(Constant)
        ControllerID='SaveLabelerFunction';
    end

    events
AddCustomLabelerFunction
    end

    methods(Static)

        function ret=getController(varargin)

            persistent ctrlObj;
            mlock;
            if isempty(ctrlObj)||~isvalid(ctrlObj)
                dispatcherObj=Simulink.sdi.internal.controllers.SDIDispatcher.getDispatcher();
                ctrlObj=signal.labeler.controllers.SaveLabelerFunction(dispatcherObj);
            end


            ret=ctrlObj;
        end
    end

    methods(Hidden)

        function this=SaveLabelerFunction(dispatcherObj)

            this.Dispatcher=dispatcherObj;


            import signal.labeler.controllers.SaveLabelerFunction;
            this.Dispatcher.subscribe(...
            [SaveLabelerFunction.ControllerID,'/','savecustomlabelerfunction'],...
            @(arg)cb_SaveLabelerFunction(this,arg));

            this.Dispatcher.subscribe(...
            [SaveLabelerFunction.ControllerID,'/','customlabelereditdescriptionok'],...
            @(arg)cb_CustomLabelerEditDescriptionOk(this,arg));

            this.Dispatcher.subscribe(...
            [SaveLabelerFunction.ControllerID,'/','labelerapphelp'],...
            @(arg)cb_HelpButton(this,arg));
        end


        function cb_SaveLabelerFunction(this,arg)




            this.saveFunction(arg);
        end
        function cb_CustomLabelerEditDescriptionOk(this,args)
            if isfield(args.data,'functionName')
                functionName=args.data.functionName;
                functionDesc=args.data.functionDesc;
                prefStruct=getpref('LACustomLabelerFunctionList',functionName);
                prefStruct.description=functionDesc;
                setpref('LACustomLabelerFunctionList',functionName,prefStruct);
                functionToAdd={prefStruct};
                this.notify('AddCustomLabelerFunction',signal.internal.SAEventData(struct('clientID',args.clientID,...
                'data',functionToAdd)));
            end
        end
        function cb_HelpButton(~,args)

            srcWidget=args.data.srcWidget;
            switch(srcWidget)
            case 'addAutoLabelFunctionsWidget'
                signal.labeler.controllers.SignalLabelerHelp('addCustomLabelerHelp');
            case 'manageAutoLabelFunctionsWidget'
                signal.labeler.controllers.SignalLabelerHelp('manageCustomLabelerHelp');
            case 'editAutoLabelFunctionDescriptionWidget'
                signal.labeler.controllers.SignalLabelerHelp('editCustomLabelerDesctriptionHelp');
            end
        end
    end

    methods(Access=protected)

        function saveFunction(this,args)
            if isfield(args.data,'functionName')
                functionName=args.data.functionName;
                functionDesc=args.data.functionDesc;
                functionLabelType=args.data.functionLabelType;

                functionLabelDataType=args.data.functionLabelDataType;
                createFunctionTemplate(this,functionName,functionDesc,true);

                prefStruct=struct('name',functionName,'description',functionDesc,'functionLabelType',functionLabelType,'functionLabelDataType',functionLabelDataType);
                setpref('LACustomLabelerFunctionList',functionName,prefStruct);

                functionToAdd={prefStruct};
                this.notify('AddCustomLabelerFunction',signal.internal.SAEventData(struct('clientID',args.clientID,...
                'data',functionToAdd)));
            end
        end



        function str=getString(~,key)

            str=getString(message(['SDI:labeler:',key]));
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
            fcnHeader1=['function [labelVals,labelLocs] = ',functionName,'(x,t,parentLabelVal,parentLabelLoc,varargin)'];
            fcnTemplateHeader=getString(this,'LabelerTemplateMsg');
            fncBodyStr=getString(this,'LabelerTmpGenWriteAlgorithm');
            commentStr=getString(this,'LabelerTmpGenWithArg');
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