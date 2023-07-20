classdef DataTipRowHelper<handle






    methods(Static)


        function actionEventHandler(ed)
            switch ed.actionType
            case 'updateDataTipRow'
                matlab.graphics.datatip.internal.DataTipRowHelper.updateDataTipRow(ed);
            case 'deleteDataTipRow'
                matlab.graphics.datatip.internal.DataTipRowHelper.deleteDataTipRow(ed);
            end
        end

        function updateDataTipRow(ed,hObj)


            if nargin==1
                hDataTipTemplate=getInspectedDataTipTemplate();
            else
                hDataTipTemplate=hObj;
            end

            rowNumber=ed.rowIndex;
            if rowNumber>numel(hDataTipTemplate.DataTipRows)
                dataTipRow=matlab.graphics.datatip.DataTipTextRow('','');
            else
                dataTipRow=hDataTipTemplate.DataTipRows(rowNumber);
            end

            switch(char(ed.propertyName))
            case 'Label'
                dataTipRow.Label=char(ed.rowData(1));
            case 'Value'
                value=char(ed.rowData(2));

                if~isempty(value)&&...
                    ~matlab.graphics.datatip.internal.DataTipTemplateHelper.isValueSourceValid...
                    (hDataTipTemplate.Parent,value)&&...
                    ~isprop(hDataTipTemplate.Parent,value)
                    value=evalin('base',value);
                end
                dataTipRow.Value=value;
            case 'Format'
                dataTipRow.Format=char(ed.rowData(3));
            end

            if isempty(dataTipRow.Label)&&isempty(dataTipRow.Value)&&...
                strcmpi(dataTipRow.Format,'auto')
                matlab.graphics.datatip.internal.DataTipRowHelper.deleteDataTipRow(ed,hDataTipTemplate);
                return;
            end
            dataTipRows=hDataTipTemplate.DataTipRows;

            if rowNumber>numel(hDataTipTemplate.DataTipRows)
                dataTipRows(end+1)=dataTipTextRow(dataTipRow.Label,dataTipRow.Value,dataTipRow.Format);
            else
                dataTipRows(rowNumber)=dataTipTextRow(dataTipRow.Label,dataTipRow.Value,dataTipRow.Format);
            end

            local_registerPropSetUndo(hDataTipTemplate,dataTipRows);
            hDataTipTemplate.DataTipRows=dataTipRows;
        end

        function validationData=validateDataTipRow(rowIndex,propName,propValue,hObj)
            try
                if nargin==3
                    hDataTipTemplate=getInspectedDataTipTemplate();
                else
                    hDataTipTemplate=hObj;
                end
                validationData=struct('isValid',true,'msg','');
                switch(propName)
                case 'Label'
                case 'Value'
                    evaluatedValue=[];
                    try
                        if~isempty(propValue)&&ischar(propValue)&&...
                            ~matlab.graphics.datatip.internal.DataTipTemplateHelper.isValueSourceValid...
                            (hDataTipTemplate.Parent,propValue)&&...
                            ~isprop(hDataTipTemplate.Parent,propValue)
                            try
                                propValue=evalin('base',propValue);
                            catch ex
                                validationData.isValid=false;
                                validationData.msg=message('MATLAB:graphics:datatip:InvalidValueProperty');
                            end
                        end
                        [~,~]=matlab.graphics.datatip.DataTipTextRow.validateValue...
                        (propValue,hDataTipTemplate.Parent);
                    catch ex
                        validationData.isValid=false;
                        validationData.msg=ex.message;
                    end
                case 'Format'
                    try
                        evaluatedValue=matlab.graphics.datatip.internal.DataTipRowHelper.getEvaluatedRowValue...
                        (rowIndex);
                        matlab.graphics.datatip.DataTipTextRow.validateFormat(propValue,evaluatedValue);
                    catch ex
                        validationData.isValid=false;
                        validationData.msg=ex.message;
                    end
                end
            catch ex
                validationData.msg=ex.message;
            end
        end

        function deleteDataTipRow(ed,hObj)
            if nargin==1
                hDataTipTemplate=getInspectedDataTipTemplate();
            else
                hDataTipTemplate=hObj;
            end
            dataTipRows=hDataTipTemplate.DataTipRows;


            if numel(hDataTipTemplate.DataTipRows)<ed.rowIndex
                return;
            end

            dataTipRows(ed.rowIndex)=[];
            local_registerPropSetUndo(hDataTipTemplate,dataTipRows);
            hDataTipTemplate.DataTipRows=dataTipRows;
        end

        function evaluatedValue=getEvaluatedRowValue(rowIndex,hObj)
            evaluatedValue=[];
            if nargin==1
                hDataTipTemplate=getInspectedDataTipTemplate();
            else
                hDataTipTemplate=hObj;
            end
            if numel(hDataTipTemplate.DataTipRows)<rowIndex
                return;
            end
            dataTipRow=hDataTipTemplate.DataTipRows(rowIndex);
            [~,evaluatedValue]=matlab.graphics.datatip.DataTipTextRow.validateValue...
            (dataTipRow.Value,hDataTipTemplate.Parent);
        end

        function tipDescriptors=getCurrentTipDescriptors(hObj)
            tipDescriptors=matlab.graphics.chart.interaction.dataannotatable.DataDescriptor.empty;
            if nargin==0
                hDataTipTemplate=getInspectedDataTipTemplate();
            else
                hDataTipTemplate=hObj;
            end

            if~isempty(hDataTipTemplate)
                currentTip=hDataTipTemplate.getCurrentDataTip();
                if isempty(currentTip)
                    tipDescriptors=matlab.graphics.datatip.internal.DataTipTemplateHelper.generateContent(...
                    hDataTipTemplate.Parent,1);
                else
                    tipDescriptors=currentTip.Cursor.getDataDescriptors();
                end
            end
        end

        function data=getSourceAndFormatData(rowIndex,hObj)
            data=struct('sourceData','','formatData','');
            if nargin==1
                hDataTipTemplate=getInspectedDataTipTemplate();
            else
                hDataTipTemplate=hObj;
            end
            data.formatData=matlab.graphics.datatip.internal.DataTipRowHelper.getFormattingData(hDataTipTemplate,rowIndex);
            data.sourceData=matlab.graphics.datatip.internal.DataTipRowHelper.getValueSourceData(hDataTipTemplate);
        end

        function formatData=getFormattingData(hObj,rowIndex)
            formatData={'auto','usd','eur','gbp','jpy','degrees','percentage',...
            'yyyy-MM-dd','eeee, MMMM d, yyyy HH:mm:ss','MMMM d, yyyy HH:mm:ss Z',...
            'y','d','h','m','s'};
            if rowIndex==0||numel(hObj.DataTipRows)<rowIndex
                return;
            end
            evaluatedValue=matlab.graphics.datatip.internal.DataTipRowHelper.getEvaluatedRowValue(rowIndex,hObj);
            if~isempty(evaluatedValue)
                try
                    if isnumeric(evaluatedValue(1))
                        formatData={'auto','usd','eur','gbp','jpy','degrees','percentage'};
                    elseif isdatetime(evaluatedValue(1))
                        formatData={'auto','yyyy-MM-dd','eeee, MMMM d, yyyy HH:mm:ss','MMMM d, yyyy HH:mm:ss Z'};
                    elseif isduration(evaluatedValue(1))
                        formatData={'auto','y','d','h','m','s'};
                    else
                        formatData={'auto'};
                    end
                catch
                end
            end
        end

        function sourceData=getValueSourceData(hObj)
            sourceData=hObj.Parent.getAllValidValueSources();
            varW=evalin('base','whos;');
            for i=1:numel(varW)
                data=evalin('base',varW(i).name);
                if strcmp(varW(i).class,'table')||strcmp(varW(i).class,'timetable')
                    for j=1:numel(data.Properties.VariableNames)
                        sourceData=[sourceData;string(strcat(varW(i).name,'.',data.Properties.VariableNames(j)))];
                    end
                elseif~isobject(data)&&~ischar(data)&&...
                    (isvector(data)||isa(data,'double'))&&...
                    (isprop(hObj.Parent,(sourceData(1)))&&...
                    numel(data)>=numel(hObj.Parent.(sourceData(1))))
                    sourceData=[sourceData;string(varW(i).name)];
                end
            end
        end
    end
end


function hDT=getInspectedDataTipTemplate()
    hInspectorInstance=internal.matlab.inspector.peer.InspectorFactory.createInspector('default','/PropertyInspector');
    hDT=[];
    if isprop(hInspectorInstance,'handleVariable')
        hDTProxy=hInspectorInstance.handleVariable;
        if~isempty(hDTProxy)
            hDT=hDTProxy.OriginalObjects(end);
        end
    end
end


function local_registerPropSetUndo(hObj,propValue)

    cmd=matlab.uitools.internal.uiundo.FunctionCommand;
    cmd.Name=[getString(message('MATLAB:propertyinspector:SetProperty')),':','DataTipRows'];
    cmd.Function=@localPropSet;
    cmd.Varargin={hObj,propValue};
    cmd.InverseFunction=@localPropSet;
    cmd.InverseVarargin={hObj,hObj.DataTipRows};
    hParent=hObj.Parent;

    hCurrentFigure=ancestor(hParent,'figure');
    if~isempty(hCurrentFigure)
        uiundo(hCurrentFigure,'function',cmd);
    end
end

function localPropSet(hObj,propValue)
    hObj.DataTipRows=propValue;
end
