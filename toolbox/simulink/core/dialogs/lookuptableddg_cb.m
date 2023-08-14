function[status,message]=lookuptableddg_cb(dlg,op,varargin)



    status=true;
    message='';

    obj=getDialogObject(dlg);









    if isequal(op,'preapply')
        [status,message]=updateForPreApply(dlg,obj);

    elseif isequal(op,'postapply')
        updateForPostApply(dlg,obj);

    elseif isequal(op,'prerevert')
        updateForPrerevert(obj);

    elseif isequal(op,'close')
        updateForCloseButton(obj);

    elseif isequal(op,'dimensions_tag')
        updateDimensionField(dlg,obj,varargin{1},varargin{2});

    elseif isequal(op,'grpTypeDef_tag')
        updateGroupTypeField(obj,varargin);

    elseif isequal(op,'FieldName')



    elseif isequal(op,'breakpointsspecification_tag')
        updateBreakpointSpecificationField(dlg,obj,varargin{1});

    end
end


function[status,message]=updateForPreApply(dlg,obj)

    status=retrieveTableBreakpointValues(dlg,obj);
    message='';
    if(isequal(status,false))
        return;
    end
    status=validateTableBreakpointValues(dlg,obj.DialogData);
    if(true==status)
        [status,message]=saveData(obj);
    end
end


function status=validateTableBreakpointValues(dlg,data)
    status=true;
    dimensionsTable=size(data.Table.Value);
    if isempty(data.Table.Value)
        status=false;
        errordlg(DAStudio.message('Simulink:Data:LUT_TableShouldNotBeScalarOrStruct'),dlg.getTitle,'modal');
    elseif isvector(data.Table.Value)
        if isequal(data.BreakpointsSpecification,'Reference')
            if(numel(data.Breakpoints)~=numel(data.Table))
                status=false;
                errordlg(DAStudio.message('Simulink:dialog:MismatchTableAndBreakpoints'),dlg.getTitle,'modal');
            end
        elseif isequal(data.BreakpointsSpecification,'Explicit values')
            if numel(data.Breakpoints)>=2
                status=false;
                errordlg(DAStudio.message('Simulink:dialog:MismatchTableAndBreakpoints'),dlg.getTitle,'modal');
            elseif(length(data.Breakpoints(1).Value)==1||~isvector(data.Breakpoints(1).Value))
                status=false;
                errordlg(DAStudio.message('Simulink:dialog:BreakpointIsNotVector',num2str(1)),dlg.getTitle,'modal');
            elseif numel(data.Breakpoints(1).Value)~=numel(data.Table.Value)
                status=false;
                errordlg(DAStudio.message('Simulink:dialog:MismatchTableAndBreakpointsDimensions',num2str(1)),dlg.getTitle,'modal');
            end
        elseif isequal(data.BreakpointsSpecification,'Even spacing')
            if numel(data.Breakpoints)>=2
                status=false;
                errordlg(DAStudio.message('Simulink:dialog:MismatchTableAndBreakpoints'));
            end
        end
    else
        if length(dimensionsTable)~=length(data.Breakpoints)
            status=false;
            errordlg(DAStudio.message('Simulink:dialog:MismatchTableAndBreakpoints'),dlg.getTitle,'modal');
        else
            if(isequal(data.BreakpointsSpecification,'Explicit values'))

                for i=1:length(data.Breakpoints)
                    if(~isvector(data.Breakpoints(i).Value))
                        status=false;
                        errordlg(DAStudio.message('Simulink:dialog:BreakpointIsNotVector',num2str(i)),dlg.getTitle,'modal');
                        break;
                    else

                        if(dimensionsTable(i)~=numel(data.Breakpoints(i).Value))
                            status=false;
                            errordlg(DAStudio.message('Simulink:dialog:MismatchTableAndBreakpointsDimensions',num2str(i)),dlg.getTitle,'modal');
                            break;
                        end
                    end
                end
            end
        end
    end
end


function usingLUTWidget=isUsingLUTWidget(obj)

    usingLUTWidget=isequal(obj.DialogData.BreakpointsSpecification,'Explicit values');






end

function status=retrieveTableBreakpointValuesFromLUTWidget(dlg,obj)
    status=true;
    try
        data=obj.DialogData;
        lutw=data.WidgetData;
        data.Table.Value=lutw.Table.Value;
        data.Table.Unit=lutw.Table.Unit;
        data.Table.FieldName=lutw.Table.FieldName;
        for idx=1:length(data.Breakpoints)
            data.Breakpoints(idx).Value=lutw.Axes(idx).Value;
            data.Breakpoints(idx).Unit=lutw.Axes(idx).Unit;
            data.Breakpoints(idx).FieldName=lutw.Axes(idx).FieldName;
        end
        obj.DialogData=data;
    catch e %#ok

        if strcmp(e.identifier,'MATLAB:array:SizeLimitExceeded')
            status=false;
            errordlg(e.message,dlg.getTitle,'modal');
            return;
        else
            status=false;
            errordlg(DAStudio.message('Simulink:dialog:LookupTableInvalidValueForTable'),dlg.getTitle,'modal');
            return;
        end
    end
end


function status=retrieveTableBreakpointValues(dlg,obj)
    status=true;
    usingLUTWidget=isUsingLUTWidgetOnEditor(obj);
    if(usingLUTWidget)
        status=retrieveTableBreakpointValuesFromLUTWidget(dlg,obj);
    else
        data=obj.DialogData;
        idx=i_valueIndex(data.table);
        if(true==obj.DialogData.TableValueDirty)
            try
                data.Table.Value=obj.evalPropValue('Table',data.table{idx}.Value,dlg.getContext());
            catch e %#ok

                if strcmp(e.identifier,'MATLAB:array:SizeLimitExceeded')
                    status=false;
                    errordlg(e.message,dlg.getTitle,'modal');
                    return;
                else
                    status=false;
                    errordlg(DAStudio.message('Simulink:dialog:LookupTableInvalidValueForTable'),dlg.getTitle,'modal');
                    return;
                end
            end
        end


        try
            if isequal(obj.DialogData.BreakpointsSpecification,'Explicit values')

                for row=1:length(data.Breakpoints)
                    if(true==obj.DialogData.BPValueDirty(row))
                        data.Breakpoints(row).Value=obj.evalPropValue('Breakpoints',data.bp{row,idx}.Value,dlg.getContext());
                    end
                end

            elseif isequal(obj.DialogData.BreakpointsSpecification,'Even spacing')
                for row=1:length(data.Breakpoints)
                    if(obj.DialogData.BPFirstpointValueDirty(row))
                        data.Breakpoints(row).FirstPoint=obj.evalPropValue('Breakpoints',data.bp{row,idx}.Value,dlg.getContext());
                    end
                    if(obj.DialogData.BPSpacingValueDirty(row))
                        data.Breakpoints(row).Spacing=obj.evalPropValue('Breakpoints',data.bp{row,idx+1}.Value,dlg.getContext());
                    end
                end
            end
        catch e %#ok
            status=false;
            errordlg(DAStudio.message('Simulink:dialog:LookupTableInvalidValueForBreakpoints',num2str(row)),dlg.getTitle,'modal');
            return;
        end
        obj.DialogData=data;
    end
end


function updateDimensionField(dlg,obj,dimValue,wsobj)
    data=obj.DialogData.bp;
    obj.DialogData.DataDimensions=dimValue;
    if nargin==4
        wsObj=wsobj;
    else
        wsObj=[];
    end
    [rows,col]=size(data);%#ok
    storedIntColRequired=false;
    for rowidx=1:rows
        dtObj=Simulink.data.getDataTypeObjIfFixpt(obj.DialogData.Breakpoints(rowidx),wsObj);
        if~isempty(dtObj)
            storedIntColRequired=true;
            break;
        end
    end
    if dimValue>rows
        isBpFromALUTObj=true;
        for count=(rows+1):dimValue
            if isequal(obj.DialogData.BreakpointsSpecification,'Reference')
                bp=['BP',num2str(count)];
                supportEnumType=false;
                data=[data;lookuptableddg_addData(obj,bp,count,isBpFromALUTObj,supportEnumType)];%#ok
                obj.DialogData.Breakpoints{count}=bp;
            elseif isequal(obj.DialogData.BreakpointsSpecification,'Explicit values')
                bp=Simulink.lookuptable.Breakpoint.Create(int32(count));
                supportEnumType=true;
                data=[data;lookuptableddg_addData(obj,bp,count,isBpFromALUTObj,supportEnumType,wsObj,storedIntColRequired)];%#ok
                obj.DialogData.Breakpoints(count)=bp;
                if isLUTWidgetDataToBeUpdated(obj)
                    obj.DialogData.WidgetData.Axes(count)=LUTWidget.Axis;
                    updateLUTWidgetAxisDataWithDialogDataBreakpointCache(obj,obj.DialogData.WidgetData,count);
                end
            elseif isequal(obj.DialogData.BreakpointsSpecification,'Even spacing')
                bp=Simulink.lookuptable.Evenspacing.Create(int32(count));
                supportEnumType=false;
                data=[data;lookuptableddg_addData(obj,bp,count,isBpFromALUTObj,supportEnumType,wsObj,storedIntColRequired)];%#ok
                obj.DialogData.Breakpoints(count)=bp;
            end
        end

        obj.DialogData.bp=data;
        dlg.refresh();
    elseif dimValue<rows
        obj.DialogData.bp=data(1:dimValue,:);
        obj.DialogData.Breakpoints=obj.DialogData.Breakpoints(1:dimValue);
        if isLUTWidgetDataToBeUpdated(obj)
            obj.DialogData.WidgetData.Axes=obj.DialogData.WidgetData.Axes(1:dimValue);
        end
        dlg.refresh();
    end

end


function updateGroupTypeField(obj,varargin)
    va=varargin{1};
    objProperty=va{1};
    objValue=va{2};
    if isequal(objProperty,'DataScope')
        dataScopeEntries=va{3};
        dataScopeStr=dataScopeEntries(objValue+1);
        obj.DialogData.StructTypeInfo.(objProperty)=dataScopeStr{1};
    else
        obj.DialogData.StructTypeInfo.(objProperty)=objValue;
    end

end

function updateDialogDataCacheWithWidgetData(obj)

    if isLUTWidgetDataToBeUpdated(obj)
        obj.DialogData.Table.Value=obj.DialogData.WidgetData.Table.Value;





    end
end

function isWidgetToBeUpdated=isLUTWidgetDataToBeUpdated(obj)
    isWidgetToBeUpdated=isUsingLUTWidgetOnEditor(obj)&&...
    isequal(obj.DialogData.BreakpointsSpecification,'Explicit values')&&...
    isfield(obj.DialogData,'WidgetData');
end

function updateLUTWidgetTableDataWithDialogDataCache(obj,lutWidgetData)
    if isLUTWidgetDataToBeUpdated(obj)
        lutWidgetData.Table.Value=obj.DialogData.Table.Value;
        lutWidgetData.Table.Unit=obj.DialogData.Table.Unit;
        lutWidgetData.Table.FieldName=obj.DialogData.Table.FieldName;
        lutWidgetData.Table.Min=obj.DialogData.Table.Min;
        lutWidgetData.Table.Max=obj.DialogData.Table.Max;
    end
end

function updateLUTWidgetAxisDataWithDialogDataBreakpointCache(obj,lutWidgetData,axisIndex)
    if isLUTWidgetDataToBeUpdated(obj)
        lutWidgetData.Axes(axisIndex).Value=obj.DialogData.Breakpoints(axisIndex).Value;
        lutWidgetData.Axes(axisIndex).Unit=obj.DialogData.Breakpoints(axisIndex).Unit;
        lutWidgetData.Axes(axisIndex).FieldName=obj.DialogData.Breakpoints(axisIndex).FieldName;
        lutWidgetData.Axes(axisIndex).Min=obj.DialogData.Breakpoints(axisIndex).Min;
        lutWidgetData.Axes(axisIndex).Max=obj.DialogData.Breakpoints(axisIndex).Max;
        lutWidgetData.clearHistory();
    end
end

function updateLUTWidgetDataWithDialogDataCache(obj)
    if(isLUTWidgetDataToBeUpdated(obj))
        lutWidgetData=obj.DialogData.WidgetData;

        for idx=(length(obj.DialogData.Breakpoints)+1):length(lutWidgetData.Axes)
            lutWidgetData.Axes(idx)=[];
        end
        for idx=1:length(obj.DialogData.Breakpoints)
            updateLUTWidgetAxisDataWithDialogDataBreakpointCache(obj,lutWidgetData,idx);
        end
        updateLUTWidgetTableDataWithDialogDataCache(obj,lutWidgetData);
    end
end

function updateBreakpointSpecificationField(dlg,obj,value)









    updateDialogDataCacheWithWidgetData(obj);



    old_bpspec=obj.BreakpointsSpecification;
    obj.BreakpointsSpecification=value;
    obj2=obj.copy;
    obj.BreakpointsSpecification=old_bpspec;

    data=obj.DialogData;
    obj2.BreakpointsSpecification=value;
    data.Breakpoints=obj2.Breakpoints;
    data.BreakpointsSpecification=obj2.BreakpointsSpecification;
    dlg.setWidgetValue('dimensions_tag',length(data.Breakpoints));
    data.DataDimensions.Value=length(data.Breakpoints);
    obj.DialogData=data;
    updateLUTWidgetDataWithDialogDataCache(obj);
    dlg.refresh();
end



function[status,message]=saveData(obj)
    status=true;
    message='';

    try
        data=obj.DialogData;
        if~isempty(data)

            if isfield(data,'Table')
                obj.Table=data.Table;
            end

            if isfield(data,'BreakpointsSpecification')
                obj.BreakpointsSpecification=data.BreakpointsSpecification;
            end

            if isfield(data,'Breakpoints')
                obj.Breakpoints=data.Breakpoints;
            end

            if isfield(data,'StructTypeInfo')
                obj.StructTypeInfo=data.StructTypeInfo;
            end

        end

    catch E
        status=false;
        message=E.message;
    end

end

function updateForPrerevert(obj)
    obj.DialogData=[];
    if isprop(obj,'DataType')
        obj.DataType='';
    end
end

function updateForPostApply(dlg,obj)
    obj.DialogData=[];
    dlg.refresh();
end

function updateForCloseButton(obj)
    if isa(obj,'Simulink.LookupTable')
        mydlgs=DAStudio.ToolRoot.getOpenDialogs(obj);
        if isequal(length(mydlgs),0)
            obj.DialogData=[];
        end
    end
end

function obj=getDialogObject(dlg)
    dlgSource=dlg.getDialogSource;
    hSlidObject=dlgSource.getForwardedObject();
    if isempty(hSlidObject)
        obj=dlgSource;
    else
        if isa(hSlidObject,'Simulink.SlidDAProxy')
            obj=hSlidObject.getForwardedObject;
        else
            obj=hSlidObject;
        end
    end
end

function idx=i_valueIndex(l_data)

    for k=1:size(l_data,2)
        if isequal(l_data{k}.Name,'Value')
            idx=k;
            break;
        end
    end
end
