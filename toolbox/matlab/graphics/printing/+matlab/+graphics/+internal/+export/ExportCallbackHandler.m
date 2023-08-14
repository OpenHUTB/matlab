classdef ExportCallbackHandler<handle



    properties(Access=protected)
        AdditionalInputs=[];
    end

    methods
        function out=currentCounterAccessor(obj,action)%#ok<INUSL>
            persistent counter;

            if isempty(counter)
                counter=0;
            end

            if strcmpi(action,'increment')
                counter=counter+1;
                out=missing;
            else
                out=counter;
            end
        end

        function callbackRoutine(obj,hExportObj,varargin)
            exportFormat='';
            exportLocation='';
            exportName='';

            whatToSave=hExportObj;
            parentFig=ancestor(whatToSave,'figure');





            needToAddProp=false;
            if isprop(parentFig,'ExportCallbackData')
                exportData=parentFig.ExportCallbackData;
                if~isempty(exportData)&&isstruct(exportData)&&...
                    all(isfield(exportData,{'exportFormat','exportLocation','exportName'}))
                    exportFormat=exportData.exportFormat;
                    exportLocation=exportData.exportLocation;
                    exportName=exportData.exportName;
                end
            else
                needToAddProp=true;
            end
            if isempty(exportFormat)

                obj.currentCounterAccessor('increment');
                exportFormat='.png';
                exportLocation=pwd;
                exportName=sprintf('untitled%d',obj.currentCounterAccessor('get'));
            end
            defname=fullfile(exportLocation,[exportName,exportFormat]);

            [filter,formats]=obj.buildFilterList(exportFormat);

            [fn,fp,idx]=obj.getFileInformation(filter,defname,...
            obj.AdditionalInputs);


            if strcmp(parentFig.Visible,'on')
                figure(parentFig);
            end
            if idx


                chosenFormat=formats{idx};

                posArgs={whatToSave,fullfile(fp,fn)};
                fmtArg={'format',chosenFormat};

                args=[posArgs(:)',fmtArg(:)'];
                matlab.graphics.internal.export.exportTo(args{:});
                [~,~,ext]=fileparts(filter{idx,1});
                [~,baseName,~]=fileparts(fn);


                if needToAddProp
                    p=addprop(parentFig,'ExportCallbackData');
                    p.Transient=true;
                    p.Hidden=true;
                end
                parentFig.ExportCallbackData.exportFormat=ext;
                parentFig.ExportCallbackData.exportLocation=fp;
                parentFig.ExportCallbackData.exportName=baseName;
            end
        end
    end

    methods(Access=protected)

        function[fn,fp,idx]=getFileInformation(obj,filter,defname,AdditionalInputs)


            dlgTitle=getString(message('MATLAB:print:ExportDialogTitle'));

            [fn,fp,idx]=uiputfile(filter,dlgTitle,defname);
        end
    end

    methods(Access=private)
        function[filter,formats]=buildFilterList(obj,defaultFormat)%#ok<INUSL>


            options={'*.png','Portable Network Graphics file (*.png)','png';...
            '*.jpg','JPEG image (*.jpg)','jpeg';...
            '*.tif','TIFF image (*.tif)','tiff';...
            '*.pdf','Adobe PDF (*.pdf)','pdf'};
            idx=find(strcmp(['*',defaultFormat],options(:,1)));
            if idx>1
                order=[idx,1:idx-1,idx+1:length(options)];
                options=options(order,:);
            end
            filter=options(:,1:2);
            formats=options(:,3);
        end

    end

end
