classdef FrameFileInfo<handle
    properties(SetAccess=private)
        FileName;
    end

    properties(Access=private)
        Figure;
    end

    properties(Dependent)
        FileStats;
        Paper;
        ConversionScale;
        FrameRects;
        SystemRect;
        TextInfo;
    end

    properties(Constant,Hidden)
        BLOCKDIAGRAM='%<blockdiagram>';
        CacheSize=5;
    end

    methods
        function this=FrameFileInfo(frameFile)
            this.FileName=frameFile;
            this.refresh();
        end

        function this=refresh(this,force)
            force=(nargin>1)&&force;
            if(force||this.isStale())
                frameInfo=this.getFrameInfoFromFile();
                this.cachedFrameInfo('set',this.FileName,frameInfo);
            end
        end

        function disp(this)
            dobj=SLPrint.Disp(this);
            dobj.updatePropValue('ConversionScale',...
            [this.ConversionScale.toString(),'/norm']);
            dobj.display();
        end

        function set.FileName(this,frameFile)
            if(exist(frameFile,'file')==2)

                this.FileName=which(frameFile);
            else
                error(message('Simulink:Printing:MissingFrameFile'));
            end

        end
        function paper=get.Paper(this)
            paper=this.getCachedFrameInfo().Paper;
        end
        function fileStats=get.FileStats(this)
            fileStats=this.getCachedFrameInfo().FileStats;
        end
        function scale=get.ConversionScale(this)
            scale=this.getCachedFrameInfo().ConversionScale;
        end
        function frameRects=get.FrameRects(this)
            frameRects=this.getCachedFrameInfo().FrameRects;
        end
        function systemRect=get.SystemRect(this)
            systemRect=this.getCachedFrameInfo().SystemRect;
        end
        function textInfo=get.TextInfo(this)
            textInfo=this.getCachedFrameInfo().TextInfo;
        end
        function figHandle=get.Figure(this)
            if(isempty(this.Figure)||~ishghandle(this.Figure,'figure'))
                try
                    this.Figure=hgload(this.FileName);
                    set(this.Figure,'PaperUnits','inches');
                catch me
                    DAStudio.error('Simulink:Printing:InvalidFrameFigure',this.FileName);
                end
            end
            figHandle=this.Figure;
        end
    end

    methods(Access=private)
        function frameInfo=getCachedFrameInfo(this)
            frameInfo=this.cachedFrameInfo('get',this.FileName);
        end

        function frameInfo=getFrameInfoFromFile(this)
            frameRects=this.getFrameRects();
            systemRect=this.getSystemRect(frameRects);


            frameInfo=struct(...
            'FileStats',this.getFileStats(),...
            'ConversionScale',this.getConversionScale(),...
            'FrameRects',{frameRects},...
            'SystemRect',systemRect,...
            'TextInfo',this.getTextInfo(),...
            'Paper',this.getPaper());

            close(this.Figure);
        end

        function tf=isStale(this)
            if(this.cachedFrameInfo('has',this.FileName))
                cacheFileStats=this.getCachedFrameInfo().FileStats;
                actFileStats=this.getFileStats();

                tf=(cacheFileStats.datenum~=actFileStats.datenum)...
                ||(cacheFileStats.bytes~=actFileStats.bytes);
            else
                tf=true;
            end
        end

        function fileStats=getFileStats(this)
            fileStats=dir(this.FileName);
        end

        function scale=getConversionScale(this)




            f=this.Figure;
            paperPosHG=SLPrint.Units(get(f,'PaperPosition'),...
            get(f,'PaperUnits'));
            scale=paperPosHG(3:4);
        end

        function frameRects=getFrameRects(this)
            f=this.Figure;

            patches=findall(f,'type','patch');
            vertices=get(patches,'vertices');



            func=@(x)all((x(:)<=1)&(x(:)>=0));
            validFrameFilter=cellfun(func,vertices);
            frameVertices=vertices(validFrameFilter);

            func=@(x)this.hgVerticesToSLRects(x);
            frameRects=cellfun(func,frameVertices,'UniformOutput',false);
        end

        function systemRect=getSystemRect(this,frameRects)
            f=this.Figure;


            sysText=findall(f,'type','text','String',this.BLOCKDIAGRAM);
            sysTextHGPos=get(sysText(1),'Position');
            sysTextPos=this.hgPointToSLPoint(sysTextHGPos);






            hasSysRect=@(x)((sysTextPos(1)>x(1))&&...
            (sysTextPos(1)<(x(1)+x(3)))&&...
            (sysTextPos(2)>x(2))&&...
            (sysTextPos(2)<(x(2)+x(4))));
            posSysRectFilter=cellfun(hasSysRect,frameRects);
            posSysRect=frameRects(posSysRectFilter);



            areaFunc=@(x)x(3)*x(4);
            area=cellfun(areaFunc,posSysRect);
            [~,minIdx]=min(area);
            systemRect=posSysRect(minIdx);
        end

        function paper=getPaper(this)
            f=this.Figure;
            paper=SLPrint.Paper(get(f,'PaperType'),get(f,'PaperOrientation'));



            paperPos=SLPrint.Units(get(f,'PaperPosition'),...
            get(f,'PaperUnits'));
            paperPos=paperPos.toInches();
            paperSize=paper.Size.toInches();
            paper.Margins=SLPrint.Units(...
            [paperPos(1)...
            ,paperSize(2)-paperPos(4)-paperPos(2)...
            ,paperSize(1)-paperPos(3)-paperPos(1)...
            ,paperPos(2)],...
            'inches');
        end

        function textInfo=getTextInfo(this)
            f=this.Figure;

            fHasString=@(x)~isempty(get(x,'String'));
            textHandles=findall(f,'type','text','-function',fHasString);


            positionHG=get(textHandles,'Position');
            if~iscell(positionHG)
                positionHG={positionHG};
            end
            func=@(x)this.hgPointToSLPoint(x);
            position=cellfun(func,positionHG,'UniformOutput',false);


            interpreter=get(textHandles,'Interpreter');
            if~iscell(interpreter)
                interpreter={interpreter};
            end

            interpretMode=cellfun(@getInterpretMode,interpreter,'UniformOutput',false);


            hgAlign=get(textHandles,'HorizontalAlignment');
            if~iscell(hgAlign)
                hgAlign={hgAlign};
            end
            hAlign=cellfun(@getQtAlignment,hgAlign,'UniformOutput',false);

            textInfo=struct(...
            'String',get(textHandles,'String'),...
            'Position',position,...
            'FontWeight',get(textHandles,'FontWeight'),...
            'FontSize',get(textHandles,'fontSize'),...
            'FontStyle',get(textHandles,'fontAngle'),...
            'HorizontalAlignment',hAlign,...
            'InterpretMode',interpretMode);

            function out=getInterpretMode(in)
                switch lower(in)
                case 'off'
                    out='INTERPRET_OFF';
                case 'tex'
                    out='INTERPRET_TEX';
                case 'rich'
                    out='INTERPRET_RICH';
                otherwise
                    error(message('Simulink:Printing:UnexpectedInterpretMode'));
                end
            end

            function out=getQtAlignment(in)
                switch lower(in)
                case 'left'
                    out='LEFT_TEXT';
                case 'right'
                    out='RIGHT_TEXT';
                case 'center'
                    out='H_CENTER_TEXT';
                otherwise
                    error(message('Simulink:Printing:UnexpectedHorizontalAlignment'));
                end
            end
        end

        function out=hgPointToSLPoint(~,HGPoint)
            out=[HGPoint(:,1),1-HGPoint(:,2)];
        end

        function out=hgVerticesToSLRects(this,vertices)
            slVertices=this.hgPointToSLPoint(vertices);

            sumXY=slVertices(:,1)+slVertices(:,2);
            [~,idx]=min(sumXY,[],1);
            topLeft=slVertices(idx,:);

            [~,idx]=max(sumXY,[],1);
            bottomRight=slVertices(idx,:);

            width=bottomRight(1)-topLeft(1);
            height=bottomRight(2)-topLeft(2);

            out=[topLeft(1),topLeft(2),width,height];
        end
    end

    methods(Static,Access=private)
        function varargout=cachedFrameInfo(method,key,newFrameInfo)
            persistent cache keyList


            if isempty(cache)
                cache=containers.Map;
            end
            if isempty(keyList)
                keyList={};
            end

            switch(method)
            case 'get'
                varargout{1}=cache(key);
            case 'has'
                varargout{1}=cache.isKey(key);
            case 'clear'
                this.KeyList={};
                this.remove(this.keys);
            case 'set'

                if~ismember(key,keyList)
                    keyList{end+1}=key;
                end


                cache(key)=newFrameInfo;


                cacheSize=SLPrint.FrameFileInfo.CacheSize;
                if(cache.Count>cacheSize)
                    cache.remove(keyList{1});
                    keyList(1)=[];
                end
            end
        end
    end
end