classdef(Hidden)DataTipTemplate<handle&matlab.mixin.SetGet&...
    matlab.graphics.mixin.internal.GraphicsDataTypeContainer







    properties(SetObservable=true,Access=public,Dependent)
        DataTipRows matlab.graphics.datatip.DataTipRow;
        Interpreter matlab.internal.datatype.matlab.graphics.datatype.TextInterpreter;
    end

    properties(Access=?tDataTipTemplate)
        DataTipRows_I;
        Interpreter_I='tex';
    end

    properties(SetObservable=true,Access=public)
        FontSize matlab.internal.datatype.matlab.graphics.datatype.Positive=10;
        FontAngle matlab.internal.datatype.matlab.graphics.datatype.FontAngle='normal'
        FontName matlab.internal.datatype.matlab.graphics.datatype.FontName='Helvetica'
    end

    properties(Hidden)



        Serializable matlab.internal.datatype.matlab.graphics.datatype.on_off='off';






        InterpreterMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';



        DataTipRowsMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    properties(Hidden,SetAccess=?tDataTipTemplate)
Parent
    end

    properties(Access=private,Transient)
        ReparentListener=event.listener.empty()


        ParentDeletionListener=event.listener.empty()

        ParentDataChangedListener=event.listener.empty()
    end

    methods
        function set.FontSize(hObj,newValue)


            hObj.errorOnUncustomizableDTTemplateIfNeeded();

            hObj.FontSize=newValue;

            hObj.updateExistingDataTips('FontSize');


            hObj.Serializable='on';%#ok<MCSUP>
        end

        function set.FontName(hObj,newValue)


            hObj.errorOnUncustomizableDTTemplateIfNeeded();

            hObj.FontName=newValue;

            hObj.updateExistingDataTips('FontName');


            hObj.Serializable='on';%#ok<MCSUP>
        end

        function set.FontAngle(hObj,newValue)


            hObj.errorOnUncustomizableDTTemplateIfNeeded();

            hObj.FontAngle=newValue;

            hObj.updateExistingDataTips('FontAngle');


            hObj.Serializable='on';%#ok<MCSUP>
        end

        function set.Interpreter(hObj,newValue)


            hObj.errorOnUncustomizableDTTemplateIfNeeded();

            hObj.Interpreter_I=newValue;
            hObj.InterpreterMode='manual';

            hObj.updateExistingDataTips('Interpreter');


            hObj.Serializable='on';
        end

        function set.DataTipRows(hObj,newRows)


            hObj.errorOnUncustomizableDTTemplateIfNeeded();


            if isempty(newRows)
                me=MException(message('MATLAB:graphics:datatip:MustHaveAtleastOneRow'));
                throwAsCaller(me);
            end


            dataTipRows=matlab.graphics.datatip.DataTipTextRow.empty(0,1);
            rowIndex=1;
            for i=1:numel(newRows)
                validatedRow=newRows(i).validateRowArgs(hObj.Parent);
                if~isempty(validatedRow)
                    dataTipRows(rowIndex,1)=validatedRow;
                    rowIndex=rowIndex+1;
                end
            end

            hObj.DataTipRows_I=dataTipRows;
            hObj.DataTipRowsMode='manual';



            if hObj.hasAdaptorParentClass()
                hTarget=hObj.Parent.getAnnotationTarget();
                hTarget.DataTipTemplate.DataTipRows_I=dataTipRows;
                hTarget.DataTipTemplate.DataTipRowsMode='manual';
            end



            hTips=hObj.getAllDataTips();
            for i=1:numel(hTips)
                hTip=hTips(i).getPointDataTip();

                hTip.UpdateFcn=[];
                hTip.markPointDataTipDirty();
            end


            hObj.Serializable='on';
        end

        function rows=get.DataTipRows(hObj)
            rows=hObj.DataTipRows_I;
        end

        function rows=get.Interpreter(hObj)
            rows=hObj.Interpreter_I;
        end
    end

    methods(Hidden)

        function doObjectSpecificInitialization(hObj,hParent)
            hObj.Parent=hParent;


            if hObj.hasAdaptorParentClass()
                hPrimTarget=hParent.getAnnotationTarget();
                if~isprop(hPrimTarget,'DataTipTemplate')
                    addprop(hPrimTarget,'DataTipTemplate');
                end
                if isempty(hPrimTarget.DataTipTemplate)||~isvalid(hPrimTarget.DataTipTemplate)
                    hPrimTarget.DataTipTemplate=hObj;
                end
            end
            hObj.initDefaultDataTipRows();
            hObj.ReparentListener=event.proplistener(hObj.Parent,findprop(hObj.Parent,'Parent'),'PostSet',@(~,~)hObj.initDefaultDataTipRows());
            hObj.ParentDeletionListener=event.listener(hObj.Parent,'ObjectBeingDestroyed',@(~,~)hObj.delete());
            hObj.ParentDataChangedListener=event.listener(hParent,'DataChanged',@(~,~)hObj.updateDataTipRows());
        end

        function updateDataTipRows(hObj)




            if isa(hObj.Parent,'matlab.graphics.mixin.DataProperties')&&...
                strcmpi(hObj.DataTipRowsMode,'manual')

                dataTipRows=hObj.DataTipRows;

                defaultDataTipRows=hObj.Parent.createDefaultDataTipRows();
                for i=1:numel(dataTipRows)



                    if strcmpi(dataTipRows(i).LabelMode,'auto')
                        ind=arrayfun(@(o)strcmpi(o.Value,dataTipRows(i).Value),defaultDataTipRows);
                        if sum(ind)==1
                            dataTipRows(i).Label_I=defaultDataTipRows(ind).Label;
                        end
                    end
                end
            else
                hObj.initDefaultDataTipRows();
            end
        end


        function initDefaultDataTipRows(hObj)


            if strcmpi(hObj.DataTipRowsMode,'auto')








                if hObj.hasAdaptorParentClass()
                    hPrimTarget=hObj.Parent.getAnnotationTarget();
                    if isprop(hPrimTarget,'DataTipTemplate')&&isvalid(hPrimTarget.DataTipTemplate)


                        if isempty(hPrimTarget.DataTipTemplate.DataTipRows_I)
                            dataTipRows=hObj.Parent.createDefaultDataTipRows();
                        else
                            dataTipRows=hPrimTarget.DataTipTemplate.DataTipRows_I;
                        end
                        hObj.DataTipRows_I=dataTipRows;
                        hObj.FontSize=hPrimTarget.DataTipTemplate.FontSize;
                        hObj.FontName=hPrimTarget.DataTipTemplate.FontName;
                        hObj.FontAngle=hPrimTarget.DataTipTemplate.FontAngle;
                        hObj.Interpreter_I=hPrimTarget.DataTipTemplate.Interpreter;
                    end
                else
                    dataTipRows=hObj.Parent.createDefaultDataTipRows();
                    hObj.DataTipRows_I=dataTipRows;
                end
            end
        end

        function proxy=getInspectorProxy(hObj)


            if~matlab.graphics.datatip.internal.DataTipTemplateHelper.isCustomizable(hObj.Parent)
                proxy=matlab.graphics.internal.propertyinspector.views.DataTipTemplateReadOnlyPropertyView(hObj);
            else
                proxy=matlab.graphics.internal.propertyinspector.views.DataTipTemplatePropertyView(hObj);
            end
        end

        function dataTips=getAllDataTips(hObj)
            dataTips=findobj(hObj.Parent.getAnnotationTarget(),'Type','DataTip');
        end

        function pointDataTips=getAllPointDataTips(hObj)
            pointDataTips=matlab.graphics.shape.internal.PointDataTip.empty(1,0);
            dataTips=getAllDataTips(hObj);
            for i=1:numel(dataTips)
                pointDataTips(i)=dataTips(i).getPointDataTip();
            end
        end

        function currentDataTip=getCurrentDataTip(hObj)
            dataTips=getAllPointDataTips(hObj);
            currentDataTip=matlab.graphics.shape.internal.PointDataTip.empty(1,0);
            if~isempty(dataTips)
                hFig=ancestor(hObj.Parent,'figure');
                if~isempty(hFig)
                    dcm=datacursormode(hFig);
                    hTip=dcm.getTipFromCursor(dcm.CurrentCursor);
                    if any(ismember(dataTips,hTip))
                        currentDataTip=hTip;
                    end
                end
            end
        end

        function hasAdaptorParent=hasAdaptorParentClass(hObj)
            hasAdaptorParent=isa(hObj.Parent,'matlab.graphics.chart.interaction.dataannotatable.AnnotationAdaptor');
        end
    end

    methods(Access=?tDataTipTemplate)

        function warnIfUsingUpdateFcn(hObj)
            hFig=ancestor(hObj.Parent,'figure');
            if~isempty(hFig)
                dcm=datacursormode(hFig);
                if~isempty(dcm.UpdateFcn)
                    sWarningBacktrace=warning('off','backtrace');
                    warning(message('MATLAB:graphics:datatip:CannotUpdateCustomFunction'));
                    warning(sWarningBacktrace);
                end
            end
        end

        function errorOnUncustomizableDTTemplateIfNeeded(hObj)
            hDS=hObj.Parent;
            if~matlab.graphics.datatip.internal.DataTipTemplateHelper.isCustomizable(hDS)

                objClass=split(class(hDS),'.');
                objectDisplayName=objClass{end};
                if~isempty(hDS)&&isprop(hDS,'DisplayName')&&~isempty(hDS.DisplayName)
                    objectDisplayName=hDS.DisplayName;
                end
                me=MException(message('MATLAB:graphics:datatip:UncustomizableDataTipTemplate',objectDisplayName));
                throwAsCaller(me);
            end
        end

        function updateExistingDataTips(hObj,propName)

            hTips=hObj.getAllDataTips();
            for i=1:numel(hTips)


                hTips(i).updateStylePropertyIfNeeded(hObj.Parent,propName);
            end
        end
    end
end
