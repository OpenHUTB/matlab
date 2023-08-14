classdef Snapshot<handle
    properties
        Target;
        Format='PNG';
        FileName='untitled';
        Orientation='Portrait';




        SizeMode='UseScaledSize';
        Scale=1;
        ScaledMaxSize=[1000,1000];
        SpecifiedSize=[200,200];

        Padding=[5,5,5,5];
    end

    properties(Constant)
        Resolution=72;
    end

    properties(Access=protected)
        TargetPadding=[5,5,5,5];
        Portal;
    end

    properties(Hidden)
        Theme='Modern';
    end

    properties(Constant,Hidden)
        FormatValues={'PNG','JPEG','BMP','TIFF','EMF','SVG','PDF'};

        SizeModeValues={'UseScaledSize','UseSpecifiedSize'};
        OrientationValues={'Portrait','Landscape','Rotated','LargestDimensionVertical'};
    end

    methods
        function this=Snapshot(varargin)
            portal=GLUE2.Portal;
            portal.pathXStyle=get_param(0,'EditorPathXStyle');
            this.Portal=portal;

            if(nargin==1)
                this.Target=varargin{1};
            end
        end

        function disp(this)
            dObj=SLPrint.Disp(this);

            if~isempty(this.Target)
                if SLPrint.Resolver.isSimulink(this.Target)
                    name=strrep(getfullname(this.Target),sprintf('\n'),' ');
                    dObj.updateProp('Target',sprintf('$1$2$3[$4] %s\n',name));
                else
                    name=strrep(getFullName(this.Target),sprintf('\n'),' ');
                    dObj.appendPropValue('Target',sprintf(' %s',name));
                end
            end

            dObj.showEnumValue('Format',this.FormatValues);
            dObj.showEnumValue('Orientation',this.OrientationValues);
            dObj.showEnumValue('SizeMode',this.SizeModeValues);

            if strcmp(this.SizeMode,'UseScaledSize')
                dObj.removeProps('SpecifiedSize');
            else
                dObj.removeProps({'Scale','ScaledMaxSize'});
            end


            dObj.updatePropValue('Padding',...
            sprintf('[%d %d %d %d] left top right bottom',this.Padding));

            dObj.appendPropValue('Resolution',' pixels/inch');

            dObj.display();
        end

        function outputFileName=snap(this)

            if isa(this.Target,'Stateflow.Chart')&&Stateflow.ReqTable.internal.isRequirementsTable(this.Target.Id)
                exporter=Stateflow.ReqTable.internal.ReqTableHTMLExporter(this.Target.Id);
                html=exporter.getHTML;
                tempFile=[tempname,'.html'];
                fid=fopen(tempFile,'wb','native','UTF-8');
                fwrite(fid,html);
                fclose(fid);
                c=onCleanup(@()delete(tempFile));
                outputFileName=this.snapFromHTML(tempFile);
                return;
            end

            drawnow;
            this.render();

            outputFileName=this.getFileName();
            portal=this.Portal;
            exportOptions=portal.exportOptions;
            exportOptions.format=this.Format;
            exportOptions.fileName=outputFileName;
            exportOptions.rotation=this.getRotation();
            exportOptions.resolution=-1;
            exportOptions.sizeMode='UseSpecifiedSize';
            exportOptions.size=this.getOutputSize();
            exportOptions.centerWithAspectRatioForSpecifiedSize=false;
            exportOptions.backgroundColorMode=get_param(0,'ExportBackgroundColorMode');
            switch this.Format
            case 'EMF'

                origTheme=portal.theme;
                portal.theme='Classic';

                portal.export();
                portal.theme=origTheme;

            otherwise
                portal.export();
            end
            if exist(outputFileName,'file')~=2
                error(message('Simulink:Printing:FailToCreateSnapshot',outputFileName));
            end
        end

        function outputFileName=snapFromHTML(this,htmlFile)
            CEFWindow=matlab.internal.webwindow("file://"+htmlFile);
            CEFWindow.show;


            pos=CEFWindow.Position;
            pos(4)=100;
            CEFWindow.Position=pos;

            CEFWindow.getScreenshot;


            jsString="Math.max(document.body.scrollWidth, "+...
            "document.documentElement.scrollWidth, "+...
            "document.body.offsetWidth, "+...
            "document.documentElement.offsetWidth, "+...
            "document.body.clientWidth, "+...
            "document.documentElement.clientWidth);";
            width=CEFWindow.executeJS(jsString);
            pos(3)=str2double(width);

            jsString="Math.max(document.body.scrollHeight, "+...
            "document.documentElement.scrollHeight, "+...
            "document.body.offsetHeight, "+...
            "document.documentElement.offsetHeight, "+...
            "document.body.clientHeight, "+...
            "document.documentElement.clientHeight);";
            height=CEFWindow.executeJS(jsString);
            pos(4)=str2double(height);
            CEFWindow.Position=pos;

            img=CEFWindow.getScreenshot;
            CEFWindow.delete;

            outputFileName=this.getFileName();
            imwrite(img,outputFileName);
        end

        function bounds=getSnapshotBounds(this,objs)
            objs=SLPrint.Resolver.resolveToDoubleHandleOrId(objs);
            nObjs=length(objs);
            bounds=zeros(nObjs,4);
            for i=1:nObjs
                if(this.isTargetChild(objs(i)))
                    objBounds=this.getObjectBounds(objs(i));
                    bounds(i,:)=this.getRotatedBounds(objBounds);
                else
                    error(message('Simulink:Printing:InvalidBoundsQuery'));
                end
            end
        end

        function snapshotPoint=getSnapshotPoint(this,point)
            outputRect=this.sceneRectToOutputRect([point,0,0]);
            bounds=this.getRotatedBounds(outputRect);
            snapshotPoint=bounds(1:2);
        end

        function snapshotSize=getSnapshotSize(this)
            outputBounds=[0,0,this.getOutputSize()];
            outputBounds=this.getRotatedBounds(outputBounds);
            snapshotSize=outputBounds(3:4);
        end

        function setIsSaveThumbnailExportFlag(this)
            portal=this.Portal;
            portal.isSaveThumbnailExport=true;
        end

        function refresh(this)
            this.render();
        end
    end


    methods
        function set.Target(this,value)
            h=SLPrint.Resolver.resolveToHandle(value,true);
            this.Target=h{1};
        end

        function set.Padding(this,value)
            if(length(value)==1)
                value=repmat(value,1,4);
            end
            if(isnumeric(value)&&(length(value)==4))
                this.Padding=value;
            else
                error(message('Simulink:Printing:InvalidPadding'));
            end
        end

        function set.Format(this,value)
            value=this.getEquivalentSupportedFormat(value);
            if slcellmember(value,this.FormatValues)
                this.Format=value;
            else
                error(message('Simulink:Printing:InvalidFormat',value));
            end
        end

        function set.Orientation(this,value)
            if ismember(lower(value),lower(this.OrientationValues))
                this.Orientation=value;
            else
                error(message('Simulink:Printing:InvalidOrientation',value));
            end
        end
    end

    methods(Access=protected)
        function render(this)
            portal=this.Portal;
            portal.theme=this.Theme;


            if isempty(this.Target)
                error(message('Simulink:Printing:NoTarget'));
            end
            if SLPrint.Resolver.isSimulink(this.Target)
                portal.enableTargetBoundsCache=true;
                portal.setTarget('Simulink',this.Target);
            else
                portal.enableTargetBoundsCache=false;
                portal.setTarget('Stateflow',this.Target);
                if~sf('IsSubviewer',this.Target.Id)
                    portal.targetContext='ShowTargetInContext';
                end
            end


            portal.targetScene.Background.Color=SLPrint.Utils.GetBGColor(...
            SLPrint.Resolver.resolveToUDD(this.Target));


            targetSceneRect=gleeTestInternal.Rect(portal.getTargetBounds());
            targetSceneRect.left=targetSceneRect.left-this.TargetPadding(1);
            targetSceneRect.top=targetSceneRect.top-this.TargetPadding(2);
            targetSceneRect.width=targetSceneRect.width+this.TargetPadding(1)+this.TargetPadding(3);
            targetSceneRect.height=targetSceneRect.height+this.TargetPadding(2)+this.TargetPadding(4);
            portal.targetSceneRect=targetSceneRect.toArray();


            portal.targetOutputRect=this.getTargetOutputRect();
        end

        function unscaledTargetSize=getUnscaledTargetSize(this)
            unscaledTargetSize=this.Portal.targetSceneRect(3:4);
        end

        function[offset,scale]=getOffsetAndScale(this)
            portal=this.Portal;
            targetOutputRect=portal.targetOutputRect;
            targetSceneRect=portal.targetSceneRect;

            scale=targetOutputRect(3)/targetSceneRect(3);
            offset=targetOutputRect(1:2)-scale*(targetSceneRect(1:2));
        end

        function targetOutputRect=getTargetOutputRect(this)
            scale=this.Scale;
            padding=this.getOutputPadding();
            offset=padding(1:2);
            trgSize=this.getUnscaledTargetSize();
            padSize=[padding(1)+padding(3),padding(2)+padding(4)];

            if strcmp(this.SizeMode,'UseScaledSize')
                outputSize=scale*trgSize+padSize;
                if any(outputSize>this.ScaledMaxSize)
                    [~,scale]=this.getOffsetAndScaleToFit(...
                    [0,0,trgSize],...
                    [0,0,this.ScaledMaxSize-padSize]);
                end

            else
                outputSize=this.SpecifiedSize;
                [~,scale]=this.getOffsetAndScaleToFit(...
                [0,0,trgSize],...
                [0,0,this.SpecifiedSize-padSize]);


                offset=offset+0.5*((outputSize-padSize)-scale*trgSize);
            end

            targetOutputRect=[offset,scale*trgSize];
        end

        function outputSize=getOutputSize(this)
            if strcmp(this.SizeMode,'UseScaledSize')
                targetOutputRect=this.getTargetOutputRect();
                targetSize=targetOutputRect(3:4);
                padding=this.getOutputPadding;
                paddingSize=[padding(1)+padding(3),padding(2)+padding(4)];
                outputSize=targetSize+paddingSize;

            else
                outputSize=this.SpecifiedSize;
            end
        end

        function padding=getOutputPadding(this)
            padding=this.Padding;
        end

        function tf=isTargetChild(this,obj)
            h=SLPrint.Resolver.resolveToHandle(obj);
            h=h{1};

            if isa(h,'Stateflow.Object')
                if isa(this.Target,'Stateflow.Chart')
                    sfviewer=this.Target;
                elseif isa(this.Target,'Stateflow.Object')
                    sfviewer=this.Target.Subviewer;
                else
                    sfviewer=[];
                end

                tf=~isa(h,'Stateflow.Chart')...
                &&((h.Subviewer==sfviewer)...
...
                ||(h.Subviewer==this.Target));

            else
                parent=get_param(get_param(h,'Parent'),'Handle');
                tf=(parent==this.Target);
            end
        end

        function targetPoint=getTargetPoint(this,point)
            sceneRect=[point,0,0];
            outputRect=this.sceneRectToOutputRect(sceneRect);
            targetPoint=outputRect(1:2);
        end

        function outputRect=sceneRectToOutputRect(this,sceneRect)
            [offset,scale]=this.getOffsetAndScale();
            outputRect=scale*(sceneRect)+[offset,0,0];
        end

        function objBounds=getObjectBounds(this,obj)


            if(this.Target==obj)
                objBounds=this.getTargetOutputRect();
            else
                h=SLPrint.Resolver.resolveToDoubleHandleOrId(obj);
                if isa(this.Target,'Stateflow.Object')
                    scopedObj=StateflowDI.Util.getDiagramElement(h);
                    de=scopedObj.temporaryObject;
                else
                    de=SLM3I.SLDomain.handle2DiagramElement(h);
                end
                bounds=this.Portal.getBounds(de);
                objBounds=this.sceneRectToOutputRect(bounds);
            end
        end

        function fileName=getFileName(this)
            extension=['.',lower(this.Format)];
            switch extension
            case '.jpeg'
                extension='.jpg';
            case '.epsc'
                extension='.eps';
            case '.psc'
                extension='.ps';
            end

            fileName=this.FileName;
            [~,~,ext]=slfileparts(fileName);
            if~strcmpi(ext,extension)
                fileName=[fileName,extension];
            end
        end

        function rotation=getRotation(this)
            switch lower(this.Orientation)
            case 'landscape'
                rotation=270;
            case 'rotated'
                rotation=90;
            case 'largestdimensionvertical'
                targetSize=this.getUnscaledTargetSize();
                if(targetSize(1)>targetSize(2))
                    rotation=270;
                else
                    rotation=0;
                end
            otherwise
                rotation=0;
            end
        end

        function rotatedBounds=getRotatedBounds(this,bounds)
            rotation=this.getRotation();

            if(rotation~=0)
                x=bounds(1);
                y=bounds(2);
                w=bounds(3);
                h=bounds(4);

                outputSize=this.getOutputSize();
                if(rotation==90)
                    rotatedBounds=[...
                    outputSize(2)-y-h...
                    ,x...
                    ,h...
                    ,w];
                else
                    rotatedBounds=[...
y...
                    ,outputSize(1)-x-w...
                    ,h...
                    ,w];
                end
            else
                rotatedBounds=bounds;
            end
        end

    end

    methods(Static,Access=protected)
        function[offset,scale]=getOffsetAndScaleToFit(srcBounds,dstBounds)
            srcAspect=srcBounds(3)/srcBounds(4);
            dstAspect=dstBounds(3)/dstBounds(4);

            if(srcAspect>dstAspect)
                scale=dstBounds(3)/srcBounds(3);
            else
                scale=dstBounds(4)/srcBounds(4);
            end


            offset=dstBounds(1:2)-srcBounds(1:2);
        end

        function format=getEquivalentSupportedFormat(driver)
            driver=upper(driver);
            if~isempty(strfind(driver,'JPEG'))
                format='JPEG';
            elseif~isempty(strfind(driver,'BMP'))
                format='BMP';
            elseif strcmpi(driver,'bitmap')
                format='BMP';
            elseif~isempty(strfind(driver,'TIFF'))
                format='TIFF';
            elseif~isempty(strfind(driver,'EPSC'))
                format='EPSC';
            elseif~isempty(strfind(driver,'PSC'))
                format='PSC';
            elseif~isempty(strfind(driver,'EPS'))
                format='EPS';
            elseif~isempty(strfind(driver,'PS'))
                format='PS';
            elseif~isempty(strfind(driver,'META'))
                format='EMF';
            else
                format=driver;
            end
        end
    end

end
