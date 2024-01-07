classdef BlockView<serdes.internal.apps.serdesdesigner.ElementView

    properties
IconFilePath
Icon
Type
HeaderDescription
    end


    methods

        function obj=BlockView(varargin)
            obj=obj@serdes.internal.apps.serdesdesigner.ElementView(varargin{:});

            iconFile=varargin(4);
            if iscell(iconFile)
                iconFile=iconFile{1};
            end
            obj.IconFilePath=[fullfile('+serdes','+internal','+apps','+serdesdesigner'),filesep,iconFile];
            obj.Icon=imread([fullfile('+serdes','+internal','+apps','+serdesdesigner'),filesep,iconFile]);
            obj.Type=extractBefore(iconFile,'_60.png');
            obj.Picture.Block.ImageSource=obj.Icon;

            elem=varargin(3);
            obj.HeaderDescription=elem{1}.getHeaderDescription();
        end


        function unselectElement(obj)
            if~obj.IsSelected
                return;
            end
            unselectElement@serdes.internal.apps.serdesdesigner.ElementView(obj);
        end


        function selectElement(obj,elem)
            if obj.IsSelected||obj.Canvas.View.isBusyClickingBlock()
                return;
            end
            obj.Canvas.View.setBusyClickingBlock(true);

            if isempty(obj.Picture.Block.ImageClickedFcn)
                set(obj.Picture.Block,'ImageClickedFcn',@(h,e)selectElement(obj,elem));
            end
            obj.Canvas.unselectAllElements();
            selectElement@serdes.internal.apps.serdesdesigner.ElementView(obj,elem);

            if isprop(elem,'BlockName')

                set(elem,'BlockName',elem.Name);
            end
            if~isempty(elem.ParameterNames)
                for j=1:numel(elem.ParameterNames)
                    if strcmp(elem.ParameterNames{j},'BlockName')
                        elem.ParameterValues{j}=elem.Name;
                        break;
                    end
                end
            end

            try
                dlg=obj.Canvas.View.Parameters.ElementDialog;
                dlg.setListenersEnable(false);
                dlg.Name=elem.Name;
                if~isempty(dlg.getSerdesElement())
                    dlg.setSerdesElement(elem);
                end
                if~isempty(dlg.getNonSerdesElement())
                    dlg.setNonSerdesElement(elem);
                end
            catch
            end
            if~isempty(dlg.getNonSerdesElement())
                dlg.setNonSerdesElement(elem);
            end
            allElementProps=properties(elem);
            missingPropNames=setdiff(allElementProps,elem.ParameterNames,'stable');
            tmpParameterNames=allElementProps;


            if any(strcmpi(superclasses(elem),'serdes.CTLE'))&&...
                ~strcmp(elem.ParameterNames{1},'myGPZ')
                missingPropNames=setdiff(allElementProps,...
                ['myGPZ';elem.ParameterNames],'stable');
                tmpParameterNames=allElementProps(2:end);
            end
            tmpParameterValues=cell(1,length(tmpParameterNames));
            for ii=1:length(elem.ParameterNames)
                paramName=elem.ParameterNames{ii};


                if any(strcmpi(superclasses(elem),'serdes.AGC'))
                    if strcmpi(paramName,'GainLimit')
                        paramName='MaxGain';
                    elseif strcmpi(paramName,'VsqMeanWindowInSymbols')
                        paramName='AveragingLength';
                    end
                end

                ndx=find(strcmpi(tmpParameterNames,paramName),1,'first');

                if strcmpi(paramName,'ConfigSelect')&&~isa(elem.ParameterValues{ii},"string")
                    tmpParameterValues{ndx}=string(elem.ParameterValues{ii});
                else
                    tmpParameterValues{ndx}=elem.ParameterValues{ii};
                end
            end
            for ii=1:length(missingPropNames)
                paramName=missingPropNames{ii};
                ndx=find(strcmpi(tmpParameterNames,paramName),1,'first');
                tmpParameterValues{ndx}=elem.(missingPropNames{ii});
            end
            elem.ParameterNames=tmpParameterNames;
            elem.ParameterValues=tmpParameterValues;
            dlg.setParameterValues(elem.ParameterValues);
            setListenersEnable(dlg,true)


            switch obj.Type
            case 'channel'
                obj.Canvas.View.Toolstrip.DeleteBtn.Description=...
                string(message('serdes:serdesdesigner:CannotDeleteElement',string(message('serdes:serdesdesigner:ChannelBlock'))));
            case 'rcTx'
                obj.Canvas.View.Toolstrip.DeleteBtn.Description=...
                string(message('serdes:serdesdesigner:CannotDeleteElement',string(message('serdes:serdesdesigner:AnalogOutBlock'))));
            case 'rcRx'
                obj.Canvas.View.Toolstrip.DeleteBtn.Description=...
                string(message('serdes:serdesdesigner:CannotDeleteElement',string(message('serdes:serdesdesigner:AnalogInBlock'))));
            otherwise
                obj.Canvas.View.Toolstrip.DeleteBtn.Description=...
                string(message('serdes:serdesdesigner:DeleteSelectedElement',obj.HeaderDescription));
            end
            obj.Canvas.adjustButtonsForScroll();
            obj.Canvas.View.setBusyClickingBlock(false);
        end
    end
end
