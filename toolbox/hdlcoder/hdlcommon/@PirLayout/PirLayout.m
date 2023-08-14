classdef PirLayout<handle




    properties(Access=protected)
hPir
OutModelFile

        pirLayoutInfo;

ShowCodeGenPIR
UsingCustomDot
DotTool
DotPath
DotFile
DotFileExt
LayoutFile
LayoutFileExt
SaveTemps
AutoRoute
AutoPlace
UseModelReference
HiliteAncestors
HiliteColor

HMargin
VMargin
BlockSizeScale
B2BHScale
B2BVScale
H2VAspectRatio
BlockWidth
BlockHeight
SubsystemWidth
SubsystemHeight
PortWidth
PortHeight
        GraphScaleFactor;
        SimulinkDrawLimit;
        DotMaxIter;
        DotNumNodesThld;
    end

    methods



        function this=PirLayout(p,outFileName,showPir,keepTempFiles)
            this.hPir=p;
            this.OutModelFile=outFileName;
            this.ShowCodeGenPIR=showPir;
            this.SaveTemps=keepTempFiles;


            hD=hdlcurrentdriver;
            if~isempty(hD)
                customDotTool=hD.getParameter('CustomDotPath');
            else
                customDotTool=[];
            end
            if~isempty(customDotTool)
                hdldisp(sprintf('PirLayout using custom layout tool %s',...
                customDotTool),3);
                this.UsingCustomDot=true;
                [this.DotPath,this.DotTool,ext]=fileparts(customDotTool);
                if~isempty(ext)
                    this.DotTool=[this.DotTool,'.',ext];
                end
            else
                this.UsingCustomDot=false;
                if ispc
                    this.DotTool='mwdot.exe';
                else
                    this.DotTool='mwdot';
                end

                arch=lower(computer);
                if strcmp(arch,'pcwin')
                    arch='win32';
                elseif strcmp(arch,'pcwin64')
                    arch='win64';
                end

                this.DotPath=fullfile(matlabroot,'bin',arch);
            end


            this.DotFile='';
            this.DotFileExt='.dot';


            this.LayoutFileExt='.plain';
            this.LayoutFile='';

            if~isempty(hD)

                this.AutoRoute=hD.getParameter('AutoRoute');


                this.AutoPlace=hD.getParameter('AutoPlace');



                this.B2BHScale=hD.getParameter('InterBlkHorzScale');
                this.B2BVScale=hD.getParameter('InterBlkVertScale');
            else

                this.AutoRoute='on';


                this.AutoPlace='on';



                this.B2BHScale=1.7;
                this.B2BVScale=1.2;
            end


            this.UseModelReference='no';


            this.HMargin=70;
            this.VMargin=50;





            this.BlockSizeScale=2;






            this.H2VAspectRatio=4/3;




            this.BlockWidth=30;
            this.BlockHeight=30;




            this.SubsystemWidth=80;
            this.SubsystemHeight=30;



            this.PortWidth=30;
            this.PortHeight=14;



            this.GraphScaleFactor=100;
            this.SimulinkDrawLimit=32768;


            this.DotMaxIter=100000;


            this.DotNumNodesThld=200;
        end


        function layoutInfo=generateDotLayoutInfo(this)
            hdldisp(sprintf('Generating Dot Layout...'),3);


            computeNodeSizes(this,this.hPir);


            this.DotFile=genDotFile(this,this.hPir);


            this.computeLayout;


            this.readLayout;

            layoutInfo=this.pirLayoutInfo;

            cleanupFiles(this);

        end

        function outDotFile=genDotFile(this,hPir)






            dotStr=genDotStr(this,hPir);


            outDotFile=genDotFileName(this);

            printDotStrToFile(this,dotStr,outDotFile);

        end



        function outDotFile=genDotFileName(this)

            outDotFile=[tempdir,this.OutModelFile,this.DotFileExt];
            this.DotFile=outDotFile;

        end


        function dotStr=genDotStr(this,hPir)

            dotStr='';

            vNetworks=hPir.Networks;
            numNetworks=length(vNetworks);

            for i=1:numNetworks
                hN=vNetworks(i);
                if(this.renderCodeGenPIR(hN))

                    dotStr=[dotStr,getDotStr(this,hN)];%#ok<*AGROW>
                end
            end

        end






        function dotStr=getDotStr(this,hN)



            dotStr=['digraph ',hN.RefNum];
            dotStr=[dotStr,'\n { \n'];
            dotStr=[dotStr,'\t rankdir=LR; \n'];
            dotStr=[dotStr,'\t node [shape=record]; \n'];
            dotStr=[dotStr,'\t edge [arrowhead=none]; \n'];

            numNodes=length(hN.Components)+hN.NumberOfPirInputPorts+hN.NumberOfPirOutputPorts;
            if(numNodes>this.DotNumNodesThld)
                limit=ceil(this.DotMaxIter/numNodes);
                dotStr=[dotStr,'\t nslimit=',num2str(limit),'; \n'];
                dotStr=[dotStr,'\t nslimit1=',num2str(limit),'; \n'];
                dotStr=[dotStr,'\t sep=1.0; \n'];
            end


            dotStr=[dotStr,getDotForNtwkNodes(this,hN)];

            dotStr=[dotStr,'\n } \n'];
        end




        function[width,height]=getDimensions(this,pirNodeName)

            loc=strcmp(pirNodeName,this.pirLayoutInfo.nodeId);
            if any(loc)
                if sum(loc)~=1
                    error(message('hdlcoder:engine:gendotfileconflict',pirNodeName));
                else
                    width=this.pirLayoutInfo.width(loc);
                    height=this.pirLayoutInfo.height(loc);
                end
            else
                error(message('hdlcoder:engine:gendotfilenodemissing',pirNodeName));
            end

        end



        function dotStr=printNodeStr(this,nodeName,nodeStructure)

            [width,height]=getDimensions(this,nodeName);

            dimensions=['width=',num2str(width),' , ',...
            'height=',num2str(height)];

            attributeStr=[' [ ','label="',nodeStructure,'" , ',...
            dimensions,' ];'];

            dotStr=['\t ',nodeName,' ',attributeStr,'\n'];

        end





        function dotStr=getDotForNtwkNodes(this,ntwk)

            dotStr='';





            ntwkRefNum=ntwk.RefNum;
            numInports=ntwk.NumberOfPirInputPorts;

            for i=1:numInports

                nodeName=[ntwkRefNum,'_','ip',num2str(i-1)];

                nodeStructure='{ { <noinports> } | { <out> } }';

                dotStr=[dotStr,printNodeStr(this,nodeName,nodeStructure);];
            end


            vComps=ntwk.Components;
            numComps=length(vComps);

            for i=1:numComps
                hC=vComps(i);

                nodeName=[ntwkRefNum,'_',hC.RefNum];

                nodeStructure=getDotForCompPorts(this,hC);

                if~isempty(nodeStructure)
                    dotStr=[dotStr,printNodeStr(this,nodeName,nodeStructure);];
                end
            end


            numOutports=ntwk.NumberOfPirOutputPorts;

            for i=1:numOutports

                nodeName=[ntwkRefNum,'_','op',num2str(i-1)];

                nodeStructure='{ { <in> } | { <nooutports> } }';

                dotStr=[dotStr,printNodeStr(this,nodeName,nodeStructure);];
            end




            vSignals=ntwk.Signals;
            numSignals=length(vSignals);

            for i=1:numSignals
                hS=vSignals(i);

                numDrivers=hS.NumberOfDrivers;
                vDrvPorts=hS.getDrivers;

                numRecvrs=hS.NumberOfReceivers;
                vRcvPorts=hS.getReceivers;


                for j=1:numDrivers

                    edgeDrvStr='';
                    hDrvP=vDrvPorts(j);
                    hDrvPOwner=hDrvP.Owner;

                    if hDrvP.isNetworkPort


                        edgeDrvStr=[edgeDrvStr,...
                        ntwkRefNum,'_','ip',num2str(hDrvP.PortIndex),':out'];
                    else


                        edgeDrvStr=[edgeDrvStr,...
                        ntwkRefNum,'_',hDrvPOwner.RefNum,':',fixNameForDot(this,hDrvP.Name)];
                    end

                    for k=1:numRecvrs

                        edgeRcvStr='';
                        hRcvP=vRcvPorts(k);
                        hRcvPOwner=hRcvP.Owner;

                        if hRcvP.isNetworkPort


                            edgeRcvStr=[edgeRcvStr,...
                            ntwkRefNum,'_','op',num2str(hRcvP.PortIndex),':in'];
                        else


                            edgeRcvStr=[edgeRcvStr,...
                            ntwkRefNum,'_',hRcvPOwner.RefNum,':',fixNameForDot(this,hRcvP.Name)];
                        end

                        dotStr=[dotStr,'\t ',edgeDrvStr,' -> ',edgeRcvStr,';\n'];

                    end
                end
            end

        end






        function dotStr=getDotForInports(this,ntwkOrComp)
            numInPorts=ntwkOrComp.NumberOfPirInputPorts;
            vInPorts=ntwkOrComp.PirInputPorts;

            dotStr='';
            dotStr=[dotStr,'{'];
            for i=1:numInPorts

                dotStr=[dotStr,' <',fixNameForDot(this,vInPorts(i).Name),'> '];

                if(i~=numInPorts)
                    dotStr=[dotStr,'|'];
                end

            end
            dotStr=[dotStr,'}'];

        end





        function dotStr=getDotForOutports(this,ntwkOrComp)
            numOutPorts=ntwkOrComp.NumberOfPirOutputPorts;
            vOutPorts=ntwkOrComp.PirOutputPorts;

            dotStr='';
            dotStr=[dotStr,'{'];
            for i=1:numOutPorts

                dotStr=[dotStr,' <',fixNameForDot(this,vOutPorts(i).Name),'> '];

                if(i~=numOutPorts)
                    dotStr=[dotStr,'|'];
                end

            end
            dotStr=[dotStr,'}'];

        end





        function dotStr=getDotForCompPorts(this,hC)
            numInports=hC.NumberOfPirInputPorts;
            numOutports=hC.NumberOfPirOutputPorts;

            if(numInports&&numOutports)
                dotStr=[' { ',getDotForInports(this,hC),' | ',...
                getDotForOutports(this,hC),' } '];
            elseif(numInports)
                dotStr=[' { ',getDotForInports(this,hC),' | ',...
                '{ <nooutports> }',' } '];
            elseif(numOutports)
                dotStr=[' { ','{ <noinports> }',' | ',...
                getDotForOutports(this,hC),' } '];
            else
                dotStr=[' { ','{ <noinports> }',' | ',...
                '{ <nooutports> }',' } '];
            end
        end





        function printDotStrToFile(this,dotStr,file)%#ok<INUSL>
            if isempty(dotStr)
                dotStr='digraph n0 { }';
            else
                if contains(file,'.plain')
                    dotStr=strrep(dotStr,'\','\\');
                end
            end
            fid=fopen(file,'w');
            if fid==-1
                error(message('hdlcoder:engine:writedotgenfile'));
            end

            fprintf(fid,dotStr);
            fclose(fid);
        end




        function computeLayout(this)
            dotExe=fullfile(this.DotPath,this.DotTool);
            this.LayoutFile=[tempdir,this.OutModelFile,this.LayoutFileExt];

            if this.UsingCustomDot
                dotArgs=' -Tplain -Kdot ';
            else
                dotArgs=[' -Tplain -Kdot -o ','"',this.LayoutFile,'"'];
            end
            dotLayoutCmd=['"',dotExe,'"',dotArgs,' "',this.DotFile,'"'];
            cmd=['system(','''',dotLayoutCmd,'''',')'];
            if this.UsingCustomDot
                [outtxt,s]=evalc(cmd);
            else
                [~,s]=evalc(cmd);
            end
            if(s)
                error(message('hdlcoder:engine:generatedotgenfile'));
            end
            if this.UsingCustomDot

                this.printDotStrToFile(outtxt,this.LayoutFile);
            end
        end

        function computeNodeSizes(this,hPir)
            initSizeInfo(this);

            vNetworks=hPir.Networks;
            numNetworks=length(vNetworks);

            for i=1:numNetworks
                hN=vNetworks(i);
                if(this.renderCodeGenPIR(hN))
                    computeNtwkNodeSizes(this,hN);
                end
            end

        end


        function flag=renderCodeGenPIR(this,hN)
            flag=hN.renderCodegenPir||strcmpi(this.ShowCodeGenPIR,'yes');
        end


        function computeNtwkNodeSizes(this,hN)

            storeInportSizes(this,hN);
            storeCompSizes(this,hN);
            storeOutportSizes(this,hN);

        end


        function storeInportSizes(this,hN)

            ntwkRefNum=hN.RefNum;
            numInports=hN.NumberOfPirInputPorts;
            for i=1:numInports

                pirNodeId=sprintf('%s_ip%d',ntwkRefNum,i-1);

                [width,height]=getPortDimensions(this);
                storeNodeSizes(this,pirNodeId,width,height);
            end
        end


        function storeOutportSizes(this,hN)

            ntwkRefNum=hN.RefNum;
            numOutports=hN.NumberOfPirOutputPorts;
            for i=1:numOutports

                pirNodeId=sprintf('%s_op%d',ntwkRefNum,i-1);

                [width,height]=getPortDimensions(this);
                storeNodeSizes(this,pirNodeId,width,height);
            end
        end


        function storeCompSizes(this,hN)

            vComps=hN.Components;
            numComps=length(vComps);

            for i=1:numComps

                hC=vComps(i);
                pirNodeId=[hN.RefNum,'_',hC.RefNum];

                if hC.isNetworkInstance
                    [width,height]=getSubsystemSize(this,hC);
                else
                    [width,height]=getBlockSize(this,hC);
                end

                storeNodeSizes(this,pirNodeId,width,height);
            end

        end


        function[width,height]=getPortDimensions(this)





            width=this.PortWidth;
            height=this.PortHeight;

        end


        function[width,height]=getSubsystemSize(this,hNtwkInstC)

            numInports=hNtwkInstC.NumberOfPirInputPorts;
            numOutports=hNtwkInstC.NumberOfPirOutputPorts;
            maxNumPorts=max(numInports,numOutports);


            width=this.SubsystemWidth;


            if maxNumPorts>0
                height=maxNumPorts*this.SubsystemHeight;
            else
                height=this.SubsystemHeight;
            end

        end


        function[blkWidth,blkHeight]=getBlockSize(this,hC)

            className=hC.ClassName;

            numInports=hC.NumberOfPirInputPorts;
            numOutports=hC.NumberOfPirOutputPorts;
            maxNumPorts=max(numInports,numOutports);

            switch className
            case 'eml_comp'
                blkWidth=80;
                blkHeight=40;
                if(maxNumPorts>1)
                    blkHeight=maxNumPorts*0.6*blkHeight;
                end
            case 'serializer_comp'
                blkWidth=75;
                blkHeight=30;
            case 'deserializer_comp'
                blkWidth=75;
                blkHeight=30;
            case 'concat_comp'
                blkWidth=5;
                blkHeight=30;
                if(maxNumPorts>1)
                    blkHeight=maxNumPorts*0.6*blkHeight;
                end
            case 'split_comp'
                blkWidth=5;
                blkHeight=30;
                if(maxNumPorts>1)
                    blkHeight=maxNumPorts*0.6*blkHeight;
                end
            case 'ntwk_inst_comp'
                blkWidth=30;
                blkHeight=30;
                if(maxNumPorts>1)
                    blkHeight=maxNumPorts*0.6*blkHeight;
                end
            otherwise

                blktype=getBlockType(this,hC);
                if strcmp(blktype,'BusSelector')||strcmp(blktype,'BusCreator')||...
                    strcmp(blktype,'Demux')||strcmp(blktype,'Mux')
                    blkWidth=this.BlockWidth/3;
                    blkHeight=this.BlockHeight*2;
                elseif strcmp(blktype,'BusAssignment')
                    blkWidth=this.BlockWidth*2;
                    blkHeight=this.BlockHeight*2;
                else
                    blkWidth=this.BlockWidth;
                    blkHeight=this.BlockHeight;
                end
            end

        end

        function blktype=getBlockType(~,hC)
            blktype='';
            if~hC.Synthetic&&hC.SimulinkHandle>0&&~hC.isCtxReference&&~hC.isNetworkInstance

                try
                    blktype=get_param(hC.SimulinkHandle,'BlockType');
                catch
                end
                if isempty(blktype)&&isprop(hC,'BlockTag')&&~isempty(hC.BlockTag)
                    namestr=textscan(hC.BlockTag,'%s','delimiter','/');
                    blktype=namestr{end}{end};
                end
            end
        end


        function storeNodeSizes(this,pirNodeId,width,height)









            width=width*this.BlockSizeScale;
            height=height*this.BlockSizeScale;

            if isempty(this.pirLayoutInfo.nodeId)

                this.pirLayoutInfo.nodeId{1}=pirNodeId;
                this.pirLayoutInfo.width=width;
                this.pirLayoutInfo.height=height;

            else
                loc=strcmpi(pirNodeId,this.pirLayoutInfo.nodeId);

                if any(loc)
                    error(message('hdlcoder:engine:computenodesizes',pirNodeName))
                else
                    this.pirLayoutInfo.nodeId{end+1}=pirNodeId;
                    this.pirLayoutInfo.width=[this.pirLayoutInfo.width,width];
                    this.pirLayoutInfo.height=[this.pirLayoutInfo.height,height];
                end
            end

        end


        function initSizeInfo(this)


            this.pirLayoutInfo.nodeId=[];

            this.pirLayoutInfo.width=[];
            this.pirLayoutInfo.height=[];

        end
        function readLayout(this)
            this.initNetworkLayoutInfo;
            pFile=fopen(this.LayoutFile,'r');
            if pFile==-1
                error(message('hdlcoder:engine:nodotgenfile'));
            end

            line=fgetl(pFile);
            if~feof(pFile)
                [~,graphWidth,graphHeight]=...
                strread(line,'graph %n %n %n','delimiter',' ');%#ok<FPARK>



                graphSize=max(graphWidth+this.HMargin,graphHeight+this.VMargin);
                if graphSize>this.SimulinkDrawLimit
                    this.GraphScaleFactor=floor((100*this.SimulinkDrawLimit)/graphSize);
                end
            end

            ldBeginPos=1;
            scale=this.GraphScaleFactor/100;

            while~feof(pFile)

                line=readLine(this,pFile);

                entryType=strread(line,'%4c',1,'delimiter',' ');%#ok<FPARK>

                switch entryType
                case 'grap'

                    [~,graphWidth,graphHeight]=...
                    strread(line,'graph %n %n %n','delimiter',' ');%#ok<FPARK>
                    this.GraphScaleFactor=100;
                    graphSize=max(graphWidth+this.HMargin,graphHeight+this.VMargin);
                    if graphSize>this.SimulinkDrawLimit
                        this.GraphScaleFactor=floor((100*this.SimulinkDrawLimit)/graphSize);
                    end
                    scale=this.GraphScaleFactor/100;

                case 'node'
                    [nodeId,xlocation,ylocation,xsize,ysize]=...
                    strread(line,'node %s %n %n %n %n',1);%#ok<FPARK>




                    if(this.GraphScaleFactor<100)
                        xlocation=xlocation*scale;
                        ylocation=ylocation*scale;
                        xsize=xsize*scale;
                        ysize=ysize*scale;
                    end
                    storeLayoutInfo(this,nodeId,xlocation,ylocation,xsize,ysize);

                case 'edge'




                case 'stop'




                    ldEndPos=getLastPos(this);
                    computeBlkPositions(this,ldBeginPos,ldEndPos);
                    ldBeginPos=ldEndPos+1;

                otherwise

                    warning(message('hdlcoder:engine:unknownode',entryType));

                end

            end

            fclose(pFile);

        end




        function line=readLine(this,pFile)%#ok<INUSL>

            line=fgetl(pFile);
            while(line(end)=='\')
                line(end)=' ';
                line=[line,fgetl(pFile)];
            end

        end



        function pos=getLastPos(this)

            pos=length(this.pirLayoutInfo.nodeId);

        end


        function initNetworkLayoutInfo(this)



            this.pirLayoutInfo.nodeId=[];

            this.pirLayoutInfo.xLoc=[];
            this.pirLayoutInfo.yLoc=[];
            this.pirLayoutInfo.xSize=[];
            this.pirLayoutInfo.ySize=[];


            this.pirLayoutInfo.left=[];
            this.pirLayoutInfo.top=[];
            this.pirLayoutInfo.right=[];
            this.pirLayoutInfo.bottom=[];

        end



        function storeLayoutInfo(this,id,xLoc,yLoc,xSize,ySize)


            if isempty(this.pirLayoutInfo.nodeId)
                this.pirLayoutInfo.nodeId{1}=char(id);
                this.pirLayoutInfo.xLoc(1)=xLoc;
                this.pirLayoutInfo.yLoc(1)=yLoc;
                this.pirLayoutInfo.xSize(1)=xSize;
                this.pirLayoutInfo.ySize(1)=ySize;
            else
                loc=strcmpi(id,this.pirLayoutInfo.nodeId);
                if any(loc)
                    error(message('hdlcoder:engine:readlayout'));
                else
                    this.pirLayoutInfo.nodeId{end+1}=char(id);
                    this.pirLayoutInfo.xLoc=[this.pirLayoutInfo.xLoc,xLoc];
                    this.pirLayoutInfo.yLoc=[this.pirLayoutInfo.yLoc,yLoc];
                    this.pirLayoutInfo.xSize=[this.pirLayoutInfo.xSize,xSize];
                    this.pirLayoutInfo.ySize=[this.pirLayoutInfo.ySize,ySize];
                end
            end

        end


        function computeBlkPositions(this,dStart,dEnd)























            this.pirLayoutInfo.xSize(dStart:dEnd)=...
            this.pirLayoutInfo.xSize(dStart:dEnd)/this.BlockSizeScale;
            this.pirLayoutInfo.ySize(dStart:dEnd)=...
            this.pirLayoutInfo.ySize(dStart:dEnd)/this.BlockSizeScale;

            maxXLoc=max(this.pirLayoutInfo.xLoc(dStart:dEnd));
            maxYLoc=max(this.pirLayoutInfo.yLoc(dStart:dEnd));




            this.pirLayoutInfo.yLoc(dStart:dEnd)=...
            maxYLoc-this.pirLayoutInfo.yLoc(dStart:dEnd);


            minXLoc=min(this.pirLayoutInfo.xLoc(dStart:dEnd));
            this.pirLayoutInfo.xLoc(dStart:dEnd)=...
            this.pirLayoutInfo.xLoc(dStart:dEnd)-minXLoc;






            xScale=1;
            yScale=1;







            xScale=xScale*this.B2BHScale;
            yScale=yScale*this.B2BVScale;


            this.pirLayoutInfo.xLoc(dStart:dEnd)=...
            this.pirLayoutInfo.xLoc(dStart:dEnd)*xScale;
            this.pirLayoutInfo.yLoc(dStart:dEnd)=...
            this.pirLayoutInfo.yLoc(dStart:dEnd)*yScale;


            XMargin=this.HMargin;
            YMargin=this.VMargin;


            this.pirLayoutInfo.xLoc(dStart:dEnd)=...
            this.pirLayoutInfo.xLoc(dStart:dEnd)+XMargin;
            this.pirLayoutInfo.yLoc(dStart:dEnd)=...
            this.pirLayoutInfo.yLoc(dStart:dEnd)+YMargin;


            this.pirLayoutInfo.left(dStart:dEnd)=...
            this.pirLayoutInfo.xLoc(dStart:dEnd)-...
            this.pirLayoutInfo.xSize(dStart:dEnd)/2;
            this.pirLayoutInfo.top(dStart:dEnd)=...
            this.pirLayoutInfo.yLoc(dStart:dEnd)-...
            this.pirLayoutInfo.ySize(dStart:dEnd)/2;
            this.pirLayoutInfo.right(dStart:dEnd)=...
            this.pirLayoutInfo.xLoc(dStart:dEnd)+...
            this.pirLayoutInfo.xSize(dStart:dEnd)/2;
            this.pirLayoutInfo.bottom(dStart:dEnd)=...
            this.pirLayoutInfo.yLoc(dStart:dEnd)+...
            this.pirLayoutInfo.ySize(dStart:dEnd)/2;


            this.pirLayoutInfo.left(dStart:dEnd)=...
            round(this.pirLayoutInfo.left(dStart:dEnd));
            this.pirLayoutInfo.top(dStart:dEnd)=...
            round(this.pirLayoutInfo.top(dStart:dEnd));
            this.pirLayoutInfo.right(dStart:dEnd)=...
            round(this.pirLayoutInfo.right(dStart:dEnd));
            this.pirLayoutInfo.bottom(dStart:dEnd)=...
            round(this.pirLayoutInfo.bottom(dStart:dEnd));

        end








        function flag=isReservedWord(~,name)
            KW={'node','edge','graph','digraph','subgraph','strict'};
            flag=any(strcmpi(KW,name));
            return
        end


        function outstr=fixNameForDot(this,instr)


            outstr=hdllegalnamefordot(instr);

            if(this.isReservedWord(outstr))

                outstr=[outstr,'_rsvd'];
            end
        end



        function[l,t,r,b]=getSLDimensions(this,pirNodeName)

            loc=strcmp(pirNodeName,this.pirLayoutInfo.nodeId);

            if any(loc)
                if sum(loc)~=1
                    error(message('hdlcoder:engine:multiplenodesfound',pirNodeName));
                else

                    try
                        l=this.pirLayoutInfo.left(loc);
                        t=this.pirLayoutInfo.top(loc);
                        r=this.pirLayoutInfo.right(loc);
                        b=this.pirLayoutInfo.bottom(loc);
                    catch e

                        disp('Index vector :');
                        disp(loc);
                        fprintf('\n');

                        disp('Node Id : ');
                        disp(pirNodeName);
                        fprintf('\n');

                        disp('Node id list:');
                        fprintf('\n');
                        disp(this.pirLayoutInfo.nodeId);

                        lmax=numel(this.pirLayoutInfo.left);
                        rmax=numel(this.pirLayoutInfo.right);
                        tmax=numel(this.pirLayoutInfo.top);
                        bmax=numel(this.pirLayoutInfo.bottom);
                        mmax=lmax;
                        if mmax<rmax
                            mmax=rmax;
                        end
                        if mmax<tmax
                            mmax=tmax;
                        end

                        if mmax<bmax
                            mmax=bmax;
                        end
                        disp('co-ordinates table left:right:top:bottom');
                        for i=1:mmax
                            lstr='out of range';
                            rstr='out of range';
                            tstr='out of range';
                            bstr='out of range';

                            if i<=lmax
                                lstr=num2str(this.pirLayoutInfo.left(i));
                            end

                            if i<=rmax
                                rstr=num2str(this.pirLayoutInfo.right(i));
                            end

                            if i<=tmax
                                tstr=num2str(this.pirLayoutInfo.top(i));
                            end

                            if i<=bmax
                                bstr=num2str(this.pirLayoutInfo.bottom(i));
                            end

                            str1=sprintf('%d=%s:%s:%s:%s\n',i,lstr,rstr,tstr,bstr);
                            disp(str1);

                        end
                        rethrow(e);
                    end

                end
            else
                error(message('hdlcoder:engine:graphnodenotfound',pirNodeName));
            end

        end



        function cleanupFiles(this)
            if~isempty(this.DotFile)&&strcmp(this.SaveTemps,'no')
                delete(this.DotFile);
                delete(this.LayoutFile);
            else
                disp('saving temps')
                disp(sprintf('DOT File %s',this.DotFile));%#ok<*DSPS>
                disp(sprintf('Layout File %s',this.LayoutFile));
            end
        end
    end
end







