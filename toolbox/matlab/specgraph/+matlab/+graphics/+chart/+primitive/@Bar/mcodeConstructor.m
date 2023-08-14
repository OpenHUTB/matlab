function mcodeConstructor(this,hCode)







    isMatrixData=false;
    hBarPeerMomentoList=[];
    if strcmpi(this.BarLayout,'stacked')||strcmpi(this.BarLayout,'grouped')
        hBarPeers=findobj(this.Parent.Children,'BarLayout',this.BarLayout);
        if length(hBarPeers)>1

            hBarPeerMomentoList=get(hCode,'MomentoRef');
            hParentMomento=up(hBarPeerMomentoList(1));
            if~isempty(hParentMomento)
                hPeerMomentoList=findobj(hParentMomento,'-depth',1);


                for n=2:length(hPeerMomentoList)
                    hPeerMomento=hPeerMomentoList(n);
                    hPeerObj=get(hPeerMomento,'ObjectRef');



                    if~isempty(hPeerObj)&&any(find(hBarPeers==hPeerObj))&&...
                        hPeerObj~=this
                        hBarPeerMomentoList=[hBarPeerMomentoList;hPeerMomento];
                        set(hPeerMomento,'Ignore',true);
                        isMatrixData=true;
                    end
                end
            end
        end
    end

    setConstructorName(hCode,'bar')

    plotutils('makemcode',this,hCode)


    ignoreProperty(hCode,{'XData','XDataMode','XDataSource'});
    if strcmp(this.XDataMode,'manual')

        xName=get(this,'XDataSource');
        xName=hCode.cleanName(xName,'xvector');
        arg=codegen.codeargument('Name',xName,'Value',this.XData,'IsParameter',true,...
        'Comment','bar xvector');
        addConstructorArgin(hCode,arg);
    end


    ignoreProperty(hCode,{'YData','YDataSource'});

    if isMatrixData
        yName='ymatrix';
    else
        yName=get(this,'YDataSource');
        yName=hCode.cleanName(yName,'yvector');
    end
    arg=codegen.codeargument('Name',yName,'Value',this.YData,'IsParameter',true);
    if isMatrixData
        set(arg,'Comment',getString(message('MATLAB:specgraph:mcodeConstructor:CommentMatrixData','bar')));
    else
        set(arg,'Comment','bar yvector');
    end
    addConstructorArgin(hCode,arg);

    ignoreProperty(hCode,'BaseLine');
    if strcmp(this.BaseLine.BaseValueMode,'auto')
        ignoreProperty(hCode,{'BaseValue'});
    end
    if~isMatrixData
        generateDefaultPropValueSyntax(hCode);
    else


        hFunc=get(hCode,'Constructor');
        hArg=codegen.codeargument('Value',hBarPeers,...
        'Name',get(hFunc,'Name'));
        addArgout(hFunc,hArg);

        set(hFunc,'Comment',...
        getString(message('MATLAB:specgraph:mcodeConstructor:CommentCreateMultipleLinesUsingMatrix',hFunc.Name)));
        codetoolsswitchyard('mcodePlotObjectVectorSet',hCode,hBarPeerMomentoList,@isDataSpecificFunction);
    end

    plotutils('MCodeBaseLine',this,hCode);


    function flag=isDataSpecificFunction(hObj,hProperty)



        name=get(hProperty,'Name');
        value=get(hProperty,'Value');


        switch(lower(name))
        case{'xdata','ydata','ydatasource','xdatasource'}
            flag=true;
        case 'edgecolor'
            if strcmpi(value,'flat')
                flag=true;
            else
                flag=false;
            end
        otherwise
            flag=false;
        end