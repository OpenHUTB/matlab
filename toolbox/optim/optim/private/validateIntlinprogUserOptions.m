function[user_slbiopts,InternalOptions]=validateIntlinprogUserOptions(options,sizes,caller)











    user_slbiopts=struct();
    InternalOptions=struct();
    if isempty(options)
        return;
    end

    options=extractOptionsStructure(options);

    InternalOptions=options.InternalOptions;


    SLBI_INF=sizes.SLBI_INF;
    SLBI_ZERO=sizes.SLBI_ZERO;
    SLBI_INTMAX=sizes.SLBI_INTMAX;



    setBranchingRule();
    setCutGeneration();
    setHeuristics();
    setIPPreprocess();
    setLPPreprocess();
    setDisplay(caller);
    setNodeSelection();
    setRootLPAlgorithm();





    user_slbiopts.xmnheu=min(SLBI_INTMAX,options.HeuristicsMaxNodes);


    user_slbiopts.xmxnod=min(SLBI_INTMAX,options.MaxNodes);


    user_slbiopts.xmxint=min(SLBI_INTMAX,options.MaxNumFeasPoints);

    thisMaxIter=options.LPMaxIter;
    if ischar(thisMaxIter)
        if strcmpi(thisMaxIter,'max(30000,10*(numberofequalities+numberofinequalities+numberofvariables))')
            thisMaxIter=max(30000,10*(sizes.mAll+sizes.nVars));
        else
            error(message('optim:intlinprog:InvalidLPMaxIterations'));
        end
    end


    user_slbiopts.xmitip=min(SLBI_INTMAX,thisMaxIter);


    user_slbiopts.xmxpsu=min(50,options.CutGenMaxIter);

    thisMaxIter=options.RootLPMaxIter;
    if ischar(thisMaxIter)
        if strcmpi(thisMaxIter,'max(30000,10*(numberofequalities+numberofinequalities+numberofvariables))')
            thisMaxIter=max(30000,10*(sizes.mAll+sizes.nVars));
        else
            error(message('optim:intlinprog:InvalidRootLPMaxIterations'));
        end
    end

    user_slbiopts.xmiter=min(SLBI_INTMAX,thisMaxIter);


    user_slbiopts.xtolx=max(SLBI_ZERO,options.TolCon);


    user_slbiopts.xrimpr=max(0.0,options.RelObjThreshold);


    user_slbiopts.xglgap=max(0.0,options.TolGapRel);


    user_slbiopts.xtolin=max(SLBI_ZERO,options.TolInteger);



    user_slbiopts.xtold1=max(SLBI_ZERO,options.TolFunLP);


    user_slbiopts.xabgap=min(SLBI_INF,options.TolGapAbs);


    user_slbiopts.xipbnd=min(SLBI_INF,options.ObjectiveCutOff);


    user_slbiopts.xmxmin=min(SLBI_INF,(options.MaxTime/60));


    user_slbiopts.xmxtlp=min(SLBI_INF,(options.MaxTime/60));


    if~isempty(options.OutputFcn)||~isempty(options.PlotFcns)
        user_slbiopts.xoutfn=2;
    end


    function setBranchingRule()

        switch(options.BranchingRule)
        case 'maxpscost'
            user_slbiopts.xbrheu=4;
        case 'mostfractional'
            user_slbiopts.xbrheu=2;
        case 'maxfun'
            user_slbiopts.xbrheu=3;
        case 'strongpscost'
            user_slbiopts.xbrheu=5;
        case 'reliability'
            user_slbiopts.xbrheu=6;
        otherwise
            user_slbiopts.xbrheu=6;
        end
    end

    function setCutGeneration()

        switch(options.CutGeneration)
        case 'basic'
            user_slbiopts.xmirct=1;
            user_slbiopts.xgomct=2;
            user_slbiopts.xclict=2;
            user_slbiopts.ximpli=2;
            user_slbiopts.xcovct=2;
            user_slbiopts.xflwct=4;
        case 'none'
            user_slbiopts.xmirct=0;
            user_slbiopts.xgomct=0;
            user_slbiopts.xclict=0;
            user_slbiopts.ximpli=0;
            user_slbiopts.xcovct=0;
            user_slbiopts.xflwct=0;
            user_slbiopts.xconfg=0;
        case 'intermediate'

            user_slbiopts.xmirct=1;
            user_slbiopts.xgomct=2;
            user_slbiopts.xclict=2;
            user_slbiopts.ximpli=2;
            user_slbiopts.xcovct=2;
            user_slbiopts.xflwct=4;


            user_slbiopts.xlapct=1;
            user_slbiopts.xparct=1;


            user_slbiopts.xrasct=1;
        case 'advanced'

            user_slbiopts.xmirct=1;
            user_slbiopts.xgomct=2;
            user_slbiopts.xclict=2;
            user_slbiopts.ximpli=2;
            user_slbiopts.xcovct=2;
            user_slbiopts.xflwct=4;


            user_slbiopts.xlapct=1;
            user_slbiopts.xparct=1;


            user_slbiopts.xscgct=1;
            user_slbiopts.xzhcut=1;
        otherwise
            user_slbiopts.xmirct=1;
            user_slbiopts.xgomct=2;
            user_slbiopts.xclict=2;
            user_slbiopts.ximpli=2;
            user_slbiopts.xcovct=2;
            user_slbiopts.xflwct=4;
        end

        if sizes.nVars==sizes.nInteger&&...
            ~strcmp(options.CutGeneration,'none')
            user_slbiopts.xscgct=1;
            user_slbiopts.xzhcut=1;
        end
    end

    function setHeuristics()









































        user_slbiopts.xhrins=-1;
        user_slbiopts.xhrbss=-1;

        user_slbiopts.xhshih=0;

        user_slbiopts.xhroun=0;

        user_slbiopts.xhdipc=0;
        user_slbiopts.xhdigu=0;
        user_slbiopts.xhdico=0;
        user_slbiopts.xhdifr=0;
        user_slbiopts.xhdive=0;
        user_slbiopts.xhdils=0;



        user_slbiopts.xnhshi=-1;

        user_slbiopts.xnhrou=-1;

        user_slbiopts.xnhdpc=-1;
        user_slbiopts.xnhdgu=-1;
        user_slbiopts.xnhdco=-1;
        user_slbiopts.xnhdfr=-1;
        user_slbiopts.xnhdvl=-1;
        user_slbiopts.xnhdls=-1;

        user_slbiopts.xtriv=0;

        user_slbiopts.xnhint=100;

        user_slbiopts.xh1opt=-1;

        user_slbiopts.xhzirn=-1;

        user_slbiopts.xh2opt=-1;

        switch(options.Heuristics)
        case 'basic'
            user_slbiopts.xhrbss=1;

            user_slbiopts.xh1opt=1;

            user_slbiopts.xhzirn=1;

            user_slbiopts.xh2opt=1;
        case 'intermediate'
            user_slbiopts.xhrbss=1;
            user_slbiopts.xhrins=1;

            user_slbiopts.xhshih=1;

            user_slbiopts.xhroun=1;

            user_slbiopts.xhdipc=1;
            user_slbiopts.xhdigu=1;
            user_slbiopts.xhdico=1;
            user_slbiopts.xhdifr=1;
            user_slbiopts.xhdive=1;
            user_slbiopts.xhdils=1;

            user_slbiopts.xnhdpc=1;
            user_slbiopts.xnhdgu=1;
            user_slbiopts.xnhdco=1;
            user_slbiopts.xnhdfr=1;
            user_slbiopts.xnhdvl=1;
            user_slbiopts.xnhdls=1;
            user_slbiopts.xnhshi=1;
            user_slbiopts.xnhrou=1;
            user_slbiopts.xnhint=100;

            user_slbiopts.xh1opt=1;

            user_slbiopts.xhzirn=1;

            user_slbiopts.xh2opt=1;
        case 'advanced'
            user_slbiopts.xhrbss=1;
            user_slbiopts.xhrins=1;

            user_slbiopts.xhshih=1;

            user_slbiopts.xhroun=1;

            user_slbiopts.xhdipc=1;
            user_slbiopts.xhdigu=1;
            user_slbiopts.xhdico=1;
            user_slbiopts.xhdifr=1;
            user_slbiopts.xhdive=1;
            user_slbiopts.xhdils=1;

            user_slbiopts.xnhdpc=1;
            user_slbiopts.xnhdgu=1;
            user_slbiopts.xnhdco=1;
            user_slbiopts.xnhdfr=1;
            user_slbiopts.xnhdvl=1;
            user_slbiopts.xnhdls=1;
            user_slbiopts.xnhshi=1;
            user_slbiopts.xnhrou=1;
            user_slbiopts.xnhint=50;

            user_slbiopts.xh1opt=1;

            user_slbiopts.xhzirn=1;

            user_slbiopts.xh2opt=1;
        case 'none'

            user_slbiopts.xhshih=-1;

            user_slbiopts.xhroun=-1;

            user_slbiopts.xhdipc=-1;
            user_slbiopts.xhdigu=-1;
            user_slbiopts.xhdico=-1;
            user_slbiopts.xhdifr=-1;
            user_slbiopts.xhdive=-1;
            user_slbiopts.xhdils=-1;

            user_slbiopts.xtriv=-1;

            user_slbiopts.xh1opt=-1;

            user_slbiopts.xhzirn=-1;

            user_slbiopts.xh2opt=-1;


        case 'rss'
            user_slbiopts.xhrbss=1;
        case 'round'

            user_slbiopts.xhshih=1;

            user_slbiopts.xhroun=1;

            user_slbiopts.xnhshi=1;
            user_slbiopts.xnhrou=1;
            user_slbiopts.xnhint=100;
        case 'rins'
            user_slbiopts.xhrins=1;
        case 'diving'

            user_slbiopts.xhshih=-1;

            user_slbiopts.xhroun=-1;

            user_slbiopts.xhdico=1;
            user_slbiopts.xhdive=1;
            user_slbiopts.xhdifr=1;
            user_slbiopts.xhdipc=1;
            user_slbiopts.xhdils=1;
            user_slbiopts.xhdigu=1;

            user_slbiopts.xnhdpc=1;
            user_slbiopts.xnhdgu=1;
            user_slbiopts.xnhdco=1;
            user_slbiopts.xnhdfr=1;
            user_slbiopts.xnhdvl=1;
            user_slbiopts.xnhdls=1;
            user_slbiopts.xnhint=100;
        case 'rss-diving'
            user_slbiopts.xhrbss=1;

            user_slbiopts.xhdico=1;
            user_slbiopts.xhdive=1;
            user_slbiopts.xhdifr=1;
            user_slbiopts.xhdipc=1;
            user_slbiopts.xhdils=1;
            user_slbiopts.xhdigu=1;

            user_slbiopts.xnhdpc=1;
            user_slbiopts.xnhdgu=1;
            user_slbiopts.xnhdco=1;
            user_slbiopts.xnhdfr=1;
            user_slbiopts.xnhdvl=1;
            user_slbiopts.xnhdls=1;
            user_slbiopts.xnhint=100;
        case 'rins-diving'
            user_slbiopts.xhrins=1;

            user_slbiopts.xhdico=1;
            user_slbiopts.xhdive=1;
            user_slbiopts.xhdifr=1;
            user_slbiopts.xhdipc=1;
            user_slbiopts.xhdils=1;
            user_slbiopts.xhdigu=1;

            user_slbiopts.xnhdpc=1;
            user_slbiopts.xnhdgu=1;
            user_slbiopts.xnhdco=1;
            user_slbiopts.xnhdfr=1;
            user_slbiopts.xnhdvl=1;
            user_slbiopts.xnhdls=1;
            user_slbiopts.xnhint=100;
        case 'round-diving'

            user_slbiopts.xhshih=1;

            user_slbiopts.xhroun=1;

            user_slbiopts.xhdico=1;
            user_slbiopts.xhdive=1;
            user_slbiopts.xhdifr=1;
            user_slbiopts.xhdipc=1;
            user_slbiopts.xhdils=1;
            user_slbiopts.xhdigu=1;

            user_slbiopts.xnhdpc=1;
            user_slbiopts.xnhdgu=1;
            user_slbiopts.xnhdco=1;
            user_slbiopts.xnhdfr=1;
            user_slbiopts.xnhdvl=1;
            user_slbiopts.xnhdls=1;
            user_slbiopts.xnhshi=1;
            user_slbiopts.xnhrou=1;
            user_slbiopts.xnhint=100;
        end
    end


    function setIPPreprocess()
        switch(options.IPPreprocess)
        case 'basic'
            user_slbiopts.xbndrd=1;
            user_slbiopts.xcored=1;
        case 'none'
            user_slbiopts.xbndrd=0;
            user_slbiopts.xcored=0;
            user_slbiopts.xlotst=0;
            user_slbiopts.xeucrd=0;
            user_slbiopts.xiidet=0;
            user_slbiopts.xprobn=0;
        case 'advanced'
            user_slbiopts.xbndrd=2;
            user_slbiopts.xcored=2;
        otherwise
            user_slbiopts.xbndrd=1;
            user_slbiopts.xcored=1;
        end
    end

    function setLPPreprocess()
        switch(options.LPPreprocess)
        case 'basic'
            user_slbiopts.xlppre=0;
        case 'none'
            user_slbiopts.xlppre=-1;
        otherwise
            user_slbiopts.xlppre=0;
        end
    end

    function setNodeSelection()
        switch(options.NodeSelection)
        case 'simplebestproj'
            user_slbiopts.xnodse=3;
        case 'minobj'
            user_slbiopts.xnodse=1;
        case 'mininfeas'
            user_slbiopts.xnodse=2;
        otherwise
            user_slbiopts.xnodse=3;
        end
    end

    function setRootLPAlgorithm()
        switch(options.RootLPAlgorithm)
        case 'dual-simplex'
            user_slbiopts.xlptyp=2;
        case 'primal-simplex'
            user_slbiopts.xlptyp=1;
        otherwise
            user_slbiopts.xlptyp=2;
        end
    end

    function setDisplay(caller)
        switch(options.Display)
        case 'iter'
            if strcmpi(caller,'linprog')

                user_slbiopts.xdispl=3;
            elseif strcmpi(caller,'intlinprog')

                user_slbiopts.xdispl=2;
            else

                user_slbiopts.xdispl=4;
            end
        case 'final'
            user_slbiopts.xdispl=1;
        case{'off','none'}
            user_slbiopts.xdispl=0;
        otherwise
            user_slbiopts.xdispl=2;
        end
    end
end
