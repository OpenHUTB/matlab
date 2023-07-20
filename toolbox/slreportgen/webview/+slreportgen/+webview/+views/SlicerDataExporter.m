classdef SlicerDataExporter<slreportgen.webview.DataExporter



    properties
        outUrl;
    end
    methods
        function h=SlicerDataExporter()
            h@slreportgen.webview.DataExporter();
            bind(h,'Simulink.Object',@exportSlicer);
            bind(h,'Stateflow.Object',@exportSlicer);
        end
    end

    methods(Access=private)
        function ret=exportSlicer(h,~)
            ret=struct('href',h.outUrl);
        end
    end
    methods
        function preExport(h,obj)

            preExport@slreportgen.webview.DataExporter(h,obj);
            modelH=obj.Model;
            try
                scfg=SlicerConfiguration.getConfiguration(modelH);
            catch

                return;
            end

            nSelectedConfig=numel(scfg.allDisplayed);
            if nSelectedConfig==1
                nCol=1;
            elseif nSelectedConfig==2
                nCol=3;
            else
                nCol=5;
            end
            modelName=get_param(modelH,'Name');
            modelNameLen=numel(modelName);

            Name=cell(1,nCol);
            Description=cell(1,nCol);
            Direction=cell(1,nCol);
            Color=cell(1,nCol);
            StartingPoint=cell(1,nCol);
            ExclusionPoint=cell(1,nCol);
            Constraints=cell(1,nCol);
            SliceSubsystem=cell(1,nCol);
            TimeWindow=cell(1,nCol);

            showExclusion=false;
            showConstraint=false;
            showSliceSubsystem=false;
            showTimeWindow=false;


            nAllSelected=numel(scfg.allDisplayed);
            for i=1:nAllSelected
                sc=scfg.sliceCriteria(scfg.allDisplayed(i));

                Name{i}=sc.name;

                Description{i}=sc.description;

                switch sc.direction
                case 'Back'
                    Direction{i}=getString(message('Sldv:ModelSlicer:gui:UpStream'));
                case 'Forward'
                    Direction{i}=getString(message('Sldv:ModelSlicer:gui:DownStream'));
                otherwise
                    Direction{i}=getString(message('Sldv:ModelSlicer:gui:Bidirectional'));
                end

                Color{i}=sprintf('<hr class= "single" color="#%s%s%s" width=70 align=left>',...
                dec2hex(255*sc.colorValue(1),2),...
                dec2hex(255*sc.colorValue(2),2),...
                dec2hex(255*sc.colorValue(3),2));


                if~isempty(sc.sliceSubSystemH)
                    bPath=getfullname(sc.sliceSubSystemH);
                    bSID=Simulink.ID.getSID(sc.sliceSubSystemH);

                    bPathShow=['.',bPath(modelNameLen+1:end)];
                    SliceSubsystem{i}=[SliceSubsystem{i},getHyperlinkHTML(bSID,bPathShow,'')];
                    showSliceSubsystem=true;
                end


                allelements=sc.getUserStarts();
                nElements=length(allelements);
                for n=1:nElements
                    bHandle=allelements(n).Handle;
                    if strcmp(allelements(n).Type,'signal')
                        parentBlkH=get_param(bHandle,'ParentHandle');
                        bPath=getfullname(parentBlkH);
                        bSID=Simulink.ID.getSID(parentBlkH);

                        bPathShow=['.',bPath(modelNameLen+1:end)];
                        colonPortNum=[':',num2str(allelements(n).PortNumber)];
                    else

                        bPath=getfullname(bHandle);
                        bSID=Simulink.ID.getSID(bHandle);

                        bPathShow=['.',bPath(modelNameLen+1:end)];
                        colonPortNum='';
                    end
                    StartingPoint{i}=[StartingPoint{i},getHyperlinkHTML(bSID,bPathShow,colonPortNum)];
                end


                allexclusions=sc.getUserExclusions();
                nExclusion=length(allexclusions);
                for n=1:nExclusion
                    bHandle=allexclusions(n).Handle;
                    bPath=getfullname(bHandle);
                    bSID=Simulink.ID.getSID(bHandle);
                    bPathShow=['.',bPath(modelNameLen+1:end)];
                    ExclusionPoint{i}=[ExclusionPoint{i},getHyperlinkHTML(bSID,bPathShow,'')];
                    showExclusion=true;
                end


                c=sc.constraints.keys;
                nConstraints=length(c);
                for n=1:nConstraints
                    blkH=Simulink.ID.getHandle(c{n});
                    portNumbers=sc.constraints(c{n}).PortNumbers;
                    BlockType=get_param(blkH,'BlockType');
                    if strcmp(BlockType,'MultiPortSwitch')&&portNumbers(1)==1
                        portNumbers(1)=[];
                    end
                    nSize=length(portNumbers);
                    if(nSize>3)
                        portNum=getString(message('Sldv:ModelSlicer:gui:PortInfoGT3',portNumbers(1),portNumbers(2),...
                        portNumbers(3)));
                    elseif(nSize==3)
                        portNum=getString(message('Sldv:ModelSlicer:gui:PortInfoEQ3',portNumbers(1),portNumbers(2),...
                        portNumbers(3)));
                    elseif(nSize==2)
                        portNum=getString(message('Sldv:ModelSlicer:gui:PortInfoEQ2',portNumbers(1),portNumbers(2)));
                    elseif(nSize==1)
                        portNum=getString(message('Sldv:ModelSlicer:gui:PortInfoEQ1',portNumbers(1)));
                    else

                        portNum='';
                    end
                    bPath=getfullname(blkH);
                    bPathShow=['.',bPath(modelNameLen+1:end)];
                    bSID=c{n};
                    colonPortNum=[':',portNum];
                    Constraints{i}=[Constraints{i},getHyperlinkHTML(bSID,bPathShow,colonPortNum)];
                    showConstraint=true;
                end
                if sc.useCvd&&~isempty(sc.cvd);
                    [startTime,stopTime]=sc.cvd.getStartStopTime();
                    showTimeWindow=true;
                    if startTime==0&&stopTime==0
                        TimeWindow{i}='[0,-]';
                    else
                        TimeWindow{i}=sprintf('[%15.15g, %15.15g]',startTime,stopTime);
                    end
                else
                    TimeWindow{i}=getString(message('Sldv:ModelSlicer:gui:NoDataSpecified'));
                end
            end

            if nSelectedConfig==2
                Name{3}=['<overlap>',getString(message('Sldv:ModelSlicer:gui:Intersect')),'</overlap>'];
                Description{3}=['<overlap>',getString(message('Sldv:ModelSlicer:gui:IntersectDescription')),'</overlap>'];
                Color{3}='<hr class="double" width=70 align=left>';
            elseif nSelectedConfig==3
                Name{4}=['<overlap>',getString(message('Sldv:ModelSlicer:gui:TwoIntersect')),'</overlap>'];
                Name{5}=['<overlap>',getString(message('Sldv:ModelSlicer:gui:ThreeIntersect')),'</overlap>'];
                Description{4}=['<overlap>',getString(message('Sldv:ModelSlicer:gui:TwoIntersectDescription')),'</overlap>'];
                Description{5}=['<overlap>',getString(message('Sldv:ModelSlicer:gui:ThreeIntersectDescription')),'</overlap>'];
                Color{4}='<hr class="double" width=70 align=left>';
                Color{5}='<hr class="triple" width=70 align=left>';
            end


            style=['<style> '...
            ,'h1 {font-size: 14px; font-weight: bold; line-height:28px} '...
            ,'table, th, td { border: 0px solid black; cellspacing 2px; padding-left:5px;}'...
            ,'overlap {font-style: oblique} '...
            ,'.seeds {padding-top:5px; padding-bottom:0px; } '...
            ,'hr {height: 0;margin: 0;padding: 0; border: 0;} '...
            ,'hr.single {border-top: 4px solid} '...
            ,'hr.double {border-top: 6px solid #000; }'...
            ,'hr.triple { border-top: 4px solid #000; border-bottom: 2px dotted #000;} hr.triple:after {	content: ''''; display: block;	margin-top: 2px; border-top: 4px solid #000;}'...
            ,'li {list-style-position: inside;} '...
            ,'</style>'];

            Title=['<h1>',getString(message('Sldv:ModelSlicer:gui:WebViewTitle')),'</h1>'];
            table='<table>';
            table=[table,generateRowHTML(getString(message('Sldv:ModelSlicer:gui:SliceListNameNoColon')),Name,'',false)];
            table=[table,generateRowHTML(getString(message('Sldv:ModelSlicer:gui:Description')),regexprep(Description,'\n','<br>'),'',false)];
            table=[table,generateRowHTML(getString(message('Sldv:ModelSlicer:gui:SliceListColor')),Color,'',false)];
            table=[table,generateRowHTML(getString(message('Sldv:ModelSlicer:gui:SignalPropagationNoColon')),Direction,'',true)];
            if showSliceSubsystem
                table=[table,generateRowHTML(getString(message('Sldv:ModelSlicer:gui:SliceSubsystem')),SliceSubsystem,'seeds',true)];
            end
            table=[table,generateRowHTML(getString(message('Sldv:ModelSlicer:gui:StartingPoints')),StartingPoint,'seeds',true)];
            if showExclusion
                table=[table,generateRowHTML(getString(message('Sldv:ModelSlicer:gui:ExclusionPoints')),ExclusionPoint,'seeds',true)];
            end
            if showConstraint
                table=[table,generateRowHTML(getString(message('Sldv:ModelSlicer:gui:Constraints')),Constraints,'seeds',true)];
            end
            if showTimeWindow
                table=[table,generateRowHTML(getString(message('Sldv:ModelSlicer:gui:SimulationTimeWindow')),TimeWindow,'',false)];
            end
            table=[table,'</table>'];
            htmlString=[style,Title,table];
            outFile=[h.BaseDir,filesep,'slicer_info.html'];
            h.outUrl=[h.BaseUrl,'/slicer_info.html'];


            try
                fid=fopen(outFile,'w','n','utf-8');
                fprintf(fid,'%s',htmlString);
                fclose(fid);
            catch me %#ok<NASGU>

            end

            addFile(h,outFile);
        end
    end
end

function str=generateRowHTML(nameStr,valueStr,class,isTop)
    if~isempty(class)
        tagS=['<div class="',class,'">'];
        tagC='</div>';
    else
        tagS='';
        tagC='';
    end
    if isTop
        topStr='valign=top';
    else
        topStr='';
    end
    str=['<tr><td valign=top><b>',tagS,nameStr,tagC,'</b></td>'];
    for ii=1:length(valueStr)
        str=[str,'<td ',topStr,' >',tagS,valueStr{ii},tagC,'</td>'];%#ok<AGROW>
    end
    str=[str,'</tr>',char(10)];
end

function str=getHyperlinkHTML(bSID,bPathShow,colonPortNum)
    str=['<li><a href="javascript:void(0)" onclick="slwebview.select(''slwebview:'...
    ,bSID,''').then(function(id){slwebview.moveToView(id)})">',bPathShow,'</a>',colonPortNum,'</li>'];
end