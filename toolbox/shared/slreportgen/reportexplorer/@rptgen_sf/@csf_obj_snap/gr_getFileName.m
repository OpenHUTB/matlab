function fName=gr_getFileName(this,id,varargin)







    if isa(id,'Stateflow.Junction')||isa(id,'Stateflow.Transition')
        uniqueName='';
    else
        uniqueName=sf('FullNameOf',get(id,'ID'));
    end

    imgInfo=rptgen.getImgFormat(this.ImageFormat);

    imFile=getImgName(rptgen.appdata_rg,...
    char(imgInfo.getExtension),'sf',uniqueName);

    locUnifiedEditorPrint(this,id,imgInfo,imFile);



    fName=imFile.relname;
    this.RuntimeFileName=imFile.fullname;



    function locUnifiedEditorPrint(this,id,imgInfo,imFile)


        driver=char(imgInfo.getDriver());
        format=driver(3:end);

        snap=SLPrint.SnapshotWithFrameAndCallouts(id);
        snap.Format=format;
        snap.FileName=imFile.fullname;
        snap.AddCallouts=this.isCallouts;
        snap.AddFrame=this.isPrintFrame&&~isempty(this.PrintFrameName);
        snap.FrameFile=this.PrintFrameName;
        snap.UseSizeSpecifiedByFrameFile=this.isPrintFrameSettings;
        snap.Theme='Classic';

        switch this.PaperOrientation
        case 'inherit'
            h=SLPrint.Resolver.resolveToUDD(id);
            if isa(h,'Stateflow.Chart')
                snap.Orientation=h.PaperOrientation;
            else
                snap.Orientation=h.Chart.PaperOrientation;
            end
        case 'auto'
            snap.Orientation='LargestDimensionVertical';

        case 'maximize'
            snap.Orientation='portrait';

        otherwise
            snap.Orientation=this.PaperOrientation;
        end

        switch snap.Format
        case{'PNG','JPEG','BMP','TIFF'}

            dpi=get(0,'screenpixelsperinch');
        otherwise

            dpi=72;
        end

        switch lower(this.imageSizing)
        case 'manual'
            snap.SizeMode='UseSpecifiedSize';
            snap.SpecifiedSize=locToPixels(this.PrintSize,this.PrintUnits,dpi);
        case 'zoom'
            snap.SizeMode='UseScaledSize';
            snap.Scale=this.PrintZoom/100;
            snap.ScaledMaxSize=locToPixels(this.MaxPrintSize,this.PrintUnits,dpi);
        otherwise
            adSF=rptgen_sf.appdata_sf;
            minFontSize=adSF.LegibleSize;

            if minFontSize>0
                fontSize=rptgen_sf.getFontSize(id);
                scale=min(adSF.LegibleSize/fontSize,1);
            else
                scale=1;
            end
            snap.SizeMode='UseScaledSize';
            snap.Scale=scale;
            snap.ScaledMaxSize=locToPixels(this.MaxPrintSize,this.PrintUnits,dpi);
        end

        adSF=rptgen_sf.appdata_sf;
        obj=SLPrint.Resolver.resolveToUDD(id);
        psSF=rptgen_sf.propsrc_sf;
        d=get(rptgen.appdata_rg,'CurrentDocument');



        if~isa(obj,'Stateflow.TruthTable')&&~isa(obj,'Stateflow.EMChart')
            graphicalChildren=obj.find(...
            '-depth',1,...
            '-not','Id',obj.Id,...
            '-function',@(x)adSF.getTypeInfo(x,'isGraphical'));

            nGraphical=length(graphicalChildren);

            if snap.AddCallouts&&~isempty(graphicalChildren)
                funcNonDescriptiveTransition=...
                @(x)isa(x,'Stateflow.Transition')&&(isempty(x.LabelString)||strcmp(x.LabelString,'?'));
                funcNonDescriptivePort=...
                @(x)isa(x,'Stateflow.Port')&&(isempty(x.LabelString)||strcmp(x.LabelString,'?'));

                calloutChildren=graphicalChildren.find(...
                '-depth',0,...
                '-not','-isa','Stateflow.Junction',...
                '-not','-isa','Stateflow.Annotation',...
                '-not','-function',funcNonDescriptiveTransition,...
                '-not','-function',funcNonDescriptivePort);
            else
                calloutChildren=[];
            end
        else
            nGraphical=0;
            graphicalChildren={};
            calloutChildren=[];
        end

        nCallouts=length(calloutChildren);


        snap.CalloutObjectList=calloutChildren;

        snap.CalloutLabelList=cellfun(@(x)num2str(x),num2cell(1:nCallouts),'UniformOutput',false);


        snap.snap();


        graphicalPointers=cell(nGraphical,3);
        calloutPointers=cell(nCallouts,3);


        emptyPointers=[];

        for i=1:nGraphical
            skip=false;
            if isa(graphicalChildren(i),'Stateflow.Transition')
                midPoint=graphicalChildren(i).MidPoint;
                pt=snap.getSnapshotPoint(midPoint);
                graphicalPointers{i,1}=[pt-1,pt+1];
            else
                pos=snap.getSnapshotBounds(graphicalChildren(i));
                if~isempty(pos)
                    graphicalPointers{i,1}=[pos(1:2),pos(1:2)+pos(3:4)];
                else
                    skip=true;
                    emptyPointers=[emptyPointers,i];%#ok pos maybe empty g1692521
                end
            end

            if~skip
                graphicalPointers{i,2}=psSF.getObjectID(graphicalChildren(i));
            end
        end

        if~isempty(emptyPointers)

            graphicalPointers(emptyPointers,:)=[];
        end

        for i=1:nCallouts
            pos=snap.getCalloutBounds(calloutChildren(i));
            calloutPointers{i,1}=[pos(1:2),pos(1:2)+pos(3:4)];
            calloutPointers{i,2}=psSF.getObjectID(calloutChildren(i));
            calloutPointers{i,3}=makeLink(...
            d,calloutPointers{i,2},psSF.getObjectName(calloutChildren(i)),'link');
        end


        this.RuntimePointerCoords=[calloutPointers;graphicalPointers];



        snapshotSize=SLPrint.Units.fromPixels(snap.ScaledMaxSize,snap.Resolution);
        this.RuntimeImageSize=snapshotSize.toPixels(get(0,'screenpixelsperinch'));



        function pixels=locToPixels(value,units,dpi)
            if strcmpi(units,'pixels')
                pixels=value;
            else
                pixels=SLPrint.Units(value,units).toPixels(dpi);
            end
