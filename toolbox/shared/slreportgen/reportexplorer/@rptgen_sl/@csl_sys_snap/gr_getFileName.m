function fName=gr_getFileName(this,sysName,varargin)








    if slreportgen.utils.isMaskedSystem(sysName)&&strcmp(get_param(sysName,"MaskHideContents"),"on")




        fName=[];
    else
        imgInfo=rptgen.getImgFormat(this.Format);

        imFile=getImgName(rptgen.appdata_rg,...
        char(imgInfo.getExtension),'sl',getfullname(sysName));

        fName=locUnifiedEditorPrint(this,sysName,imgInfo,imFile);
    end


    function fName=locUnifiedEditorPrint(this,sysName,imgInfo,imFile)

        d=get(rptgen.appdata_rg,'CurrentDocument');
        apSL=rptgen_sl.appdata_sl;
        psSL=rptgen_sl.propsrc_sl;
        psSF=rptgen_sf.propsrc_sf;

        driver=char(imgInfo.getDriver());
        format=driver(3:end);

        snap=SLPrint.SnapshotWithFrameAndCallouts(sysName);
        snap.Format=format;
        snap.FileName=imFile.fullname;
        snap.AddCallouts=this.UseCallouts;
        snap.AddFrame=this.isPrintFrame&&~isempty(this.PrintFrameName);
        snap.FrameFile=this.PrintFrameName;
        snap.Theme='Classic';

        switch this.PaperOrientation
        case 'maximize'


            snap.Orientation='portrait';
        case 'inherit'
            snap.Orientation=get_param(sysName,'PaperOrientation');
        case 'auto'
            snap.Orientation='LargestDimensionVertical';
        otherwise
            snap.Orientation=this.PaperOrientation;
        end

        dpi=get(0,'screenpixelsperinch');

        switch lower(this.PaperExtentMode)
        case 'manual'
            snap.SizeMode='UseSpecifiedSize';
            snap.SpecifiedSize=SLPrint.Units(this.PaperExtent,this.PrintUnits).toPixels(dpi);
        case 'zoom'
            snap.SizeMode='UseScaledSize';
            snap.Scale=this.PaperZoom/100;
            snap.ScaledMaxSize=SLPrint.Units(this.MaxPaperExtent,this.PrintUnits).toPixels(dpi);
        otherwise
            snap.SizeMode='UseScaledSize';
            snap.Scale=1;
            paper=SLPrint.Paper(get_param(sysName,'PaperType'),...
            get_param(sysName,'PaperOrientation'));
            autoSize=paper.Size-SLPrint.Units(2,'inches');
            snap.ScaledMaxSize=autoSize.toPixels(dpi);
        end





        sysH=get_param(sysName,'Handle');


        blocksH=find_system(sysH,'SearchDepth',1,'LookUnderMasks','all',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'type','block');
        blocksH(blocksH==sysH)=[];
        nBlocks=length(blocksH);


        snap.CalloutObjectList=blocksH;

        snap.CalloutLabelList=cellfun(@(x)num2str(x),num2cell(1:nBlocks),'UniformOutput',false);



        origScaledMaxSize=snap.ScaledMaxSize;

        rootComponent=rptgen.findRpt(this);
        if isempty(rootComponent)
            apRG=rptgen.appdata_rg;
            rootComponent=apRG.RootComponent;
        end
        docFormat=rootComponent.Format;

        if(strcmpi(docFormat,'pdf-fop')||strcmpi(docFormat,'dom-pdf-direct'))...
            &&strcmpi(snap.Format,'SVG')...
            &&strcmpi(this.PaperExtentMode,'auto')&&strcmp(this.ViewportType,'none')
            snap.ScaledMaxSize=[inf,inf];
        end


        snap.snap();
        snap.ScaledMaxSize=origScaledMaxSize;


        lines=get_param(sysH,'lines');
        hasSrc=cellfun(@(x)isValidSlObject(slroot,x),{lines(:).SrcBlock});
        lines=lines(hasSrc);
        nLines=length(lines);

        pointers=struct('LinkID','','Areas',[],'DisplayText','');
        blockPointers=repmat(pointers,1,nBlocks);
        calloutPointers=repmat(pointers,1,nBlocks*this.UseCallouts);
        linePointers=repmat(pointers,1,nLines*this.UseCallouts);

        sysListH=cell2mat(get_param(apSL.ReportedSystemList,'Handle'));
        for i=1:nBlocks
            pos=snap.getSnapshotBounds(blocksH(i));


            if((pos(3)~=0)&&(pos(4)~=0))


                if~ismember(blocksH(i),sysListH)
                    if strcmp(get_param(blocksH(i),'BlockType'),'ModelReference')

                        try
                            modelName=get_param(blocksH(i),'ModelName');
                            blockPointers(i).LinkID=psSL.getObjectID(modelName,'model');
                        catch

                            blockPointers(i).LinkID=psSL.getObjectID(blocksH(i),'block');
                        end
                    else
                        chart=rptgen_sf.block2chart(blocksH(i));
                        if~isempty(chart)

                            blockPointers(i).LinkID=psSF.getObjectID(chart);
                        else
                            blockPointers(i).LinkID=psSL.getObjectID(blocksH(i),'block');
                        end
                    end
                else
                    blockPointers(i).LinkID=psSL.getObjectID(blocksH(i));
                end
                blockPointers(i).Areas={[pos(1:2),pos(1:2)+pos(3:4)]};


                if snap.AddCallouts
                    calloutPointers(i).LinkID=blockPointers(i).LinkID;
                    calloutPos=snap.getCalloutBounds(blocksH(i));
                    calloutPointers(i).Areas={[calloutPos(1:2),calloutPos(1:2)+calloutPos(3:4)]};
                    calloutPointers(i).DisplayText=makeLink(d,blockPointers(i).LinkID,psSL.getObjectName(blocksH(i)),'link');
                end
            end
        end

        j=0;
        for i=1:nLines
            portList=get_param(lines(i).SrcBlock,'PortHandles');
            portIdx=str2double(lines(i).SrcPort);
            if~isnan(portIdx)
                hSignal=portList.Outport(portIdx);
                hSignalName=psSL.getPropValue(hSignal,'GraphicalName','Signal');
                hSignalName=hSignalName{1};

                if~isempty(hSignalName)
                    j=j+1;
                    linePointers(j).LinkID=psSL.getObjectID(hSignal,'Signal');
                    linePointers(j).Areas=locGetLinePoints(snap,get_param(hSignal,'line'));
                end
            end
        end


        linePointers(j+1:end)=[];


        this.RuntimePointers=[calloutPointers,blockPointers,linePointers];

        this.RuntimeFileName=imFile.fullname;



        snapshotSize=SLPrint.Units.fromPixels(snap.getSnapshotSize(),snap.Resolution);
        this.RuntimeSize=snapshotSize.toPixels(get(0,'screenpixelsperinch'));

        fName=imFile.relname;




        function lineBox=locBorder(x1,y1,x2,y2,r)




            h=y2-y1;
            w=x2-x1;

            n=r/(sqrt(max(h^2+w^2,1)));

            lineBox=[x1-n*w+n*h,y1-n*h-n*w,...
            x2+n*w+n*h,y2+n*h-n*w,...
            x2+n*w-n*h,y2+n*h+n*w,...
            x1-n*w-n*h,y1-n*h+n*w];


            function points=locGetLinePoints(snap,line)

                linePoints=get_param(line,'Points');
                nPoints=size(linePoints,1);
                points=cell(1,nPoints-1);
                for i=1:nPoints-1;
                    p1=snap.getSnapshotPoint(linePoints(i,:));
                    p2=snap.getSnapshotPoint(linePoints(i+1,:));
                    points{i}=locBorder(p1(1),p1(2),p2(1),p2(2),4);
                end

                lineChildren=get_param(line,'LineChildren');
                nChildren=length(lineChildren);
                branchPoints=cell(1,nChildren);
                for i=1:length(lineChildren)
                    branchPoints{i}=locGetLinePoints(snap,lineChildren(i));
                end

                points=[points,branchPoints{:}];
