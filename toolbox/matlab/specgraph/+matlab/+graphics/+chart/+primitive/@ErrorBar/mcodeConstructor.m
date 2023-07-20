function mcodeConstructor(this,code)




    setConstructorName(code,'errorbar')

    plotutils('makemcode',this,code)


    ignoreProperty(code,'XData');
    ignoreProperty(code,'XDataMode');
    ignoreProperty(code,'XDataSource');


    ignoreProperty(code,'YData');
    ignoreProperty(code,'YDataSource');


    ignoreProperty(code,'XNegativeDelta');
    ignoreProperty(code,'XNegativeDeltaSource');
    ignoreProperty(code,'XPositiveDelta');
    ignoreProperty(code,'XPositiveDeltaSource');
    ignoreProperty(code,'YNegativeDelta');
    ignoreProperty(code,'YNegativeDeltaSource');
    ignoreProperty(code,'YPositiveDelta');
    ignoreProperty(code,'YPositiveDeltaSource');

    isVectorOutput=false;
    hObjMomento=get(code,'MomentoRef');

    local_generate_color(hObjMomento);








    set(hObjMomento,'Ignore',true);
    hParentMomento=up(hObjMomento);
    hPeerMomentoList=[];
    orig_xdata=get(this,'XData');
    orig_ydata=get(this,'YData');
    orig_xpdata=get(this,'XPositiveDelta');
    orig_xndata=get(this,'XNegativeDelta');
    orig_ypdata=get(this,'YPositiveDelta');
    orig_yndata=get(this,'YNegativeDelta');
    if~isempty(hParentMomento)
        hPeerMomentoList=findobj(hParentMomento,'-depth',1);
        hConstructMomentoList=hObjMomento;
        hConstructErrorList=this;
        net_xdata=orig_xdata;
        net_ydata=orig_ydata;
        net_xpdata=orig_xpdata;
        net_xndata=orig_xndata;
        net_ypdata=orig_ypdata;
        net_yndata=orig_yndata;
    end


    for n=2:length(hPeerMomentoList)
        hPeerMomento=hPeerMomentoList(n);
        hPeerObj=get(hPeerMomento,'ObjectRef');
        if isa(hPeerObj,'matlab.graphics.chart.primitive.ErrorBar')
            peer_xdata=get(hPeerObj,'XData');
            peer_ydata=get(hPeerObj,'YData');
            peer_xpdata=get(hPeerObj,'XPositiveDelta');
            peer_xndata=get(hPeerObj,'XNegativeDelta');
            peer_ypdata=get(hPeerObj,'YPositiveDelta');
            peer_yndata=get(hPeerObj,'YNegativeDelta');



            if~isequal(hPeerObj,this)&&...
                ~get(hPeerMomento,'Ignore')&&...
                isequal(length(orig_xdata),length(peer_xdata))&&...
                isequal(length(orig_ydata),length(peer_ydata))&&...
                isequal(length(orig_xndata),length(peer_xndata))&&...
                isequal(length(orig_xpdata),length(peer_xpdata))&&...
                isequal(length(orig_yndata),length(peer_yndata))&&...
                isequal(length(orig_ypdata),length(peer_ypdata))&&...
                ~localHasConstructor(hPeerObj)


                hConstructMomentoList=[hPeerMomento;hConstructMomentoList];%#ok<AGROW>
                hConstructErrorList=[hPeerObj;hConstructErrorList];%#ok<AGROW>
                net_xdata=[net_xdata,peer_xdata];%#ok<AGROW>
                net_ydata=[net_ydata,peer_ydata];%#ok<AGROW>
                net_xndata=[net_xndata,peer_xndata];%#ok<AGROW>
                net_xpdata=[net_xpdata,peer_xpdata];%#ok<AGROW>
                net_yndata=[net_yndata,peer_yndata];%#ok<AGROW>
                net_ypdata=[net_ypdata,peer_ypdata];%#ok<AGROW>




                set(hPeerMomento,'Ignore',true);
                local_generate_color(hPeerMomento);

                isVectorOutput=true;
            end
        end
    end







    haveHorizontal=~isempty(this.XNegativeDelta)||~isempty(this.XPositiveDelta);
    haveVertical=~isempty(this.YNegativeDelta)||~isempty(this.YPositiveDelta);

    horizontalEqual=isequal(this.XNegativeDelta,this.XPositiveDelta);
    verticalEqual=isequal(this.YNegativeDelta,this.YPositiveDelta);

    allEqual=isequal(this.XNegativeDelta,this.XPositiveDelta)&&...
    isequal(this.XNegativeDelta,this.YNegativeDelta)&&...
    isequal(this.XNegativeDelta,this.YPositiveDelta);


    autoX=strcmp(this.XDataMode,'auto')&&...
    (allEqual||...
    (~haveVertical&&horizontalEqual)||...
    (~haveHorizontal&&verticalEqual));


    if~autoX
        localAddArgument(this,code,'XData','X','errorbar X',isVectorOutput);
    end


    localAddArgument(this,code,'YData','Y','errorbar Y',isVectorOutput);


    if~haveHorizontal

        if verticalEqual

            localAddArgument(this,code,'YNegativeDelta','D','errorbar Delta',isVectorOutput);
        else

            localAddArgument(this,code,'YNegativeDelta','YNeg','errorbar YNegativeDelta',isVectorOutput);
            localAddArgument(this,code,'YPositiveDelta','YPos','errorbar YPositiveDelta',isVectorOutput);
        end
    elseif~haveVertical


        if horizontalEqual

            localAddArgument(this,code,'XNegativeDelta','D','errorbar Delta',isVectorOutput);
        else

            localAddArgument(this,code,'XNegativeDelta','XNeg','errorbar XNegativeDelta',isVectorOutput);
            localAddArgument(this,code,'XPositiveDelta','XPos','errorbar XPositiveDelta',isVectorOutput);
        end

        addConstructorArgin(code,'horizontal');
    else

        if allEqual

            localAddArgument(this,code,'YNegativeDelta','D','errorbar Delta',isVectorOutput);
            addConstructorArgin(code,'both');
        else

            localAddArgument(this,code,'YNegativeDelta','YNeg','errorbar YNegativeDelta',isVectorOutput);
            localAddArgument(this,code,'YPositiveDelta','YPos','errorbar YPositiveDelta',isVectorOutput);
            localAddArgument(this,code,'XNegativeDelta','XNeg','errorbar XNegativeDelta',isVectorOutput);
            localAddArgument(this,code,'XPositiveDelta','XPos','errorbar XPositiveDelta',isVectorOutput);
        end
    end


    if isVectorOutput

        hFunc=getConstructor(code);
        constructor_name=get(hFunc,'Name');
        hArg=codegen.codeargument('Value',hConstructErrorList,...
        'Name',get(hFunc,'Name'));
        addArgout(hFunc,hArg);


        set(hFunc,'Comment',...
        getString(message('MATLAB:specgraph:mcodeConstructor:CommentCreateMultipleErrorBarsUsingMatrix',constructor_name)));


        codetoolsswitchyard('mcodePlotObjectVectorSet',code,hConstructMomentoList,@isDataSpecificFunction);


    else
        generateDefaultPropValueSyntax(code);
    end

end


function localAddArgument(this,code,deltaProp,defaultName,comment,matrix)


    if matrix
        defaultName=[defaultName,'Matrix'];


        comment=getString(message('MATLAB:specgraph:mcodeConstructor:CommentMatrixData',comment));
    else

        comment=getString(message('MATLAB:specgraph:mcodeConstructor:CommentVectorData',comment));
    end



    name=this.([deltaProp,'Source']);
    if strncmp(name,'getcolumn(',10)
        name=[];
    end
    name=code.cleanName(name,defaultName);


    arg=codegen.codeargument('Name',name,'Value',this.(deltaProp),...
    'IsParameter',true,'Comment',comment);
    addConstructorArgin(code,arg);

end


function flag=localHasConstructor(hObj)




    flag=false;
    info=getappdata(hObj,'MCodeGeneration');
    if isstruct(info)&&isfield(info,'MCodeConstructorFcn')
        fcn=info.MCodeConstructorFcn;
        if~isempty(fcn)
            flag=true;
        end


    else
        hb=hggetbehavior(hObj,'MCodeGeneration','-peek');
        if~isempty(hb)
            fcn=get(hb,'MCodeConstructorFcn');
            if~isempty(fcn)
                flag=true;
            end
        end
    end

end


function local_generate_color(hObjMomento)



    hasColor=true;
    hPropertyList=get(hObjMomento,'PropertyObjects');
    hObj=get(hObjMomento,'ObjectRef');
    if isempty(hPropertyList)
        hasColor=false;
    else
        if isempty(findobj(hPropertyList,'Name','Color'))
            hasColor=false;
        end
    end

    colorMode=get(hObj,'ColorMode');

    if~hasColor&&strcmpi(colorMode,'manual')
        pobj=codegen.momentoproperty;
        set(pobj,'Name','Color');
        set(pobj,'Value',get(hObj,'Color'));
        hPropertyList=[hPropertyList,pobj];
        set(hObjMomento,'PropertyObject',hPropertyList);
    end

end


function flag=isDataSpecificFunction(hObj,hProperty)



    name=lower(get(hProperty,'Name'));

    switch(name)
    case{'xdata','xdatamode','ydata','xdatasource','ydatasource','parent',...
        'xnegativedelta','xpositivedelta','xnegativedeltasource','xpositivedeltasource',...
        'ynegativedelta','ypositivedelta','ynegativedeltasource','ypositivedeltasource'}
        flag=true;

    case 'color'
        if strcmpi(get(hObj,'ColorMode'),'auto');
            flag=true;
        else
            flag=false;
        end
    otherwise
        flag=false;
    end

end
