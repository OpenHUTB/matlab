classdef sfunctionbuilderView<handle




    properties(SetAccess=protected)
cefObj
clientID
publishChannel
subscribeChannel
subscription
sfunctionbuilderInitialContent
sfunctionbuilderController
sfunctionbuilderBlockHandle
listener
unSavedChangeFlag
    end

    properties(Constant)
        sfunctionbuilderEditorMarkers=struct(...
        'includesBeginMarker','Includes_BEGIN',...
        'includesEndMarker','Includes_END',...
        'externsBeginMarker','Externs_BEGIN',...
        'externsEndMarker','Externs_END',...
        'startBeginMarker','Start_BEGIN',...
        'startEndMarker','Start_END',...
        'outputsBeginMarker','Output_BEGIN',...
        'outputsEndMarker','Output_END',...
        'updateBeginMarker','Update_BEGIN',...
        'updateEndMarker','Update_END',...
        'derivativesBeginMarker','Derivatives_BEGIN',...
        'derivativesEndMarker','Derivatives_END',...
        'terminateBeginMarker','Terminate_BEGIN',...
        'terminateEndMarker','Terminate_END',...
        'markerPrefix','/* ',...
        'markerSuffix',' */'...
        );
    end

    methods(Access=private)

        function sendCloseNotificationEditor(obj,webwidowObj)
            obj.updateSFBWindowPosition('editorDialog',webwidowObj.Position);
            if obj.unSavedChangeFlag
                msg.command="Close the editor dialog";
                msg.content=DAStudio.message('Simulink:blocks:SFunctionBuilderUnsavedChanges');
                message.publish(obj.publishChannel,msg);
            else
                msg.command='close without save';
                obj.sfunbuilder(msg);
            end
        end

        function sendCloseNotificationParameterDialog(obj,webwindowObj)
            obj.updateSFBWindowPosition('parameterDialog',webwindowObj.Position);
            sfcnbuilder.destroyViewAndModel(obj.sfunctionbuilderBlockHandle);
        end


        function sendReadyNotification(obj)
            msg.command="MATLAB is ready";
            msg.content=struct('matlabroot',matlabroot);
            message.publish(obj.publishChannel,msg);
        end

        function updateSFBWindowPosition(obj,windowType,position)
            obj.sfunctionbuilderController.updateSFBWindowPostion(obj.sfunctionbuilderBlockHandle,windowType,position);
        end

    end

    methods(Static=true)
        function blockRenameListener(blockObj,eventData)%#ok<INUSD>


            controller=sfunctionbuilder.internal.sfunctionbuilderController.getInstance;
            controller.updateSFunctionBlockPath(blockObj.Handle,blockObj.getFullName);
        end
    end

    methods

        function obj=sfunctionbuilderView(blockHandle,initialContent)

            obj.clientID=char(matlab.lang.internal.uuid);
            obj.publishChannel=strcat("/SFunctionBuilder/",obj.clientID,"/MATLAB");
            obj.subscribeChannel=strcat("/SFunctionBuilder/",obj.clientID,"/JS");
            obj.subscription=message.subscribe(obj.subscribeChannel,@(msg)obj.sfunbuilder(msg));


            obj.sfunctionbuilderController=sfunctionbuilder.internal.sfunctionbuilderController.getInstance();

            obj.sfunctionbuilderBlockHandle=blockHandle;





            obj.sfunctionbuilderController.saveSfunctionName(blockHandle);
            obj.sfunctionbuilderController.saveWizardData(blockHandle);

            obj.sfunctionbuilderInitialContent=initialContent;
            obj.createCEFObj();

            obj.listener=Simulink.listener(get_param(blockHandle,'Object'),'NameChangeEvent',@sfunctionbuilder.internal.sfunctionbuilderView.blockRenameListener);
            obj.unSavedChangeFlag=false;
        end

        function createCEFObj(obj)
            if slsvTestingHook('SFBuilderGUIDebugMode')>0

                nurl=connector.getUrl('/toolbox/shared/sfunctionbuilderjs/web/index-debug.html');
            else

                nurl=connector.getUrl('/toolbox/shared/sfunctionbuilderjs/web/index.html');
            end

            urlWithPortID=[nurl,'&','UUID=',obj.clientID,'&EnableBusArray=',int2str(slfeature('slBusArraySFBuilder')),'&EnablePacking=',int2str(slfeature('slSFcnPackaging'))];
            cef=matlab.internal.webwindow(urlWithPortID,matlab.internal.getDebugPort,'EnableZoom',true);



            if ispc
                iconSrc=fullfile(matlabroot,'toolbox/shared/sfunctionbuilderjs/m/+sfunctionbuilder/+internal/resources/simulink_16.ico');
                cef.Icon=iconSrc;
            elseif isunix
                iconSrc=getIconFile(matlab.ui.internal.toolstrip.Icon.SIMULINK_16);
                cef.Icon=iconSrc;
            end

            obj.cefObj=cef;

            param=obj.sfunctionbuilderInitialContent.Parameters;


            if isempty(param.Name)||isempty(param.Name{1})
                obj.launchEditorDialog();
            else
                obj.launchParameterDialog();
            end

            if slsvTestingHook('SFBuilderGUIDebugMode')==1

                obj.cefObj.executeJS('cefclient.sendMessage("openDevTools");');
            end
        end


        function launchParameterDialog(obj)

            windowPosition=obj.sfunctionbuilderController.getSFBWindowPostion(obj.sfunctionbuilderBlockHandle,'parameterDialog');
            if isempty(windowPosition)
                obj.cefObj.Position=setParameterBlockDialogSize();
            else
                obj.cefObj.Position=windowPosition;
            end
            obj.cefObj.CustomWindowClosingCallback=@(e,~)sendCloseNotificationParameterDialog(obj,e);
            appdata=obj.sfunctionbuilderController.getApplicationData(obj.sfunctionbuilderBlockHandle);
            obj.cefObj.Title=appdata.DefaultTitle;
        end


        function launchEditorDialog(obj)

            windowPosition=obj.sfunctionbuilderController.getSFBWindowPostion(obj.sfunctionbuilderBlockHandle,'editorDialog');
            if isempty(windowPosition)
                obj.cefObj.Position=setEditorDialogSize(obj.cefObj.Position);
            else
                obj.cefObj.Position=windowPosition;
            end
            obj.cefObj.CustomWindowClosingCallback=@(e,~)sendCloseNotificationEditor(obj,e);
            appdata=obj.sfunctionbuilderController.getApplicationData(obj.sfunctionbuilderBlockHandle);
            obj.cefObj.Title=appdata.DefaultTitle;
        end

        function sfunbuilder(obj,msg)

            try
                msgCommand=msg.command;
                switch msgCommand
                case 'JS starts'
                    obj.sendReadyNotification();
                case 'JS is ready'
                    obj.initializeUI();
                case 'convert to editor dialog'
                    obj.launchEditorDialog();
                    obj.initializeEditorDialog();
                case 'populate editor dialog'
                    obj.populateEditorDialog();
                case 'populate RTC editor'
                    obj.populateRTCEditor();
                case 'populate parameter dialog'
                    obj.populateParameterDialog();
                case 'close without save'
                    sfcnbuilder.destroyViewAndModel(obj.sfunctionbuilderBlockHandle);
                case 'close and save'
                    appdata=obj.sfunctionbuilderController.getApplicationData(obj.sfunctionbuilderBlockHandle);
                    abortClose=false;
                    if~isempty(appdata.SfunWizardData.SfunName)||obj.unSavedChangeFlag
                        abortClose=obj.sfunctionbuilderController.doSave(obj.sfunctionbuilderBlockHandle);
                    end
                    if(~abortClose)
                        sfcnbuilder.destroyViewAndModel(obj.sfunctionbuilderBlockHandle);
                    end

                case 'doSave'
                    obj.sfunctionbuilderController.doSave(obj.sfunctionbuilderBlockHandle);
                case 'update sfunction name'
                    name=msg.content;
                    obj.sfunctionbuilderController.updateSFunctionName(obj.sfunctionbuilderBlockHandle,name);
                case 'update sfunction language'
                    language=msg.content;
                    obj.sfunctionbuilderController.updateSFunctionLanguage(obj.sfunctionbuilderBlockHandle,language);
                case 'update sfunction build option'
                    option=msg.content;
                    obj.sfunctionbuilderController.updateSFunctionBuildOption(obj.sfunctionbuilderBlockHandle,option);
                case 'update sfunction package option'
                    option=msg.content;
                    obj.sfunctionbuilderController.updateSFunctionPackageOption(obj.sfunctionbuilderBlockHandle,option);
                    obj.unSaveChangeFlag=true;
                case 'update certificate name'
                    option=msg.content;
                    obj.sfunctionbuilderController.updateCertificateName(obj.sfunctionbuilderBlockHandle,option);
                    obj.unSaveChangeFlag=true;
                case 'doBuild'
                    option.optionName='SaveCodeOnly';
                    option.optionSelected=false;
                    obj.sfunctionbuilderController.updateSFunctionBuildOption(obj.sfunctionbuilderBlockHandle,option);
                    obj.sfunctionbuilderController.doBuild(obj.sfunctionbuilderBlockHandle);
                case 'doPackage'
                    obj.sfunctionbuilderController.doPackage(obj.sfunctionbuilderBlockHandle);
                case 'setCertificateFile'
                    certificateFile=msg.content;
                    obj.sfunctionbuilderController.updateCertificateName(obj.sfunctionbuilderBlockHandle,certificateFile);
                    obj.sfunctionbuilderController.doPackage(obj.sfunctionbuilderBlockHandle);
                case 'doCodeGenOnly'
                    option.optionName='SaveCodeOnly';
                    option.optionSelected=true;
                    obj.sfunctionbuilderController.updateSFunctionBuildOption(obj.sfunctionbuilderBlockHandle,option);
                    obj.sfunctionbuilderController.doBuild(obj.sfunctionbuilderBlockHandle);

                case 'update parameter value'
                    parameter=msg.content.parameter;
                    name=parameter{1};
                    newValue=parameter{2};
                    obj.sfunctionbuilderController.updateParameterValue(obj.sfunctionbuilderBlockHandle,name,newValue);

                case 'add item to port table'
                    newItem=msg.content.newItem;
                    try
                        obj.sfunctionbuilderController.addItemToPortTable(obj.sfunctionbuilderBlockHandle,newItem);
                    catch ME
                        obj.sfunctionbuilderController.refreshViews(obj.sfunctionbuilderBlockHandle,'fail to add port item',ME.message);
                    end
                case 'delete item from port table'
                    items=msg.content.items;
                    names=cell(1,length(items));
                    scopes=cell(1,length(items));
                    for i=1:length(items)
                        item=items{i};
                        itemName=item{1};
                        itemScope=item{2};

                        if isfield(itemName,'oldValue')
                            names{i}=itemName.oldValue;
                        else
                            names{i}=itemName;
                        end
                        scopes{i}=itemScope;
                    end
                    obj.sfunctionbuilderController.delItemFromPortTable(obj.sfunctionbuilderBlockHandle,names,scopes);
                case 'update item of port table'
                    try
                        item=msg.content.newItem;
                        fieldToUpdate=msg.content.field;
                        oldValue=msg.content.oldValue;
                        obj.sfunctionbuilderController.updateItemOfPortTable(obj.sfunctionbuilderBlockHandle,item,fieldToUpdate,oldValue);
                    catch ME
                        applicationData=obj.sfunctionbuilderController.getApplicationData(obj.sfunctionbuilderBlockHandle);
                        SfunWizardData=attachErrorMessagePortTable(applicationData.SfunWizardData,item,fieldToUpdate,oldValue,ME.message);
                        obj.sfunctionbuilderController.refreshViews(...
                        obj.sfunctionbuilderBlockHandle,'fail to update port table',ME.message,SfunWizardData);
                    end

                case 'add item to library table'
                    newItem=msg.content;
                    try
                        obj.sfunctionbuilderController.addItemToLibTable(obj.sfunctionbuilderBlockHandle,newItem);
                    catch ME
                        obj.sfunctionbuilderController.refreshViews(obj.sfunctionbuilderBlockHandle,'fail to add lib path',ME.message);
                    end
                case 'delete item from library table'
                    items=msg.content.items;
                    ranges=msg.content.ranges;
                    for i=1:numel(items)
                        item=items{i};
                        itemTag=item{1};
                        itemValue=item{2};

                        if isfield(itemValue,'oldValue')
                            itemValue=itemValue.oldValue;
                        end
                        items{i}={itemTag,itemValue};
                    end


                    for idx=1:numel(ranges)
                        ranges(idx).start=ranges(idx).start+1;
                        ranges(idx).end=ranges(idx).end+1;
                    end
                    obj.sfunctionbuilderController.delItemFromLibTable(obj.sfunctionbuilderBlockHandle,items,ranges);
                case 'update item of library table'
                    try
                        newItem=msg.content.newItem;
                        oldItem=newItem;
                        fieldToUpdate=msg.content.field;
                        if strcmp(fieldToUpdate,'type')
                            oldItem{1}=msg.content.oldValue;
                            newValue=newItem{1};
                        elseif strcmp(fieldToUpdate,'value')
                            oldItem{2}=msg.content.oldValue;
                            newValue=newItem{2};
                        end
                        oldValue=msg.content.oldValue;
                        index=msg.content.index+1;
                        obj.sfunctionbuilderController.updateItemOfLibTable(obj.sfunctionbuilderBlockHandle,oldItem,fieldToUpdate,newValue,index);
                    catch ME
                        applicationData=obj.sfunctionbuilderController.getApplicationData(obj.sfunctionbuilderBlockHandle);
                        SfunWizardData=attachErrorMessageLibTable(applicationData.SfunWizardData,newItem,fieldToUpdate,oldValue,index,ME.message);
                        obj.sfunctionbuilderController.refreshViews(...
                        obj.sfunctionbuilderBlockHandle,'fail to update library table',ME.message,struct('LibraryData',SfunWizardData.LibraryFilesTable));
                    end


                case 'update sfunction setting'
                    try
                        setting=msg.content;
                        obj.sfunctionbuilderController.updateSFunctionSetting(obj.sfunctionbuilderBlockHandle,setting);
                    catch ME
                        obj.sfunctionbuilderController.refreshViews(obj.sfunctionbuilderBlockHandle,'invalid setting',ME.message);
                    end


                case 'set source file overwritable'
                    obj.sfunctionbuilderController.setSourceFileOverwritable(obj.sfunctionbuilderBlockHandle);
                case 'set tlc file overwritable'
                    obj.sfunctionbuilderController.setTLCFileOverwritable(obj.sfunctionbuilderBlockHandle);


                case 'read file'
                    try
                        fileName=msg.content.fileName;
                        [fileContent,filePath]=obj.sfunctionbuilderController.readFileByName(fileName);
                        msg.content=struct('Name',fileName,'Content',fileContent,'Path',filePath);
                        msg.command='view source file';
                        message.publish(obj.publishChannel,msg);
                    catch ME
                        obj.sfunctionbuilderController.refreshViews(obj.sfunctionbuilderBlockHandle,'fail to read the file',ME.message);
                    end

                case 'update editor'
                    content=msg.content;
                    codeInfo=parseEditorContent(content,obj.sfunctionbuilderEditorMarkers);
                    obj.sfunctionbuilderController.updateUserCode(obj.sfunctionbuilderBlockHandle,codeInfo);
                    if~strcmp(content,readCode(obj.sfunctionbuilderInitialContent,obj.sfunctionbuilderEditorMarkers))
                        obj.unSavedChangeFlag=true;
                    end
                case 'show help'
                    helpview('simulink','sfunctionbuilder')
                case 'webwindow close request'
                    obj.sendCloseNotificationEditor(obj.cefObj);
                otherwise
                    assert(false,'unrecognized sfbuilder event');
                end
            catch ex


                if slsvTestingHook('SFBuilderGUIDebugMode')>0
                    disp(ex.getReport);
                end
            end
        end


        function url=getURL(obj)
            url=obj.cefObj.URL;
        end



        function open(obj)
            if isempty(obj.cefObj)
                obj.createCEFObj();
            end
            obj.cefObj.show();
            obj.cefObj.bringToFront();
        end

        function deleteView(obj)
            applicationData=obj.sfunctionbuilderController.getApplicationData(obj.sfunctionbuilderBlockHandle);
            if isfield(applicationData,'SfunWizardData')
                if isfield(applicationData.SfunWizardData,'BeginPackaging')
                    applicationData.SfunWizardData.BeginPackaging='0';
                end
                if isfield(applicationData.SfunWizardData,'SignPackage')
                    applicationData.SfunWizardData.SignPackage='0';
                end
                if isfield(applicationData.SfunWizardData,'CertificateName')
                    applicationData.SfunWizardData.CertificateName='';
                end
            end
            obj.cefObj.close();
        end


        function refresh(obj,action,data)
            msg.command=action;
            switch action
            case 'refresh toolstrip'
                sfcnName=data.SfunName;
                sfcnLanguage=data.LangExt;
                sfcnOptions.ShowCompileSteps=data.ShowCompileSteps;
                sfcnOptions.CreateDebugMex=data.CreateDebugMex;
                sfcnOptions.GenerateTLC=data.GenerateTLC;
                sfcnOptions.SaveCodeOnly=data.SaveCodeOnly;
                sfcnOptions.SupportCoverage=data.SupportCoverage;
                sfcnOptions.SupportSldv=data.SupportSldv;
                msg.content=struct('Name',sfcnName,'Language',sfcnLanguage,'Options',sfcnOptions);
            case 'refresh ports table'
                inputs=data.InputPorts;
                outputs=data.OutputPorts;
                parameters=data.Parameters;
                msg.content=struct('InputPorts',inputs,...
                'OutputPorts',outputs,...
                'Parameters',parameters);
            case 'refresh parameter table'
                parameters=data.Parameters;
                msg.content=struct('Parameters',parameters);
            case 'refresh settings'




                if isfield(data,'SampleMode')&&~isempty(data.SampleMode)
                    SampleTimeMode=data.SampleMode;
                    SampleTImeValue=data.SampleTime;
                else


                    sfunblkWizData=data;
                    SampleTimeMode='Inherited';
                    usingSampleTimeAsParameter=false;
                    for k=1:length(data.Parameters.Name)
                        paramName=data.Parameters.Name{k};
                        if(~isempty(paramName)&&strcmp(paramName,data.SampleTime))
                            sfunblkWizData.SampleTimeValue=data.Parameters.Name{k};
                            usingSampleTimeAsParameter=true;
                            SampleTimeMode='Discrete';
                            break;
                        end
                    end
                    if(strcmp(sfunblkWizData.SampleTime,getString(message('Simulink:dialog:inheritedLabel')))||...
                        strcmp(sfunblkWizData.SampleTime,getString(message('Simulink:dialog:continuousLabel')))||...
                        strcmp(sfunblkWizData.SampleTime,'Continuous')||...
                        strcmp(sfunblkWizData.SampleTime,'Inherited'))
                        sampTime=[];
                    else
                        sampTime=str2num(sfunblkWizData.SampleTime);
                    end

                    if~usingSampleTimeAsParameter
                        if(~isempty(sampTime)&&sampTime>0)
                            sfunblkWizData.SampleTimeValue=sfunblkWizData.SampleTime;
                            SampleTimeMode='Discrete';
                        else
                            sfunblkWizData.SampleTimeValue='';
                            if(strcmp(sfunblkWizData.SampleTime,getString(message('Simulink:dialog:continuousLabel')))||...
                                strcmp(sfunblkWizData.SampleTime,'Continuous'))
                                SampleTimeMode='Continuous';
                            end
                        end
                    end
                    SampleTImeValue=sfunblkWizData.SampleTime;

                end
                msg.content=struct('NumberOfDiscreteStates',data.NumberOfDiscreteStates,...
                'DiscreteStatesIC',data.DiscreteStatesIC,...
                'NumberOfContinuousStates',data.NumberOfContinuousStates,...
                'ContinuousStatesIC',data.ContinuousStatesIC,...
                'Majority',data.Majority,...
                'SampleTime',SampleTimeMode,...
                'SampleTimeValue',SampleTImeValue,...
                'NumberOfPWorks',data.NumberOfPWorks,...
                'UseSimStruct',data.UseSimStruct,...
                'DirectFeedThrough',data.DirectFeedThrough,...
                'SupportForEach',data.SupportForEach,...
                'EnableMultiThread',data.EnableMultiThread,...
                'EnableCodeReuse',data.EnableCodeReuse);
            case 'refresh editor'
                [editorContent,readOnlyLines]=readCode(data,obj.sfunctionbuilderEditorMarkers);
                msg.content=struct('editorContent',editorContent,...
                'readOnlyLines',readOnlyLines);
            case 'refresh library table'
                msg.content=struct('LibraryData',data.LibraryFilesTable);
            case{'invalid sfunction name','set source file overwritable','set sfunction tlc overwritable',...
                'refresh buildlog','fail to add port item','fail to update port table','fail to add lib path',...
                'fail to update library table','invalid setting','fail to read the file'}
                msg.content=data;
            otherwise
                assert(false,'unrecognized refresh event');
            end
            message.publish(obj.publishChannel,msg);
        end



        function initializeUI(obj)
            param=obj.sfunctionbuilderInitialContent.Parameters;
            if isempty(param.Name)||isempty(param.Name{1})
                obj.initializeEditorDialog();
            else
                obj.initializeParameterDialog();
            end
        end

        function initializeEditorDialog(obj)

            msg.command='launch editor dialog';
            message.publish(obj.publishChannel,msg);

        end

        function populateEditorDialog(obj)

            initialData=obj.sfunctionbuilderInitialContent;
            obj.refresh('refresh toolstrip',initialData);
            obj.refresh('refresh ports table',initialData);
            obj.refresh('refresh settings',initialData);
            obj.refresh('refresh library table',initialData);
        end

        function populateRTCEditor(obj)
            initialData=obj.sfunctionbuilderInitialContent;
            obj.refresh('refresh editor',initialData);
        end

        function populateParameterDialog(obj)

            initialData=obj.sfunctionbuilderInitialContent;
            obj.refresh('refresh parameter table',initialData);
        end

        function initializeParameterDialog(obj)

            msg.command='launch parameter dialog';
            message.publish(obj.publishChannel,msg);
        end


        function refreshTitle(obj,newTitle)
            if~isempty(obj.cefObj)
                obj.cefObj.Title=newTitle;
            end
        end


        function setUnSavedFlag(obj,flag)
            obj.unSavedChangeFlag=flag;
        end

    end

    methods(Static)

    end

end

function dialogPos=setEditorDialogSize(currentPos)
    screensSize=get(0,'MonitorPositions');
    screenSize=screensSize(1,:);
    dialogW=screenSize(3)/2;
    dialogH=screenSize(4)/2;
    if currentPos(3)>=dialogW&&currentPos(4)>=dialogH
        dialogPos=currentPos;
        return
    else

        dialogPos(1)=(screenSize(3)-dialogW)/2;
        dialogPos(2)=(screenSize(4)-dialogH)/2;
        dialogPos(3)=dialogW;
        dialogPos(4)=dialogH;
    end


end

function dialogPos=setParameterBlockDialogSize()
    screensSize=get(0,'MonitorPositions');
    screenSize=screensSize(1,:);
    dialogW=screenSize(3)/4;
    dialogH=screenSize(4)/3.5;


    dialogPos(1)=(screenSize(3)-dialogW)/2;
    dialogPos(2)=(screenSize(4)-dialogH)/2;
    dialogPos(3)=dialogW;
    dialogPos(4)=dialogH;
end


function typeNames=getTypeNamesForItem(item,numItems)
    typeNames=cell(1,numItems);
    if numItems==0
        return;
    end
    mskFP=strcmp(item.DataType,'fixpt');
    mskCFP=strcmp(item.DataType,'cfixpt');
    if isfield(item,'Bus')
        hasBus=true;
        mskBus=cellfun(@(x)~isempty(x)&&strcmp(x,'on'),item.Bus);
    else
        hasBus=false;
    end
    wordLengths=str2double(item.WordLength);
    isUnsigned=cellfun(@(x)isempty(x)||strcmp(x,'0'),item.IsSigned);

    typeNames((mskFP|mskCFP)&wordLengths<=64)={'int64_T'};
    typeNames((mskFP|mskCFP)&wordLengths<=32)={'int32_T'};
    typeNames((mskFP|mskCFP)&wordLengths<=16)={'int16_T'};
    typeNames((mskFP|mskCFP)&wordLengths<=8)={'int8_T'};
    typeNames((mskFP|mskCFP)&isUnsigned)=cellfun(@(x)['u',x],typeNames((mskFP|mskCFP)&isUnsigned),'UniformOutput',false);
    typeNames(mskCFP)=cellfun(@(x)['c',x],typeNames(mskCFP),'UniformOutput',false);
    if hasBus
        typeNames(~(mskFP|mskCFP)&mskBus)=item.Busname(~(mskFP|mskCFP)&mskBus);
        typeNames(~(mskFP|mskCFP)&~mskBus)=item.DataType(~(mskFP|mskCFP)&~mskBus);
    else
        typeNames(~(mskFP|mskCFP))=item.DataType(~(mskFP|mskCFP));
    end
end

function[content,readOnlyLines]=readCode(data,markers)








    readOnlyLines=[];
    if isempty(data.SfunName)
        sfuncName='system';
    else
        sfuncName=data.SfunName;
    end

    numDS=data.NumberOfDiscreteStates;
    numCS=data.NumberOfContinuousStates;
    inputs=data.InputPorts;
    outputs=data.OutputPorts;
    parameters=data.Parameters;
    useSimStruct=data.UseSimStruct;
    isZeroPWorks=ismember(data.NumberOfPWorks,{'0',''});
    isDirectFeedThrough=data.DirectFeedThrough;

    if isempty(inputs.Name)||isempty(inputs.Name{1})
        NumberOfInputs=0;
    else
        NumberOfInputs=length(inputs.Name);
    end

    if isempty(outputs.Name)||isempty(outputs.Name{1})
        NumberOfOutputs=0;
    else
        NumberOfOutputs=length(outputs.Name);
    end

    if isempty(parameters.Name)||isempty(parameters.Name{1})
        NumberOfParameters=0;
    else
        NumberOfParameters=length(parameters.Name);
    end

    if isempty(isDirectFeedThrough)||~strcmp(isDirectFeedThrough,'1')
        isDirectFeedThrough=false;
    else
        isDirectFeedThrough=true;
    end

    emptyIdx=cellfun(@(x)isempty(x),inputs.Dimensions);
    inputWidth(emptyIdx)={0};
    inputWidth(~emptyIdx)=num2cell(cellfun(@(x)prod(str2num(x)),inputs.Dimensions(~emptyIdx)));

    emptyIdx=cellfun(@(x)isempty(x),outputs.Dimensions);
    outputWidth(emptyIdx)={0};
    outputWidth(~emptyIdx)=num2cell(cellfun(@(x)prod(str2num(x)),outputs.Dimensions(~emptyIdx)));

    inputTypes=getTypeNamesForItem(inputs,NumberOfInputs);
    outputTypes=getTypeNamesForItem(outputs,NumberOfOutputs);
    currentLine=1;
    readOnlyLines=[readOnlyLines,currentLine];
    includes=data.IncludeHeadersText;
    if isempty(includes)
        includesLines=1;
    else
        includesLines=length(regexp(includes,'\r?\n','split'));
    end
    currentLine=currentLine+includesLines+1;
    readOnlyLines=[readOnlyLines,currentLine];
    content=[markers.markerPrefix,markers.includesBeginMarker,markers.markerSuffix,...
    newline,data.IncludeHeadersText,newline,...
    markers.markerPrefix,markers.includesEndMarker,markers.markerSuffix,newline];


    externsBegin=[newline,markers.markerPrefix,markers.externsBeginMarker,markers.markerSuffix];
    currentLine=currentLine+2;
    readOnlyLines=[readOnlyLines,currentLine-1:currentLine];
    if isempty(data.ExternalDeclaration)
        externsLines=1;
    else
        externsLines=length(regexp(data.ExternalDeclaration,'\r?\n','split'));
    end
    currentLine=currentLine+externsLines+1;
    readOnlyLines=[readOnlyLines,currentLine];
    content=[content,externsBegin,newline,...
    data.ExternalDeclaration,newline,...
    markers.markerPrefix,markers.externsEndMarker,markers.markerSuffix];


    startFunctionSig=['void ',sfuncName,'_Start_wrapper('];
    UserCodeTextmdlStartBegin=[newline,newline,startFunctionSig];
    prefix=blanks(0);
    if NumberOfParameters==0&&strcmp(numDS,'0')&&...
        strcmp(numCS,'0')&&isZeroPWorks&&...
        strcmp(useSimStruct,'0')
        UserCodeTextmdlStartBegin=[UserCodeTextmdlStartBegin,'void)',newline,'{'];
    else
        if~strcmp(numDS,'0')
            UserCodeTextmdlStartBegin=[UserCodeTextmdlStartBegin,prefix,'real_T *xD'];
            prefix=[',',newline,blanks(strlength(startFunctionSig))];
        end

        if~strcmp(numCS,'0')
            UserCodeTextmdlStartBegin=[UserCodeTextmdlStartBegin,prefix,'real_T *xC'];
            prefix=[',',newline,blanks(strlength(startFunctionSig))];
        end

        for i=1:NumberOfParameters
            parameter=[prefix,'const ',parameters.DataType{i},' *',parameters.Name{i},', ','const int_T p_width',num2str(i-1)];
            UserCodeTextmdlStartBegin=[UserCodeTextmdlStartBegin,parameter];
            prefix=[',',newline,blanks(strlength(startFunctionSig))];
        end


        if~isZeroPWorks
            UserCodeTextmdlStartBegin=[UserCodeTextmdlStartBegin,prefix,'void **pW'];
            prefix=[',',newline,blanks(strlength(startFunctionSig))];
        end

        if strcmp(useSimStruct,'0')
            UserCodeTextmdlStartBegin=[UserCodeTextmdlStartBegin,')',newline,'{'];
        else
            UserCodeTextmdlStartBegin=[UserCodeTextmdlStartBegin,prefix,'SimStruct *S)',newline,'{'];
        end
    end
    UserCodeTextmdlStartBegin=[UserCodeTextmdlStartBegin,newline,...
    markers.markerPrefix,markers.startBeginMarker,markers.markerSuffix];
    UserCodeTextmdlStartBeginLines=length(regexp(UserCodeTextmdlStartBegin,'\r?\n','split'));
    readOnlyLines=[readOnlyLines,currentLine+1:currentLine+UserCodeTextmdlStartBeginLines-1];
    currentLine=currentLine+UserCodeTextmdlStartBeginLines;
    if isempty(data.UserCodeTextmdlStart)
        UserCodeTextmdlStartLines=1;
    else
        UserCodeTextmdlStartLines=length(regexp(data.UserCodeTextmdlStart,'\r?\n','split'));
    end
    currentLine=currentLine+UserCodeTextmdlStartLines+1;
    UserCodeTextmdlStartEnd=[markers.markerPrefix,markers.startEndMarker,markers.markerSuffix,newline,'}'];
    readOnlyLines=[readOnlyLines,currentLine-1:currentLine];
    content=[content,UserCodeTextmdlStartBegin,newline,data.UserCodeTextmdlStart,newline,UserCodeTextmdlStartEnd];



    outputsFunctionSig=['void ',sfuncName,'_Outputs_wrapper('];
    UserCodeTextmdlOutputsBegin=[newline,newline,outputsFunctionSig];
    prefix=blanks(0);
    if NumberOfParameters==0&&(NumberOfInputs==0||~isDirectFeedThrough)&&...
        NumberOfOutputs==0&&strcmp(numDS,'0')&&...
        strcmp(numCS,'0')&&isZeroPWorks&&...
        strcmp(useSimStruct,'0')
        UserCodeTextmdlOutputsBegin=[UserCodeTextmdlOutputsBegin,'void)',newline,'{'];
    else
        if isDirectFeedThrough
            for i=1:NumberOfInputs
                input=[prefix,'const ',inputTypes{i},' *',inputs.Name{i}];
                UserCodeTextmdlOutputsBegin=[UserCodeTextmdlOutputsBegin,input];
                prefix=[',',newline,blanks(strlength(outputsFunctionSig))];
            end
        end

        for i=1:NumberOfOutputs
            output=[prefix,outputTypes{i},' *',outputs.Name{i}];
            UserCodeTextmdlOutputsBegin=[UserCodeTextmdlOutputsBegin,output];
            prefix=[',',newline,blanks(strlength(outputsFunctionSig))];
        end

        if~strcmp(numDS,'0')
            UserCodeTextmdlOutputsBegin=[UserCodeTextmdlOutputsBegin,prefix,'const real_T *xD'];
            prefix=[',',newline,blanks(strlength(outputsFunctionSig))];
        end

        if~strcmp(numCS,'0')
            UserCodeTextmdlOutputsBegin=[UserCodeTextmdlOutputsBegin,prefix,'const real_T *xC'];
            prefix=[',',newline,blanks(strlength(outputsFunctionSig))];
        end

        for i=1:NumberOfParameters
            parameter=[prefix,'const ',parameters.DataType{i},' *',parameters.Name{i},', ','const int_T p_width',num2str(i-1)];
            UserCodeTextmdlOutputsBegin=[UserCodeTextmdlOutputsBegin,parameter];
            prefix=[',',newline,blanks(strlength(outputsFunctionSig))];
        end


        if~isZeroPWorks
            UserCodeTextmdlOutputsBegin=[UserCodeTextmdlOutputsBegin,prefix,'void **pW'];
            prefix=[',',newline,blanks(strlength(outputsFunctionSig))];
        end

        negIdx=cellfun(@(x)x<0,outputWidth);
        if any(negIdx)
            if negIdx(1)
                widthStr=sprintf('const int_T y_width,');
            else
                widthStr='';
            end
            if numel(negIdx)>=2
                widthStr=sprintf(['%sconst int_T y_%d_width,'],widthStr,find(negIdx(2:end)==1)-1);
            end
            UserCodeTextmdlOutputsBegin=[UserCodeTextmdlOutputsBegin,prefix,widthStr(1:end-1)];
            prefix=[',',newline,blanks(strlength(outputsFunctionSig))];
        end

        negIdx=cellfun(@(x)x<0,inputWidth);
        if any(negIdx)&&isDirectFeedThrough
            if negIdx(1)
                widthStr=sprintf('const int_T u_width,');
            else
                widthStr='';
            end
            if numel(negIdx)>=2
                widthStr=sprintf(['%sconst int_T u_%d_width,'],widthStr,find(negIdx(2:end)==1)-1);
            end
            UserCodeTextmdlOutputsBegin=[UserCodeTextmdlOutputsBegin,prefix,widthStr(1:end-1)];
            prefix=[',',newline,blanks(strlength(outputsFunctionSig))];
        end

        if strcmp(useSimStruct,'0')
            UserCodeTextmdlOutputsBegin=[UserCodeTextmdlOutputsBegin,')',newline,'{'];
        else
            UserCodeTextmdlOutputsBegin=[UserCodeTextmdlOutputsBegin,prefix,'SimStruct *S)',newline,'{'];
        end
    end
    UserCodeTextmdlOutputsBegin=[UserCodeTextmdlOutputsBegin,newline,...
    markers.markerPrefix,markers.outputsBeginMarker,markers.markerSuffix];
    UserCodeTextmdlOutputsBeginLines=length(regexp(UserCodeTextmdlOutputsBegin,'\r?\n','split'));
    readOnlyLines=[readOnlyLines,currentLine+1:currentLine+UserCodeTextmdlOutputsBeginLines-1];
    currentLine=currentLine+UserCodeTextmdlOutputsBeginLines;
    if isempty(data.UserCodeText)
        UserCodeTextmdlLines=1;
    else
        UserCodeTextmdlLines=length(regexp(data.UserCodeText,'\r?\n','split'));
    end
    currentLine=currentLine+UserCodeTextmdlLines+1;
    UserCodeTextmdlOutputsEnd=[markers.markerPrefix,markers.outputsEndMarker,markers.markerSuffix,newline,'}'];
    readOnlyLines=[readOnlyLines,currentLine-1:currentLine];
    content=[content,UserCodeTextmdlOutputsBegin,newline,data.UserCodeText,newline,UserCodeTextmdlOutputsEnd];





    if~strcmp(numDS,'0')
        updateFunctionSig=['void ',sfuncName,'_Update_wrapper('];
        UserCodeTextmdlUpdateBegin=[newline,newline,updateFunctionSig];
        prefix=blanks(0);
        for i=1:NumberOfInputs
            input=[prefix,'const ',inputTypes{i},' *',inputs.Name{i}];
            UserCodeTextmdlUpdateBegin=[UserCodeTextmdlUpdateBegin,input];
            prefix=[',',newline,blanks(strlength(updateFunctionSig))];
        end

        for i=1:NumberOfOutputs
            output=[prefix,outputTypes{i},' *',outputs.Name{i}];
            UserCodeTextmdlUpdateBegin=[UserCodeTextmdlUpdateBegin,output];
            prefix=[',',newline,blanks(strlength(updateFunctionSig))];
        end

        if~strcmp(numDS,'0')
            UserCodeTextmdlUpdateBegin=[UserCodeTextmdlUpdateBegin,prefix,'real_T *xD'];
            prefix=[',',newline,blanks(strlength(updateFunctionSig))];
        end

        for i=1:NumberOfParameters
            parameter=[prefix,'const ',parameters.DataType{i},' *',parameters.Name{i},', ','const int_T p_width',num2str(i-1)];
            UserCodeTextmdlUpdateBegin=[UserCodeTextmdlUpdateBegin,parameter];
            prefix=[',',newline,blanks(strlength(updateFunctionSig))];
        end


        if~isZeroPWorks
            UserCodeTextmdlUpdateBegin=[UserCodeTextmdlUpdateBegin,prefix,'void **pW'];
            prefix=[',',newline,blanks(strlength(updateFunctionSig))];
        end

        negIdx=cellfun(@(x)x<0,outputWidth);
        if any(negIdx)
            if negIdx(1)
                widthStr=sprintf('const int_T y_width,');
            else
                widthStr='';
            end
            if numel(negIdx)>=2
                widthStr=sprintf(['%sconst int_T y_%d_width,'],widthStr,find(negIdx(2:end)==1)-1);
            end
            UserCodeTextmdlUpdateBegin=[UserCodeTextmdlUpdateBegin,prefix,widthStr(1:end-1)];
            prefix=[',',newline,blanks(strlength(updateFunctionSig))];
        end

        negIdx=cellfun(@(x)x<0,inputWidth);
        if any(negIdx)&&isDirectFeedThrough
            if negIdx(1)
                widthStr=sprintf('const int_T u_width,');
            else
                widthStr='';
            end
            if numel(negIdx)>=2
                widthStr=sprintf(['%sconst int_T u_%d_width,'],widthStr,find(negIdx(2:end)==1)-1);
            end
            UserCodeTextmdlUpdateBegin=[UserCodeTextmdlUpdateBegin,prefix,widthStr(1:end-1)];
            prefix=[',',newline,blanks(strlength(updateFunctionSig))];
        end

        if strcmp(useSimStruct,'0')
            UserCodeTextmdlUpdateBegin=[UserCodeTextmdlUpdateBegin,')',newline,'{'];
        else
            UserCodeTextmdlUpdateBegin=[UserCodeTextmdlUpdateBegin,prefix,'SimStruct *S)',newline,'{'];
        end

        UserCodeTextmdlUpdateBegin=[UserCodeTextmdlUpdateBegin,newline,markers.markerPrefix,markers.updateBeginMarker,markers.markerSuffix];
        UserCodeTextmdlUpdateBeginLines=length(regexp(UserCodeTextmdlUpdateBegin,'\r?\n','split'));
        readOnlyLines=[readOnlyLines,currentLine+1:currentLine+UserCodeTextmdlUpdateBeginLines-1];
        currentLine=currentLine+UserCodeTextmdlUpdateBeginLines;
        if isempty(data.UserCodeTextmdlUpdate)
            UserCodeTextmdlLines=1;
        else
            UserCodeTextmdlLines=length(regexp(data.UserCodeTextmdlUpdate,'\r?\n','split'));
        end
        currentLine=currentLine+UserCodeTextmdlLines+1;
        UserCodeTextmdlUpdateEnd=[markers.markerPrefix,markers.updateEndMarker,markers.markerSuffix,newline,'}'];
        readOnlyLines=[readOnlyLines,currentLine-1:currentLine];
        content=[content,UserCodeTextmdlUpdateBegin,newline,data.UserCodeTextmdlUpdate,newline,UserCodeTextmdlUpdateEnd];
    end




    if~strcmp(numCS,'0')
        derivativesFunctionSig=['void ',sfuncName,'_Derivatives_wrapper('];
        UserCodeTextmdlDerivativesBegin=[newline,newline,derivativesFunctionSig];
        prefix=blanks(0);

        for i=1:NumberOfInputs
            input=[prefix,'const ',inputTypes{i},' *',inputs.Name{i}];
            UserCodeTextmdlDerivativesBegin=[UserCodeTextmdlDerivativesBegin,input];
            prefix=[',',newline,blanks(strlength(derivativesFunctionSig))];
        end

        for i=1:NumberOfOutputs
            output=[prefix,outputTypes{i},' *',outputs.Name{i}];
            UserCodeTextmdlDerivativesBegin=[UserCodeTextmdlDerivativesBegin,output];
            prefix=[',',newline,blanks(strlength(derivativesFunctionSig))];
        end

        UserCodeTextmdlDerivativesBegin=[UserCodeTextmdlDerivativesBegin,prefix,'real_T *dx,',...
        newline,blanks(strlength(derivativesFunctionSig)),'real_T *xC'];

        for i=1:NumberOfParameters
            parameter=[prefix,'const ',parameters.DataType{i},' *',parameters.Name{i},', ','const int_T p_width',num2str(i-1)];
            UserCodeTextmdlDerivativesBegin=[UserCodeTextmdlDerivativesBegin,parameter];
            prefix=[',',newline,blanks(strlength(derivativesFunctionSig))];
        end


        if~isZeroPWorks
            UserCodeTextmdlDerivativesBegin=[UserCodeTextmdlDerivativesBegin,prefix,'void **pW'];
            prefix=[',',newline,blanks(strlength(derivativesFunctionSig))];
        end

        negIdx=cellfun(@(x)x<0,outputWidth);
        if any(negIdx)
            if negIdx(1)
                widthStr=sprintf('const int_T y_width,');
            else
                widthStr='';
            end
            if numel(negIdx)>=2
                widthStr=sprintf(['%sconst int_T y_%d_width,'],widthStr,find(negIdx(2:end)==1)-1);
            end
            UserCodeTextmdlDerivativesBegin=[UserCodeTextmdlDerivativesBegin,prefix,widthStr(1:end-1)];
            prefix=[',',newline,blanks(strlength(derivativesFunctionSig))];
        end

        negIdx=cellfun(@(x)x<0,inputWidth);
        if any(negIdx)&&isDirectFeedThrough
            if negIdx(1)
                widthStr=sprintf('const int_T u_width,');
            else
                widthStr='';
            end
            if numel(negIdx)>=2
                widthStr=sprintf(['%sconst int_T u_%d_width,'],widthStr,find(negIdx(2:end)==1)-1);
            end
            UserCodeTextmdlDerivativesBegin=[UserCodeTextmdlDerivativesBegin,prefix,widthStr(1:end-1)];
            prefix=[',',newline,blanks(strlength(derivativesFunctionSig))];
        end

        if strcmp(useSimStruct,'0')
            UserCodeTextmdlDerivativesBegin=[UserCodeTextmdlDerivativesBegin,')',newline,'{'];
        else
            UserCodeTextmdlDerivativesBegin=[UserCodeTextmdlDerivativesBegin,prefix,'SimStruct *S)',newline,'{'];
        end

        UserCodeTextmdlDerivativesBegin=[UserCodeTextmdlDerivativesBegin,newline,markers.markerPrefix,markers.derivativesBeginMarker,markers.markerSuffix];
        UserCodeTextmdlDerivativesBeginLines=length(regexp(UserCodeTextmdlDerivativesBegin,'\r?\n','split'));
        readOnlyLines=[readOnlyLines,currentLine+1:currentLine+UserCodeTextmdlDerivativesBeginLines-1];
        currentLine=currentLine+UserCodeTextmdlDerivativesBeginLines;
        if isempty(data.UserCodeTextmdlDerivative)
            UserCodeTextmdlLines=1;
        else
            UserCodeTextmdlLines=length(regexp(data.UserCodeTextmdlDerivative,'\r?\n','split'));
        end
        currentLine=currentLine+UserCodeTextmdlLines+1;
        UserCodeTextmdlDerivativesEnd=[markers.markerPrefix,markers.derivativesEndMarker,markers.markerSuffix,newline,'}'];
        readOnlyLines=[readOnlyLines,currentLine-1:currentLine];
        content=[content,UserCodeTextmdlDerivativesBegin,newline,data.UserCodeTextmdlDerivative,newline,UserCodeTextmdlDerivativesEnd];
    end




    terminateFunctionSig=['void ',sfuncName,'_Terminate_wrapper('];
    UserCodeTextmdlTerminateBegin=[newline,newline,terminateFunctionSig];
    prefix=blanks(0);
    if isempty(parameters.Name)&&strcmp(numDS,'0')&&strcmp(numCS,'0')&&isZeroPWorks&&...
        strcmp(useSimStruct,'0')
        UserCodeTextmdlTerminateBegin=[UserCodeTextmdlTerminateBegin,'void)',newline,'{'];
    else

        if~strcmp(numDS,'0')
            UserCodeTextmdlTerminateBegin=[UserCodeTextmdlTerminateBegin,prefix,'real_T *xD'];
            prefix=[',',newline,blanks(strlength(terminateFunctionSig))];
        end

        if~strcmp(numCS,'0')
            UserCodeTextmdlTerminateBegin=[UserCodeTextmdlTerminateBegin,prefix,'real_T *xC'];
            prefix=[',',newline,blanks(strlength(terminateFunctionSig))];
        end

        for i=1:NumberOfParameters
            parameter=[prefix,'const ',parameters.DataType{i},' *',parameters.Name{i},', ','const int_T p_width',num2str(i-1)];
            UserCodeTextmdlTerminateBegin=[UserCodeTextmdlTerminateBegin,parameter];
            prefix=[',',newline,blanks(strlength(terminateFunctionSig))];
        end


        if~isZeroPWorks
            UserCodeTextmdlTerminateBegin=[UserCodeTextmdlTerminateBegin,prefix,'void **pW'];
            prefix=[',',newline,blanks(strlength(terminateFunctionSig))];
        end

        if strcmp(useSimStruct,'0')
            UserCodeTextmdlTerminateBegin=[UserCodeTextmdlTerminateBegin,')',newline,'{'];
        else
            UserCodeTextmdlTerminateBegin=[UserCodeTextmdlTerminateBegin,prefix,'SimStruct *S)',newline,'{'];
        end

    end
    UserCodeTextmdlTerminateBegin=[UserCodeTextmdlTerminateBegin,newline,markers.markerPrefix,markers.terminateBeginMarker,markers.markerSuffix];
    UserCodeTextmdlTerminateBeginLines=length(regexp(UserCodeTextmdlTerminateBegin,'\r?\n','split'));
    readOnlyLines=[readOnlyLines,currentLine+1:currentLine+UserCodeTextmdlTerminateBeginLines-1];
    currentLine=currentLine+UserCodeTextmdlTerminateBeginLines;
    if isempty(data.UserCodeTextmdlTerminate)
        UserCodeTextmdlLines=1;
    else
        UserCodeTextmdlLines=length(regexp(data.UserCodeTextmdlTerminate,'\r?\n','split'));
    end
    currentLine=currentLine+UserCodeTextmdlLines+1;
    UserCodeTextmdlTerminateEnd=[markers.markerPrefix,markers.terminateEndMarker,markers.markerSuffix,newline,'}'];
    readOnlyLines=[readOnlyLines,currentLine-1:currentLine];
    content=[content,UserCodeTextmdlTerminateBegin,newline,data.UserCodeTextmdlTerminate,newline,UserCodeTextmdlTerminateEnd];

end


function codeInfo=parseEditorContent(content,markers)

    codeInfo.IncludeHeadersText=readSections(content,markers.includesBeginMarker,markers.includesEndMarker);

    codeInfo.ExternalDeclaration=readSections(content,markers.externsBeginMarker,markers.externsEndMarker);

    codeInfo.UserCodeTextmdlStart=readSections(content,markers.startBeginMarker,markers.startEndMarker);

    codeInfo.UserCodeText=readSections(content,markers.outputsBeginMarker,markers.outputsEndMarker);

    codeInfo.UserCodeTextmdlUpdate=readSections(content,markers.updateBeginMarker,markers.updateEndMarker);

    codeInfo.UserCodeTextmdlDerivative=readSections(content,markers.derivativesBeginMarker,markers.derivativesEndMarker);

    codeInfo.UserCodeTextmdlTerminate=readSections(content,markers.terminateBeginMarker,markers.terminateEndMarker);
end



function info=readSections(content,beginMarker,endMarker)
    expression=['(?<=\/\* ',beginMarker,' \*\/\n)(.*)(?=\n\/\* ',endMarker,' \*\/)'];
    matchStr=regexp(content,expression,'match');

    if length(matchStr)==1
        info=matchStr{1};
    else
        info=[];
    end

end



function SfunWizardData=attachErrorMessagePortTable(SfunWizardData,item,fieldToUpdate,oldValue,errorMsg)
    switch fieldToUpdate
    case 'name'
        portName=oldValue;
        portScope=item{2};
        switch portScope
        case 'input'
            idx=strcmp(SfunWizardData.InputPorts.Name,portName);
            portNameWithError=struct('oldValue',portName,'newValue',item{1},'errorMsg',errorMsg);
            SfunWizardData.InputPorts.Name{idx}=portNameWithError;
        case 'output'
            idx=strcmp(SfunWizardData.OutputPorts.Name,portName);
            portNameWithError=struct('oldValue',portName,'newValue',item{1},'errorMsg',errorMsg);
            SfunWizardData.OutputPorts.Name{idx}=portNameWithError;
        case 'parameter'
            idx=strcmp(SfunWizardData.Parameters.Name,portName);
            portNameWithError=struct('oldValue',portName,'newValue',item{1},'errorMsg',errorMsg);
            SfunWizardData.Parameters.Name{idx}=portNameWithError;
        end
    case 'dimension'
        portName=item{1};
        portScope=item{2};
        portDims=item{4};

        switch portScope
        case 'input'
            idx=strcmp(SfunWizardData.InputPorts.Name,portName);
            SfunWizardData.InputPorts.Dims{idx}=portDims;
        case 'output'
            idx=strcmp(SfunWizardData.OutputPorts.Name,portName);
            SfunWizardData.OutputPorts.Dims{idx}=portDims;
        case 'parameter'
            assert(false,'Dimension is not editable for parameter in sfunction');
        end
    end
end


function SfunWizardData=attachErrorMessageLibTable(SfunWizardData,item,fieldToUpdate,oldValue,index,errorMsg)
    if strcmp(fieldToUpdate,'value')
        libValue=oldValue;
    elseif strcmp(fieldToUpdate,'tag')
        libValue=item{2};
    end
    portNameWithError=struct('oldValue',libValue,'newValue',item{2},'errorMsg',errorMsg);
    myFields={'SrcPaths','LibPaths','IncPaths','EnvPaths','Entries'};
    indexList=zeros(size(myFields));
    for idx=1:numel(myFields)
        indexList(idx)=numel(SfunWizardData.LibraryFilesTable.(myFields{idx}));
    end
    cumIndexList=cumsum(indexList);
    fieldIdx=find(index<=cumIndexList,1);
    if fieldIdx==1
        offsetVal=0;
    else
        offsetVal=cumIndexList(fieldIdx-1);
    end
    SfunWizardData.LibraryFilesTable.(myFields{fieldIdx}){index-offsetVal}=portNameWithError;
end
