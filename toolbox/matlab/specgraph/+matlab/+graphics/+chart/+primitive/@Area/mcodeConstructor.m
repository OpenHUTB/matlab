function mcodeConstructor(this,code)




    setConstructorName(code,'area')

    plotutils('makemcode',this,code)

    hAreaPeerMomentoList=[];
    hAreaPeers=findobj(this.Parent.Children,'-class','matlab.graphics.chart.primitive.Area');
    isMatrixData=false;
    if length(hAreaPeers)>1

        hAreaPeerMomentoList=get(code,'MomentoRef');
        hParentMomento=up(hAreaPeerMomentoList(1));
        if~isempty(hParentMomento)
            hPeerMomentoList=findobj(hParentMomento,'-depth',1);


            for n=2:length(hPeerMomentoList)
                hPeerMomento=hPeerMomentoList(n);
                hPeerObj=get(hPeerMomento,'ObjectRef');



                if~isempty(hPeerObj)&&any(find(hAreaPeers==hPeerObj))&&...
                    hPeerObj~=this
                    hAreaPeerMomentoList=[hAreaPeerMomentoList;hPeerMomento];
                    set(hPeerMomento,'Ignore',true);
                    isMatrixData=true;
                end
            end
        end
    end


    ignoreProperty(code,'XData');
    ignoreProperty(code,'XDataMode');
    ignoreProperty(code,'XDataSource');
    if strcmp(this.XDataMode,'manual')

        xName=get(this,'XDataSource');
        xName=code.cleanName(xName,'X');
        arg=codegen.codeargument('Name',xName,'Value',this.XData,'IsParameter',true,...
        'Comment','area x');
        addConstructorArgin(code,arg);
    end


    ignoreProperty(code,'YData');
    ignoreProperty(code,'YDataSource');

    if isMatrixData
        yName='ymatrix';
    else
        yName=get(this,'YDataSource');
        yName=code.cleanName(yName,'yvector');
    end
    arg=codegen.codeargument('Name',yName,'Value',this.YData,'IsParameter',true);
    if isMatrixData
        set(arg,'Comment',getString(message('MATLAB:specgraph:mcodeConstructor:CommentMatrixData','area')));
    else
        set(arg,'Comment','area yvector');
    end
    addConstructorArgin(code,arg);

    ignoreProperty(code,'BaseLine');
    if strcmp(this.BaseLine.BaseValueMode,'auto')
        ignoreProperty(code,{'BaseValue'});
    end

    if~isMatrixData
        generateDefaultPropValueSyntax(code);
    else


        hFunc=get(code,'Constructor');
        hArg=codegen.codeargument('Value',hAreaPeers,...
        'Name',get(hFunc,'Name'));
        addArgout(hFunc,hArg);

        set(hFunc,'Comment',...
        getString(message('MATLAB:specgraph:mcodeConstructor:CommentCreateMultipleLinesUsingMatrix',hFunc.Name)));
        codetoolsswitchyard('mcodePlotObjectVectorSet',code,hAreaPeerMomentoList,@isDataSpecificFunction);
    end


    function flag=isDataSpecificFunction(hObj,hProperty)



        name=get(hProperty,'Name');


        switch(lower(name))
        case{'xdata','xdatamode','ydata','ydatasource','xdatasource'}
            flag=true;
        otherwise
            flag=false;
        end
